const express = require('express');
const router = express.Router();
const hotAxleController = require('../controllers/hotAxleController');
const { authenticate } = require('../middleware/auth.middleware');
const { requireLocation } = require('../middleware/rbac.middleware');

router.all('/receive-data', hotAxleController.receiveData);

router.get('/get-data', authenticate, requireLocation, hotAxleController.getHotAxleData);
router.get('/filters', authenticate, requireLocation, hotAxleController.getFilterOptions);
router.get("/history", authenticate, requireLocation, hotAxleController.getHistory);
router.get("/dashboard-status", authenticate, requireLocation, hotAxleController.getDashboardStatus);
router.get("/new-company-data", authenticate, requireLocation, hotAxleController.getNewCompanyData);

module.exports = router;