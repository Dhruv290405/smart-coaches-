const supabaseAdmin = require('../config/supabaseAdmin');

async function insertIoTData({ sensor_id, water_level, timestamp }) {
  const { data: inserted, error } = await supabaseAdmin
    .from('iot_water_level')
    .insert([{ sensor_id, water_level, timestamp }])
    .select();

  if (error) throw error;

  console.log('Inserting IoT data:', { sensor_id, water_level, timestamp });

  return {
    id: inserted[0].id,
    sensor_id,
    water_level,
    timestamp
  };
}

async function findRulesForSensor(sensor_id) {
  const { data, error } = await supabaseAdmin
    .from('sensor_config')
    .select('rule_id')
    .eq('sensor_id', sensor_id);

  if (error) throw error;
  return data;
}

async function getConditionsForRule(rule_id) {
  const { data, error } = await supabaseAdmin
    .from('rule_condition_master')
    .select('condition_id, rule_id, connector, alert_type_id')
    .eq('rule_id', rule_id);

  if (error) throw error;
  return data;
}

async function getSubConditionsForCondition(condition_id) {
  const { data, error } = await supabaseAdmin
    .from('rule_sub_condition')
    .select('sub_condition_id, condition_id, operator, threshold_value, sort_order')
    .eq('condition_id', condition_id)
    .order('sort_order', { ascending: true });

  if (error) throw error;

  return data.map(r => ({
    sub_condition_id: r.sub_condition_id,
    condition_id: r.condition_id,
    operator: (r.operator || '').toString().toUpperCase(),
    threshold_value: parseFloat(r.threshold_value),
    sort_order: r.sort_order
  }));
}

async function getWaterLevelData(sensor_id) {
  const { data, error } = await supabaseAdmin
    .from('iot_water_level')
    .select('*')
    .eq('sensor_id', sensor_id)
    .order('timestamp', { ascending: false })
    .limit(1);

  if (error) throw error;
  return data.length > 0 ? data[0] : null;
}

async function getWaterLevelDataForCoach(coach_id) {
  const { data: sensors, error: sensorError } = await supabaseAdmin
    .from('sensor_config')
    .select('sensor_id')
    .eq('coach_id', coach_id)
    .eq('sensor_type_id', 5);

  if (sensorError) throw sensorError;
  if (!sensors || sensors.length === 0) return null;

  const sensorIds = sensors.map(s => s.sensor_id);

  const { data, error } = await supabaseAdmin
    .from('iot_water_level')
    .select('*')
    .in('sensor_id', sensorIds)
    .order('timestamp', { ascending: false });

  if (error) throw error;
  return data.length > 0 ? data : null;
}

module.exports = {
  insertIoTData,
  getWaterLevelData,
  getWaterLevelDataForCoach,
  findRulesForSensor,
  getConditionsForRule,
  getSubConditionsForCondition
};
