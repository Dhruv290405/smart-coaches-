const express = require("express");
const router = express.Router();
const fsdsController = require("../controllers/fsdsController");
router.post("/receive-data", fsdsController.receiveData);
router.get("/get-data", fsdsController.getData);
module.exports = router;