const { saveFcm, deleteFcm } = require('../models/fcm_token.model');
const { successResponse, errorResponse } = require('../utils/response');


exports.saveFcmToken = async (req, res) => {
    try {
        const { fcm_token } = req.body;
        const user_id = req.user?.user_id;

        if (!user_id || !fcm_token) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        const savedToken = await saveFcm({ user_id, fcm_token });

        return successResponse(res, 'FCM token saved successfully', savedToken);
    } catch (err) {
        console.error('Error saving FCM token:', err);
        return errorResponse(res, 'Failed to save FCM token', 500);
    }
};
exports.deleteFcmToken = async (req, res) => {
    try { const { fcm_token } = req.body; if (!req.user?.user_id || !fcm_token) return res.status(400).json({ error: 'FCM token is required' }); await deleteFcm({ user_id: req.user.user_id, fcm_token }); return successResponse(res, 'FCM token removed successfully'); }
    catch (err) { return errorResponse(res, 'Failed to remove FCM token', 500); }
};
