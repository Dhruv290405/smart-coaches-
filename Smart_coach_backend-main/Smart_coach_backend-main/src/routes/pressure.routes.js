const express = require('express');
const router = express.Router();
const pressureController = require('../controllers/pressureController');
const { authenticate } = require('../middleware/auth.middleware');
const { requireLocation } = require('../middleware/rbac.middleware');

router.all('/receive-data', pressureController.receiveData);

router.get('/get-pressure-data', authenticate, requireLocation, pressureController.getPressureData);
router.get("/dashboard-status", authenticate, requireLocation, pressureController.getDashboardStatus);

module.exports = router;