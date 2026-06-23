const { successResponse, errorResponse } = require("../utils/response");
const sensorConfigModel = require("../models/sensor_config.model");
const { toMySQLDatetime } = require("../middleware/datetime");

const sensorConfigController = {
  // Create a new coach
  async createSensorConfig(req, res, next) {
    try {
      const { device_id, master_module_id, coach_id, sensors } = req.body;

      console.log("Received sensors:", req.body);

      if (!Array.isArray(sensors) || sensors.length === 0) {
        return errorResponse(res, 'Request body must include a non-empty "configs" array', 400);
      }

      // get sensor_type_id from sensor_device_mapping
      const sensor_type_id = await sensorConfigModel.getSensorTypeId(device_id);

      // get rule_id from rule_sensor_mapping
      const rule_id = await sensorConfigModel.getRuleId(sensor_type_id);

      const insertedIds = [];

      for (const config of sensors) {
        const {
          sensor_id,
          sensor_make_id,
          install_date,
          placement,
          location,
          remarks,
        } = config;

        try {
          const insertedId = await sensorConfigModel.insertSensorConfig({
            sensor_id,
            device_id,
            sensor_type_id,
            rule_id,
            sensor_make_id,
            install_date,
            placement,
            location,
            remarks,
            master_module_id,
            coach_id,
          });

          insertedIds.push({ sensor_id, insertedId });
        } catch (err) {
          if (err.message.includes('already exists')) {
            return errorResponse(
              res,
              `Sensor ID "${sensor_id}" already exists. Insertion stopped.`,
              409
            );
          }
          throw err;
        }
      }

      return successResponse(
        res,
        "Sensor configs created successfully",
        { insertedIds },
        201
      );

    } catch (error) {
      next(error);
    }
  },

  async getAllSensorConfigs(req, res, next) {
    try {
      var configs = await sensorConfigModel.getAllSensorConfigs();

      // 🔥 FIX: Check if configs exists and has data before accessing index 0
      if (!configs || configs.length === 0) {
        return successResponse(res, 'No sensor configurations found.', [], 200);
      }

      // Har config ke liye uske module ke attached devices fetch karna
      const updatedConfigs = await Promise.all(
        configs.map(async (config) => {
          // Check for module_id or master_module_id from the row
          const mid = config.module_id || config.master_module_id;
          let totalDevices = 0;
          
          if (mid) {
            totalDevices = await sensorConfigModel.noOfDevicesAttachedToModule(mid);
          }

          return {
            ...config,
            created_at: config.created_at ? new Date(config.created_at).toLocaleString('en-IN', { timeZone: 'Asia/Kolkata', hour12: true }) : null,
            updated_at: config.updated_at ? new Date(config.updated_at).toLocaleString('en-IN', { timeZone: 'Asia/Kolkata', hour12: true }) : null,
            total_devices_attached: totalDevices,
            is_active: !!config.is_active,
            dual_profile_supported: !!config.dual_profile_supported,
            lora_enabled: !!config.lora_enabled,
            esim_enabled: !!config.esim_enabled,
          };
        })
      );

      return successResponse(res, 'Sensor configs fetched successfully', updatedConfigs, 200);
    } catch (error) {
      next(error);
    }
  },

  async getMappedSensorConfigs(req, res, next) {
    try {
      var configs = await sensorConfigModel.getMappedSensorConfigs();
      
      return successResponse(res, 'Sensor configs fetched successfully', configs, 200);
    } catch (error) {
      next(error);
    }
  },

  async updateSensorConfig(req, res, next) {
    try {
      const { sensor_config_id } = req.query;

      if (!sensor_config_id) {
        return errorResponse(res, 'Sensor config ID is required in params', 400);
      }

      const {
        sensor_id,
        device_id,
        sensor_make_id,
        install_date,
        placement,
        location,
        remarks,
      } = req.body;

      const updated = await sensorConfigModel.updateSensorConfig(sensor_config_id, {
        sensor_id,
        device_id,
        sensor_make_id,
        install_date,
        placement,
        location,
        remarks
      });

      if (!updated) {
        return errorResponse(res, `No sensor config found with ID ${sensor_config_id}`, 404);
      }

      return successResponse(
        res,
        "Sensor config updated successfully",
        { sensor_config_id },
        200
      );

    } catch (error) {
      if (error.message.includes('already exists')) {
        return errorResponse(res, error.message, 409); // Conflict
      }
      next(error);
    }
  },
  
  async deleteSensorConfig(req, res, next) {
    try {
      const { sensor_config_id } = req.query;

      if (!sensor_config_id) {
        return errorResponse(res, 'Sensor config ID is required in params', 400);
      }

      const deleted = await sensorConfigModel.deleteSensorConfig(sensor_config_id);

      if (!deleted) {
        return errorResponse(res, `No sensor config found with ID ${sensor_config_id}`, 404);
      }

      return successResponse(
        res,
        "Sensor config deleted successfully",
        { sensor_config_id },
        200
      );

    } catch (error) {
      next(error);
    }
  },

  async getTrainAndCoachBySensorId(req, res, next) {
    try {
      const { sensor_id } = req.query;

      if (!sensor_id) {
        return errorResponse(res, 'Sensor ID is required in query', 400);
      }

      const result = await sensorConfigModel.getTrainAndCoachBySensorId(sensor_id);

      if (!result) {
        return errorResponse(res, `No train/coach found for sensor ID ${sensor_id}`, 404);
      }

      return successResponse(
        res,
        "Train and coach fetched successfully",
        result,
        200
      );

    } catch (error) {
      next(error);
    }
  }
  
};

module.exports = sensorConfigController;