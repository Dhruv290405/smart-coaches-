const BaseModel = require('./base.model');
const { pool } = require('../config/db');

class SensorModel extends BaseModel {
  constructor() {
    super('sensor_master');
  }

  async getAll(filters = {}) {
    let query = `
        SELECT 
      sm.sensor_type_id,
      sm.sensor_type_name,
      sm.category,
      sm.name,
      sm.description,
      sm.value_format,
      sm.min_expected_value,
      sm.max_expected_value,
      sm.sampling_frequency,
      sm.time_interval,
      sm.is_active,
      sm.created_at,
      sm.updated_at,
      sm.created_by,
      sm.updated_by,
      vt.name AS category_name,
      u1.first_name AS created_by_user,
      u2.first_name AS updated_by_user
    FROM sensor_master sm
    LEFT JOIN value_type_master vt ON sm.category = vt.value_type_id
    LEFT JOIN user_master u1 ON sm.created_by = u1.user_id
    LEFT JOIN user_master u2 ON sm.updated_by = u2.user_id
    WHERE 1 = 1  
  `;

    const params = [];

    if (filters.sensor_type) {
      query += ' AND sm.sensor_type = ?';
      params.push(filters.sensor_type);
    }

    if (filters.status) {
      query += ' AND sm.status = ?';
      params.push(filters.status);
    }

    if (filters.search) {
      query += ` AND (
      sm.name LIKE ? OR
      sm.sensor_type_name LIKE ? OR
      sm.value_type LIKE ?
    )`;
      const term = `%${filters.search}%`;
      params.push(term, term, term);
    }

    query += ' ORDER BY sm.sensor_type_id DESC';

    const [sensorRows] = await this.pool.query(query, params);

    const sensorIds = sensorRows.map(s => s.sensor_type_id);
    if (sensorIds.length === 0) return [];

    // ✅ Fetch units mapped
    const [unitRows] = await this.pool.query(
      `SELECT smap.sensor_id, um.unit_id, um.unit 
     FROM sensor_unit_mapping smap
     JOIN unit_master um ON smap.unit_id = um.unit_id
     WHERE smap.sensor_id IN (?)`,
      [sensorIds]
    );

    // ✅ Fetch devices mapped
    const [deviceRows] = await this.pool.query(
      `SELECT sdm.sensor_id, dm.device_id, dm.short_name, dm.full_name 
     FROM sensor_device_mapping sdm
     JOIN device_master dm ON sdm.device_id = dm.device_id
     WHERE sdm.sensor_id IN (?)`,
      [sensorIds]
    );

    // ✅ Group unit/device by sensor_id
    const unitMap = {}, deviceMap = {};
    unitRows.forEach(row => {
      if (!unitMap[row.sensor_id]) unitMap[row.sensor_id] = [];
      unitMap[row.sensor_id].push({
        unit_id: row.unit_id,
        unit: row.unit
      });
    });

    deviceRows.forEach(row => {
      if (!deviceMap[row.sensor_id]) deviceMap[row.sensor_id] = [];
      deviceMap[row.sensor_id].push({
        device_id: row.device_id,
        short_name: row.short_name,
        full_name: row.full_name
      });
    });

    // ✅ Merge and return final array
    return sensorRows.map(sensor => ({
      sensor_type_id: sensor.sensor_type_id,
      sensor_type_name: sensor.sensor_type_name,
      category: {
        id: sensor.category,
        name: sensor.category_name
      },
      name: sensor.name,
      description: sensor.description,
      value_format: sensor.value_format,
      min_expected_value: sensor.min_expected_value,
      max_expected_value: sensor.max_expected_value,
      sampling_frequency: sensor.sampling_frequency,
      time_interval: sensor.time_interval,
      is_active: !!sensor.is_active,
      created_at: sensor.created_at,
      updated_at: sensor.updated_at,
      created_by: sensor.created_by_user,
      updated_by: sensor.updated_by_user,
      units: unitMap[sensor.sensor_type_id] || [],
      devices: deviceMap[sensor.sensor_type_id] || []
    }));

  }


  async deleteSensorById(sensorId) {
    // 1. Delete from sensor_mapping (units)
    await this.pool.query(
      `DELETE FROM sensor_unit_mapping WHERE sensor_id = ?`,
      [sensorId]
    );

    // 2. Delete from sensor_device_mapping
    await this.pool.query(
      `DELETE FROM sensor_device_mapping WHERE sensor_id = ?`,
      [sensorId]
    );

    // 3. Delete from sensor_master
    const [result] = await this.pool.query(
      `DELETE FROM sensor_master WHERE sensor_type_id = ?`,
      [sensorId]
    );

    return result.affectedRows > 0;
  }



  // Get sensor by ID
  async getById(sensorId) {
    const [rows] = await this.pool.query(
      `SELECT * FROM sensor_master
       WHERE sensor_type_id = ?`,
      [sensorId]
    );
    return rows[0] || null;
  }


  // get all categories from value_type_master
  async getAllCategories() {
    const [rows] = await this.pool.query(
      'SELECT value_type_id, name, base_unit FROM value_type_master ORDER BY name'
    );
    return rows;
  }

  // Get units by category
  async getUnitsByCategory(categoryId) {
    const [rows] = await this.pool.query(
      `SELECT um.unit_id, um.unit, um.is_base_unit
       FROM unit_master um
       JOIN value_type_master vtm ON um.value_type_id = vtm.value_type_id
       WHERE vtm.value_type_id = ?
       ORDER BY um.unit`,
      [categoryId]
    );
    return rows;
  }

  // Check if serial number already exists
  async serialNumberExists(serialNumber, excludeId = null) {
    let query = 'SELECT id FROM sensors WHERE serial_number = ?';
    const params = [serialNumber];

    if (excludeId) {
      query += ' AND id != ?';
      params.push(excludeId);
    }

    const [rows] = await this.pool.query(query, params);
    return rows.length > 0;
  }

  // Get latest readings for a sensor
  async getReadings(sensorId, limit = 100) {
    const [rows] = await this.pool.query(
      `SELECT * FROM sensor_readings 
       WHERE sensor_id = ? 
       ORDER BY reading_time DESC 
       LIMIT ?`,
      [sensorId, parseInt(limit)]
    );
    return rows;
  }

  // Add a new reading for a sensor
  async addReading(sensorId, reading) {
    const {
      value,
      unit,
      reading_time = new Date(),
      error_code = null,
      error_message = null,
      latitude = null,
      longitude = null,
      battery_level = null,
      signal_strength = null,
      raw_data = null
    } = reading;

    const [result] = await this.pool.query(
      `INSERT INTO sensor_readings 
       (sensor_id, device_id, value, unit, reading_time, error_code, 
        error_message, latitude, longitude, battery_level, 
        signal_strength, raw_data, created_at) 
       VALUES (?, (SELECT device_id FROM sensors WHERE id = ?), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
      [sensorId, sensorId, value, unit, reading_time, error_code,
        error_message, latitude, longitude, battery_level,
        signal_strength, raw_data]
    );

    // Update last_reading_time on the sensor
    await this.pool.query(
      'UPDATE sensors SET last_reading_time = ? WHERE id = ?',
      [reading_time, sensorId]
    );

    return result.insertId;
  }

  // Get sensor statistics
  async getStatistics(sensorId, startDate, endDate) {
    const [stats] = await this.pool.query(
      `SELECT 
          MIN(value) as min_value,
          MAX(value) as max_value,
          AVG(value) as avg_value,
          COUNT(*) as reading_count,
          MIN(reading_time) as first_reading,
          MAX(reading_time) as last_reading
       FROM sensor_readings 
       WHERE sensor_id = ? 
         AND reading_time BETWEEN ? AND ?`,
      [sensorId, startDate, endDate]
    );

    return stats[0] || null;
  }

  // Get sensor alerts
  async getAlerts(sensorId, limit = 10) {
    const [alerts] = await this.pool.query(
      `SELECT * FROM sensor_alerts 
       WHERE sensor_id = ? 
       ORDER BY created_at DESC 
       LIMIT ?`,
      [sensorId, limit]
    );
    return alerts;
  }

  // Create a new alert for a sensor
  async createAlert(sensorId, alert) {
    const {
      alert_type,
      threshold_value,
      actual_value,
      message,
      severity,
      resolved = false,
      resolved_at = null,
      resolved_by = null,
      resolved_notes = null
    } = alert;

    const [result] = await this.pool.query(
      `INSERT INTO sensor_alerts 
       (sensor_id, device_id, alert_type, threshold_value, actual_value, 
        message, severity, resolved, resolved_at, resolved_by, resolved_notes) 
       VALUES (?, (SELECT device_id FROM sensors WHERE id = ?), ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [sensorId, sensorId, alert_type, threshold_value, actual_value,
        message, severity, resolved, resolved_at, resolved_by, resolved_notes]
    );

    return result.insertId;
  }

  // Get Sensors
  async getWaterSensorsForCoach(filters = {}) {
    const { coach_id } = filters;
    
    const query = `
        SELECT sensor_config_id, sensor_id, sensor_type_id FROM sensor_config
        WHERE coach_id = ? AND sensor_type_id = 5
    `;

    const [rows] = await this.pool.query(query, [coach_id]);
    return rows;
  }
}

module.exports = new SensorModel();
