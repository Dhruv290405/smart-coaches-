const OLD_BASE = 'https://smart-coach-api-production.up.railway.app/smart_coach_api/api';
const NEW_BASE = 'https://smart-coaches-production.up.railway.app/smart_coach_api/api';

const postJson = (url, body) =>
  fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });

const getOldData = async (path) => {
  const r = await fetch(OLD_BASE + path);
  if (!r.ok) { console.error(`  GET ${path} failed: ${r.status}`); return []; }
  const j = await r.json();
  return j.data || j.records || [];
};

const endpoints = [
  { name: 'Hot Axle', get: '/hot-axle/dashboard-status', post: '/hot-axle/receive-data' },
  { name: 'BC Pressure', get: '/pressure/dashboard-status', post: '/pressure/receive-data',
    map: item => ({ device_id: item.device_id, coach_number: item.coach_number, coach_type: item.coach_type, owning_rly: item.owning_rly, readings: [item] }) },
];

async function migrateType({ name, get, post, map }) {
  console.log(`\n--- ${name} ---`);
  const items = await getOldData(get);
  if (!items.length) { console.log(`  No data`); return; }
  console.log(`  Got ${items.length} items`);

  let ok = 0, fail = 0;
  for (const item of items) {
    try {
      const r = await postJson(NEW_BASE + post, map ? map(item) : item);
      if (r.ok) ok++; else { fail++; if (fail <= 2) console.error(`  ${r.status}: ${await r.text()}`); }
    } catch (e) {
      fail++; if (fail <= 2) console.error(`  ${e.message}`);
    }
  }
  console.log(`  ${ok} OK, ${fail} failed`);
}

async function main() {
  console.log('Bridge: Old → New Railway');
  for (const ep of endpoints) await migrateType(ep);
  console.log('\nDone!');
}

main().catch(console.error);
