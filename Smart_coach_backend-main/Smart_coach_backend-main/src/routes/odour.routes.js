const express = require("express");
const router = express.Router();
const odourController = require("../controllers/odourController");
router.post("/receive-data", odourController.receiveData);
module.exports = router;