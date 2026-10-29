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

  console.log('=== Verifying deployed fix ===');
  const ncRes = await fetch(BASE + '/hot-axle/new-company-data', { headers: { Authorization: 'Bearer ' + token } });
  const nc = await ncRes.json();
  if (!nc.data || nc.data.length === 0) { console.log('No data'); process.exit(0); }

  console.log('Total rows returned:', nc.data.length);

  const latest = {};
  for (const d of nc.data) {
    if (!latest[d.device_id]) latest[d.device_id] = d;
  }

  const hamsOrder = ['HAMS001', 'HAMS002', 'HAMS003', 'HAMS004', 'HAMS005', 'HAMS006', 'HAMS008', 'HAMS009'];
  let allFound = true;
  for (const devId of hamsOrder) {
    const d = latest[devId];
    if (d) {
      console.log(devId + ': OK | location=' + (d.location || 'N/A') + ' battery=' + (d.battery_status || 'N/A') + ' (' + (d.battery_voltage ?? 'N/A') + 'V)');
    } else {
      console.log(devId + ': MISSING');
      allFound = false;
    }
  }
  console.log('\nAll 8 devices present:', allFound ? 'YES' : 'NO');
  process.exit(0);
})();
