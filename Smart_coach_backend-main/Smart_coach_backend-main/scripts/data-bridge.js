const OLD_BASE = 'https://smart-coach-api-production.up.railway.app/smart_coach_api/api';
const NEW_BASE = 'https://api.vaspsystemic.com/smart_coach_api/api';

const postJson = (url, body) =>
  fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });

const getOldData = async (path) => {
  const r = await fetch(OLD_BASE + path);
  if (!r.ok) { console.error(`  GET ${path} failed: ${r.status}`); return []; }
  const j = await r.json();
  return j.data || j.records || [];
};

const stripDerived = (obj) => {
  const derived = ['tech_coach_no', 'train_no', 'id', 'created_at'];
  const out = {};
  for (const [k, v] of Object.entries(obj)) {
    if (!derived.includes(k)) out[k] = v;
  }
  return out;
};

const MAX_WLI_SENSOR_ID = 50;
let wliLastSeenId = 0;

const buildWliPayload = (sensorId, waterLevel, ts) => ({
  source: { deviceId: `WLI-${sensorId}`, systemType: 'WLI' },
  location: { coachId: String(sensorId), coachName: `Coach ${sensorId}` },
  placement: { type: 'UNDERSLUNG' },
  timestamp: ts || new Date().toISOString(),
  assets: [{
    assetId: `TANK-${sensorId}-1`, assetName: 'Water Tank Sensor',
    rawValue: waterLevel,
    levelCm: Math.round((waterLevel / 100) * 35 * 10) / 10,
    volumeLiters: Math.round((waterLevel / 100) * 35 * 4.5 * 10) / 10,
    percentFull: waterLevel
  }]
});

const migrateWli = async () => {
  for (let sid = 1; sid <= MAX_WLI_SENSOR_ID; sid++) {
    const r = await fetch(OLD_BASE + `/iot_water_level/get_water_level_data?sensor_id=${sid}`);
    if (!r.ok) continue;
    const data = (await r.json()).data;
    if (!data || !data.id || data.id <= wliLastSeenId) continue;
    const res = await postJson(NEW_BASE + '/wli/receive-data', buildWliPayload(sid, data.water_level, data.timestamp));
    if (res.ok) { console.log(`  WLI sensor ${sid}: id=${data.id} water_level=${data.water_level}`); wliLastSeenId = data.id; }
  }
};

const endpoints = [
  { name: 'Hot Axle', get: '/hot-axle/dashboard-status', post: '/hot-axle/receive-data', map: stripDerived },
  { name: 'BC Pressure', get: '/pressure/dashboard-status', post: '/pressure/receive-data',
    map: item => {
      const clean = stripDerived(item);
      return { device_id: clean.device_id, coach_number: clean.coach_number, coach_type: clean.coach_type, owning_rly: clean.owning_rly, readings: [clean] };
    }},
  { name: 'WLI', get: null, post: null, custom: migrateWli },
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
  for (const ep of endpoints) {
    if (ep.custom) await ep.custom();
    else await migrateType(ep);
  }
  console.log('\nDone!');
}

main().catch(console.error);
