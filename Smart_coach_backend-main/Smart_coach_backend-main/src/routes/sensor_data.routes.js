const express = require('express');
const { saveSensorData, getSensorData, getTrainsForUsers } = require('../controllers/sensor_data.controller');

module.exports = (io) => {
  const router = express.Router();

  router.post('/', (req, res) => saveSensorData(req, res, io));
  router.get('/', getSensorData);
  router.get('/trains', getTrainsForUsers);

  return router;
};
