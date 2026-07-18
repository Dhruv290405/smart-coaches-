const OLD_BASE = 'https://smart-coach-api-production.up.railway.app/smart_coach_api/api';
const NEW_BASE = 'https://api.vaspsystemic.com/smart_coach_api/api';
const POLL_INTERVAL_MS = 60_000; // 1 minute
const MAX_SENSOR_ID = 50;

let lastSeenId = 0;

const getOld = async (path) => {
  const r = await fetch(OLD_BASE + path);
  if (!r.ok) return null;
  return (await r.json()).data || null;
};

const postNew = (path, body) =>
  fetch(NEW_BASE + path, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  });

// Convert water_level (0-100) to the rich format
const buildWliPayload = (sensorId, waterLevel, ts, coachId, deviceId) => {
  const levelCm = Math.round((waterLevel / 100) * 35 * 10) / 10; // 35cm max tank
  const volumeLiters = Math.round(levelCm * 4.5 * 10) / 10;
  return {
    source: { deviceId: deviceId || `WLI-${sensorId}`, systemType: 'WLI' },
    location: { coachId: String(coachId || sensorId), coachName: `Coach ${coachId || sensorId}` },
    placement: { type: 'UNDERSLUNG' },
    timestamp: ts || new Date().toISOString(),
    assets: [{
      assetId: `TANK-${sensorId}-1`,
      assetName: 'Water Tank Sensor',
      rawValue: waterLevel,
      levelCm,
      volumeLiters,
      percentFull: waterLevel
    }]
  };
};

async function pollOnce() {
  // Try each sensor_id to see if there's new data
  for (let sid = 1; sid <= MAX_SENSOR_ID; sid++) {
    const data = await getOld(`/iot_water_level/get_water_level_data?sensor_id=${sid}`);
    if (!data || !data.id) continue;
    if (data.id <= lastSeenId) continue;

    const payload = buildWliPayload(sid, data.water_level, data.timestamp);
    const r = await postNew('/wli/receive-data', payload);
    if (r.ok) {
      console.log(`[${new Date().toISOString()}] Bridged sensor ${sid}: id=${data.id} water_level=${data.water_level}`);
      lastSeenId = data.id;
    } else {
      console.error(`[${new Date().toISOString()}] POST failed for sensor ${sid}: ${r.status}`);
    }
  }
}

async function main() {
  console.log('WLI Bridge: Old → New Railway (polling every ' + (POLL_INTERVAL_MS / 1000) + 's)');
  await pollOnce();
  setInterval(pollOnce, POLL_INTERVAL_MS);
}

main().catch(console.error);
