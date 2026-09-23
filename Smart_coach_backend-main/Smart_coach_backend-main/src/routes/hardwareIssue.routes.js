const express = require("express");
const router = express.Router();
const hardwareIssueController = require("../controllers/hardwareIssue.controller");
const { authenticate } = require("../middleware/auth.middleware");

// Hardware device button press — NO auth (device posts directly)
router.post("/event", hardwareIssueController.event);

// Auth required below
router.get("/mapping", authenticate, hardwareIssueController.getMapping);
router.get("/report", authenticate, hardwareIssueController.getReport);
router.get("/", authenticate, hardwareIssueController.getAll);

module.exports = router;