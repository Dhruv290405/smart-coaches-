const { successResponse, errorResponse } = require('../utils/response');
const sensor_makeModel = require('../models/sensor_make.model');

const sensorMakeController = {
    // Register a new user
    async getAllSensroMake(req, res, next) {
        try {
          const sensorsMake = await sensor_makeModel.getAllSensorMake();
    
          if (!sensorsMake || sensorsMake.length === 0) {
            return successResponse(res, "No sensorsMake found.", []);
          }
    
          return successResponse(res, "sensorsMake retrieved successfully.", sensorsMake);
        } catch (error) {
          next(error);
        }
      },
  }
  
  module.exports = sensorMakeController;