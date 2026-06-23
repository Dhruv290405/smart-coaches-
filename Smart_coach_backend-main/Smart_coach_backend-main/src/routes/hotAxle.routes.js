const express = require('express');
const router = express.Router();
const hotAxleController = require('../controllers/hotAxleController');

router.all('/receive-data', hotAxleController.receiveData);

router.get('/get-data', hotAxleController.getHotAxleData);
router.get("/history", hotAxleController.getHistory);
router.get("/dashboard-status", hotAxleController.getDashboardStatus);

module.exports = router;