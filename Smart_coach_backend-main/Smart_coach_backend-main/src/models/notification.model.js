const supabaseAdmin = require('../config/supabaseAdmin');

const NotificationModel = {
    getByUserId: async (userId, limit = 20, offset = 0) => {
        try {
            const { data, error } = await supabaseAdmin
                .from('user_notifications')
                .select('*')
                .eq('user_id', userId)
                .order('created_at', { ascending: false })
                .range(offset, offset + limit - 1);
            if (error) throw error;
            return data || [];
        } catch (err) {
            console.error("Model Error [getByUserId]:", err.message);
            throw err;
        }
    },

    markAsRead: async (notificationId, userId) => {
        try {
            const { data, error } = await supabaseAdmin
                .from('user_notifications')
                .update({ is_read: true })
                .eq('id', notificationId)
                .eq('user_id', userId)
                .select();
            if (error) throw error;
            return data;
        } catch (err) {
            console.error("Model Error [markAsRead]:", err.message);
            throw err;
        }
    },

    deleteNotification: async (notificationId, userId) => {
        try {
            const { error } = await supabaseAdmin
                .from('user_notifications')
                .delete()
                .eq('id', notificationId)
                .eq('user_id', userId);
            if (error) throw error;
            return true;
        } catch (err) {
            console.error("Model Error [deleteNotification]:", err.message);
            throw err;
        }
    }
};

module.exports = NotificationModel;
