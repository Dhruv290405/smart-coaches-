const express = require('express');
const { body, param, query } = require('express-validator');
const sensorMakeController = require('../controllers/sensor_make.controller');
const { authenticate, authorize, authorizeByToken } = require('../middleware/auth.middleware');

const router = express.Router();

router.get(
    '/',
    authenticate,
    sensorMakeController.getAllSensroMake
  );

module.exports = router;