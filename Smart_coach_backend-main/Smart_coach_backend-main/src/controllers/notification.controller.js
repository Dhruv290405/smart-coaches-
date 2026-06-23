const NotificationModel = require('../models/notification.model');

// 1. Get Notifications List
exports.getNotifications = async (req, res) => {
    try {
        const userId = req.user.user_id || req.user.id; // Auth middleware se user id milegi
        const limit = parseInt(req.query.limit) || 20;
        const offset = parseInt(req.query.offset) || 0;

        const notifications = await NotificationModel.getByUserId(userId, limit, offset);
        
        // Count unread notifications for the badge on bell icon
        const unreadCount = notifications.filter(n => n.is_read === 0 || n.is_read === false).length;

        res.status(200).json({
            success: true,
            unreadCount,
            data: notifications
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

// 2. Mark Notification as Read
exports.readNotification = async (req, res) => {
    try {
        const userId = req.user.user_id;
        const notificationId = req.params.id;

        await NotificationModel.markAsRead(notificationId, userId);

        res.status(200).json({
            success: true,
            message: "Notification marked as read successfully"
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

// 3. Delete Single Notification
exports.deleteNotification = async (req, res) => {
    try {
        const userId = req.user.user_id || req.user.id;
        const notificationId = req.params.id;

        await NotificationModel.deleteNotification(notificationId, userId);

        res.status(200).json({
            success: true,
            message: "Notification deleted successfully"
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};