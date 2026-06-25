const express = require('express');
const router = express.Router();
const { getDieselReadings, getDieselHistory } = require('../controllers/diesel.controller');

router.get('/readings', getDieselReadings);
router.get('/history', getDieselHistory);

module.exports = router;
