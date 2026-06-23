const { validationResult } = require('express-validator');
const { successResponse, errorResponse } = require('../utils/response');
const sensorModel = require('../models/sensor.model');
const deviceModel = require('../models/device.model');
const { pool } = require('../config/db');
const { toMySQLDatetime } = require('../middleware/datetime');

const sensorController = {
  // GET /api/sensors
  async getAllSensors(req, res, next) {
    try {
      const { sensor_type_name, status, search } = req.query;

      const filters = {};
      if (sensor_type_name) filters.sensor_type_name = sensor_type_name;
      if (status) filters.status = status;
      if (search) filters.search = search;

      const sensors = await sensorModel.getAll(filters);

      return successResponse(res, 'Sensors retrieved successfully', sensors);
    } catch (error) {
      next(error);
    }
  },

  // Create a new sensor
  async createSensor(req, res, next) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const created_by = req.user.user_id;

      const {
        sensor_type_name,
        category,           // FK → value_type_master.value_type_id
        name,
        description,
        value_format,
        min_expected_value,
        max_expected_value,
        sampling_frequency,
        time_interval,
        is_active = true,
        unit_ids = [],      // array of unit IDs
        device_ids = []     // array of device IDs
      } = req.body;

      // Validate value_type/category exists
      const [catRow] = await pool.execute(
        `SELECT value_type_id FROM value_type_master WHERE value_type_id = ?`,
        [category]
      );
      if (catRow.length === 0) {
        return errorResponse(res, 'Invalid category (value type)', 400);
      }

      // Validate all units exist
      if (unit_ids.length > 0) {
        const [unitRows] = await pool.query(
          `SELECT unit_id FROM unit_master WHERE unit_id IN (?)`,
          [unit_ids]
        );
        if (unitRows.length !== unit_ids.length) {
          return errorResponse(res, 'One or more unit IDs are invalid', 400);
        }
      }

      // Validate all devices exist
      if (device_ids.length > 0) {
        const [deviceRows] = await pool.query(
          `SELECT device_id FROM device_master WHERE device_id IN (?)`,
          [device_ids]
        );
        if (deviceRows.length !== device_ids.length) {
          return errorResponse(res, 'One or more device IDs are invalid', 400);
        }
      }

      // Insert into sensor_master
      const insertSensorSql = `
      INSERT INTO sensor_master (
        sensor_type_name,
        category,
        name,
        description,
        value_format,
        min_expected_value,
        max_expected_value,
        sampling_frequency,
        time_interval,
        is_active,
        created_at,
        created_by
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

      const created_at = toMySQLDatetime();

      const [result] = await pool.execute(insertSensorSql, [
        sensor_type_name,
        category,
        name,
        description || null,
        value_format,
        min_expected_value || null,
        max_expected_value || null,
        sampling_frequency,
        time_interval,
        is_active,
        created_at,
        created_by
      ]);

      const sensor_id = result.insertId;

      // Map units (sensor_mapping)
      if (unit_ids.length > 0) {
        const unitInsertSql = `
        INSERT INTO sensor_unit_mapping (sensor_id, unit_id) VALUES ?
      `;
        const unitValues = unit_ids.map((unit_id) => [sensor_id, unit_id]);
        await pool.query(unitInsertSql, [unitValues]);
      }

      // Map devices (sensor_device_mapping)
      if (device_ids.length > 0) {
        const deviceInsertSql = `
        INSERT INTO sensor_device_mapping (sensor_id, device_id) VALUES ?
      `;
        const deviceValues = device_ids.map((device_id) => [sensor_id, device_id]);
        await pool.query(deviceInsertSql, [deviceValues]);
      }

      return successResponse(
        res,
        'Sensor created successfully',
        {
          sensor_type_id: sensor_id,
          sensor_type_name,
          name,
          category,
          unit_ids,
          device_ids,
          sampling_frequency,
          value_format,
          created_at,
          created_by
        },
        201
      );
    } catch (error) {
      next(error);
    }
  },

  // Get all categories from value_type_master
  async getAllCategories(req, res, next) {
    try {
      const categories = await sensorModel.getAllCategories();
      return successResponse(res, 'Categories retrieved successfully', categories);
    } catch (error) {
      next(error);
    }
  },

  // Get units by category
  async getUnitsByCategory(req, res, next) {
    try {
      const { categoryId } = req.params;

      // Validate categoryId
      if (!categoryId || isNaN(categoryId)) {
        return errorResponse(res, 'Invalid category ID', 400);
      }

      const units = await sensorModel.getUnitsByCategory(parseInt(categoryId));
      return successResponse(res, 'Units retrieved successfully', units);
    } catch (error) {
      next(error);
    }
  },

  // Validate device exists if being updated
  async validateDevice(deviceId) {
    if (deviceId) {
      const device = await deviceModel.getById(deviceId);
      if (!device) {
        throw new Error('Device not found');
      }
    }
    return true;
  },

  // Validate serial number uniqueness
  async validateSerialNumber(serialNumber, sensorId, existingSerial) {
    if (serialNumber && serialNumber !== existingSerial) {
      const serialExists = await sensorModel.serialNumberExists(serialNumber, sensorId);
      if (serialExists) {
        throw new Error('A sensor with this serial number already exists');
      }
    }
    return true;
  },

  async updateSensor(req, res, next) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const sensor_type_id = req.params.id;
      const updated_by = req.user.user_id;

      const {
        sensor_type_name,
        category,
        name,
        description,
        value_format,
        min_expected_value,
        max_expected_value,
        sampling_frequency,
        time_interval,
        is_active = true,
        unit_ids = [],
        device_ids = []
      } = req.body;

      // ✅ Check if sensor exists
      const [existingRows] = await pool.query(
        `SELECT * FROM sensor_master WHERE sensor_type_id = ?`,
        [sensor_type_id]
      );
      if (existingRows.length === 0) {
        return errorResponse(res, 'Sensor not found', 404);
      }

      // ✅ Validate category
      const [catRow] = await pool.query(
        `SELECT value_type_id FROM value_type_master WHERE value_type_id = ?`,
        [category]
      );
      if (catRow.length === 0) {
        return errorResponse(res, 'Invalid category (value type)', 400);
      }

      // ✅ Validate all unit_ids
      if (unit_ids.length > 0) {
        const [unitRows] = await pool.query(
          `SELECT unit_id FROM unit_master WHERE unit_id IN (?)`,
          [unit_ids]
        );
        if (unitRows.length !== unit_ids.length) {
          return errorResponse(res, 'One or more unit IDs are invalid', 400);
        }
      }

      // ✅ Validate all device_ids
      if (device_ids.length > 0) {
        const [deviceRows] = await pool.query(
          `SELECT device_id FROM device_master WHERE device_id IN (?)`,
          [device_ids]
        );
        if (deviceRows.length !== device_ids.length) {
          return errorResponse(res, 'One or more device IDs are invalid', 400);
        }
      }

      // ✅ Update sensor_master
      const updateSensorSql = `
        UPDATE sensor_master SET
          sensor_type_name = ?,
          category = ?,
          name = ?,
          description = ?,
          value_format = ?,
          min_expected_value = ?,
          max_expected_value = ?,
          sampling_frequency = ?,
          time_interval = ?,
          is_active = ?,
          updated_at = ?,
          updated_by = ?
        WHERE sensor_type_id = ?
      `;

      const updated_at = toMySQLDatetime();
      await pool.execute(updateSensorSql, [
        sensor_type_name,
        category,
        name,
        description || null,
        value_format,
        min_expected_value || null,
        max_expected_value || null,
        sampling_frequency,
        time_interval,
        is_active,
        updated_at,
        updated_by,
        sensor_type_id
      ]);

      // ✅ Replace unit mappings
      await pool.query(`DELETE FROM sensor_unit_mapping WHERE sensor_id = ?`, [sensor_type_id]);
      if (unit_ids.length > 0) {
        const unitValues = unit_ids.map(unit_id => [sensor_type_id, unit_id]);
        await pool.query(`INSERT INTO sensor_unit_mapping (sensor_id, unit_id) VALUES ?`, [unitValues]);
      }

      // ✅ Replace device mappings
      await pool.query(`DELETE FROM sensor_device_mapping WHERE sensor_id = ?`, [sensor_type_id]);
      if (device_ids.length > 0) {
        const deviceValues = device_ids.map(device_id => [sensor_type_id, device_id]);
        await pool.query(`INSERT INTO sensor_device_mapping (sensor_id, device_id) VALUES ?`, [deviceValues]);
      }

      return successResponse(res, 'Sensor updated successfully', {
        sensor_type_id,
        sensor_type_name,
        category,
        name,
        description,
        value_format,
        min_expected_value,
        max_expected_value,
        sampling_frequency,
        time_interval,
        is_active,
        updated_by,
        unit_ids,
        device_ids
      });
    } catch (error) {
      next(error);
    }
  },


  // Delete a sensor
  async deleteSensor(req, res, next) {
    try {
      const { id } = req.params;

      // Check if sensor exists
      const sensor = await sensorModel.getById(id);
      if (!sensor) {
        return errorResponse(res, 'Sensor not found', 404);
      }

      // Delete sensor and mappings
      const deleted = await sensorModel.deleteSensorById(id);

      if (deleted) {
        return successResponse(res, 'Sensor deleted successfully', null, 200);
      } else {
        return errorResponse(res, 'Failed to delete sensor', 500);
      }

    } catch (error) {
      console.error('Delete Sensor Error:', error);
      next(error);
    }
  },


  // Add a reading to a sensor
  async addReading(req, res, next) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { id } = req.params;
      const {
        value,
        unit,
        reading_time,
        error_code,
        error_message,
        latitude,
        longitude,
        battery_level,
        signal_strength,
        raw_data
      } = req.body;

      // Check if sensor exists
      const sensor = await sensorModel.getById(id);
      if (!sensor) {
        return errorResponse(res, 'Sensor not found', 404);
      }

      // Validate value against min/max if defined
      if (sensor.min_value !== null && value < sensor.min_value) {
        return errorResponse(
          res,
          `Value (${value}) is below the minimum allowed value (${sensor.min_value})`,
          400
        );
      }

      if (sensor.max_value !== null && value > sensor.max_value) {
        return errorResponse(
          res,
          `Value (${value}) is above the maximum allowed value (${sensor.max_value})`,
          400
        );
      }

      // Add the reading
      const readingId = await sensorModel.addReading(id, {
        value,
        unit: unit || sensor.unit,
        reading_time,
        error_code,
        error_message,
        latitude,
        longitude,
        battery_level,
        signal_strength,
        raw_data
      });

      // Check for threshold alerts
      await checkForAlerts(id, value, req.user);

      return successResponse(
        res,
        'Reading added successfully',
        { id: readingId },
        201
      );
    } catch (error) {
      next(error);
    }
  },

  // Get readings for a sensor
  async getReadings(req, res, next) {
    try {
      const { id } = req.params;
      const {
        start_date,
        end_date = new Date().toISOString(),
        limit = 100
      } = req.query;

      // Check if sensor exists
      const sensor = await sensorModel.getById(id);
      if (!sensor) {
        return errorResponse(res, 'Sensor not found', 404);
      }

      // If no start_date provided, default to last 24 hours
      const startDate = start_date || new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();

      let query = 'SELECT * FROM sensor_readings WHERE sensor_id = ? AND reading_time BETWEEN ? AND ?';
      const params = [id, startDate, end_date];

      // Add limit if provided
      if (limit) {
        query += ' ORDER BY reading_time DESC LIMIT ?';
        params.push(parseInt(limit));
      }

      const [readings] = await sensorModel.pool.query(query, params);

      return successResponse(res, 'Readings retrieved successfully', {
        sensor_id: id,
        count: readings.length,
        start_date: startDate,
        end_date: end_date,
        readings
      });
    } catch (error) {
      next(error);
    }
  },

  // Get statistics for a sensor
  async getStatistics(req, res, next) {
    try {
      const { id } = req.params;
      const {
        start_date = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString(),
        end_date = new Date().toISOString()
      } = req.query;

      // Check if sensor exists
      const sensor = await sensorModel.getById(id);
      if (!sensor) {
        return errorResponse(res, 'Sensor not found', 404);
      }

      const stats = await sensorModel.getStatistics(id, start_date, end_date);

      return successResponse(res, 'Statistics retrieved successfully', {
        sensor_id: id,
        start_date,
        end_date,
        statistics: stats || {}
      });
    } catch (error) {
      next(error);
    }
  },

  // Get alerts for a sensor
  async getAlerts(req, res, next) {
    try {
      const { id } = req.params;
      const {
        resolved,
        start_date,
        end_date = new Date().toISOString(),
        limit = 50
      } = req.query;

      // Check if sensor exists
      const sensor = await sensorModel.getById(id);
      if (!sensor) {
        return errorResponse(res, 'Sensor not found', 404);
      }

      let query = 'SELECT * FROM sensor_alerts WHERE sensor_id = ?';
      const params = [id];

      // Add filters
      if (resolved !== undefined) {
        query += ' AND resolved = ?';
        params.push(resolved === 'true');
      }

      if (start_date) {
        query += ' AND created_at BETWEEN ? AND ?';
        params.push(start_date, end_date);
      }

      // Add limit and order
      query += ' ORDER BY created_at DESC LIMIT ?';
      params.push(parseInt(limit));

      const [alerts] = await sensorModel.pool.query(query, params);

      return successResponse(res, 'Alerts retrieved successfully', {
        sensor_id: id,
        count: alerts.length,
        alerts
      });
    } catch (error) {
      next(error);
    }
  },

  // Create an alert for a sensor
  async createAlert(req, res, next) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { id } = req.params;
      const {
        alert_type,
        threshold_value,
        actual_value,
        message,
        severity = 'WARNING',
        resolved = false,
        resolved_notes = null
      } = req.body;

      // Check if sensor exists
      const sensor = await sensorModel.getById(id);
      if (!sensor) {
        return errorResponse(res, 'Sensor not found', 404);
      }

      const alert = await sensorModel.createAlert(id, {
        alert_type,
        threshold_value,
        actual_value,
        message,
        severity,
        resolved,
        resolved_by: resolved ? req.user.id : null,
        resolved_at: resolved ? new Date() : null,
        resolved_notes: resolved ? resolved_notes : null
      });

      return successResponse(
        res,
        'Alert created successfully',
        { id: alert },
        201
      );
    } catch (error) {
      next(error);
    }
  },

  // Update an alert
  async updateAlert(req, res, next) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { id, alertId } = req.params;
      const {
        resolved,
        resolved_notes
      } = req.body;

      // Check if sensor exists
      const sensor = await sensorModel.getById(id);
      if (!sensor) {
        return errorResponse(res, 'Sensor not found', 404);
      }

      // Check if alert exists
      const [alerts] = await sensorModel.pool.query(
        'SELECT * FROM sensor_alerts WHERE id = ? AND sensor_id = ?',
        [alertId, id]
      );

      if (alerts.length === 0) {
        return errorResponse(res, 'Alert not found', 404);
      }

      const alert = alerts[0];

      // Only allow updating resolved status and notes
      const updateData = {
        resolved: resolved !== undefined ? resolved : alert.resolved,
        resolved_by: resolved ? req.user.id : alert.resolved_by,
        resolved_at: resolved ? new Date() : alert.resolved_at,
        resolved_notes: resolved_notes !== undefined ? resolved_notes : alert.resolved_notes
      };

      await sensorModel.pool.query(
        'UPDATE sensor_alerts SET resolved = ?, resolved_by = ?, resolved_at = ?, resolved_notes = ? WHERE id = ?',
        [
          updateData.resolved,
          updateData.resolved_by,
          updateData.resolved_at,
          updateData.resolved_notes,
          alertId
        ]
      );

      return successResponse(res, 'Alert updated successfully', { id: alertId });
    } catch (error) {
      next(error);
    }
  },

  async getWaterSensorsForCoach(req, res, next) {
    try {
      const { coach_id } = req.query;
      const sensors = await sensorModel.getWaterSensorsForCoach({ coach_id });
      return successResponse(res, 'Sensors fetched successfully', sensors);
    } catch (error) {
      console.error('Error fetching sensors for coach:', error);
      return errorResponse(res, 'Failed to fetch sensors', 500);
    }
  }
};

// Helper function to check for threshold alerts
async function checkForAlerts(sensorId, value, user) {
  try {
    const sensor = await sensorModel.getById(sensorId);
    if (!sensor) return;

    let alertType = null;
    let message = '';
    let severity = 'WARNING';
    let thresholdValue = null;

    // Check critical threshold
    if (sensor.critical_threshold !== null && value >= sensor.critical_threshold) {
      alertType = 'CRITICAL_THRESHOLD';
      message = `Sensor value (${value}${sensor.unit || ''}) exceeded critical threshold (${sensor.critical_threshold}${sensor.unit || ''})`;
      severity = 'CRITICAL';
      thresholdValue = sensor.critical_threshold;
    }
    // Check warning threshold (only if not already in critical)
    else if (sensor.warning_threshold !== null && value >= sensor.warning_threshold) {
      alertType = 'WARNING_THRESHOLD';
      message = `Sensor value (${value}${sensor.unit || ''}) exceeded warning threshold (${sensor.warning_threshold}${sensor.unit || ''})`;
      thresholdValue = sensor.warning_threshold;
    }

    // Create alert if threshold exceeded
    if (alertType) {
      await sensorModel.createAlert(sensorId, {
        alert_type: alertType,
        threshold_value: thresholdValue,
        actual_value: value,
        message,
        severity,
        resolved: false
      });

      // Here you could also trigger notifications (email, SMS, etc.)
      // notifyUsers(sensor, alertType, message, user);
    }
  } catch (error) {
    console.error('Error checking for alerts:', error);
  }
}

module.exports = sensorController;
