const supabaseAdmin = require('../config/supabaseAdmin');

async function insertIoTData({ sensor_id, train_id, coach_id, value, timestamp }) {
  const { data: inserted, error } = await supabaseAdmin
    .from('iot_odour_level')
    .insert([{ sensor_id, train_id, coach_id, value, timestamp }])
    .select();

  console.log('Inserting IoT data:', { sensor_id, train_id, coach_id, value, timestamp });

  if (error) throw error;

  return {
    id: inserted[0].id,
    sensor_id,
    train_id,
    coach_id,
    value,
    timestamp
  };
}

async function getLatestIoTDataFromDB(trainId, coachId) {
  const { data: rows, error } = await supabaseAdmin
    .from('iot_odour_level')
    .select('*')
    .eq('train_id', trainId)
    .eq('coach_id', coachId)
    .order('sensor_id', { ascending: true });

  if (error) throw error;

  const latestMap = new Map();
  for (const row of rows || []) {
    const key = row.sensor_id;
    if (!latestMap.has(key) || new Date(row.timestamp) > new Date(latestMap.get(key).timestamp)) {
      latestMap.set(key, row);
    }
  }

  return [...latestMap.values()];
}

module.exports = {
  insertIoTData,
  getLatestIoTDataFromDB
};
