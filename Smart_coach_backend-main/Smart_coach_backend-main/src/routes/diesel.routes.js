const express = require('express');
const router = express.Router();
const { getDieselReadings, getDieselHistory } = require('../controllers/diesel.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.get('/readings', authenticate, getDieselReadings);
router.get('/history', authenticate, getDieselHistory);

module.exports = router;
