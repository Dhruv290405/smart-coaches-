const express = require('express');
const router = express.Router();
const { addIoTData, getLatestIoTData } = require('../controllers/iot_odour.controller');


router.post('/', addIoTData);
router.get('/latest', getLatestIoTData);

module.exports = router;
