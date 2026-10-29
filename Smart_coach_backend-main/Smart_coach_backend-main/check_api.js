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

  // Get new-company-data
  const ncRes = await fetch(BASE + '/hot-axle/new-company-data', { headers: { Authorization: 'Bearer ' + token } });
  const nc = await ncRes.json();
  if (!nc.data || nc.data.length === 0) { console.log('No data'); process.exit(0); }

  console.log('Total rows:', nc.data.length);

  // Check latest per device_id
  const latest = {};
  for (const d of nc.data) {
    if (!latest[d.device_id]) latest[d.device_id] = d;
  }
  
  const hamsOrder = ['HAMS001', 'HAMS002', 'HAMS003', 'HAMS004', 'HAMS005', 'HAMS006', 'HAMS008', 'HAMS009'];
  for (const devId of hamsOrder) {
    const d = latest[devId];
    if (d) {
      const location = d.location || '(empty)';
      const batStatus = d.battery_status || '(empty)';
      const batVoltage = d.battery_voltage !== undefined && d.battery_voltage !== null ? d.battery_voltage : '(null)';
      console.log(devId + ': location=' + location + ' bat_status=' + batStatus + ' bat_voltage=' + batVoltage);
    } else {
      console.log(devId + ': NOT FOUND in response');
    }
  }

  process.exit(0);
})();
