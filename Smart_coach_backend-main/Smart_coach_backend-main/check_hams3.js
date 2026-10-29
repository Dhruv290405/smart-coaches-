const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const p2 = createClient(process.env.OLD_SUPABASE_URL, process.env.OLD_SUPABASE_SERVICE_ROLE_KEY);

(async () => {
  // Count total for HAMS-M1-001
  const { count, error } = await p2.from('hams_data').select('*', { count: 'exact', head: true }).eq('master_id', 'HAMS-M1-001');
  console.log('Total rows for HAMS-M1-001:', count, error ? error.message : '');

  // Also count HAMS_003
  const { count: c2 } = await p2.from('hams_data').select('*', { count: 'exact', head: true }).eq('master_id', 'HAMS_003');
  console.log('Total rows for HAMS_003:', c2);

  // Get latest row per device for HAMS-M1-001
  const { data: latest } = await p2.from('hams_data').select('device_id, battery_status, battery_voltage, created_at').eq('master_id', 'HAMS-M1-001').order('created_at', { ascending: false }).limit(1000);
  if (latest) {
    console.log('Fetched rows:', latest.length);
    const perDevice = {};
    for (const h of latest) {
      if (!perDevice[h.device_id]) perDevice[h.device_id] = { count: 1, first: h };
      else perDevice[h.device_id].count++;
    }
    for (const [dev, info] of Object.entries(perDevice)) {
      console.log(dev + ': count=' + info.count + ' latest_bat_status=' + info.first.battery_status + ' latest_bat_volt=' + info.first.battery_voltage);
    }
  }

  process.exit(0);
})();
