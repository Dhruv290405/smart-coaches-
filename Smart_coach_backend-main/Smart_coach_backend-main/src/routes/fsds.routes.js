const express = require("express");
const router = express.Router();
const fsdsController = require("../controllers/fsdsController");
const { authenticate } = require('../middleware/auth.middleware');

router.post("/receive-data", fsdsController.receiveData);
router.get("/get-data", authenticate, fsdsController.getData);

module.exports = router;