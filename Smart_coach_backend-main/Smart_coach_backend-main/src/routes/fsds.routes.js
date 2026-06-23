const express = require("express");
const router = express.Router();
const fsdsController = require("../controllers/fsdsController");
router.post("/receive-data", fsdsController.receiveData);
module.exports = router;