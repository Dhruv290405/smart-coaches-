const fetch = require('node-fetch');
const BASE = 'https://api.vaspsystemic.com/smart_coach_api/api';

(async () => {
  const loginRes = await fetch(BASE + '/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'tester@example.com', password: '123456' })
  });
  const login = await loginRes.json();
  const token = login.data?.token;
  if (!token) { console.log('Login FAIL'); return; }

  const ncRes = await fetch(BASE + '/hot-axle/new-company-data', { headers: { Authorization: 'Bearer ' + token } });
  const nc = await ncRes.json();
  if (!nc.data || nc.data.length === 0) { console.log('No data'); process.exit(0); }

  console.log('Total rows:', nc.data.length);

  // Count per device_id
  const counts = {};
  for (const d of nc.data) {
    const devId = d.device_id || 'null';
    counts[devId] = (counts[devId] || 0) + 1;
  }
  console.log('Per device count:', JSON.stringify(counts));

  // Check sample for each device  
  const samples = {};
  for (const d of nc.data) {
    const devId = d.device_id || 'null';
    if (!samples[devId]) {
      samples[devId] = { device_id: d.device_id, master_id: d.master_id, location: d.location, battery_status: d.battery_status, battery_voltage: d.battery_voltage };
    }
  }
  console.log('\nSamples:');
  for (const [dev, s] of Object.entries(samples)) {
    console.log(dev + ': master=' + s.master_id + ' loc=' + s.location + ' bat_status=' + s.battery_status + ' bat_volt=' + s.battery_voltage);
  }

  process.exit(0);
})();
