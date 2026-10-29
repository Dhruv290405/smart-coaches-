const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const p2 = createClient(process.env.OLD_SUPABASE_URL, process.env.OLD_SUPABASE_SERVICE_ROLE_KEY);

(async () => {
  // Check what master_ids exist
  const { data: all } = await p2.from('hams_data').select('device_id, master_id').limit(500);
  if (!all || all.length === 0) { console.log('No data'); process.exit(0); }

  const masterIds = {};
  const perDevice = {};
  for (const h of all) {
    const m = h.master_id || 'NULL';
    masterIds[m] = (masterIds[m] || 0) + 1;
    const key = h.device_id + '|' + m;
    perDevice[key] = (perDevice[key] || 0) + 1;
  }
  console.log('master_id distribution:', JSON.stringify(masterIds));
  console.log('\nPer device|master count:', JSON.stringify(perDevice));

  // Query specifically for HAMS-M1-001
  const { data: m1 } = await p2.from('hams_data').select('device_id, battery_status, battery_voltage').eq('master_id', 'HAMS-M1-001').limit(200);
  console.log('\n== Devices with master_id = HAMS-M1-001 ==');
  if (m1) {
    const devs = {};
    for (const h of m1) devs[h.device_id] = (devs[h.device_id] || 0) + 1;
    console.log('Device count:', JSON.stringify(devs));
    const latest = {};
    for (const h of m1) if (!latest[h.device_id]) latest[h.device_id] = h;
    for (const [d, h] of Object.entries(latest)) {
      console.log(d + ': bat_status=' + h.battery_status + ' bat_voltage=' + h.battery_voltage);
    }
  }

  process.exit(0);
})();
