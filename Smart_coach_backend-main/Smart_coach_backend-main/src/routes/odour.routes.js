const express = require("express");
const router = express.Router();
const odourController = require("../controllers/odourController");
router.post("/receive-data", odourController.receiveData);
router.get("/coaches", odourController.getDashboardStatus);
module.exports = router;