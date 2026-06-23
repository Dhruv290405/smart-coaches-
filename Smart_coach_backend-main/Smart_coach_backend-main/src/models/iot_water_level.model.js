const { pool } = require('../config/db');

async function insertIoTData({ sensor_id, water_level, timestamp }) {
  const [result] = await pool.query(
    `INSERT INTO iot_water_level (sensor_id, water_level, timestamp)
         VALUES (?, ?, ?)`,
    [sensor_id, water_level, timestamp]
  );

  console.log('Inserting IoT data:', { sensor_id, water_level, timestamp });

  return {
    id: result.insertId,
    sensor_id,
    water_level,
    timestamp
  };

}

async function findRulesForSensor(sensor_id) {
  const [rows] = await pool.query(
    `SELECT rule_id FROM sensor_config WHERE sensor_id = ?`,
    [sensor_id]
  );

  return rows;
}

// get all condition rows for a rule from rule_condition_master
async function getConditionsForRule(rule_id) {
  // We include connection, alert_type_id, sort_order etc
  const [rows] = await pool.query(
    `SELECT condition_id, rule_id, connector, alert_type_id
       FROM rule_condition_master
      WHERE rule_id = ?`,
    [rule_id]
  );

  return rows;
}

// get subconditions for a condition_id from rule_sub_condition
async function getSubConditionsForCondition(condition_id) {
  const [rows] = await pool.query(
    `SELECT sub_condition_id, condition_id, operator, threshold_value, sort_order
       FROM rule_sub_condition
      WHERE condition_id = ?
      ORDER BY sort_order ASC`, // ensures ordering from DB
    [condition_id]
  );

  // Normalize and preserve sort order
  return rows.map(r => ({
    sub_condition_id: r.sub_condition_id,
    condition_id: r.condition_id,
    operator: (r.operator || '').toString().toUpperCase(),
    threshold_value: parseFloat(r.threshold_value),
    sort_order: r.sort_order
  }));
}


async function getWaterLevelData(sensor_id) {
  const query = `
    SELECT * 
    FROM iot_water_level
    WHERE sensor_id = ?
    ORDER BY timestamp DESC
    LIMIT 1
  `;

  const [rows] = await pool.query(query, [sensor_id]);
  return rows.length > 0 ? rows[0] : null;
}

async function getWaterLevelDataForCoach(coach_id) {
  const query = `
    SELECT iwl.*
    FROM iot_water_level iwl
    JOIN sensor_config sc ON iwl.sensor_id = sc.sensor_id
    WHERE sc.coach_id = ? AND sc.sensor_type_id = 5
    ORDER BY iwl.timestamp DESC
  `;

  const [rows] = await pool.query(query, [coach_id]);
  return rows.length > 0 ? rows : null;
}

module.exports = {
  insertIoTData,
  getWaterLevelData,
  getWaterLevelDataForCoach,
  findRulesForSensor,
  getConditionsForRule,
  getSubConditionsForCondition
};
