const express = require('express');
const { body, param, query } = require('express-validator');
const sensorConfigController = require('../controllers/sensor_config.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

const router = express.Router();

router.post('/', authenticate, sensorConfigController.createSensorConfig);
router.get('/', authenticate, sensorConfigController.getAllSensorConfigs);
router.get('/mapped_sensors', authenticate, sensorConfigController.getMappedSensorConfigs);
router.put('/', authenticate, sensorConfigController.updateSensorConfig);
router.delete('/', authenticate, sensorConfigController.deleteSensorConfig);
router.get('/train_and_coach', sensorConfigController.getTrainAndCoachBySensorId);

module.exports = router;
