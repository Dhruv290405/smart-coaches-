const { pool } = require('../config/db');

async function insertIoTData({ sensor_id, train_id, coach_id, value, timestamp }) {
  const [result] = await pool.query(
    `INSERT INTO iot_odour_level (sensor_id, train_id, coach_id, value, timestamp)
         VALUES (?, ?, ?, ?, ?)`,
    [sensor_id, train_id, coach_id, value, timestamp]
  );

  console.log('Inserting IoT data:', { sensor_id, train_id, coach_id, value, timestamp });

  return {
    id: result.insertId,
    sensor_id,
    train_id,
    coach_id,
    value,
    timestamp
  };
}

async function getLatestIoTDataFromDB(trainId, coachId) {
  const [rows] = await pool.query(
    `
    SELECT t1.*
    FROM iot_odour_level t1
    INNER JOIN (
      SELECT sensor_id, MAX(timestamp) AS latest_timestamp
      FROM iot_odour_level
      WHERE train_id = ? AND coach_id = ?
      GROUP BY sensor_id
    ) t2
    ON t1.sensor_id = t2.sensor_id AND t1.timestamp = t2.latest_timestamp
    WHERE t1.train_id = ? AND t1.coach_id = ?
    ORDER BY t1.sensor_id
    `,
    [trainId, coachId, trainId, coachId]
  );

  return rows;
}


module.exports = {
  insertIoTData,
  getLatestIoTDataFromDB
};
