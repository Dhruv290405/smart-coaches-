const supabaseOld = require('../config/supabaseOld');
const supabaseAdmin = require('../config/supabaseAdmin');
const { saveInAppNotificationForAllUsers } = require('../utils/notificationService');

const _notifiedFaults = new Map(); // deviceKey -> { fault_name, timestamp, notifiedAt }
let _lastProcessedFaultId = null;
let _coachCache = new Map();
let _coachCacheLastUpdated = 0;

function formatIST(dateValue) {
  if (!dateValue) return '';
  const d = new Date(dateValue);
  if (isNaN(d.getTime())) return String(dateValue);
  const istDate = new Date(d.getTime() + (5.5 * 60 * 60 * 1000));
  const dd = String(istDate.getUTCDate()).padStart(2, '0');
  const mm = String(istDate.getUTCMonth() + 1).padStart(2, '0');
  const yyyy = istDate.getUTCFullYear();
  let hours = istDate.getUTCHours();
  const minutes = String(istDate.getUTCMinutes()).padStart(2, '0');
  const seconds = String(istDate.getUTCSeconds()).padStart(2, '0');
  const ampm = hours >= 12 ? 'PM' : 'AM';
  const hh12 = String(hours % 12 || 12).padStart(2, '0');
  return `${dd}/${mm}/${yyyy} ${hh12}:${minutes}:${seconds} ${ampm} IST`;
}

async function refreshCoachCache() {
  const now = Date.now();
  if (now - _coachCacheLastUpdated < 10 * 60 * 1000 && _coachCache.size > 0) return;
  try {
    for (const client of [supabaseAdmin, supabaseOld]) {
      if (!client) continue;
      const { data } = await client.from('coaches_railway').select('device_id, technical_id, coach_no, Train_no, Location');
      if (data) {
        data.forEach((c) => {
          if (c.device_id) _coachCache.set(c.device_id, c);
        });
      }
    }
    _coachCacheLastUpdated = now;
  } catch (err) {
    console.error('[BrakeFaultWatcher] Error caching coaches:', err.message);
  }
}

function resolveCoachInfo(deviceId, rawCoachNo) {
  const c = _coachCache.get(deviceId) || {};
  let coachNo = 'Unknown';
  if (c.technical_id && /^\d+$/.test(String(c.technical_id))) {
    coachNo = String(c.technical_id);
  } else if (c.coach_no && c.coach_no !== 'LWSCZ - AC') {
    coachNo = String(c.coach_no);
  } else if (rawCoachNo && rawCoachNo !== 'LWSCZ - AC') {
    coachNo = String(rawCoachNo);
  }

  // Known fallback mappings
  if (coachNo === 'Unknown' || coachNo === 'LWSCZ - AC') {
    if (deviceId === 'Raspberry4_7' || deviceId === 'Raspberry4_6') coachNo = '226965';
    if (deviceId === 'Raspberry4_5') coachNo = '19771';
    if (deviceId === 'Raspberry4_4') coachNo = '231035';
    if (deviceId === 'Raspberry4_1') coachNo = '231545';
    if (deviceId === 'Raspberry4_2') coachNo = '193431';
    if (deviceId === 'Raspberry4_3') coachNo = '197832';
  }

  const trainNo = c.Train_no || (deviceId === 'Raspberry4_7' ? '1207069' : 'Unknown');
  const location = c.Location || 'Nagpur';

  return { coach_no: coachNo, train_no: trainNo, location };
}

async function startBrakeFaultWatcher() {
  if (!supabaseOld) {
    console.warn('[BrakeFaultWatcher] supabaseOld not configured. Skipping watcher.');
    return;
  }

  console.log('📡 [BrakeFaultWatcher] Initializing 24/7 background brake fault watcher...');
  await refreshCoachCache();

  try {
    const { data: latest } = await supabaseOld
      .from('brake_fault_event')
      .select('id')
      .order('id', { ascending: false })
      .limit(1);
    if (latest && latest.length > 0) {
      _lastProcessedFaultId = latest[0].id;
      console.log(`[BrakeFaultWatcher] Synced with latest brake_fault_event ID: ${_lastProcessedFaultId}`);
    }
  } catch (err) {
    console.error('[BrakeFaultWatcher] Failed to fetch latest fault ID on init:', err.message);
  }

  const pollIntervalMs = 15000; // Check every 15 seconds 24/7
  setInterval(async () => {
    try {
      if (_lastProcessedFaultId == null) {
        const { data: latest } = await supabaseOld
          .from('brake_fault_event')
          .select('id')
          .order('id', { ascending: false })
          .limit(1);
        if (latest && latest.length > 0) _lastProcessedFaultId = latest[0].id;
        return;
      }

      await refreshCoachCache();

      const { data: newFaults, error } = await supabaseOld
        .from('brake_fault_event')
        .select('*')
        .gt('id', _lastProcessedFaultId)
        .order('id', { ascending: true })
        .limit(20);

      if (error) {
        console.error('[BrakeFaultWatcher] Error checking new faults:', error.message);
        return;
      }

      if (!newFaults || newFaults.length === 0) return;

      for (const fault of newFaults) {
        if (fault.id > _lastProcessedFaultId) {
          _lastProcessedFaultId = fault.id;
        }

        const deviceKey = fault.device_id || fault.coach_no || 'unknown';
        const faultName = fault.fault_name || 'Brake Fault';
        const fnUpper = faultName.toUpperCase();

        const last = _notifiedFaults.get(deviceKey);
        const isSameFault = last && last.fault_name === faultName;
        const timeSinceLastNotification = Date.now() - (last ? last.notifiedAt : 0);

        // Rule: No repeat messages for the same defect on a device until a new one arises (or 2-hour reminder)
        if (isSameFault && timeSinceLastNotification < (2 * 60 * 60 * 1000)) {
          console.log(`[BrakeFaultWatcher] Suppressing duplicate "${faultName}" for device ${deviceKey}. Already notified at ${new Date(last.notifiedAt).toISOString()}`);
          continue;
        }

        const coachInfo = resolveCoachInfo(fault.device_id, fault.coach_no);
        const istTime = formatIST(fault.timestamp || new Date());

        const title = `Alert: ${faultName} in Train ${coachInfo.train_no}, Coach_Unique Id ${coachInfo.coach_no}`;
        const body = `Fault: ${faultName} detected on Coach ${coachInfo.coach_no} (Train ${coachInfo.train_no}) at ${istTime}.`;

        const isSevereOrEmergency = fnUpper.includes('SEVERE')
          || fnUpper.includes('OVERCHARG')
          || fnUpper.includes('EMERGENCY');

        console.log(`🚀 [BrakeFaultWatcher] Dispatching alert for device ${deviceKey}: ${title} at ${istTime}`);

        await saveInAppNotificationForAllUsers(title, body, 'BRAKE_BINDING', {
          module: 'brake_binding',
          location: coachInfo.location,
          coach_no: coachInfo.coach_no,
          train_no: coachInfo.train_no,
          fault_name: faultName,
          is_diagnostic_flag: true,
          severity: isSevereOrEmergency ? 'critical' : 'warning',
          send_sms: isSevereOrEmergency,
        });

        _notifiedFaults.set(deviceKey, {
          fault_name: faultName,
          timestamp: fault.timestamp,
          notifiedAt: Date.now()
        });
      }
    } catch (err) {
      console.error('[BrakeFaultWatcher] Poller loop error:', err.message);
    }
  }, pollIntervalMs);
}

module.exports = {
  startBrakeFaultWatcher,
  formatIST,
  resolveCoachInfo,
  _notifiedFaults,
};
