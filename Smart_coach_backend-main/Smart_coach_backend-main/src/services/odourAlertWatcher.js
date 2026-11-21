/**
 * 24/7 Bad Odour alert watcher.
 *
 * Nagpur odour devices write straight into `bad_odour_data` (ACP/Odour Supabase
 * project) and never call the backend, so alerts must be raised by polling.
 * The decision comes from utils/odourIndex.evaluateOdourReading() (BODR spec):
 *
 *  - CRITICAL when NH3 > 10 ppm, CH4 > 15 ppm or H2S > 5 ppm (each gas
 *    independently), or Combined Odour Index >= 250
 *    -> in-app + push + email + SMS ("Bad Odour")
 *  - HIGH / MEDIUM / Normal -> no notification (shown in the app only)
 *
 * Rules:
 *  - Alert on the first CRITICAL reading (the spec has no confirmation delay).
 *  - One alert per episode; while the coach stays CRITICAL a reminder is sent
 *    every REMINDER_MS.
 *  - The coach is re-armed after REARM_READINGS consecutive non-critical readings.
 *  - Before sending, user_notifications is checked so a server restart/deploy
 *    does not resend an alert already sent within REMINDER_MS.
 *  - SMS has its own 2 h cooldown per coach + fault in smsAlert.service.
 */
const acpSupabase = require('../config/supabaseAcp');
const supabaseAdmin = require('../config/supabaseAdmin');
const { broadcastPushNotification } = require('../utils/notificationService');
const { evaluateOdourReading } = require('../utils/odourIndex');
const { formatIST } = require('./brakeFaultWatcher');

const TABLE = 'bad_odour_data';
const COACHES_TABLE = 'coaches_Bad_Odour';
const POLL_INTERVAL_MS = 30 * 1000;
const BATCH_LIMIT = 1000;
const CONFIRM_READINGS = 1; // spec: a single reading above threshold is CRITICAL
const REARM_READINGS = 3;
const REMINDER_MS = 2 * 60 * 60 * 1000;
const SEED_ROWS = 300;
// Warning = Medium phase (index 90-249, Hygiene Score 37.5-77.5 %): in-app + push only.
// Critical = index >= 250 (Hygiene Score <= 37.5 %): in-app + push + email + SMS.
const LEVELS = ['Normal', 'Warning', 'Critical'];

function watcherLevel(ev) {
  if (ev.level === 'Critical') return 'Critical';
  if (ev.band === 'Medium') return 'Warning';
  return 'Normal';
}
const alertRank = (level) => LEVELS.indexOf(level);

let _lastId = null;
// device -> { alerted, firedAt, upCount, upMinRank, normalCount }
const _state = new Map();
let _coachCache = new Map();
let _coachCacheAt = 0;

async function refreshCoachCache() {
  if (Date.now() - _coachCacheAt < 10 * 60 * 1000 && _coachCache.size > 0) return;
  try {
    const { data, error } = await acpSupabase.from(COACHES_TABLE).select('*');
    if (error) throw error;
    const next = new Map();
    (data || []).forEach((c) => { if (c.device_ID) next.set(c.device_ID, c); });
    _coachCache = next;
    _coachCacheAt = Date.now();
  } catch (err) {
    console.error('[OdourAlertWatcher] Coach cache refresh failed:', err.message);
  }
}

function pick(...values) {
  return values.find((v) => v != null && String(v).trim() !== '' && String(v).toLowerCase() !== 'unknown');
}

function coachInfo(row) {
  const c = _coachCache.get(row.device_ID) || {};
  const coachNo = pick(row.Coach_no, c.Coach_no);
  const coachId = pick(row.Coach_ID, c.Coach_ID, row.device_ID);
  return {
    // Same label the app shows, e.g. "LWCZAC - COACH_02"
    coach_no: coachNo && coachId && coachNo !== coachId ? `${coachNo} - ${coachId}` : String(coachId || coachNo || 'Unknown'),
    train_no: String(pick(row.Train_No, c.Train_No) || 'Unknown'),
    location: String(pick(c.location, c.Location, row.location) || 'Nagpur'),
  };
}

/**
 * Feed one reading into the per-device state machine.
 * Returns { level, ev } to alert on, or null.
 */
function evaluate(row, now = Date.now()) {
  const device = row.device_ID;
  if (!device) return null;
  const ev = evaluateOdourReading(row);
  const rank = alertRank(watcherLevel(ev));

  const s = _state.get(device) || { alerted: 'Normal', firedAt: 0, upCount: 0, upMinRank: 99, normalCount: 0 };
  const alertedRank = alertRank(s.alerted);
  let fire = null;

  if (rank > alertedRank) {
    // Escalation: needs CONFIRM_READINGS consecutive readings above the alerted level.
    s.upCount += 1;
    s.upMinRank = Math.min(s.upMinRank, rank);
    s.normalCount = 0;
    if (s.upCount >= CONFIRM_READINGS) {
      s.alerted = LEVELS[s.upMinRank];
      s.firedAt = now;
      s.upCount = 0;
      s.upMinRank = 99;
      fire = { level: s.alerted, ev };
    }
  } else {
    s.upCount = 0;
    s.upMinRank = 99;
    if (rank === 0) {
      s.normalCount += 1;
      if (s.normalCount >= REARM_READINGS) s.alerted = 'Normal';
    } else {
      s.normalCount = 0;
      // Still at the alerted level: periodic reminder.
      if (rank === alertedRank && now - s.firedAt >= REMINDER_MS) {
        s.firedAt = now;
        fire = { level: s.alerted, ev };
      }
    }
  }

  _state.set(device, s);
  return fire;
}

function buildMessage(row, fire) {
  const info = coachInfo(row);
  const { level, ev } = fire;
  const faultName = level === 'Critical' ? 'Bad Odour' : 'Odour Warning';
  const title = `Alert: ${faultName} in Train ${info.train_no}, Coach_Unique Id ${info.coach_no}`;
  const r2 = (v) => Math.round(v * 100) / 100;
  const head = level === 'Critical'
    ? `CRITICAL ${faultName} on Coach ${info.coach_no} (Train ${info.train_no}) at ${formatIST(row.timestamp || new Date())}. `
      + `Overall Hygiene Score ${ev.hygiene}% (alert at 37.5% or below), Odour Index ${ev.index}. `
    : `WARNING: bad odour increasing (Medium) on Coach ${info.coach_no} (Train ${info.train_no}) at ${formatIST(row.timestamp || new Date())}. `
      + `Overall Hygiene Score ${ev.hygiene}% (Medium: 37.5% - 77.5%), Odour Index ${ev.index}. `;
  const body = head + `Readings: NH3 ${r2(ev.nh3)} ppm, CH4 ${r2(ev.ch4)} ppm, H2S ${r2(ev.h2s)} ppm.`;
  return { info, faultName, title, body };
}

async function recentlySent(title) {
  try {
    const since = new Date(Date.now() - REMINDER_MS).toISOString();
    const { data, error } = await supabaseAdmin
      .from('user_notifications')
      .select('id')
      .eq('type', 'ODOUR')
      .eq('title', title)
      .gte('created_at', since)
      .limit(1);
    if (error) return false;
    return (data || []).length > 0;
  } catch (_) {
    return false;
  }
}

async function dispatch(row, fire) {
  const { info, faultName, title, body } = buildMessage(row, fire);
  if (await recentlySent(title)) {
    console.log(`[OdourAlertWatcher] Skipping "${title}" — already sent within the last 2 h.`);
    return;
  }
  const isCritical = fire.level === 'Critical';
  console.log(`🚀 [OdourAlertWatcher] ${title} | level=${fire.level} | index=${fire.ev.index} | hygiene=${fire.ev.hygiene}%`);
  await broadcastPushNotification(
    title,
    body,
    'ODOUR',
    {
      module: 'odour',
      coach_no: info.coach_no,
      train_no: info.train_no,
      fault_name: faultName,
      odour_index: fire.ev.index,
      severity: isCritical ? 'critical' : 'warning',
      send_sms: isCritical,
      location: info.location,
    },
    // Medium-phase warnings: in-app + phone push only (no email, no SMS).
    { module: 'odour', location: info.location, email: isCritical, sms: isCritical }
  );
}

async function processRows(rows) {
  for (const row of rows) {
    if (_lastId == null || row.id > _lastId) _lastId = row.id;
    const fire = evaluate(row);
    if (fire) {
      try { await dispatch(row, fire); } catch (e) { console.error('[OdourAlertWatcher] Dispatch error:', e.message); }
    }
  }
}

const SELECT_COLS = 'id, timestamp, device_ID, Coach_ID, Coach_no, Train_No, location, voc_index, nh3_ppm, h2s_ppm, methane_ppm, Status_VOC';

async function seed() {
  // Replay the most recent readings so coaches that are ALREADY critical get
  // alerted right after startup. recentlySent() prevents duplicates on restart.
  const { data, error } = await acpSupabase
    .from(TABLE)
    .select(SELECT_COLS)
    .order('id', { ascending: false })
    .limit(SEED_ROWS);
  if (error) throw error;
  const rows = (data || []).reverse();
  if (rows.length === 0) { _lastId = 0; return; }
  await processRows(rows);
}

async function startOdourAlertWatcher() {
  if (!acpSupabase) {
    console.warn('[OdourAlertWatcher] ACP/Odour Supabase not configured. Skipping watcher.');
    return;
  }
  console.log('📡 [OdourAlertWatcher] Starting Bad Odour alert watcher...');
  await refreshCoachCache();
  try {
    await seed();
    console.log(`[OdourAlertWatcher] Synced at bad_odour_data id ${_lastId}, tracking ${_state.size} device(s).`);
  } catch (err) {
    console.error('[OdourAlertWatcher] Seed failed:', err.message);
  }

  let running = false;
  setInterval(async () => {
    if (running) return;
    running = true;
    try {
      await refreshCoachCache();
      if (_lastId == null) { await seed(); return; }
      const { data, error } = await acpSupabase
        .from(TABLE)
        .select(SELECT_COLS)
        .gt('id', _lastId)
        .order('id', { ascending: true })
        .limit(BATCH_LIMIT);
      if (error) throw error;
      await processRows(data || []);
    } catch (err) {
      console.error('[OdourAlertWatcher] Poll error:', err.message);
    } finally {
      running = false;
    }
  }, POLL_INTERVAL_MS);
}

module.exports = { startOdourAlertWatcher, evaluate, buildMessage, _state, _dispatch: dispatch };
