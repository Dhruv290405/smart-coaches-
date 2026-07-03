const supabaseAdmin = require('../config/supabaseAdmin');

exports.insertSensorData = async (sensorId, value, timestamp) => {
  const { data: inserted, error } = await supabaseAdmin
    .from('sensor_data')
    .insert([{ sensor_id: sensorId, value, timestamp }])
    .select();
  if (error) throw error;
  return inserted[0].id;
};

exports.getSensorData = async ({ sensor_id, from_date, to_date, limit }) => {
  let query = supabaseAdmin.from('sensor_data').select('*');

  if (sensor_id) query = query.eq('sensor_id', sensor_id);
  if (from_date) query = query.gte('timestamp', from_date);
  if (to_date) query = query.lte('timestamp', to_date);

  const { data, error } = await query
    .order('timestamp', { ascending: false })
    .limit(limit || 100);

  if (error) throw error;
  return data || [];
};

exports.getTrainsForUser = async (userId) => {
  const { data: rows, error } = await supabaseAdmin
    .from('train_master')
    .select('train_id, train_number, train_name');
  if (error) throw error;
  return rows || [];
};
