const express = require('express');
const router = express.Router();
const pneumaticController = require('../controllers/pneumatic.controller');
const authMiddleware = require('../middleware/auth.middleware');

const authenticate = typeof authMiddleware === 'function' ? authMiddleware : authMiddleware.authenticate;

router.get('/status', authenticate, pneumaticController.getBreakBindingData);

router.get('/coaches-by-location', authenticate, pneumaticController.getCoachesByLocation);

module.exports = router;