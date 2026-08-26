const admin = require("../config/firebase");
const supabaseAdmin = require("../config/supabaseAdmin");

/**
 * Send push notification via FCM
 */
async function sendPushNotification(fcmToken, title, body, data = {}) {
  const message = {
    token: fcmToken,
    notification: { title, body },
    android: {
      notification: {
        sound: 'default',
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      },
      priority: 'high',
    },
    data: Object.fromEntries(
      Object.entries(data).map(([k, v]) => [k, String(v)])
    ),
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("✅ Notification sent:", response);
    return response;
  } catch (error) {
    console.error("❌ FCM error:", error);
  }
}

/**
 * Broadcast a push notification to every registered FCM token AND save an
 * in-app notification row for every user (so it also appears in the bell).
 * Mirrors the water-level module behaviour (no location scoping yet).
 * `type` is used by the app to route the tap to the right module screen.
 */
async function broadcastPushNotification(title, body, type, data = {}) {
  try {
    const { data: rows, error } = await supabaseAdmin
      .from('user_fcm_tokens')
      .select('fcm_token, user_id');

    if (error) {
      console.error("❌ Failed to fetch FCM tokens:", error.message);
      return;
    }

    const tokens = [];
    const userIds = new Set();
    for (const row of (rows || [])) {
      if (row.fcm_token) tokens.push(row.fcm_token);
      if (row.user_id != null) userIds.add(row.user_id);
    }

    for (const token of tokens) {
      await sendPushNotification(token, title, body, data);
    }

    await saveInAppNotificationForAllUsers(title, body, type);
  } catch (err) {
    console.error("❌ broadcastPushNotification error:", err.message);
  }
}

/**
 * Save an in-app notification row for every user (so it appears in the bell).
 * User list is derived from registered FCM tokens.
 */
async function saveInAppNotificationForAllUsers(title, body, type) {
  try {
    const { data: rows, error } = await supabaseAdmin
      .from('user_fcm_tokens')
      .select('user_id');
    if (error) {
      console.error("❌ Failed to fetch users for notifications:", error.message);
      return;
    }
    const userIds = new Set();
    for (const row of (rows || [])) {
      if (row.user_id != null) userIds.add(row.user_id);
    }
    if (userIds.size === 0) return;

    const inserts = Array.from(userIds).map(uid => ({
      user_id: uid,
      title,
      message: body,
      type,
      is_read: false,
    }));
    const { error: insErr } = await supabaseAdmin
      .from('user_notifications')
      .insert(inserts);
    if (insErr) console.error("❌ Failed to save in-app notifications:", insErr.message);
  } catch (err) {
    console.error("❌ saveInAppNotificationForAllUsers error:", err.message);
  }
}

module.exports = { sendPushNotification, broadcastPushNotification, saveInAppNotificationForAllUsers };
