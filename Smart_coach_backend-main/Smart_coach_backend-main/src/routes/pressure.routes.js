const express = require('express');
const router = express.Router();
const pressureController = require('../controllers/pressureController');

router.all('/receive-data', pressureController.receiveData);

router.get('/get-pressure-data', pressureController.getPressureData);
router.get("/dashboard-status", pressureController.getDashboardStatus);

module.exports = router;