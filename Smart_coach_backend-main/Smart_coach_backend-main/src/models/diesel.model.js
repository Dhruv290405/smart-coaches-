const { pool } = require('../config/db');

const DIESEL_SENSOR_TYPE_ID = 6;

async function getDieselSensors(coachId) {
  let query = `SELECT sc.sensor_id, sc.coach_id, c.train_id, t.train_number, t.train_name
               FROM sensor_config sc
               JOIN coaches c ON sc.coach_id = c.id
               JOIN trains t ON c.train_id = t.id
               WHERE sc.sensor_type_id = ?`;
  const params = [DIESEL_SENSOR_TYPE_ID];

  if (coachId) {
    query += ` AND sc.coach_id = ?`;
    params.push(coachId);
  }

  const [rows] = await pool.query(query, params);
  return rows;
}

async function getLatestReadings(sensorIds) {
  if (!sensorIds.length) return [];
  const placeholders = sensorIds.map(() => '?').join(',');
  const [rows] = await pool.query(
    `SELECT sd.* FROM sensor_data sd
     INNER JOIN (
       SELECT sensor_id, MAX(timestamp) AS max_ts
       FROM sensor_data
       WHERE sensor_id IN (${placeholders})
       GROUP BY sensor_id
     ) latest ON sd.sensor_id = latest.sensor_id AND sd.timestamp = latest.max_ts`,
    sensorIds
  );
  return rows;
}

async function getReadingHistory(sensorId, limit = 50) {
  const [rows] = await pool.query(
    `SELECT value, timestamp FROM sensor_data
     WHERE sensor_id = ?
     ORDER BY timestamp DESC
     LIMIT ?`,
    [sensorId, limit]
  );
  return rows;
}

module.exports = {
  getDieselSensors,
  getLatestReadings,
  getReadingHistory,
  DIESEL_SENSOR_TYPE_ID,
};
