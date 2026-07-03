const supabaseAdmin = require('../config/supabaseAdmin');

const DIESEL_SENSOR_TYPE_ID = 6;

async function getDieselSensors(coachId) {
  let query = supabaseAdmin
    .from('sensor_config')
    .select('sensor_id, coach_id')
    .eq('sensor_type_id', DIESEL_SENSOR_TYPE_ID);

  if (coachId) {
    query = query.eq('coach_id', coachId);
  }

  const { data: sensors, error } = await query;
  if (error) throw error;

  const enriched = await Promise.all(sensors.map(async (sensor) => {
    const { data: coach } = await supabaseAdmin
      .from('coaches')
      .select('id, train_id')
      .eq('id', sensor.coach_id)
      .single();

    let trainData = { train_number: null, train_name: null };
    if (coach && coach.train_id) {
      const { data: train } = await supabaseAdmin
        .from('trains')
        .select('id, train_number, train_name')
        .eq('id', coach.train_id)
        .single();

      if (train) {
        trainData = { train_number: train.train_number, train_name: train.train_name };
      }
    }

    return {
      sensor_id: sensor.sensor_id,
      coach_id: sensor.coach_id,
      train_id: coach?.train_id || null,
      ...trainData
    };
  }));

  return enriched;
}

async function getLatestReadings(sensorIds) {
  if (!sensorIds.length) return [];

  const { data, error } = await supabaseAdmin
    .from('sensor_data')
    .select('*')
    .in('sensor_id', sensorIds)
    .order('timestamp', { ascending: false });

  if (error) throw error;

  const latestMap = new Map();
  for (const row of data) {
    if (!latestMap.has(row.sensor_id)) {
      latestMap.set(row.sensor_id, row);
    }
  }
  return Array.from(latestMap.values());
}

async function getReadingHistory(sensorId, limit = 50) {
  const { data, error } = await supabaseAdmin
    .from('sensor_data')
    .select('value, timestamp')
    .eq('sensor_id', sensorId)
    .order('timestamp', { ascending: false })
    .limit(limit);

  if (error) throw error;
  return data;
}

module.exports = {
  getDieselSensors,
  getLatestReadings,
  getReadingHistory,
  DIESEL_SENSOR_TYPE_ID,
};
