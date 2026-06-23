const { pool } = require('../config/db');
const supabase = require('../config/supabase');

const NotificationModel = {
    // 1. Fetch all notifications for a specific user (MySQL format)
    getByUserId: async (userId, limit = 20, offset = 0) => {
        try {
            const query = `
                SELECT * FROM user_notifications 
                WHERE user_id = ? 
                ORDER BY created_at DESC 
                LIMIT ? OFFSET ?
            `;
            // MySQL mein limit aur offset numbers hone chahiye
            const [rows] = await pool.query(query, [userId, parseInt(limit), parseInt(offset)]);
            return rows || [];
        } catch (err) {
            console.error("Model Error [getByUserId]:", err.message);
            throw err;
        }
    },

    // 2. Mark a specific notification as Read
    markAsRead: async (notificationId, userId) => {
        try {
            const query = `
                UPDATE user_notifications 
                SET is_read = TRUE 
                WHERE id = ? AND user_id = ?
            `;
            const [result] = await pool.query(query, [notificationId, userId]);
            return result;
        } catch (err) {
            console.error("Model Error [markAsRead]:", err.message);
            throw err;
        }
    },

    // 3. Delete a notification
    deleteNotification: async (notificationId, userId) => {
        try {
            const query = `
                DELETE FROM user_notifications 
                WHERE id = ? AND user_id = ?
            `;
            const [result] = await pool.query(query, [notificationId, userId]);
            return true;
        } catch (err) {
            console.error("Model Error [deleteNotification]:", err.message);
            throw err;
        }
    }
};

module.exports = NotificationModel;