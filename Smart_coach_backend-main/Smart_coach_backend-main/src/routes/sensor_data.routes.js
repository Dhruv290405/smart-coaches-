const express = require('express');
const { saveSensorData, getTrainsForUsers } = require('../controllers/sensor_data.controller');

module.exports = (io) => {
  const router = express.Router();

  router.post('/', (req, res) => saveSensorData(req, res, io));
  router.get('/trains', (req, res, next) => getTrainsForUsers(req, res, next));

  return router;
};
