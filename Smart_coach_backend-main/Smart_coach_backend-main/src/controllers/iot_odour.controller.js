const { insertIoTData, getLatestIoTDataFromDB } = require('../models/iot_odour.model');
const { successResponse, errorResponse } = require('../utils/response')

exports.addIoTData = async (req, res) => {
    try {
        const { sensor_id, train_id, coach_id, value, timestamp } = req.query;

        if (!sensor_id || !train_id || !coach_id || value == null || !timestamp) {
            return errorResponse(res, 'Missing required fields', 400);
        }

        const savedData = await insertIoTData({ sensor_id, train_id, coach_id, value, timestamp });

        // Emit to all connected clients via WebSocket
        if (global._io) {
            global._io.emit('iot_odour_data_update', savedData);
            console.log('📡 Emitted iot_odour_data_update:', savedData);
        }

        return successResponse(res, 'IoT data saved successfully', savedData, 201);
    } catch (err) {
        console.error('Error saving IoT data:', err);
        return errorResponse(res, 'Failed to save IoT data', 500);
    }
};

// GET /latest-iot-data
exports.getLatestIoTData = async (req, res) => {
  try {

    const { train_id, coach_id } = req.query;

    if (!train_id || !coach_id) {
      return errorResponse(res, 'train_id and coach_id are required', 400);
    }

    // Fetch latest data from DB
    const latestData = await getLatestIoTDataFromDB(train_id, coach_id);

    console.log('Fetched latest IoT data:', latestData);

    if (!latestData) {
      return res.status(404).json({ message: 'No data found' });
    }

    return successResponse(res, 'Latest IoT data fetched successfully', latestData, 200);
  } catch (err) {
    console.error(err);
    return errorResponse(res, 'Failed to fetch data', 500);
  }
};
