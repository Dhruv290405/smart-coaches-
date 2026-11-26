/**
 * 24/7 HAMS (Hot Axle Section 1) alert watcher.
 *
 * HAMS sensors write directly into hams_data (Project 2 / supabaseOld) via
 * Lambda and never call the backend, so alerts must be raised by polling.
 *
 * Thresholds (Indian Railway standard):
 *   Normal:       < 70 C   -> no alert
 *   Warm Warning: 70-90 C  -> in-app + push
 *   Hot Critical: > 90 C   -> in-app + push + email + SMS
 *   Sensor Fault: > 150 C  -> excluded (bad reading)
 *
 * Only master_id HAMS-M1-001 is live (hardcoded).
 * 2-hour dedup per device + level. Re-arm after 3 consecutive normal readings.
 */
const supabaseOld = require('../config/supabaseOld');
const supabaseAdmin = require('../config/supabaseAdmin');
const { broadcastPushNotification, UNREGISTERED_LOCATION } = require('../utils/notificationService');
const { formatIST } = require('./brakeFaultWatcher');
const { clearCooldown: clearSmsCooldown } = require('./smsAlert.service');

const TABLE = 'hams_data';
const POLL_INTERVAL_MS = 30 * 1000;
const BATCH_LIMIT = 500;
const REARM_READINGS = 3;
const REMINDER_MS = 30 * 60 * 1000; // 30 min — safety-critical
const SEED_ROWS = 100;

const THRESHOLDS = { sensorFault: 150, hot: 90, warm: 70 };

function classify(temp) {
  if (temp > THRESHOLDS.sensorFault) return 'SensorFault';
  if (temp > THRESHOLDS.hot) return 'Hot';
  if (temp >= THRESHOLDS.warm) return 'Warm';
  return 'Normal';
}

const LEVELS = ['Normal', 'Warm', 'Hot'];
const rank = (lvl) => LEVELS.indexOf(lvl);

let _lastId = null;
// device_id -> { alerted, firedAt, normalCount }
const _state = new Map();

let _hamsMeta = null;
let _hamsMetaAt = 0;

async function refreshMeta() {
  if (Date.now() - _hamsMetaAt < 10 * 60 * 1000 && _hamsMeta) return;
  try {
    const { data } = await supabaseAdmin.from('coaches_hams').select('*');
    if (data && data.length > 0) {
      const reg = data.find(r => r.actual_id && r.actual_id.toLowerCase() === 'hams-m1-001') || data[0];
      _hamsMeta = {
        coach_no: reg.technical_id || '226965',
        train_no: reg.train_no || '1207069',
        location: reg.location || 'Nagpur',
      };
    } else {
      _hamsMeta = { coach_no: '226965', train_no: '1207069', location: 'Nagpur' };
    }
    _hamsMetaAt = Date.now();
  } catch (err) {
    console.error('[HAMSAlertWatcher] Meta refresh failed:', err.message);
    if (!_hamsMeta) _hamsMeta = { coach_no: '226965', train_no: '1207069', location: 'Nagpur' };
  }
}

function evaluate(row) {
  const deviceId = row.device_id;
  if (!deviceId) return null;
  const temp = parseFloat(row.temperature);
  if (isNaN(temp)) return null;

  const level = classify(temp);
  if (level === 'SensorFault' || level === 'Normal') {
    const s = _state.get(deviceId);
    if (s) {
      if (level === 'Normal') {
        s.normalCount = (s.normalCount || 0) + 1;
        if (s.normalCount >= REARM_READINGS) {
          s.alerted = 'Normal';
          clearSmsCooldown(deviceId);
        }
      }
      _state.set(deviceId, s);
    }
    return null;
  }

  const s = _state.get(deviceId) || { alerted: 'Normal', firedAt: 0, normalCount: 0 };
  const alertedRank = rank(s.alerted);
  const currentRank = rank(level);
  s.normalCount = 0;

  let fire = null;

  if (currentRank > alertedRank) {
    s.alerted = level;
    s.firedAt = Date.now();
    fire = { level, temp };
  } else if (currentRank === alertedRank && Date.now() - s.firedAt >= REMINDER_MS) {
    s.firedAt = Date.now();
    fire = { level, temp };
  }

  _state.set(deviceId, s);
  return fire;
}

async function recentlySent(title) {
  try {
    const since = new Date(Date.now() - REMINDER_MS).toISOString();
    const { data, error } = await supabaseAdmin
      .from('user_notifications')
      .select('id')
      .eq('type', 'HOT_AXLE')
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
  await refreshMeta();
  const meta = _hamsMeta;
  const isCritical = fire.level === 'Hot';
  const faultName = isCritical ? 'Critical Hot Axle' : 'Hot Axle Warning';
  const deviceId = row.device_id || 'Unknown';
  const at = formatIST(row.created_at || new Date());

  const title = `Alert: ${faultName} in Train ${meta.train_no}, Coach_Unique Id ${meta.coach_no}`;
  const body = `${faultName}: Sensor ${deviceId} reading ${fire.temp.toFixed(1)} C on Coach ${meta.coach_no} (Train ${meta.train_no}) at ${at}. ` +
    (isCritical ? 'Immediate inspection required - bearing failure risk.' : 'Monitor closely, inspect at next halt.');

  if (await recentlySent(title)) {
    console.log(`[HAMSAlertWatcher] Skipping "${title}" - already sent within 2h.`);
    return;
  }

  console.log(`[HAMSAlertWatcher] ${title} | ${deviceId} | ${fire.temp} C | ${fire.level}`);

  await broadcastPushNotification(
    title,
    body,
    'HOT_AXLE',
    {
      module: 'hot_axle_section1',
      coach_no: meta.coach_no,
      train_no: meta.train_no,
      status: isCritical ? 'Critical' : 'Warning',
      fault_name: faultName,
      severity: isCritical ? 'critical' : 'warning',
      send_sms: isCritical,
      location: meta.location,
    },
    { module: 'hot_axle_section1', location: meta.location, email: isCritical, sms: isCritical }
  );
}

async function processRows(rows) {
  for (const row of rows) {
    if (_lastId == null || row.id > _lastId) _lastId = row.id;
    if (row.master_id && row.master_id !== 'HAMS-M1-001') continue;
    const fire = evaluate(row);
    if (fire) {
      try { await dispatch(row, fire); } catch (e) { console.error('[HAMSAlertWatcher] Dispatch error:', e.message); }
    }
  }
}

async function seed() {
  const { data, error } = await supabaseOld
    .from(TABLE)
    .select('*')
    .eq('master_id', 'HAMS-M1-001')
    .order('id', { ascending: false })
    .limit(SEED_ROWS);
  if (error) throw error;
  const rows = (data || []).reverse();
  if (rows.length === 0) { _lastId = 0; return; }
  await processRows(rows);
}

async function startHamsAlertWatcher() {
  if (!supabaseOld) {
    console.warn('[HAMSAlertWatcher] supabaseOld not configured. Skipping watcher.');
    return;
  }
  console.log('[HAMSAlertWatcher] Starting HAMS Hot Axle alert watcher...');
  await refreshMeta();
  try {
    await seed();
    console.log(`[HAMSAlertWatcher] Synced at hams_data id ${_lastId}, tracking ${_state.size} sensor(s).`);
  } catch (err) {
    console.error('[HAMSAlertWatcher] Seed failed:', err.message);
  }

  let running = false;
  setInterval(async () => {
    if (running) return;
    running = true;
    try {
      await refreshMeta();
      if (_lastId == null) { await seed(); return; }
      const { data, error } = await supabaseOld
        .from(TABLE)
        .select('*')
        .eq('master_id', 'HAMS-M1-001')
        .gt('id', _lastId)
        .order('id', { ascending: true })
        .limit(BATCH_LIMIT);
      if (error) throw error;
      await processRows(data || []);
    } catch (err) {
      console.error('[HAMSAlertWatcher] Poll error:', err.message);
    } finally {
      running = false;
    }
  }, POLL_INTERVAL_MS);
}

module.exports = { startHamsAlertWatcher, evaluate, _state };
