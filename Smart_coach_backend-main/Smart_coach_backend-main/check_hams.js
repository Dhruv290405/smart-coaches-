const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const p2 = createClient(process.env.OLD_SUPABASE_URL, process.env.OLD_SUPABASE_SERVICE_ROLE_KEY);

(async () => {
  const { data: hams, error } = await p2.from('hams_data').select('device_id, battery_status, battery_voltage, master_id').limit(200);
  if (error) { console.log('Error:', error.message.substring(0, 200)); process.exit(0); }
  if (!hams || hams.length === 0) { console.log('No data'); process.exit(0); }

  console.log('Rows:', hams.length);
  const counts = {};
  for (const h of hams) counts[h.device_id] = (counts[h.device_id] || 0) + 1;
  console.log('Per device:', JSON.stringify(counts));
  
  const latest = {};
  for (const h of hams) {
    if (!latest[h.device_id]) latest[h.device_id] = h;
  }
  for (const [dev, d] of Object.entries(latest)) {
    console.log(dev + ': bat_status=' + d.battery_status + ' bat_voltage=' + d.battery_voltage + ' master=' + d.master_id);
  }
  process.exit(0);
})();
