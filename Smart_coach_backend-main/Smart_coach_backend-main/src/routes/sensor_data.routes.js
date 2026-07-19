const express = require('express');
const { saveSensorData, getSensorData, getTrainsForUsers } = require('../controllers/sensor_data.controller');
const { authenticate } = require('../middleware/auth.middleware');

module.exports = (io) => {
  const router = express.Router();

  router.post('/', (req, res) => saveSensorData(req, res, io));
  router.get('/', authenticate, getSensorData);
  router.get('/trains', authenticate, getTrainsForUsers);

  return router;
};
