const supabaseAdmin = require('../config/supabaseAdmin');
const BaseModel = require('./base.model');

class MasterModuleModel extends BaseModel {
  constructor() {
    super('master_module');
  }

  async createWithDevices(data, deviceIds) {
    const { data: coachRows } = await supabaseAdmin
      .from('coach_master')
      .select('no_of_master_module')
      .eq('coach_id', data.coach_id);

    if (!coachRows || coachRows.length === 0) {
      return { error: true, message: 'Invalid coach_id provided.' };
    }

    const noOfAllowedModules = coachRows[0].no_of_master_module;

    const { data: existingModules } = await supabaseAdmin
      .from('master_module')
      .select('module_id')
      .eq('coach_id', data.coach_id);

    const currentCount = existingModules ? existingModules.length : 0;

    if (currentCount >= noOfAllowedModules) {
      return {
        error: true,
        message: `Module limit reached for this coach (allowed: ${noOfAllowedModules}, current: ${currentCount})`
      };
    }

    const { data: moduleResult, error: insError } = await supabaseAdmin
      .from('master_module')
      .insert([{
        coach_id: data.coach_id,
        module_unique_id: data.module_unique_id,
        make_model: data.make_model,
        firmware_version: data.firmware_version,
        seriel_number: data.seriel_number,
        installation_date: data.installation_date,
        location: data.location,
        placement_type: data.placement_type,
        sim_no: data.sim_no,
        recharge_date: data.recharge_date,
        service_provider_primary: data.service_provider_primary,
        service_provider_secondary: data.service_provider_secondary || null,
        activation_date: data.activation_date,
        sim_status: data.sim_status,
        battery_replacement_date: data.battery_replacement_date,
        dual_profile_supported: data.dual_profile_supported,
        lora_enabled: data.lora_enabled,
        esim_enabled: data.esim_enabled,
        battery_capacity: data.battery_capacity || null,
        battery_type: data.battery_type || null,
        battery_recharge_date: data.battery_recharge_date,
        power_supply_available: data.power_supply_available,
        created_by: data.created_by,
        created_date: data.created_date
      }])
      .select();
    if (insError) throw insError;
    const moduleId = moduleResult[0].module_id;

    if (deviceIds.length > 0) {
      const { data: validDevices } = await supabaseAdmin
        .from('device_master')
        .select('device_id')
        .in('device_id', deviceIds);

      const validDeviceIds = (validDevices || []).map(d => d.device_id);

      if (validDeviceIds.length !== deviceIds.length) {
        return { error: true, message: 'Some device_ids are invalid or do not exist in device_master' };
      }

      const values = validDeviceIds.map(deviceId => ({
        module_id: moduleId,
        device_id: deviceId
      }));

      await supabaseAdmin.from('module_device_mapping').insert(values);
    }

    return { error: false, moduleId };
  }

  async findByUserId(userId) {
    const { data: modules } = await supabaseAdmin
      .from('master_module')
      .select('*')
      .order('module_id');

    if (!modules || modules.length === 0) return [];

    const coachIds = [...new Set(modules.map(m => m.coach_id).filter(Boolean))];
    const moduleIds = modules.map(m => m.module_id);

    let coaches = [];
    if (coachIds.length > 0) {
      const { data: c } = await supabaseAdmin
        .from('coach_master')
        .select('*')
        .in('coach_id', coachIds);
      coaches = c || [];
    }

    const trainIds = [...new Set(coaches.map(c => c.train_id).filter(Boolean))];

    let trains = [];
    if (trainIds.length > 0) {
      const { data: t } = await supabaseAdmin
        .from('train_master')
        .select('*')
        .in('train_id', trainIds);
      trains = t || [];
    }

    const { data: userTrainMappings } = await supabaseAdmin
      .from('user_train_mapping')
      .select('train_id')
      .eq('user_id', userId);
    const mappedTrainIds = new Set((userTrainMappings || []).map(utm => utm.train_id));

    const { data: devMappings } = await supabaseAdmin
      .from('module_device_mapping')
      .select('*')
      .in('module_id', moduleIds);
    const deviceIdsFromMapping = [...new Set((devMappings || []).map(dm => dm.device_id).filter(Boolean))];

    let devices = [];
    if (deviceIdsFromMapping.length > 0) {
      const { data: d } = await supabaseAdmin
        .from('device_master')
        .select('*')
        .in('device_id', deviceIdsFromMapping);
      devices = d || [];
    }

    const userIds = new Set();
    modules.forEach(m => { if (m.created_by) userIds.add(m.created_by); if (m.updated_by) userIds.add(m.updated_by); });
    coaches.forEach(c => { if (c.created_by) userIds.add(c.created_by); if (c.updated_by) userIds.add(c.updated_by); });
    trains.forEach(t => { if (t.created_by) userIds.add(t.created_by); if (t.updated_by) userIds.add(t.updated_by); });

    let users = [];
    if (userIds.size > 0) {
      const { data: u } = await supabaseAdmin
        .from('user_master')
        .select('user_id, first_name')
        .in('user_id', [...userIds]);
      users = u || [];
    }
    const userMap = {};
    users.forEach(u => { userMap[u.user_id] = u.first_name; });

    const coachMap = {};
    coaches.forEach(c => { coachMap[c.coach_id] = c; });
    const trainMap = {};
    trains.forEach(t => { trainMap[t.train_id] = t; });
    const devMap = {};
    devices.forEach(d => { devMap[d.device_id] = d; });
    const moduleDeviceMap = {};
    (devMappings || []).forEach(dm => {
      if (!moduleDeviceMap[dm.module_id]) moduleDeviceMap[dm.module_id] = [];
      moduleDeviceMap[dm.module_id].push(dm);
    });

    const rows = [];

    for (const mm of modules) {
      const coach = coachMap[mm.coach_id] || {};
      const train = trainMap[coach.train_id] || {};
      const moduleDevices = moduleDeviceMap[mm.module_id] || [];

      if (moduleDevices.length === 0) {
        rows.push({
          ...mm,
          coach_id: coach.coach_id,
          coach_unique_id: coach.coach_unique_id,
          coach_display_id: coach.coach_display_id,
          position: coach.position,
          train_id: train.train_id,
          train_number: train.train_number,
          train_name: train.train_name,
          module_created_by_name: userMap[mm.created_by] || null,
          module_updated_by_name: userMap[mm.updated_by] || null,
          coach_created_by_name: userMap[coach.created_by] || null,
          coach_updated_by_name: userMap[coach.updated_by] || null,
          train_created_by_name: userMap[train.created_by] || null,
          train_updated_by_name: userMap[train.updated_by] || null,
          mapped_device_id: null,
          device_unique_id: null,
          device_short_name: null,
          device_full_name: null,
          is_train_mapped_to_user: train.train_id ? (mappedTrainIds.has(train.train_id) ? 1 : 0) : 0
        });
      } else {
        for (const dm of moduleDevices) {
          const device = devMap[dm.device_id] || {};
          rows.push({
            ...mm,
            coach_id: coach.coach_id,
            coach_unique_id: coach.coach_unique_id,
            coach_display_id: coach.coach_display_id,
            position: coach.position,
            train_id: train.train_id,
            train_number: train.train_number,
            train_name: train.train_name,
            module_created_by_name: userMap[mm.created_by] || null,
            module_updated_by_name: userMap[mm.updated_by] || null,
            coach_created_by_name: userMap[coach.created_by] || null,
            coach_updated_by_name: userMap[coach.updated_by] || null,
            train_created_by_name: userMap[train.created_by] || null,
            train_updated_by_name: userMap[train.updated_by] || null,
            mapped_device_id: device.device_id || null,
            device_unique_id: device.device_unique_id || null,
            device_short_name: device.short_name || null,
            device_full_name: device.full_name || null,
            is_train_mapped_to_user: train.train_id ? (mappedTrainIds.has(train.train_id) ? 1 : 0) : 0
          });
        }
      }
    }

    return rows;
  }

  async findByCoachId(coach_id) {
    console.log(`test: ${coach_id}`);
    const { data: modules } = await supabaseAdmin
      .from('master_module')
      .select('*')
      .eq('coach_id', coach_id);
    if (!modules || modules.length === 0) return [];

    const { data: coach } = await supabaseAdmin
      .from('coach_master')
      .select('coach_unique_id')
      .eq('coach_id', coach_id)
      .single();

    return modules.map(m => ({ ...m, coach_unique_id: coach?.coach_unique_id || null }));
  }

  async noOfDevicesAttachedToModule(module_id) {
    const { data, error } = await supabaseAdmin
      .from('module_device_mapping')
      .select('device_id')
      .eq('module_id', module_id);
    if (error) throw error;
    return data ? data.length : 0;
  }

  async updateWithDevices(moduleId, data, deviceIds) {
    const updateFields = Object.keys(data).map(key => `${key} = ?`).join(', ');
    const updateValues = Object.values(data);

    const updateData = {};
    for (const key of Object.keys(data)) {
      updateData[key] = data[key];
    }
    const { error: updateError } = await supabaseAdmin
      .from('master_module')
      .update(updateData)
      .eq('module_id', moduleId);
    if (updateError) throw updateError;

    if (deviceIds.length > 0) {
      const { data: validDevices } = await supabaseAdmin
        .from('device_master')
        .select('device_id')
        .in('device_id', deviceIds);

      const validDeviceIds = (validDevices || []).map(d => d.device_id);
      if (validDeviceIds.length !== deviceIds.length) {
        throw new Error('Some device_ids are invalid or do not exist in device_master');
      }

      await supabaseAdmin.from('module_device_mapping').delete().eq('module_id', moduleId);

      const values = validDeviceIds.map(deviceId => ({
        module_id: moduleId,
        device_id: deviceId
      }));
      await supabaseAdmin.from('module_device_mapping').insert(values);
    } else {
      await supabaseAdmin.from('module_device_mapping').delete().eq('module_id', moduleId);
    }
  }

  async deleteById(moduleId) {
    await supabaseAdmin.from('module_device_mapping').delete().eq('module_id', moduleId);
    const { error } = await supabaseAdmin.from('master_module').delete().eq('module_id', moduleId);
    if (error) throw error;
  }

  async exists(moduleId) {
    const { data, error } = await supabaseAdmin
      .from('master_module')
      .select('module_id')
      .eq('module_id', moduleId)
      .limit(1);
    if (error) throw error;
    return data.length > 0;
  }
}

module.exports = new MasterModuleModel();
