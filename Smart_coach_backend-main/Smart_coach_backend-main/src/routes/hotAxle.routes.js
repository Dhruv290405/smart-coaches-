const express = require('express');
const router = express.Router();
const hotAxleController = require('../controllers/hotAxleController');
const { authenticate } = require('../middleware/auth.middleware');

router.all('/receive-data', hotAxleController.receiveData);

router.get('/get-data', authenticate, hotAxleController.getHotAxleData);
router.get('/filters', authenticate, hotAxleController.getFilterOptions);
router.get("/history", authenticate, hotAxleController.getHistory);
router.get("/dashboard-status", authenticate, hotAxleController.getDashboardStatus);
router.get("/new-company-data", authenticate, hotAxleController.getNewCompanyData);

module.exports = router;