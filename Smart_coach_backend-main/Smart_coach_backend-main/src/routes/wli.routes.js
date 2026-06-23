const express = require("express");
const router = express.Router();
const wliController = require("../controllers/wliController");

router.post("/receive-data", wliController.receiveData);

module.exports = router;