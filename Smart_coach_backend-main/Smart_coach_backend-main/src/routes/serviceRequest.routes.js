const express = require("express");
const router = express.Router();
const serviceRequestController = require("../controllers/serviceRequest.controller");
const { authenticate } = require("../middleware/auth.middleware");

// Passenger submits — NO auth
router.post("/", serviceRequestController.create);

// Train operator views — auth required
router.get("/", authenticate, serviceRequestController.getAll);
router.get("/:id", authenticate, serviceRequestController.getById);
router.patch("/:id/status", authenticate, serviceRequestController.updateStatus);

module.exports = router;
