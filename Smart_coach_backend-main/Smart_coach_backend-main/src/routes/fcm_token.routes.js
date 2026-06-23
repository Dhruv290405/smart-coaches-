const express = require('express');
const router = express.Router();
const { saveFcmToken } = require('../controllers/fcm_token.controller');

router.post('/fcm-token', saveFcmToken);

module.exports = router;