require('dotenv').config();
const { broadcastPushNotification } = require('./src/utils/notificationService');
(async () => {
  try {
    const r = await broadcastPushNotification('FCM Test Push', 'This should appear in phone panel now', 'TEST');
    console.log('BROADCAST RESULT:', JSON.stringify(r, null, 2));
  } catch (e) {
    console.log('THREW:', e && e.message);
  }
  process.exit(0);
})();
