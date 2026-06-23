const { insertSensorData } = require('../models/sensor_data.model');

// Controller gets io from route
exports.saveSensorData = async (req, res, io) => {
  try {
    const { sensor_id, value, timestamp } = req.body;

    if (!sensor_id || value === undefined || !timestamp) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    await insertSensorData(sensor_id, value, timestamp);

    // Emit event to connected clients
    io.emit('sensor_update', { sensor_id, value, timestamp });

    res.json({ success: true, message: 'Sensor data saved' });
  } catch (err) {
    console.error('Error saving sensor data:', err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

// get Trains for user
exports.getTrainsForUsers = async (req, res, next) => {
  try {
      const trains = await trainModel.getTrainsForUsers();
      return successResponse(res, 'Trains retrieved successfully', trains);
    } catch (error) {
      console.error('Error retrieving trains for user:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
}