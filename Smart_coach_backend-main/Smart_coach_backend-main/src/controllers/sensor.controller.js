const { validationResult } = require('express-validator');
const { successResponse, errorResponse } = require('../utils/response');
const sensorModel = require('../models/sensor.model');
const deviceModel = require('../models/device.model');
const supabaseAdmin = require('../config/supabaseAdmin');
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
      // Enrich each sensor with human‑readable status and device name (if a single device linked)
      const enriched = await Promise.all(sensors.map(async (s) => {
        const status = s.is_active ? 'Online' : 'Offline';
        let deviceName = null;
        if (s.device_ids && s.device_ids.length === 1) {
          const dev = await deviceModel.getById(s.device_ids[0]);
          deviceName = dev ? dev.device_name || dev.device_id : null;
        }
        return { ...s, status, deviceName };
      }));
      return successResponse(res, 'Sensors retrieved successfully', enriched);
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
      const { data: catRow, error: catErr } = await supabaseAdmin
        .from('value_type_master')
        .select('value_type_id')
        .eq('value_type_id', category)
        .limit(1);

      if (catErr) throw catErr;
      if (!catRow || catRow.length === 0) {
        return errorResponse(res, 'Invalid category (value type)', 400);
      }

      // Validate all units exist
      if (unit_ids.length > 0) {
        const { data: unitRows, error: unitErr } = await supabaseAdmin
          .from('unit_master')
          .select('unit_id')
          .in('unit_id', unit_ids);

        if (unitErr) throw unitErr;
        if (!unitRows || unitRows.length !== unit_ids.length) {
          return errorResponse(res, 'One or more unit IDs are invalid', 400);
        }
      }

      // Validate all devices exist
      if (device_ids.length > 0) {
        const { data: deviceRows, error: devErr } = await supabaseAdmin
          .from('device_master')
          .select('device_id')
          .in('device_id', device_ids);

        if (devErr) throw devErr;
        if (!deviceRows || deviceRows.length !== device_ids.length) {
          return errorResponse(res, 'One or more device IDs are invalid', 400);
        }
      }

      // Insert into sensor_master
      const created_at = toMySQLDatetime();

      const { data: result, error: insertErr } = await supabaseAdmin
        .from('sensor_master')
        .insert([{
          sensor_type_name,
          category,
          name,
          description: description || null,
          value_format,
          min_expected_value: min_expected_value || null,
          max_expected_value: max_expected_value || null,
          sampling_frequency,
          time_interval,
          is_active,
          created_at,
          created_by
        }])
        .select();

      if (insertErr) throw insertErr;

      const sensor_id = result[0].sensor_type_id;

      // Map units (sensor_mapping)
      if (unit_ids.length > 0) {
        const unitValues = unit_ids.map((unit_id) => ({ sensor_id, unit_id }));
        const { error: mapUnitErr } = await supabaseAdmin
          .from('sensor_unit_mapping')
          .insert(unitValues);

        if (mapUnitErr) throw mapUnitErr;
      }

      // Map devices (sensor_device_mapping)
      if (device_ids.length > 0) {
        const deviceValues = device_ids.map((device_id) => ({ sensor_id, device_id }));
        const { error: mapDevErr } = await supabaseAdmin
          .from('sensor_device_mapping')
          .insert(deviceValues);

        if (mapDevErr) throw mapDevErr;
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
      const { data: existingRows, error: existErr } = await supabaseAdmin
        .from('sensor_master')
        .select('*')
        .eq('sensor_type_id', sensor_type_id);

      if (existErr) throw existErr;
      if (!existingRows || existingRows.length === 0) {
        return errorResponse(res, 'Sensor not found', 404);
      }

      // ✅ Validate category
      const { data: catRow, error: catErr } = await supabaseAdmin
        .from('value_type_master')
        .select('value_type_id')
        .eq('value_type_id', category)
        .limit(1);

      if (catErr) throw catErr;
      if (!catRow || catRow.length === 0) {
        return errorResponse(res, 'Invalid category (value type)', 400);
      }

      // ✅ Validate all unit_ids
      if (unit_ids.length > 0) {
        const { data: unitRows, error: unitErr } = await supabaseAdmin
          .from('unit_master')
          .select('unit_id')
          .in('unit_id', unit_ids);

        if (unitErr) throw unitErr;
        if (!unitRows || unitRows.length !== unit_ids.length) {
          return errorResponse(res, 'One or more unit IDs are invalid', 400);
        }
      }

      // ✅ Validate all device_ids
      if (device_ids.length > 0) {
        const { data: deviceRows, error: devErr } = await supabaseAdmin
          .from('device_master')
          .select('device_id')
          .in('device_id', device_ids);

        if (devErr) throw devErr;
        if (!deviceRows || deviceRows.length !== device_ids.length) {
          return errorResponse(res, 'One or more device IDs are invalid', 400);
        }
      }

      // ✅ Update sensor_master
      const updated_at = toMySQLDatetime();

      const { error: updateErr } = await supabaseAdmin
        .from('sensor_master')
        .update({
          sensor_type_name,
          category,
          name,
          description: description || null,
          value_format,
          min_expected_value: min_expected_value || null,
          max_expected_value: max_expected_value || null,
          sampling_frequency,
          time_interval,
          is_active,
          updated_at,
          updated_by
        })
        .eq('sensor_type_id', sensor_type_id);

      if (updateErr) throw updateErr;

      // ✅ Replace unit mappings
      const { error: delUnitErr } = await supabaseAdmin
        .from('sensor_unit_mapping')
        .delete()
        .eq('sensor_id', sensor_type_id);

      if (delUnitErr) throw delUnitErr;

      if (unit_ids.length > 0) {
        const unitValues = unit_ids.map(unit_id => ({ sensor_id: sensor_type_id, unit_id }));
        const { error: insUnitErr } = await supabaseAdmin
          .from('sensor_unit_mapping')
          .insert(unitValues);

        if (insUnitErr) throw insUnitErr;
      }

      // ✅ Replace device mappings
      const { error: delDevErr } = await supabaseAdmin
        .from('sensor_device_mapping')
        .delete()
        .eq('sensor_id', sensor_type_id);

      if (delDevErr) throw delDevErr;

      if (device_ids.length > 0) {
        const deviceValues = device_ids.map(device_id => ({ sensor_id: sensor_type_id, device_id }));
        const { error: insDevErr } = await supabaseAdmin
          .from('sensor_device_mapping')
          .insert(deviceValues);

        if (insDevErr) throw insDevErr;
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

      let dbQuery = supabaseAdmin
        .from('sensor_readings')
        .select('*')
        .eq('sensor_id', id)
        .gte('reading_time', startDate)
        .lte('reading_time', end_date)
        .order('reading_time', { ascending: false });

      if (limit) {
        dbQuery = dbQuery.limit(parseInt(limit));
      }

      const { data: readings, error } = await dbQuery;
      if (error) throw error;

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

      let dbQuery = supabaseAdmin
        .from('sensor_alerts')
        .select('*')
        .eq('sensor_id', id)
        .order('created_at', { ascending: false })
        .limit(parseInt(limit));

      if (resolved !== undefined) {
        dbQuery = dbQuery.eq('resolved', resolved === 'true');
      }

      if (start_date) {
        dbQuery = dbQuery.gte('created_at', start_date).lte('created_at', end_date);
      }

      const { data: alerts, error } = await dbQuery;
      if (error) throw error;

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
      const { data: alerts, error: alertErr } = await supabaseAdmin
        .from('sensor_alerts')
        .select('*')
        .eq('id', alertId)
        .eq('sensor_id', id);

      if (alertErr) throw alertErr;

      if (!alerts || alerts.length === 0) {
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

      const { error: updErr } = await supabaseAdmin
        .from('sensor_alerts')
        .update({
          resolved: updateData.resolved,
          resolved_by: updateData.resolved_by,
          resolved_at: updateData.resolved_at,
          resolved_notes: updateData.resolved_notes
        })
        .eq('id', alertId);

      if (updErr) throw updErr;

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
