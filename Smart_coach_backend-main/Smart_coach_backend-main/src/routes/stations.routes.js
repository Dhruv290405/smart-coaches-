const express = require('express');
const router = express.Router();
const { authenticate, authorize } = require('../middleware/auth.middleware');
const stationsController = require('../controllers/stations.controller');

router.get('/', authenticate, stationsController.getAllStations);

module.exports = router;
