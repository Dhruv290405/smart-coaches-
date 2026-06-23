const express = require('express');
const { body, param, query } = require('express-validator');
const coachMakeController = require('../controllers/coach-make.controller');
const { authenticate, authorize, authorizeByToken } = require('../middleware/auth.middleware');

const router = express.Router();

router.get(
    '/',
    authenticate,
    coachMakeController.getAllCoachMake
  );

module.exports = router;