const supabaseAdmin = require('../config/supabaseAdmin');

exports.insertSensorData = async (sensorId, value, timestamp) => {
  const { data: inserted, error } = await supabaseAdmin
    .from('sensor_data')
    .insert([{ sensor_id: sensorId, value, timestamp }])
    .select();
  if (error) throw error;
  return inserted[0].id;
};

exports.getTrainsForUser = async (userId) => {
  const { data: rows, error } = await supabaseAdmin
    .from('trains_master')
    .select('train_id, train_number, train_name');
  if (error) throw error;
  return rows || [];
};
