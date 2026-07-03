const express = require('express');
const router = express.Router();
const pressureController = require('../controllers/pressureController');
const { authenticate } = require('../middleware/auth.middleware');

router.all('/receive-data', pressureController.receiveData);

router.get('/get-pressure-data', authenticate, pressureController.getPressureData);
router.get("/dashboard-status", authenticate, pressureController.getDashboardStatus);

module.exports = router;