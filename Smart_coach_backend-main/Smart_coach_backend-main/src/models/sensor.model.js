const BaseModel = require('./base.model');
const supabaseAdmin = require('../config/supabaseAdmin');

class SensorModel extends BaseModel {
  constructor() {
    super('sensor_master');
  }

  async getAll(filters = {}) {
    let query = supabaseAdmin
      .from('sensor_master')
      .select('*');

    if (filters.sensor_type) {
      query = query.eq('sensor_type', filters.sensor_type);
    }

    if (filters.status) {
      query = query.eq('status', filters.status);
    }

    if (filters.search) {
      const term = `%${filters.search}%`;
      query = query.or(`name.ilike.${term},sensor_type_name.ilike.${term},value_type.ilike.${term}`);
    }

    query = query.order('sensor_type_id', { ascending: false });

    const { data: sensorRows, error } = await query;
    if (error) throw error;
    if (!sensorRows || sensorRows.length === 0) return [];

    const sensorIds = sensorRows.map(s => s.sensor_type_id);

    const categoryIds = [...new Set(sensorRows.filter(s => s.category).map(s => s.category))];
    const userIds = [...new Set(sensorRows.flatMap(s => [s.created_by, s.updated_by].filter(Boolean)))];

    let catMap = {};
    if (categoryIds.length > 0) {
      const { data: cats } = await supabaseAdmin.from('value_type_master').select('value_type_id, name').in('value_type_id', categoryIds);
      for (const c of cats || []) catMap[c.value_type_id] = c;
    }

    let userMap = {};
    if (userIds.length > 0) {
      const { data: users } = await supabaseAdmin.from('user_master').select('user_id, first_name').in('user_id', userIds);
      for (const u of users || []) userMap[u.user_id] = u;
    }

    const { data: unitRows } = await supabaseAdmin
      .from('sensor_unit_mapping')
      .select('sensor_id, unit_id, unit_master!unit_id(unit_id, unit)')
      .in('sensor_id', sensorIds);

    const { data: deviceRows } = await supabaseAdmin
      .from('sensor_device_mapping')
      .select('sensor_id, device_id, device_master!device_id(device_id, short_name, full_name)')
      .in('sensor_id', sensorIds);

    const unitMap = {};
    for (const row of unitRows || []) {
      if (!unitMap[row.sensor_id]) unitMap[row.sensor_id] = [];
      unitMap[row.sensor_id].push({
        unit_id: row.unit_master.unit_id,
        unit: row.unit_master.unit
      });
    }

    const deviceMap = {};
    for (const row of deviceRows || []) {
      if (!deviceMap[row.sensor_id]) deviceMap[row.sensor_id] = [];
      deviceMap[row.sensor_id].push({
        device_id: row.device_master.device_id,
        short_name: row.device_master.short_name,
        full_name: row.device_master.full_name
      });
    }

    return sensorRows.map(sensor => ({
      sensor_type_id: sensor.sensor_type_id,
      sensor_type_name: sensor.sensor_type_name,
      category: {
        id: sensor.category,
        name: sensor.category ? (catMap[sensor.category] ? catMap[sensor.category].name : null) : null
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
      created_by: sensor.created_by ? (userMap[sensor.created_by] ? userMap[sensor.created_by].first_name : null) : null,
      updated_by: sensor.updated_by ? (userMap[sensor.updated_by] ? userMap[sensor.updated_by].first_name : null) : null,
      units: unitMap[sensor.sensor_type_id] || [],
      devices: deviceMap[sensor.sensor_type_id] || []
    }));
  }

  async deleteSensorById(sensorId) {
    const { error: delUnitError } = await supabaseAdmin
      .from('sensor_unit_mapping')
      .delete()
      .eq('sensor_id', sensorId);
    if (delUnitError) throw delUnitError;

    const { error: delDevError } = await supabaseAdmin
      .from('sensor_device_mapping')
      .delete()
      .eq('sensor_id', sensorId);
    if (delDevError) throw delDevError;

    const { data, error } = await supabaseAdmin
      .from('sensor_master')
      .delete()
      .eq('sensor_type_id', sensorId)
      .select();

    if (error) throw error;
    return data && data.length > 0;
  }

  async getById(sensorId) {
    const { data, error } = await supabaseAdmin
      .from('sensor_master')
      .select('*')
      .eq('sensor_type_id', sensorId)
      .maybeSingle();
    if (error) throw error;
    return data;
  }

  async getAllCategories() {
    const { data, error } = await supabaseAdmin
      .from('value_type_master')
      .select('value_type_id, name, base_unit')
      .order('name');
    if (error) throw error;
    return data || [];
  }

  async getUnitsByCategory(categoryId) {
    const { data, error } = await supabaseAdmin
      .from('unit_master')
      .select(`
        unit_id, unit, is_base_unit
      `)
      .eq('value_type_id', categoryId)
      .order('unit');
    if (error) throw error;
    return data || [];
  }

  async serialNumberExists(serialNumber, excludeId = null) {
    let query = supabaseAdmin.from('sensors').select('id').eq('serial_number', serialNumber);
    if (excludeId) {
      query = query.neq('id', excludeId);
    }
    const { data, error } = await query;
    if (error) throw error;
    return (data || []).length > 0;
  }

  async getReadings(sensorId, limit = 100) {
    const { data, error } = await supabaseAdmin
      .from('sensor_readings')
      .select('*')
      .eq('sensor_id', sensorId)
      .order('reading_time', { ascending: false })
      .limit(parseInt(limit));
    if (error) throw error;
    return data || [];
  }

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

    const { data: sensorData } = await supabaseAdmin
      .from('sensors')
      .select('device_id')
      .eq('id', sensorId)
      .maybeSingle();

    const device_id = sensorData ? sensorData.device_id : null;

    const { data: result, error } = await supabaseAdmin
      .from('sensor_readings')
      .insert([{
        sensor_id: sensorId,
        device_id: device_id,
        value: value,
        unit: unit,
        reading_time: reading_time,
        error_code: error_code,
        error_message: error_message,
        latitude: latitude,
        longitude: longitude,
        battery_level: battery_level,
        signal_strength: signal_strength,
        raw_data: raw_data,
        created_at: new Date().toISOString()
      }])
      .select();

    if (error) throw error;

    await supabaseAdmin
      .from('sensors')
      .update({ last_reading_time: reading_time })
      .eq('id', sensorId);

    return result[0].id;
  }

  async getStatistics(sensorId, startDate, endDate) {
    const { data: readings, error } = await supabaseAdmin
      .from('sensor_readings')
      .select('value, reading_time')
      .eq('sensor_id', sensorId)
      .gte('reading_time', startDate)
      .lte('reading_time', endDate);

    if (error) throw error;
    if (!readings || readings.length === 0) return null;

    const values = readings.map(r => parseFloat(r.value)).filter(v => !isNaN(v));
    const times = readings.map(r => new Date(r.reading_time).getTime());

    return {
      min_value: Math.min(...values),
      max_value: Math.max(...values),
      avg_value: values.reduce((a, b) => a + b, 0) / values.length,
      reading_count: readings.length,
      first_reading: new Date(Math.min(...times)).toISOString(),
      last_reading: new Date(Math.max(...times)).toISOString()
    };
  }

  async getAlerts(sensorId, limit = 10) {
    const { data, error } = await supabaseAdmin
      .from('sensor_alerts')
      .select('*')
      .eq('sensor_id', sensorId)
      .order('created_at', { ascending: false })
      .limit(limit);
    if (error) throw error;
    return data || [];
  }

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

    const { data: sensorData } = await supabaseAdmin
      .from('sensors')
      .select('device_id')
      .eq('id', sensorId)
      .maybeSingle();

    const device_id = sensorData ? sensorData.device_id : null;

    const { data: result, error } = await supabaseAdmin
      .from('sensor_alerts')
      .insert([{
        sensor_id: sensorId,
        device_id: device_id,
        alert_type: alert_type,
        threshold_value: threshold_value,
        actual_value: actual_value,
        message: message,
        severity: severity,
        resolved: resolved,
        resolved_at: resolved_at,
        resolved_by: resolved_by,
        resolved_notes: resolved_notes
      }])
      .select();

    if (error) throw error;
    return result[0].id;
  }

  async getWaterSensorsForCoach(filters = {}) {
    const { coach_id } = filters;

    const { data, error } = await supabaseAdmin
      .from('sensor_config')
      .select('sensor_config_id, sensor_id, sensor_type_id')
      .eq('coach_id', coach_id)
      .eq('sensor_type_id', 5);
    if (error) throw error;
    return data || [];
  }
}

module.exports = new SensorModel();
