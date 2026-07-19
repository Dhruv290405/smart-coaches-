const express = require('express');
const router = express.Router();
const { getDieselReadings, getDieselHistory } = require('../controllers/diesel.controller');
const { authenticate } = require('../middleware/auth.middleware');
const { requireLocation } = require('../middleware/rbac.middleware');

router.get('/readings', authenticate, requireLocation, getDieselReadings);
router.get('/history', authenticate, requireLocation, getDieselHistory);

module.exports = router;
