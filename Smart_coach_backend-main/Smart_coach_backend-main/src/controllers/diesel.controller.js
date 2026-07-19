const dieselModel = require('../models/diesel.model');
const rbac = require('../utils/rbac');
const { successResponse, errorResponse } = require('../utils/response');

exports.getDieselReadings = async (req, res) => {
  try {
    const { coach_id } = req.query;
    const authorizedCoaches = await rbac.getAuthorizedCoachNumbers(req.user);
    const sensors = await dieselModel.getDieselSensors(coach_id, authorizedCoaches);

    if (!sensors.length) {
      return successResponse(res, 'No diesel sensors found for this coach', [], 200);
    }

    const sensorIds = sensors.map(s => s.sensor_id);
    const readings = await dieselModel.getLatestReadings(sensorIds);

    const result = sensors.map(sensor => {
      const reading = readings.find(r => r.sensor_id === sensor.sensor_id);
      const value = reading ? parseFloat(reading.value) : 0;
      const timestamp = reading ? reading.timestamp : new Date().toISOString();
      const percentage = Math.min(100, Math.max(0, Math.round(value)));

      let status = 'Good';
      if (percentage <= 25) status = 'Critical';
      else if (percentage <= 50) status = 'Warning';

      return {
        sensor_id: sensor.sensor_id,
        coach_id: sensor.coach_id,
        train_number: sensor.train_number,
        train_name: sensor.train_name,
        percentage,
        status,
        loco_number: `Loco #${sensor.coach_id}`,
        capacity: 5000,
        consumption_rate: 400,
        estimated_run_time: +(percentage / 20).toFixed(1),
        range_left: Math.round(percentage * 12),
        last_updated: timestamp,
      };
    });

    return successResponse(res, 'Diesel readings retrieved', result, 200);
  } catch (err) {
    console.error('Error fetching diesel readings:', err);
    return errorResponse(res, 'Failed to fetch diesel readings', 500);
  }
};

exports.getDieselHistory = async (req, res) => {
  try {
    const { sensor_id } = req.query;
    if (!sensor_id) {
      return errorResponse(res, 'Missing sensor_id', 400);
    }

    const history = await dieselModel.getReadingHistory(sensor_id);
    return successResponse(res, 'Diesel reading history retrieved', history, 200);
  } catch (err) {
    console.error('Error fetching diesel history:', err);
    return errorResponse(res, 'Failed to fetch diesel history', 500);
  }
};
