const { validationResult } = require('express-validator');
const { successResponse, errorResponse } = require('../utils/response');
const deviceModel = require('../models/device.model');
const masterModuleModel = require('../models/master-module.model');
const deviceTypeModel = require('../models/master.model').deviceTypeModel;
const { pool } = require('../config/db');
const { toMySQLDatetime } = require('../middleware/datetime');


const deviceController = {
  // Get all devices with optional filters
  async getAllDevices(req, res, next) {
    try {
      const {
        master_module_id,
        device_type_id,
        status,
        search
      } = req.query;

      let query = `
        SELECT 
            d.*,  
            mm.seriel_number AS master_module_serial,  
            c.coach_unique_id,  
            t.train_number,  
            t.train_name,  
            dt.full_name AS device_type_name,  
            dt.short_name AS device_model,  
            u1.first_name AS created_by,  
            u2.first_name AS updated_by

          FROM device_master d  

          LEFT JOIN master_module mm ON d.master_module_id = mm.module_id  
          LEFT JOIN coach_master c ON mm.coach_id = c.coach_id  
          LEFT JOIN train_master t ON c.train_id = t.train_id  
          LEFT JOIN device_master dt ON d.device_id = dt.device_id  

          -- Join with user_master for created_by and updated_by
          LEFT JOIN user_master u1 ON d.created_by = u1.user_id  
          LEFT JOIN user_master u2 ON d.updated_by = u2.user_id  

          WHERE 1=1;
                `;



      const params = [];

      // Add filters
      if (master_module_id) {
        query += ' AND d.master_module_id = ?';
        params.push(master_module_id);
      }

      if (device_type_id) {
        query += ' AND d.device_type_id = ?';
        params.push(device_type_id);
      }

      if (status) {
        query += ' AND d.status = ?';
        params.push(status);
      }

      if (search) {
        query += ' AND (d.name LIKE ? OR d.serial_number LIKE ? OR d.mac_address LIKE ?)';
        const searchTerm = `%${search}%`;
        params.push(searchTerm, searchTerm, searchTerm);
      }


      const [device_master] = await pool.execute(query, params);

      return successResponse(res, 'Devices retrieved successfully', device_master);
    } catch (error) {
      next(error);
    }
  },

  // Get a single device by ID
  async getDeviceById(req, res, next) {
    try {
      const { id } = req.params;
      const device = await deviceModel.getById(id);

      if (!device) {
        return errorResponse(res, 'Device not found', 404);
      }

      // Get sensors and latest readings for this device
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
  // Create a new device
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

      //  Check for existing device_unique_id
      const [existing] = await pool.execute(
        `SELECT device_id FROM device_master WHERE device_unique_id = ? LIMIT 1`,
        [device_unique_id]
      );

      if (existing.length > 0) {
        return res.status(409).json({
          success: false,
          message: 'Device with this unique ID already exists.'
        });
      }

      const sql = `
      INSERT INTO device_master (
        device_unique_id,
        data_type,
        time_unit,
        description,
        created_by,
        created_at,
        is_active,
        frequency_secs,
        full_name,
        short_name,
        no_of_sensors
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

      const created_at = toMySQLDatetime();

      const values = [
        device_unique_id,
        data_type ?? null,
        time_unit,
        description || null,
        created_by,
        created_at,
        is_active,
        frequency_secs ?? null,
        full_name,
        short_name,
        no_of_sensors
      ];

      const [result] = await pool.execute(sql, values);


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
          id: result.insertId,
          ...finalData
        },
        201
      );
    } catch (error) {
      next(error);
    }
  },

  // Helper function to validate master module
  async validateMasterModule(master_module_id) {
    if (master_module_id) {
      const masterModule = await masterModuleModel.getById(master_module_id);
      if (!masterModule) {
        throw new Error('Master module not found');
      }
    }
    return true;
  },

  // Helper function to validate device type
  async validateDeviceType(device_type_id) {
    if (device_type_id) {
      const deviceType = await deviceTypeModel.getById(device_type_id);
      if (!deviceType) {
        throw new Error('Device type not found');
      }
    }
    return true;
  },

  // Helper function to validate serial number
  async validateSerialNumber(serial_number, deviceId, existingSerial) {
    if (serial_number && serial_number !== existingSerial) {
      const serialExists = await deviceModel.serialNumberExists(serial_number, deviceId);
      if (serialExists) {
        throw new Error('A device with this serial number already exists');
      }
    }
  },

  // Helper function to validate MAC address
  async validateMacAddress(mac_address, deviceId, existingMac) {
    if (mac_address !== undefined && mac_address !== existingMac && mac_address) {
      const macExists = await deviceModel.macAddressExists(mac_address, deviceId);
      if (macExists) {
        throw new Error('A device with this MAC address already exists');
      }
    }
  },

  // Helper function to prepare device update data
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

  // Update a device
  // Update an existing device

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

      //  Check if the device exists
      const [existingDevice] = await pool.execute(
        `SELECT * FROM device_master WHERE device_id = ?`,
        [device_id]
      );

      if (existingDevice.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Device not found'
        });
      }

      //  Check for duplicate unique key (excluding current device)
      const [conflict] = await pool.execute(
        `SELECT device_id FROM device_master WHERE device_unique_id = ? AND device_id != ? LIMIT 1`,
        [device_unique_id, device_id]
      );

      if (conflict.length > 0) {
        return res.status(409).json({
          success: false,
          message: 'Another device with this unique ID already exists.'
        });
      }

      const updated_at = toMySQLDatetime();

      const updateSql = `
      UPDATE device_master SET
        device_unique_id = ?,
        data_type = ?,
        time_unit = ?,
        description = ?,
        updated_by = ?,
        updated_at = ?,
        is_active = ?,
        frequency_secs = ?,
        full_name = ?,
        short_name = ?,
        no_of_sensors = ?
      WHERE device_id = ?
    `;

      const updateValues = [
        device_unique_id,
        data_type,
        time_unit,
        description || null,
        updated_by,
        updated_at,
        is_active,
        frequency_secs ?? null,
        full_name,
        short_name,
        no_of_sensors,
        device_id
      ];

      await pool.execute(updateSql, updateValues);

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


  // Delete a device
  async deleteDevice(req, res, next) {
    try {
      const { id } = req.params;

      // Check if device exists
      const device = await deviceModel.getById(id);
      if (!device) {
        return errorResponse(res, 'Device not found', 404);
      }

      // Check if device has sensors
      // const sensors = await deviceModel.getSensors(id);
      // if (sensors.length > 0) {
      //   return errorResponse(
      //     res,
      //     'Cannot delete device because it has sensors assigned',
      //     400
      //   );
      // }

      // Delete the device
      await deviceModel.delete(id);
      
      return successResponse(res, 'Device deleted successfully', null, 200);
    } catch (error) {
      next(error);
    }
  },

  // Get device status
  async getDeviceStatus(req, res, next) {
    try {
      const { id } = req.params;

      // Check if device exists
      const device = await deviceModel.getById(id);
      if (!device) {
        return errorResponse(res, 'Device not found', 404);
      }

      // Get latest readings for this device
      const latestReadings = await deviceModel.getLatestReadings(id, 50);

      // Calculate status based on latest readings (simplified example)
      const status = {
        device_id: device.id,
        device_name: device.name,
        status: 'ONLINE', // Default status
        last_reading: latestReadings[0] ? latestReadings[0].reading_time : null,
        battery_level: null,
        signal_strength: null,
        readings: latestReadings
      };

      // Update status based on latest readings
      if (latestReadings.length === 0) {
        status.status = 'NO_DATA';
      } else {
        // Check for any error conditions in the latest readings
        const hasError = latestReadings.some(reading => reading.error_code);
        if (hasError) {
          status.status = 'ERROR';
        }

        // Extract battery level and signal strength if available using optional chaining
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