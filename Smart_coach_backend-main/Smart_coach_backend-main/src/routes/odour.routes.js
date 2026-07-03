const express = require("express");
const router = express.Router();
const odourController = require("../controllers/odourController");
const { authenticate } = require('../middleware/auth.middleware');

router.post("/receive-data", odourController.receiveData);
router.get("/coaches", authenticate, odourController.getDashboardStatus);

module.exports = router;