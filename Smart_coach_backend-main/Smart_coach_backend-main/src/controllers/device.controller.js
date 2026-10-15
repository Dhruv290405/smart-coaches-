const { validationResult } = require('express-validator');
const { successResponse, errorResponse } = require('../utils/response');
const deviceModel = require('../models/device.model');
const masterModuleModel = require('../models/master-module.model');
const deviceTypeModel = require('../models/master.model').deviceTypeModel;
const supabaseAdmin = require('../config/supabaseAdmin');
const { toMySQLDatetime } = require('../middleware/datetime');


const deviceController = {
  async getAllDevices(req, res, next) {
    try {
      const {
        master_module_id,
        device_type_id,
        status,
        search
      } = req.query;

      let query = supabaseAdmin.from('device_master').select('*');

      if (master_module_id) {
        query = query.eq('master_module_id', master_module_id);
      }

      if (device_type_id) {
        query = query.eq('device_type_id', device_type_id);
      }

      if (status) {
        query = query.eq('status', status);
      }

      if (search) {
        query = query.or(`name.ilike.%${search}%,serial_number.ilike.%${search}%,mac_address.ilike.%${search}%`);
      }

      const { data: devices, error } = await query;
      if (error) throw error;

      const moduleIds = [...new Set((devices || []).map(d => d.master_module_id).filter(Boolean))];
      const userIds = [...new Set((devices || []).flatMap(d => [d.created_by, d.updated_by].filter(Boolean)))];

      let mmMap = {};
      if (moduleIds.length > 0) {
        const { data: mods } = await supabaseAdmin.from('master_module').select('*').in('module_id', moduleIds);
        for (const m of mods || []) mmMap[m.module_id] = m;
      }

      let userMap = {};
      if (userIds.length > 0) {
        const { data: users } = await supabaseAdmin.from('user_master').select('user_id, first_name').in('user_id', userIds);
        for (const u of users || []) userMap[u.user_id] = u.first_name;
      }

      const coachIds = [...new Set(Object.values(mmMap).map(m => m.coach_id).filter(Boolean))];
      let coachMap = {};
      if (coachIds.length > 0) {
        const { data: coaches } = await supabaseAdmin.from('coach_master').select('*').in('coach_id', coachIds);
        for (const c of coaches || []) coachMap[c.coach_id] = c;
      }

      const trainIds = [...new Set(Object.values(coachMap).map(c => c.train_id).filter(Boolean))];
      let trainMap = {};
      if (trainIds.length > 0) {
        const { data: trains } = await supabaseAdmin.from('train_master').select('train_id, train_number, train_name').in('train_id', trainIds);
        for (const t of trains || []) trainMap[t.train_id] = t;
      }

      const device_master = (devices || []).map(d => {
        const mm = mmMap[d.master_module_id] || {};
        const coach = coachMap[mm.coach_id] || {};
        const train = trainMap[coach.train_id] || {};
        return {
          ...d,
          master_module_serial: mm.seriel_number || null,
          coach_unique_id: coach.coach_unique_id || null,
          train_number: train.train_number || null,
          train_name: train.train_name || null,
          device_type_name: d.full_name || null,
          device_model: d.short_name || null,
          created_by: userMap[d.created_by] ?? null,
          updated_by: userMap[d.updated_by] ?? null,
        };
      });

      return successResponse(res, 'Devices retrieved successfully', device_master);
    } catch (error) {
      next(error);
    }
  },

  async getDeviceById(req, res, next) {
    try {
      const { id } = req.params;
      const device = await deviceModel.getById(id);

      if (!device) {
        return errorResponse(res, 'Device not found', 404);
      }

      const [sensors, latestReadings] = await Promise.all([
        deviceModel.getSensors(id),
        deviceModel.getLatestReadings(id)
      ]);

      return successResponse(res, 'Device retrieved successfully', {
        ...device,
        sensors,
        latest_readings: latestReadings
      });
    } catch (error) {
      next(error);
    }
  },

  async getDevicesByMasterModuleId(req, res, next) {
    try {
      const { master_module_id } = req.params;
  
      if (!master_module_id) {
        return errorResponse(res, 'master_module_id is required', 400);
      }
  
      const devices = await deviceModel.getByMasterModuleId(master_module_id);
  
      if (!devices || devices.length === 0) {
        return errorResponse(res, 'No devices found for the given master_module_id', 404);
      }
  
      return successResponse(res, 'Devices retrieved successfully', devices);
    } catch (error) {
      next(error);
    }
  },  
  async createDevice(req, res, next) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const created_by = req.user.user_id;

      const {
        device_unique_id,
        data_type,
        time_unit,
        description,
        is_active,
        frequency_secs,
        full_name,
        short_name,
        no_of_sensors
      } = req.body;

      const { data: existing, error: checkErr } = await supabaseAdmin
        .from('device_master')
        .select('device_id')
        .eq('device_unique_id', device_unique_id)
        .limit(1);

      if (checkErr) throw checkErr;

      if (existing && existing.length > 0) {
        return res.status(409).json({
          success: false,
          message: 'Device with this unique ID already exists.'
        });
      }

      const created_at = toMySQLDatetime();

      const { data: result, error: insertErr } = await supabaseAdmin
        .from('device_master')
        .insert([{
          device_unique_id,
          data_type: data_type ?? null,
          time_unit,
          description: description || null,
          created_by,
          created_at,
          is_active,
          frequency_secs: frequency_secs ?? null,
          full_name,
          short_name,
          no_of_sensors
        }])
        .select();

      if (insertErr) throw insertErr;

      const finalData = {
        device_unique_id,
        data_type: data_type ?? null,
        time_unit,
        description,
        created_at,
        created_by,
        is_active,
        frequency_secs: frequency_secs ?? null,
        full_name,
        short_name,
        no_of_sensors
      };

      return successResponse(
        res,
        'Device created successfully',
        {
          id: result[0].device_id,
          ...finalData
        },
        201
      );
    } catch (error) {
      next(error);
    }
  },

  async validateMasterModule(master_module_id) {
    if (master_module_id) {
      const masterModule = await masterModuleModel.getById(master_module_id);
      if (!masterModule) {
        throw new Error('Master module not found');
      }
    }
    return true;
  },

  async validateDeviceType(device_type_id) {
    if (device_type_id) {
      const deviceType = await deviceTypeModel.getById(device_type_id);
      if (!deviceType) {
        throw new Error('Device type not found');
      }
    }
    return true;
  },

  async validateSerialNumber(serial_number, deviceId, existingSerial) {
    if (serial_number && serial_number !== existingSerial) {
      const serialExists = await deviceModel.serialNumberExists(serial_number, deviceId);
      if (serialExists) {
        throw new Error('A device with this serial number already exists');
      }
    }
  },

  async validateMacAddress(mac_address, deviceId, existingMac) {
    if (mac_address !== undefined && mac_address !== existingMac && mac_address) {
      const macExists = await deviceModel.macAddressExists(mac_address, deviceId);
      if (macExists) {
        throw new Error('A device with this MAC address already exists');
      }
    }
  },

  prepareDeviceUpdateData(updates, existingDevice) {
    return {
      master_module_id: updates.master_module_id ?? existingDevice.master_module_id,
      device_type_id: updates.device_type_id ?? existingDevice.device_type_id,
      name: updates.name || existingDevice.name,
      serial_number: updates.serial_number || existingDevice.serial_number,
      mac_address: updates.mac_address ?? existingDevice.mac_address,
      firmware_version: updates.firmware_version ?? existingDevice.firmware_version,
      ip_address: updates.ip_address ?? existingDevice.ip_address,
      status: updates.status || existingDevice.status,
      description: updates.description ?? existingDevice.description,
      installation_date: updates.installation_date ?? existingDevice.installation_date,
      last_maintenance_date: updates.last_maintenance_date ?? existingDevice.last_maintenance_date,
      calibration_date: updates.calibration_date ?? existingDevice.calibration_date,
      calibration_due_date: updates.calibration_due_date ?? existingDevice.calibration_due_date,
      updated_at: new Date()
    };
  },

  async updateDevice(req, res, next) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const updated_by = req.user.user_id;
      const device_id = req.params.id;

      const {
        device_unique_id,
        data_type,
        time_unit,
        description,
        is_active,
        frequency_secs,
        full_name,
        short_name,
        no_of_sensors
      } = req.body;

      const { data: existingDevice, error: existErr } = await supabaseAdmin
        .from('device_master')
        .select('*')
        .eq('device_id', device_id);

      if (existErr) throw existErr;

      if (!existingDevice || existingDevice.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Device not found'
        });
      }

      const { data: conflict, error: conflictErr } = await supabaseAdmin
        .from('device_master')
        .select('device_id')
        .eq('device_unique_id', device_unique_id)
        .neq('device_id', device_id)
        .limit(1);

      if (conflictErr) throw conflictErr;

      if (conflict && conflict.length > 0) {
        return res.status(409).json({
          success: false,
          message: 'Another device with this unique ID already exists.'
        });
      }

      const updated_at = toMySQLDatetime();

      const { error: updateErr } = await supabaseAdmin
        .from('device_master')
        .update({
          device_unique_id,
          data_type,
          time_unit,
          description: description || null,
          updated_by,
          updated_at,
          is_active,
          frequency_secs: frequency_secs ?? null,
          full_name,
          short_name,
          no_of_sensors
        })
        .eq('device_id', device_id);

      if (updateErr) throw updateErr;

      const responseData = {
        device_id,
        device_unique_id,
        data_type,
        time_unit,
        description,
        is_active,
        frequency_secs: frequency_secs ?? null,
        full_name,
        short_name,
        updated_by,
        updated_at,
        no_of_sensors
      };

      return successResponse(
        res,
        'Device updated successfully',
        responseData,
        200
      );

    } catch (error) {
      next(error);
    }
  },

  async deleteDevice(req, res, next) {
    try {
      const { id } = req.params;

      const device = await deviceModel.getById(id);
      if (!device) {
        return errorResponse(res, 'Device not found', 404);
      }

      await deviceModel.delete(id);
      
      return successResponse(res, 'Device deleted successfully', null, 200);
    } catch (error) {
      next(error);
    }
  },

  async getDeviceStatus(req, res, next) {
    try {
      const { id } = req.params;

      const device = await deviceModel.getById(id);
      if (!device) {
        return errorResponse(res, 'Device not found', 404);
      }

      const latestReadings = await deviceModel.getLatestReadings(id, 50);

      const status = {
        device_id: device.id,
        device_name: device.name,
        status: 'ONLINE',
        last_reading: latestReadings[0] ? latestReadings[0].reading_time : null,
        battery_level: null,
        signal_strength: null,
        readings: latestReadings
      };

      if (latestReadings.length === 0) {
        status.status = 'NO_DATA';
      } else {
        const hasError = latestReadings.some(reading => reading.error_code);
        if (hasError) {
          status.status = 'ERROR';
        }

        const batteryReading = latestReadings.find(r => r?.sensor_name?.toLowerCase().includes('battery'));
        const signalReading = latestReadings.find(r => r?.sensor_name?.toLowerCase().includes('signal'));

        status.battery_level = batteryReading?.value;
        status.signal_strength = signalReading?.value;
      }

      return successResponse(res, 'Device status retrieved successfully', status);
    } catch (error) {
      next(error);
    }
  }
};

module.exports = deviceController;
