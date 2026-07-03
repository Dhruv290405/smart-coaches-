const express = require("express");
const router = express.Router();
const wliController = require("../controllers/wliController");
const { authenticate } = require('../middleware/auth.middleware');

router.post("/receive-data", wliController.receiveData);
router.get("/coaches", authenticate, wliController.getDashboardStatus);

module.exports = router;