const admin = require("../config/firebase");
const supabaseAdmin = require("../config/supabaseAdmin");
const rbac = require("./rbac");
const emailService = require("./emailService");
const smsAlertService = require("../services/smsAlert.service");

const DLT_TEMPLATE_ID = process.env.DLT_TEMPLATE_ID || '1077537860081116008';
const DLT_CONTENT_TEMPLATE = `SmartCoaches Railway Coach Monitoring Alert: [alphanumeric].
Immediate action required for train safety.
Check dashboard now. - Mirtha technology`;

/**
 * Builds the exact SMS message fitting the approved DLT content template:
 * SmartCoaches Railway Coach Monitoring Alert: [alphanumeric]. Immediate action required for train safety. Check dashboard now. - Mirtha technology.
 */
function buildDltSmsMessage(title, data = {}) {
  let variableText = '';
  if (typeof title === 'string' && title.startsWith('Alert:')) {
    variableText = title.trim();
  } else {
    const faultName = data.fault_name || data.status || title || 'Fault Alert';
    const trainNo = data.train_no || data.Train_no || 'Unknown';
    const coachNo = data.coach_no || data.coach_number || 'Unknown';
    const deviceId = data.device_id || data.deviceId || 'Device';
    const now = new Date();
    const pad = (n) => String(n).padStart(2, '0');
    const timestamp = data.timestamp || `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}`;
    variableText = `Alert: ${faultName} in Train ${trainNo}, Coach_Unique Id ${coachNo}, Device ${deviceId} | ${timestamp}`;
  }

  // Remove any trailing period from variableText so it doesn't create duplicate dots before ". Immediate action"
  variableText = variableText.replace(/\.+$/, '');

  // Wrap inside the exact registered DLT template
  return `SmartCoaches Railway Coach Monitoring Alert: ${variableText}. Immediate action required for train safety. Check dashboard now. - Mirtha technology.`;
}

/**
 * Map an in-app notification `type` to an RBAC module key. Types that are not
 * tied to a division-scoped telemetry module map to null (never scoped).
 */
const TYPE_TO_MODULE = {
  ODOUR: 'odour',
  HOT_AXLE: 'hot_axle_section2',
  ACP: 'acp',
  BRAKE_BINDING: 'brake_binding',
  CR_OVERCHARGE: 'brake_binding',
  WATER: null,
  DIESEL: null,
};

/**
 * Only these module keys are division-scoped. Anything else (e.g. diesel, water)
 * is broadcast to everyone as before so we never silently drop alerts.
 */
const SCOPED_MODULES = new Set([
  'acp',
  'hot_axle_section1',
  'hot_axle_section2',
  'bc_pressure',
  'sensor_config',
  'odour',
  'brake_binding',
]);

function resolveModuleKey(type, data = {}) {
  const fromData = data && data.module ? String(data.module) : null;
  const mappedType = TYPE_TO_MODULE[type] || null;
  const key = fromData && SCOPED_MODULES.has(fromData) ? fromData : mappedType;
  return key && SCOPED_MODULES.has(key) ? key : null;
}

/**
 * Decide whether a (pseudo) user should receive a notification for `moduleKey`.
 * Admins always receive. Users whose division is not in the module map keep the
 * legacy "receive everything" behaviour.
 */
function normaliseLocationAlias(str) {
  if (!str) return '';
  let s = String(str).trim().toLowerCase();
  s = s.replace(/[\(\)\-_]/g, ' ').replace(/\s+/g, ' ').trim();
  if (s.includes('kolkatta') || s.includes('kolkata') || s.includes('howrah')) {
    return 'kolkata_howrah';
  }
  return s;
}

function locationMatchesScope(userLocations, targetLocation) {
  if (!targetLocation || targetLocation === 'unknown' || targetLocation === 'all') return true;

  const normTarget = normaliseLocationAlias(targetLocation);

  return userLocations.some((loc) => {
    const normUserLoc = normaliseLocationAlias(loc);
    if (!normUserLoc) return false;
    if (normUserLoc === normTarget) return true;
    return rbac.locationMatches(normUserLoc, normTarget);
  });
}

function userMatchesScope(user, moduleKey, location) {
  if (rbac.isUnrestrictedUser(user)) return true;

  if (!rbac.getUserLocation(user)) return false;

  if (moduleKey && !rbac.isModuleLocationOwner(user, moduleKey)) return false;

  if (location) {
    const locs = rbac.getUserLocations(user);
    if (!locationMatchesScope(locs, location)) return false;
  }
  return true;
}

/**
 * Resolve the FCM tokens + user ids that should receive a notification for the
 * given module (and optional location).
 */
async function resolveRecipients(moduleKey, location = null) {
  const { data: rows, error } = await supabaseAdmin
    .from('user_fcm_tokens')
    .select('id, fcm_token, user_id')
    .order('id', { ascending: false });

  if (error) {
    console.error("❌ Failed to fetch FCM tokens:", error.message);
    return { tokens: [], userIds: [] };
  }

  const userIds = [...new Set((rows || []).map((r) => r.user_id).filter((id) => id != null))];
  console.log("[push-debug] moduleKey=" + moduleKey + " location=" + location + " totalRows=" + (rows||[]).length + " userIds=" + userIds.length);
  if (userIds.length === 0) return { tokens: [], userIds: [] };

  // No scoping needed — behave exactly like before.
  if (!moduleKey) {
    const tokens = [];
    const seen = new Set();
    for (const row of (rows || [])) {
      if (row.fcm_token && !seen.has(row.fcm_token)) {
        seen.add(row.fcm_token);
        tokens.push(row.fcm_token);
      }
    }
    return { tokens, userIds };
  }

  const { data: users, error: userErr } = await supabaseAdmin
    .from('user_master')
    .select(`
      user_id, email, role_id,
      zone_master!left(name),
      division_master!left(name),
      region_master!left(name)
    `)
    .in('user_id', userIds);

  if (userErr) {
    console.error("❌ Failed to fetch users for notification scoping:", userErr.message);
    return { tokens: [], userIds: [] };
  }

  const allowedUserIds = new Set();
  for (const u of (users || [])) {
    const pseudo = {
      user_id: u.user_id,
      email: u.email,
      role_id: u.role_id,
      zone_name: Array.isArray(u.zone_master) ? u.zone_master[0]?.name : u.zone_master?.name || null,
      division_name: Array.isArray(u.division_master) ? u.division_master[0]?.name : u.division_master?.name || null,
      region_name: Array.isArray(u.region_master) ? u.region_master[0]?.name : u.region_master?.name || null,
    };
    if (userMatchesScope(pseudo, moduleKey, location)) allowedUserIds.add(u.user_id);
  }

  // Pick the most recent active tokens per allowed user (up to 3 per user) to avoid
  // slow broadcasts to dozens of expired tokens.
  const userTokenCount = {};
  const tokens = [];
  const seenTokens = new Set();
  for (const row of (rows || [])) {
    if (row.fcm_token && allowedUserIds.has(row.user_id)) {
      if (!seenTokens.has(row.fcm_token)) {
        seenTokens.add(row.fcm_token);
        const count = userTokenCount[row.user_id] || 0;
        if (count < 3) {
          userTokenCount[row.user_id] = count + 1;
          tokens.push(row.fcm_token);
        }
      }
    }
  }

  console.log("[push-debug] allowedUserIds=" + allowedUserIds.size + " finalTokens=" + tokens.length);
  return { tokens, userIds: [...allowedUserIds] };
}

/**
 * Send push notification via FCM
 */
async function sendPushNotification(fcmToken, title, body, data = {}) {
  const message = {
    token: fcmToken,
    notification: {
      title,
      body,
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'high_importance_channel',
        sound: 'default',
        priority: 'high',
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        defaultSound: true,
        defaultVibrateTimings: true,
      },
    },
    data: Object.fromEntries(
      Object.entries(data || {}).map(([k, v]) => [k, String(v != null ? v : '')])
    ),
  };

  try {
    const response = await admin.messaging().send(message);
    console.log(`✅ [FCM] Notification sent to ${fcmToken.slice(0, 10)}...: ${response}`);
    return response;
  } catch (error) {
    console.error(`❌ [FCM] Error for token ${fcmToken.slice(0, 10)}...:`, error.code || error.message);
    if (
      error.code === 'messaging/registration-token-not-registered' ||
      error.code === 'messaging/invalid-registration-token' ||
      (error.message && error.message.includes('Requested entity was not found'))
    ) {
      supabaseAdmin
        .from('user_fcm_tokens')
        .delete()
        .eq('fcm_token', fcmToken)
        .then(() => console.log(`🧹 [FCM] Cleaned stale token ${fcmToken.slice(0, 10)}... from DB`))
        .catch(() => {});
    }
  }
}

/**
 * Broadcast a push notification to the users authorized for the notification's
 * module (division-scoped via RBAC) AND save an in-app notification row for the
 * same users (so it appears in each user's bell).
 *
 * `scope.location` (optional) further narrows recipients to that location.
 */
async function broadcastPushNotification(title, body, type, data = {}, scope = {}) {
  try {
    const moduleKey = scope.module || resolveModuleKey(type, data);
    const location = scope.location || data.location || data.train_location || null;

    const { tokens, userIds } = await resolveRecipients(moduleKey, location);
    console.log(`[push] module=${moduleKey} location=${location} tokens=${tokens.length} users=${userIds.length}`);

    await Promise.allSettled(tokens.map((token) => sendPushNotification(token, title, body, data)));

    await saveInAppNotifications(title, body, type, userIds);

    // Email channel (Brevo) — only for allow-listed alert types, throttled.
    // When a location is known, email only users whose data scope matches it.
    await emailService.sendAlertEmails(userIds, title, body, type, { location });

    // SMS channel — location-scoped, severity-based recipient filtering.
    const severity = (data && data.severity) ? String(data.severity).toLowerCase() : 'warning';
    if (location) {
      try {
        await smsAlertService.sendLocationAlert(location, severity, `SmartCoaches Railway Coach Monitoring Alert: ${title}. Immediate action required for train safety. Check dashboard now. -SmartCoaches`.slice(0, 160), process.env.DLT_TEMPLATE_ID);
      } catch (smsErr) {
        console.error('❌ SMS alert error:', smsErr.message);
      }
    }
  } catch (err) {
    console.error("ERR", err.message);
  }
}

/**
 * Save in-app notification rows for the given user ids. When `userIds` is not
 * provided, falls back to every registered user (legacy behaviour).
 */
async function saveInAppNotifications(title, body, type, userIds) {
  try {
    let ids = userIds;
    if (!ids) {
      const { data: rows, error } = await supabaseAdmin
        .from('user_fcm_tokens')
        .select('user_id');
      if (error) {
        console.error("❌ Failed to fetch users for notifications:", error.message);
        return;
      }
      ids = [...new Set((rows || []).map((r) => r.user_id).filter((u) => u != null))];
    }
    if (!ids || ids.length === 0) return;

    const cutoff = new Date(Date.now() - 2 * 60 * 1000).toISOString();
    const { data: recent, error: recentError } = await supabaseAdmin
      .from('user_notifications')
      .select('user_id')
      .in('user_id', ids)
      .eq('title', title)
      .eq('message', body)
      .eq('type', type)
      .gte('created_at', cutoff);
    if (recentError) throw recentError;

    const recentIds = new Set((recent || []).map((row) => row.user_id));
    const freshIds = ids.filter((uid) => !recentIds.has(uid));
    if (freshIds.length === 0) return;

    const inserts = freshIds.map((uid) => ({
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
    console.error("❌ saveInAppNotifications error:", err.message);
  }
}

/**
 * Backwards-compatible entry point used by controllers that only write in-app
 * rows (e.g. brake binding). Scopes by module when `type` maps to one.
 */
async function saveInAppNotificationForAllUsers(title, body, type, scope = {}) {
  try {
    const moduleKey = scope.module || resolveModuleKey(type, {});
    const location = scope.location || null;
    const { tokens, userIds } = await resolveRecipients(moduleKey, location);
    await saveInAppNotifications(title, body, type, userIds);

    // Push channel (FCM)
    await Promise.allSettled(tokens.map((token) => sendPushNotification(token, title, body, { type, ...scope })));

    // Email channel (Brevo) — only for allow-listed alert types, throttled.
    // When a location is known, email only users whose data scope matches it.
    await emailService.sendAlertEmails(userIds, title, body, type, { location });

    // SMS channel — location-scoped, severity-based recipient filtering.
    const severity = (scope && scope.severity) ? String(scope.severity).toLowerCase() : 'warning';
    if (location) {
      try {
        await smsAlertService.sendLocationAlert(location, severity, `SmartCoaches Railway Coach Monitoring Alert: ${title}. Immediate action required for train safety. Check dashboard now. -SmartCoaches`.slice(0, 160), process.env.DLT_TEMPLATE_ID);
      } catch (smsErr) {
        console.error('❌ SMS alert error:', smsErr.message);
      }
    }
    } catch (err) {
      console.error("ERR", err.message);
    }
}

module.exports = {
  sendPushNotification,
  broadcastPushNotification,
  saveInAppNotificationForAllUsers,
  saveInAppNotifications,
  resolveRecipients,
  DLT_TEMPLATE_ID,
  DLT_CONTENT_TEMPLATE,
  buildDltSmsMessage,
};
