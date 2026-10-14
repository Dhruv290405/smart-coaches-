const express = require('express');
const router = express.Router();
const { saveFcmToken, deleteFcmToken } = require('../controllers/fcm_token.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.post('/fcm-token', authenticate, saveFcmToken);
router.delete('/fcm-token', authenticate, deleteFcmToken);

module.exports = router;