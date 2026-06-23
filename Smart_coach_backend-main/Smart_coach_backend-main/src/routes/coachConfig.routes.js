// src/routes/coachConfig.routes.js
const express = require('express');
const router = express.Router();
const coachConfigController = require('../controllers/coachConfigController');

router.get('/:coach_no', coachConfigController.getCoachDetails);

module.exports = router;