const BaseModel = require('./base.model');
const supabaseAdmin = require('../config/supabaseAdmin');

class DeviceModel extends BaseModel {
  constructor() {
    super('device_master');
  }

  async getAll(filters = {}, page = 1, limit = 10) {
    const offset = (page - 1) * limit;
    let query = supabaseAdmin
      .from('devices')
      .select('*', { count: 'exact' });

    if (filters.master_module_id) {
      query = query.eq('master_module_id', filters.master_module_id);
    }

    if (filters.device_type_id) {
      query = query.eq('device_type_id', filters.device_type_id);
    }

    if (filters.status) {
      query = query.eq('status', filters.status);
    }

    if (filters.search) {
      const term = `%${filters.search}%`;
      query = query.or(`name.ilike.${term},serial_number.ilike.${term},mac_address.ilike.${term}`);
    }

    query = query.order('name').range(offset, offset + limit - 1);

    const { data: devices, error } = await query;
    if (error) throw error;
    if (!devices || devices.length === 0) return [];

    const mmIds = [...new Set(devices.filter(d => d.master_module_id).map(d => d.master_module_id))];
    let mmMap = {};
    if (mmIds.length > 0) {
      const { data: mmData } = await supabaseAdmin
        .from('master_modules')
        .select(`
          *,
          coach:coach_id(
            coach_number,
            train:train_id(number, name)
          )
        `)
        .in('id', mmIds);
      for (const mm of mmData || []) {
        mmMap[mm.id] = mm;
      }
    }

    const dtIds = [...new Set(devices.filter(d => d.device_type_id).map(d => d.device_type_id))];
    let dtMap = {};
    if (dtIds.length > 0) {
      const { data: dtData } = await supabaseAdmin
        .from('device_types')
        .select('*')
        .in('id', dtIds);
      for (const dt of dtData || []) {
        dtMap[dt.id] = dt;
      }
    }

    return devices.map(d => {
      const mm = d.master_module_id ? mmMap[d.master_module_id] : null;
      const coach = mm ? mm.coach : null;
      const train = coach ? coach.train : null;
      const dt = d.device_type_id ? dtMap[d.device_type_id] : null;
      return {
        ...d,
        master_module_name: mm ? mm.name : null,
        master_module_serial: mm ? mm.serial_number : null,
        master_module: undefined,
        coach_number: coach ? coach.coach_number : null,
        train_number: train ? train.number : null,
        train_name: train ? train.name : null,
        device_type_name: dt ? dt.name : null,
        device_model: dt ? dt.model : null
      };
    });
  }

  async getById(id) {
    const { data, error } = await supabaseAdmin
      .from('device_master')
      .select('*')
      .eq('device_id', id)
      .maybeSingle();
    if (error) throw error;
    return data;
  }

  async getByMasterModuleId(master_module_id) {
    const { data: devices, error } = await supabaseAdmin
      .from('device_master')
      .select('*')
      .eq('master_module_id', master_module_id);
    if (error) throw error;
    if (!devices || devices.length === 0) return [];

    const mmIds = [...new Set(devices.filter(d => d.master_module_id).map(d => d.master_module_id))];
    let mmMap = {};
    if (mmIds.length > 0) {
      const { data: mmData } = await supabaseAdmin
        .from('master_module')
        .select(`
          *,
          coach:coach_id(
            coach_unique_id,
            train:train_id(train_number, train_name)
          )
        `)
        .in('module_id', mmIds);
      for (const mm of mmData || []) {
        mmMap[mm.module_id] = mm;
      }
    }

    const userIds = [...new Set(devices.filter(d => d.created_by || d.updated_by).flatMap(d => [d.created_by, d.updated_by].filter(Boolean)))];
    let userMap = {};
    if (userIds.length > 0) {
      const { data: userData } = await supabaseAdmin
        .from('user_master')
        .select('user_id, first_name')
        .in('user_id', userIds);
      for (const u of userData || []) {
        userMap[u.user_id] = u;
      }
    }

    return devices.map(d => {
      const mm = d.master_module_id ? mmMap[d.master_module_id] : null;
      const coach = mm ? mm.coach : null;
      const train = coach ? coach.train : null;
      return {
        ...d,
        master_module_serial: mm ? mm.seriel_number : null,
        coach_unique_id: coach ? coach.coach_unique_id : null,
        train_number: train ? train.train_number : null,
        train_name: train ? train.train_name : null,
        full_name: d.full_name || null,
        short_name: d.short_name || null,
        created_by: d.created_by || null,
        created_by_name: d.created_by ? (userMap[d.created_by] ? userMap[d.created_by].first_name : null) : null,
        updated_by: d.updated_by || null,
        updated_by_name: d.updated_by ? (userMap[d.updated_by] ? userMap[d.updated_by].first_name : null) : null
      };
    });
  }

  async serialNumberExists(serialNumber, excludeId = null) {
    let query = supabaseAdmin.from('devices').select('id').eq('serial_number', serialNumber);
    if (excludeId) {
      query = query.neq('id', excludeId);
    }
    const { data, error } = await query;
    if (error) throw error;
    return (data || []).length > 0;
  }

  async macAddressExists(macAddress, excludeId = null) {
    if (!macAddress) return false;

    let query = supabaseAdmin.from('devices').select('id').eq('mac_address', macAddress);
    if (excludeId) {
      query = query.neq('id', excludeId);
    }
    const { data, error } = await query;
    if (error) throw error;
    return (data || []).length > 0;
  }

  async getSensors(deviceId) {
    const { data, error } = await supabaseAdmin
      .from('sensors')
      .select('*')
      .eq('device_id', deviceId)
      .order('name');
    if (error) throw error;
    return data || [];
  }

  async getLatestReadings(deviceId, limit = 10) {
    const { data: sensors, error: sensError } = await supabaseAdmin
      .from('sensors')
      .select('id, name')
      .eq('device_id', deviceId)
      .order('name')
      .limit(limit);
    if (sensError) throw sensError;
    if (!sensors || sensors.length === 0) return [];

    const sensorIds = sensors.map(s => s.id);

    const { data: readings, error: readError } = await supabaseAdmin
      .from('sensor_readings')
      .select('*')
      .in('sensor_id', sensorIds)
      .eq('device_id', deviceId)
      .order('reading_time', { ascending: false });
    if (readError) throw readError;

    const latestBySensor = {};
    for (const r of readings || []) {
      if (!latestBySensor[r.sensor_id]) {
        latestBySensor[r.sensor_id] = r;
      }
    }

    return sensors.map(s => ({
      sensor_id: s.id,
      sensor_name: s.name,
      ...latestBySensor[s.id] || {}
    }));
  }

  async delete(id) {
    const { error } = await supabaseAdmin
      .from('device_master')
      .delete()
      .eq('device_id', id);
    if (error) throw error;
    return { status: true, message: 'Device deleted successfully' };
  }
}

module.exports = new DeviceModel();
