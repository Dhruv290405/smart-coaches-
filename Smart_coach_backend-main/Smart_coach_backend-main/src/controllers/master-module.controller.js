const { validationResult } = require('express-validator');
const { successResponse, errorResponse } = require('../utils/response');
const masterModuleModel = require('../models/master-module.model');
const coachModel = require('../models/coach.model');
const { toMySQLDatetime } = require('../middleware/datetime');
const deviceTypeModel = require('../models/master.model').deviceTypeModel;

const masterModuleController = {

  async createMasterModule(req, res, next) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const created_by = req.user.user_id;
      const {
        coach_id,
        module_unique_id,
        make_model,
        firmware_version,
        seriel_number,
        installation_date,
        location,
        placement_type,
        sim_no,
        recharge_date,
        service_provider_primary,
        service_provider_secondary,
        activation_date,
        sim_status,
        battery_replacement_date,
        dual_profile_supported = false,
        lora_enabled = false,
        esim_enabled = false,
        battery_capacity,
        battery_type,
        battery_recharge_date,
        device_ids = []
      } = req.body;

      const moduleData = {
        coach_id,
        module_unique_id,
        make_model,
        firmware_version,
        seriel_number,
        installation_date,
        location,
        placement_type,
        sim_no,
        recharge_date,
        service_provider_primary,
        service_provider_secondary,
        activation_date,
        sim_status,
        battery_replacement_date,
        dual_profile_supported,
        lora_enabled,
        esim_enabled,
        battery_capacity,
        battery_type,
        battery_recharge_date,
        created_by,
        created_date: toMySQLDatetime(),
      };

      const result = await masterModuleModel.createWithDevices(moduleData, device_ids || []);


      if (result.error) {
        return res.status(400).json({ success: false, message: result.message });
      }

      return successResponse(res, 'Master module created successfully', {
        module_id: result.moduleId,
        ...moduleData,
        device_ids
      }, 201);
    } catch (error) {
      next(error);
    }
  },

  async getMasterModulesByUser(req, res, next) {
    // Helper function to group devices by module or mapped device ID
    function groupModulesWithDevices(rawRows) {
      const modulesMap = new Map();

      for (const row of rawRows) {
        // Safe check to avoid key grouping errors if mapping is empty
        const targetModuleKey = row.mapped_device_id || row.module_id;

        if (!modulesMap.has(targetModuleKey)) {
          modulesMap.set(targetModuleKey, {
            // Priority given to mapped_device_id as per requirement
            module_id: row.mapped_device_id ? row.mapped_device_id : row.module_id, 
            module_unique_id: row.module_unique_id,
            make_model: row.make_model,
            firmware_version: row.firmware_version,
            seriel_number: row.seriel_number,
            installation_date: row.installation_date,
            location: row.location,
            placement_type: row.placement_type,
            sim_no: row.sim_no,
            recharge_date: row.recharge_date,
            service_provider_primary: row.service_provider_primary,
            service_provider_secondary: row.service_provider_secondary,
            activation_date: row.activation_date,
            sim_status: row.sim_status,
            battery_replacement_date: row.battery_replacement_date,
            dual_profile_supported: Boolean(row.dual_profile_supported),
            lora_enabled: Boolean(row.lora_enabled),
            esim_enabled: Boolean(row.esim_enabled),
            battery_capacity: row.battery_capacity,
            battery_type: row.battery_type,
            battery_recharge_date: row.battery_recharge_date,
            created_by: row.created_by,
            module_created_by_name: row.module_created_by_name,
            module_updated_by_name: row.module_updated_by_name,
            created_date: row.created_date,
            updated_by: row.updated_by,
            updated_date: row.updated_date,

            coach: {
              coach_id: row.coach_id,
              coach_unique_id: row.coach_unique_id,
              coach_display_id: row.coach_display_id,
              created_by_name: row.coach_created_by_name,
              updated_by_name: row.coach_updated_by_name
            },

            train: {
              train_id: row.train_id,
              train_number: row.train_number,
              train_name: row.train_name
            },

            created_by_name: row.created_by_name,
            updated_by_name: row.updated_by_name,

            devices: []
          });
        }

        if (row.mapped_device_id) {
          modulesMap.get(targetModuleKey).devices.push({
            device_id: row.mapped_device_id,
            device_unique_id: row.device_unique_id,
            short_name: row.device_short_name,
            full_name: row.device_full_name
          });
        }
      }

      return Array.from(modulesMap.values());
    }

    try {
      const userId = req.user.user_id;
      if (!userId) {
        return res.status(400).json({ message: 'User ID is required.' });
      }

      const rawRows = await masterModuleModel.findByUserId(userId);

      if (!rawRows || rawRows.length === 0) {
        return successResponse(res, 'No master modules found for the trains assigned to this user.', []);
      }

      const modules = groupModulesWithDevices(rawRows);

      return successResponse(res, 'Master modules retrieved successfully.', modules);
    } catch (error) {
      next(error);
    }
  },

  async getMasterModulesByCoachId(req, res, next) {
    try {
      const { coach_id } = req.query;
      console.log("coach_id : ", req.query.coach_id)
      
      if (!coach_id) {
        return res.status(400).json({ message: 'Coach ID is required.' });
      }

      let modules = await masterModuleModel.findByCoachId(coach_id);

      // Safety Check: Agar modules empty array hai toh direct return karein
      if (!modules || modules.length === 0) {
        return successResponse(res, 'No master modules found for this coach.', []);
      }

      // Har module ke liye unke devices ka count nikalna
      const updatedModules = await Promise.all(
        modules.map(async (module) => {
          const totalDevices = await masterModuleModel.noOfDevicesAttachedToModule(module.module_id);
          
          return {
            ...module,
            total_devices_attached: totalDevices || 0,
            dual_profile_supported: !!module.dual_profile_supported,
            lora_enabled: !!module.lora_enabled,
            esim_enabled: !!module.esim_enabled,
          };
        })
      );

      return successResponse(res, 'Master modules retrieved successfully.', updatedModules);
    } catch (error) {
      next(error);
    }
  },

  async updateMasterModule(req, res, next) {
    try {
      const moduleId = parseInt(req.params.id, 10);
      const updatedBy = req.user.user_id;

      if (isNaN(moduleId)) {
        return res.status(400).json({ error: 'Invalid module ID' });
      }

      // Check if module exists
      const moduleExists = await masterModuleModel.exists(moduleId);
      if (!moduleExists) {
        return res.status(404).json({ error: 'Master module not found.' });
      }

      const {
        coach_id,
        module_unique_id,
        make_model,
        firmware_version,
        seriel_number,
        installation_date,
        location,
        placement_type,
        sim_no,
        service_provider_primary,
        service_provider_secondary,
        activation_date,
        sim_status,
        battery_replacement_date,
        dual_profile_supported = false,
        lora_enabled = false,
        esim_enabled = false,
        battery_capacity,
        battery_type,
        device_ids = []
      } = req.body;

      const updatedData = {
        coach_id,
        module_unique_id,
        make_model,
        firmware_version,
        seriel_number,
        installation_date,
        location,
        placement_type,
        sim_no,
        service_provider_primary,
        service_provider_secondary,
        activation_date,
        sim_status,
        battery_replacement_date,
        dual_profile_supported,
        lora_enabled,
        esim_enabled,
        battery_capacity,
        battery_type,
        updated_by: updatedBy,
        updated_date: new Date()
      };

      await masterModuleModel.updateWithDevices(moduleId, updatedData, device_ids);

      return successResponse(res, 'Master module updated successfully.');
    } catch (error) {
      next(error);
    }
  },

  async deleteMasterModule(req, res, next) {
    try {
      const moduleId = parseInt(req.params.id, 10);

      if (isNaN(moduleId)) {
        return res.status(400).json({ error: 'Invalid module ID' });
      }

      // Check if module exists
      const moduleExists = await masterModuleModel.exists(moduleId);
      if (!moduleExists) {
        return res.status(404).json({ error: 'Master module not found.' });
      }

      await masterModuleModel.deleteById(moduleId);

      return successResponse(res, 'Master module deleted successfully.');
    } catch (error) {
      next(error);
    }
  }

};

module.exports = masterModuleController;