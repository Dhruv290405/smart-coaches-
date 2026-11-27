const express = require("express");
const router = express.Router();
const odourController = require("../controllers/odourController");
const { authenticate } = require('../middleware/auth.middleware');
const { requireLocation } = require('../middleware/rbac.middleware');

router.post("/receive-data", odourController.receiveData);
router.get("/coaches", authenticate, requireLocation, odourController.getDashboardStatus);
router.get("/section2-coaches", authenticate, requireLocation, odourController.getSection2Data);
router.get("/history", authenticate, requireLocation, odourController.getHistory);
router.get("/report-data", authenticate, requireLocation, odourController.getReportData);
router.get("/aggregated-history", authenticate, requireLocation, odourController.getAggregatedHistory);
router.get("/aggregated-report-data", authenticate, requireLocation, odourController.getAggregatedReportData);

module.exports = router;