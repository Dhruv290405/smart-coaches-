const admin = require("../config/firebase");
const supabaseAdmin = require("../config/supabaseAdmin");
const rbac = require("./rbac");
const emailService = require("./emailService");

/**
 * Map an in-app notification `type` to an RBAC module key. Types that are not
 * tied to a division-scoped telemetry module map to null (never scoped).
 */
const TYPE_TO_MODULE = {
  ODOUR: 'odour',
  HOT_AXLE: 'hot_axle_section1',
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
  const key = fromData || TYPE_TO_MODULE[type] || null;
  return key && SCOPED_MODULES.has(key) ? key : null;
}

/**
 * Decide whether a (pseudo) user should receive a notification for `moduleKey`.
 * Admins always receive. Users whose division is not in the module map keep the
 * legacy "receive everything" behaviour.
 */
function userMatchesScope(user, moduleKey, location) {
  if (rbac.isAdmin(user)) return true;

  if (!rbac.getUserLocation(user)) return false;

  const moduleAllowed = (key) => {
    if (!key) return true;
    if (key === 'hot_axle_section1' || key === 'hot_axle_section2') {
      return (
        rbac.isModuleAuthorized(user, 'hot_axle_section1') ||
        rbac.isModuleAuthorized(user, 'hot_axle_section2')
      );
    }
    return rbac.isModuleAuthorized(user, key);
  };

  if (!moduleAllowed(moduleKey)) return false;

  if (location) {
    // Suffix-aware match: a "Jaipur" user should match "Jaipur_N1"/"Jaipur_N2".
    const target = String(location).trim().toLowerCase();
    const locs = rbac.getUserLocations(user).map((l) => String(l).trim().toLowerCase());
    const matches = locs.some(
      (l) => target === l || target.startsWith(`${l}_`) || target.startsWith(`${l} `)
    );
    if (!matches) return false;
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
    .select('fcm_token, user_id');

  if (error) {
    console.error("❌ Failed to fetch FCM tokens:", error.message);
    return { tokens: [], userIds: [] };
  }

  const userIds = [...new Set((rows || []).map((r) => r.user_id).filter((id) => id != null))];
  if (userIds.length === 0) return { tokens: [], userIds: [] };

  // No scoping needed — behave exactly like before.
  if (!moduleKey) {
    const tokens = [];
    for (const row of (rows || [])) if (row.fcm_token) tokens.push(row.fcm_token);
    return { tokens, userIds };
  }

  const { data: users, error: userErr } = await supabaseAdmin
    .from('user_master')
    .select(`
      user_id, role_id,
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
      role_id: u.role_id,
      zone_name: Array.isArray(u.zone_master) ? u.zone_master[0]?.name : u.zone_master?.name || null,
      division_name: Array.isArray(u.division_master) ? u.division_master[0]?.name : u.division_master?.name || null,
      region_name: Array.isArray(u.region_master) ? u.region_master[0]?.name : u.region_master?.name || null,
    };
    if (userMatchesScope(pseudo, moduleKey, location)) allowedUserIds.add(u.user_id);
  }

  const tokens = [];
  for (const row of (rows || [])) {
    if (row.fcm_token && allowedUserIds.has(row.user_id)) tokens.push(row.fcm_token);
  }
  return { tokens, userIds: [...allowedUserIds] };
}

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

    for (const token of tokens) {
      await sendPushNotification(token, title, body, data);
    }

    await saveInAppNotifications(title, body, type, userIds);

    // Email channel (Brevo) — only for allow-listed alert types, throttled.
    await emailService.sendAlertEmails(userIds, title, body, type);
  } catch (err) {
    console.error("❌ broadcastPushNotification error:", err.message);
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
    const { userIds } = await resolveRecipients(moduleKey, location);
    await saveInAppNotifications(title, body, type, userIds);

    // Email channel (Brevo) — only for allow-listed alert types, throttled.
    await emailService.sendAlertEmails(userIds, title, body, type);
  } catch (err) {
    console.error("❌ saveInAppNotificationForAllUsers error:", err.message);
  }
}

module.exports = {
  sendPushNotification,
  broadcastPushNotification,
  saveInAppNotificationForAllUsers,
  saveInAppNotifications,
  resolveRecipients,
};
