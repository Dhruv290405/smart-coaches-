/**
 * 24/7 ACP (Alarm Chain Pulling) alert watcher.
 *
 * ACP devices publish over MQTT -> AWS, which writes straight into
 * `railway_acp_data` (ACP/Odour Supabase project). The POST /acp/receive-data
 * endpoint (which used to raise ACP alerts) is no longer called, so alerts are
 * raised here by polling the table.
 *
 * Rule (same as acpController.receiveAcpData): count_value > 0 on an ACP asset
 * = "ACP Obstruction" -> in-app + push + email + SMS.
 *
 * Anti-spam:
 *  - The device count is latched, so an alert fires only when an asset's
 *    count RISES (0 -> n, or n -> n+k = a new chain pull). Unchanged counts
 *    never re-alert.
 *  - On startup the current counts are recorded silently (no burst on deploy).
 *  - user_notifications is checked so the same alert is not resent within 2 h.
 *  - Blocked coaches (acp blocked list) are ignored.
 */
const acpSupabase = require('../config/supabaseAcp');
const supabaseAdmin = require('../config/supabaseAdmin');
const AcpModel = require('../models/acpModel');
const { broadcastPushNotification } = require('../utils/notificationService');
const { formatIST } = require('./brakeFaultWatcher');

const TABLE = 'railway_acp_data';
const POLL_INTERVAL_MS = 30 * 1000;
const BATCH_LIMIT = 1000;
const REMINDER_MS = 2 * 60 * 60 * 1000;
const SEED_ROWS = 500;
// ACP is a Danapur module (rbac DIVISION_MODULE_MAP); admins + tester always receive.
const ACP_LOCATION = process.env.ACP_ALERT_LOCATION || 'Danapur';
const BLOCKED_COACHES = ['205063'];
const SELECT_COLS = 'id, msg_type, loc_name, asset_id, asset_name, coach_no, technical_id, device_id, count_value, totalized_count, metric_timestamp, created_at';

let _lastId = null;
// asset -> { alerted, firedAt, zeroCount }
const _state = new Map();
let _blocked = new Set(BLOCKED_COACHES);
let _blockedAt = 0;

async function refreshBlocked() {
  if (Date.now() - _blockedAt < 5 * 60 * 1000) return;
  try {
    const list = await AcpModel.getBlockedCoaches();
    _blocked = new Set([...BLOCKED_COACHES, ...(list || []).map(String)]);
  } catch (err) {
    console.error('[AcpAlertWatcher] Blocked list refresh failed:', err.message);
  }
  _blockedAt = Date.now();
}

function assetKey(row) {
  return row.asset_id || row.device_id || row.asset_name;
}

function techNo(row) {
  return String(row.technical_id || (row.asset_name || '').split(' ')[1] || '');
}

/**
 * Feed one reading into the per-asset state. Returns true to alert.
 * The device count is latched (it stays at e.g. 6 for hours), so a NEW chain
 * pull is a RISE in the count (0 -> 6, 6 -> 7). Unchanged counts never re-alert.
 * With prime=true (startup) the current counts are recorded silently.
 */
function evaluate(row, now = Date.now(), prime = false) {
  const key = assetKey(row);
  if (!key) return false;
  // Only METRICS rows carry the ACP count; ignore heartbeats / other messages.
  if (row.msg_type && String(row.msg_type).toUpperCase() !== 'METRICS') return false;
  if (row.count_value == null) return false;
  if (_blocked.has(techNo(row))) return false;
  const count = Number(row.count_value) || 0;
  const prev = _state.get(key);
  _state.set(key, { count, at: now });
  if (prime) return false;
  const prevCount = prev ? prev.count : 0;
  return count > 0 && count > prevCount;
}

function buildMessage(row) {
  const coach = row.coach_no || 'Unknown';
  const tech = techNo(row);
  const coachLabel = tech ? `${coach} (${tech})` : coach;
  const train = row.loc_name || 'Unknown';
  const title = `Alert: ACP Obstruction in Train ${train}, Coach_Unique Id ${coachLabel}`;
  const body = `ACP (alarm chain pulling) detected on Coach ${coachLabel}, ${train} at `
    + `${formatIST(row.metric_timestamp || row.created_at || new Date())}. `
    + `ACP count: ${row.count_value}${row.totalized_count != null ? `, total: ${row.totalized_count}` : ''}. `
    + `Device: ${row.asset_name || row.device_id || '-'}.`;
  return { coach: coachLabel, train, title, body };
}

async function recentlySent(title) {
  try {
    const since = new Date(Date.now() - REMINDER_MS).toISOString();
    const { data, error } = await supabaseAdmin
      .from('user_notifications')
      .select('id')
      .eq('type', 'ACP')
      .eq('title', title)
      .gte('created_at', since)
      .limit(1);
    if (error) return false;
    return (data || []).length > 0;
  } catch (_) {
    return false;
  }
}

async function dispatch(row) {
  const { coach, train, title, body } = buildMessage(row);
  if (await recentlySent(title)) {
    console.log(`[AcpAlertWatcher] Skipping "${title}" — already sent within the last 2 h.`);
    return;
  }
  console.log(`🚀 [AcpAlertWatcher] ${title} | count=${row.count_value}`);
  await broadcastPushNotification(
    title,
    body,
    'ACP',
    {
      module: 'acp',
      coach_no: coach,
      train_no: train,
      fault_name: 'ACP Obstruction',
      count: row.count_value,
      severity: 'critical',
      send_sms: true,
      location: ACP_LOCATION,
    },
    { module: 'acp', location: ACP_LOCATION }
  );
}

async function processRows(rows, prime = false) {
  for (const row of rows) {
    if (_lastId == null || row.id > _lastId) _lastId = row.id;
    if (evaluate(row, Date.now(), prime)) {
      try { await dispatch(row); } catch (e) { console.error('[AcpAlertWatcher] Dispatch error:', e.message); }
    }
  }
}

async function seed() {
  // Record the latest count per asset silently, so a restart/deploy does not
  // re-alert latched counts; only rises after startup alert.
  const { data, error } = await acpSupabase
    .from(TABLE)
    .select(SELECT_COLS)
    .order('id', { ascending: false })
    .limit(SEED_ROWS);
  if (error) throw error;
  const rows = (data || []).reverse();
  if (rows.length === 0) { _lastId = 0; return; }
  await processRows(rows, true);
}

async function startAcpAlertWatcher() {
  if (!acpSupabase) {
    console.warn('[AcpAlertWatcher] ACP Supabase not configured. Skipping watcher.');
    return;
  }
  console.log('📡 [AcpAlertWatcher] Starting ACP alert watcher...');
  await refreshBlocked();
  try {
    await seed();
    console.log(`[AcpAlertWatcher] Synced at ${TABLE} id ${_lastId}, tracking ${_state.size} asset(s).`);
  } catch (err) {
    console.error('[AcpAlertWatcher] Seed failed:', err.message);
  }

  let running = false;
  setInterval(async () => {
    if (running) return;
    running = true;
    try {
      await refreshBlocked();
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
      console.error('[AcpAlertWatcher] Poll error:', err.message);
    } finally {
      running = false;
    }
  }, POLL_INTERVAL_MS);
}

module.exports = { startAcpAlertWatcher, evaluate, buildMessage, _state };
