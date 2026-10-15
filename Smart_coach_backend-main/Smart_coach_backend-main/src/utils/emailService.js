const supabaseAdmin = require('../config/supabaseAdmin');

const BREVO_API_URL = 'https://api.brevo.com/v3/smtp/email';

const DEFAULT_ALERT_TYPES = 'BRAKE_BINDING,CR_OVERCHARGE,HOT_AXLE,ACP,ODOUR';

// In-memory throttle state (resets on server restart, which is fine).
const lastSentByKey = new Map();
let sentToday = 0;
let dayStamp = new Date().toISOString().slice(0, 10);

function isConfigured() {
  return !!(process.env.BREVO_API_KEY && process.env.BREVO_SENDER_EMAIL);
}

/**
 * Email alerts are opt-in via env. When EMAIL_ALERTS_ENABLED is not 'false' and
 * Brevo is configured, email alerts are on.
 */
function isEnabled() {
  if (String(process.env.EMAIL_ALERTS_ENABLED || '').toLowerCase() === 'false') {
    return false;
  }
  return isConfigured();
}

function allowedTypes() {
  const raw = process.env.EMAIL_ALERT_TYPES || DEFAULT_ALERT_TYPES;
  return new Set(
    raw
      .split(',')
      .map((s) => s.trim().toUpperCase())
      .filter(Boolean)
  );
}

function cooldownMs() {
  const parsed = parseInt(process.env.EMAIL_ALERT_COOLDOWN_MS || '', 10);
  return Number.isFinite(parsed) && parsed >= 0 ? parsed : 15 * 60 * 1000;
}

function dailyLimit() {
  const parsed = parseInt(process.env.EMAIL_DAILY_LIMIT || '', 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : 250;
}

function rollDay() {
  const today = new Date().toISOString().slice(0, 10);
  if (today !== dayStamp) {
    dayStamp = today;
    sentToday = 0;
    lastSentByKey.clear();
  }
}

async function sendTransactionalEmail(to, subject, html) {
  if (!isConfigured()) throw new Error('Brevo email is not configured');

  const senderName = process.env.BREVO_SENDER_NAME || 'Smart Coach';
  const response = await fetch(BREVO_API_URL, {
    method: 'POST',
    headers: {
      accept: 'application/json',
      'api-key': process.env.BREVO_API_KEY,
      'content-type': 'application/json',
    },
    body: JSON.stringify({
      sender: { name: senderName, email: process.env.BREVO_SENDER_EMAIL },
      to: [{ email: to }],
      subject,
      htmlContent: html,
    }),
  });

  if (!response.ok) {
    const details = await response.text();
    throw new Error(`Brevo send failed (${response.status}): ${details}`);
  }
}

async function getEmailsForUsers(userIds) {
  const ids = [...new Set((userIds || []).filter((id) => id != null))];
  if (ids.length === 0) return [];

  const { data, error } = await supabaseAdmin
    .from('user_master')
    .select('user_id, email, first_name')
    .in('user_id', ids);
  if (error) {
    console.error('[EMAIL] Failed to fetch recipient emails:', error.message);
    return [];
  }
  return (data || []).filter((u) => u.email && String(u.email).includes('@'));
}

function buildAlertHtml(title, body, type) {
  const safe = (v) =>
    String(v == null ? '' : v)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;');
  return `
    <div style="font-family:Arial,sans-serif;font-size:14px;color:#222;">
      <p style="display:inline-block;background:#c62828;color:#fff;border-radius:4px;padding:2px 8px;font-size:12px;">
        ${safe(type)}
      </p>
      <h2 style="margin:12px 0 6px;">${safe(title)}</h2>
      <p style="margin:0 0 16px;">${safe(body)}</p>
      <p style="color:#777;font-size:12px;margin-top:24px;">
        Smart Coach automated alert. Please log in to the app for full details.
      </p>
    </div>
  `;
}

/**
 * Send an alert email via Brevo to the given users, honouring the type
 * allowlist, a per-recipient/per-type cooldown, and a daily cap so we stay
 * within Brevo's quota.
 */
async function sendAlertEmails(userIds, title, body, type) {
  try {
    if (!isEnabled()) return { sent: 0, skipped: 'disabled' };

    const typeKey = String(type || '').toUpperCase();
    if (!typeKey || !allowedTypes().has(typeKey)) {
      return { sent: 0, skipped: 'type_not_allowed' };
    }

    rollDay();
    const limit = dailyLimit();
    if (sentToday >= limit) return { sent: 0, skipped: 'daily_limit' };

    const recipients = await getEmailsForUsers(userIds);
    if (recipients.length === 0) return { sent: 0, skipped: 'no_recipients' };

    const cooldown = cooldownMs();
    const now = Date.now();
    const subject = `[Smart Coach] ${title}`;
    const html = buildAlertHtml(title, body, typeKey);

    let sent = 0;
    for (const user of recipients) {
      if (sentToday >= limit) break;
      const key = `${String(user.email).toLowerCase()}|${typeKey}`;
      if (now - (lastSentByKey.get(key) || 0) < cooldown) continue;
      try {
        await sendTransactionalEmail(user.email, subject, html);
        lastSentByKey.set(key, now);
        sentToday++;
        sent++;
      } catch (err) {
        console.error(`[EMAIL] Failed to send "${typeKey}" to ${user.email}: ${err.message}`);
      }
    }
    if (sent > 0) console.log(`[EMAIL] Sent ${sent} "${typeKey}" alert email(s).`);
    return { sent };
  } catch (err) {
    console.error('[EMAIL] sendAlertEmails error:', err.message);
    return { sent: 0, skipped: 'error' };
  }
}

module.exports = {
  isConfigured,
  isEnabled,
  allowedTypes,
  sendTransactionalEmail,
  sendAlertEmails,
};
