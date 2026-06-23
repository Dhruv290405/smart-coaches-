const { pool } = require('../config/db');

exports.insertSensorData = async (sensorId, value, timestamp) => {
  const [result] = await pool.query(
    `INSERT INTO sensor_data (sensor_id, value, timestamp) VALUES (?, ?, ?)`,
    [sensorId, value, timestamp]
  );
  return result.insertId;
};

// get trains for user
exports.getTrainsForUser = async (userId) => {
  const [rows] = await pool.query(
    `SELECT train_id, train_number, train_name  FROM trains_master`
  );
  return rows;
};