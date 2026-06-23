const express = require('express');
const router = express.Router();
const { authenticate, authorize } = require('../middleware/auth.middleware');
const regionsController = require('../controllers/regions.controller');

router.get('/', authenticate, regionsController.getAllRegions);

module.exports = router;
