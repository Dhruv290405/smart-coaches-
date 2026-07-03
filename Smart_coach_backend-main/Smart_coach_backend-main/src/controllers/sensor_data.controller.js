const { insertSensorData, getSensorData, getTrainsForUser } = require('../models/sensor_data.model');
const { successResponse, errorResponse } = require('../utils/response');

exports.saveSensorData = async (req, res, io) => {
  try {
    const { sensor_id, value, timestamp } = req.body;

    if (!sensor_id || value === undefined || !timestamp) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    await insertSensorData(sensor_id, value, timestamp);

    if (global._io) {
      global._io.emit('sensor_update', { sensor_id, value, timestamp });
    }

    res.json({ success: true, message: 'Sensor data saved' });
  } catch (err) {
    console.error('Error saving sensor data:', err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

exports.getSensorData = async (req, res) => {
  try {
    const { sensor_id, from_date, to_date, limit } = req.query;
    const data = await getSensorData({ sensor_id, from_date, to_date, limit: parseInt(limit) || 100 });
    return successResponse(res, 'Sensor data retrieved successfully', data);
  } catch (error) {
    console.error('Error retrieving sensor data:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

exports.getTrainsForUsers = async (req, res) => {
  try {
    const trains = await getTrainsForUser();
    return successResponse(res, 'Trains retrieved successfully', trains);
  } catch (error) {
    console.error('Error retrieving trains for user:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};