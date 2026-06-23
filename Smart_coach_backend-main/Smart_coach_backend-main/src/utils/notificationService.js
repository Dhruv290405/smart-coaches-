const admin = require("../config/firebase");

/**
 * Send push notification via FCM
 */
async function sendPushNotification(fcmToken, title, body, data = {}) {
  const message = {
    token: fcmToken,
    notification: { title, body },
    data: Object.fromEntries(
      Object.entries(data).map(([k, v]) => [k, String(v)]) // ensure all values are strings
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

module.exports = { sendPushNotification };
