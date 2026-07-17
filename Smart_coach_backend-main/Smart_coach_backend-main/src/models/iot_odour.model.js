const acpSupabase = require('../config/supabaseAcp');

async function insertIoTData({ device_id, temperature, humidity, voc_index, methane_ppm, h2s_ppm, nh3_ppm, long_lock_count, timestamp_device }) {
  const { data: inserted, error } = await acpSupabase
    .from('iot_bad_odour')
    .insert([{
      device_id: device_id || 'Unknown',
      temperature: temperature || 0,
      humidity: humidity || 0,
      voc_index: voc_index || 0,
      methane_ppm: methane_ppm || 0,
      h2s_ppm: h2s_ppm || 0,
      nh3_ppm: nh3_ppm || 0,
      long_lock_count: long_lock_count || 0,
      timestamp_device: timestamp_device || new Date().toISOString()
    }])
    .select();

  if (error) throw error;
  return { id: inserted[0].id };
}

async function getLatestIoTDataFromDB(trainId, coachId) {
  const { data: rows, error } = await acpSupabase
    .from('iot_bad_odour')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(50);

  if (error) throw error;
  return rows || [];
}

module.exports = {
  insertIoTData,
  getLatestIoTDataFromDB
};
