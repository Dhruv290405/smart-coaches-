// src/routes/coachConfig.routes.js
const express = require('express');
const router = express.Router();
const coachConfigController = require('../controllers/coachConfigController');
const { authenticate } = require('../middleware/auth.middleware');
const { requireLocation } = require('../middleware/rbac.middleware');

router.get('/:coach_no', authenticate, requireLocation, coachConfigController.getCoachDetails);

module.exports = router;