const express = require('express');
const { body, param, query } = require('express-validator');
const coachTypeController = require('../controllers/coach-type.controller');
const { authenticate, authorize, authorizeByToken } = require('../middleware/auth.middleware');

const router = express.Router();

router.get(
    '/',
    authenticate,
    coachTypeController.getAllCoachType
  );

module.exports = router;