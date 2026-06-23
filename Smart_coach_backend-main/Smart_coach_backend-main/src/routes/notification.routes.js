const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notification.controller');

// Yahan 'protect' ki jagah 'authenticate' use hoga kyunki wahi export ho raha hai
const { authenticate } = require('../middleware/auth.middleware'); 

// Ab saare handlers valid functions honge
router.get('/', authenticate, notificationController.getNotifications);
router.patch('/:id/read', authenticate, notificationController.readNotification);
router.delete('/:id', authenticate, notificationController.deleteNotification);

module.exports = router;