const express = require('express');
const router = express.Router();
const { addIoTData, getWaterLevelData, getDataForCoach } = require('../controllers/iot_water_level.controller');


router.post('/', addIoTData);
router.get('/get_water_level_data', getWaterLevelData);
router.get('/get_data_for_coach', getDataForCoach);

module.exports = router;
