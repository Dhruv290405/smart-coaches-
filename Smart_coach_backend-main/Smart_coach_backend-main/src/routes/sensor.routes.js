const express = require('express');
const { body, param, query } = require('express-validator');
const sensorController = require('../controllers/sensor.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

const router = express.Router();

// Get all sensors
router.get(
  '/',
  authenticate,
  sensorController.getAllSensors
);

// Create new sensor (Admin only)
router.post(
  '/',
  authenticate,
  sensorController.createSensor
);

// Get all categories from value_type_master
router.get(
  '/categories',
  sensorController.getAllCategories
);

// Based on selected category, get the units from unit_master
router.get(
  '/categories/:categoryId/units',
  sensorController.getUnitsByCategory
);

// Update sensor (Admin only)
router.put(
  '/:id',
  authenticate,
  sensorController.updateSensor
);

// Delete sensor (Admin only)
router.delete(
  '/:id',
  authenticate,
  sensorController.deleteSensor
);

// Add reading to sensor
router.post(
  '/:id/readings',
  authenticate,
  sensorController.addReading
);

// Get readings for a sensor
router.get(
  '/:id/readings',
  authenticate,
  sensorController.getReadings
);

// Get statistics for a sensor
router.get(
  '/:id/statistics',
  authenticate,
  sensorController.getStatistics
);

// Get alerts for a sensor
router.get(
  '/:id/alerts',
  authenticate,
  sensorController.getAlerts
);

// Create alert for a sensor
router.post(
  '/:id/alerts',
  authenticate,
  sensorController.createAlert
);

// Update alert for a sensor
router.put(
  '/:id/alerts/:alertId',
  authenticate,
  sensorController.updateAlert
);

// Get water sensor for coach
router.get(
  '/watersensorsforcoach',
  authenticate,
  sensorController.getWaterSensorsForCoach
);

module.exports = router;
