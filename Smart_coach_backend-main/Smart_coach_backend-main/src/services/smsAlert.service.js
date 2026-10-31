const supabaseAdminClient = require('../config/supabaseAdmin');
const supabaseAdmin = supabaseAdminClient.supabaseAdmin || supabaseAdminClient;
const rbac = require('../utils/rbac');
const sms = require('./sms.service');

const DEFAULT_DLT_TEMPLATE_ID = process.env.DLT_TEMPLATE_ID || '1077529980085199915';

/**
 * Resolve SMS recipients for an alert based on location + severity or pre-resolved targetUserIds.
 * @param {string} location - division/region/zone name
 * @param {string} severity - 'critical' | 'warning' | 'info'
 * @param {Array<number>} [targetUserIds] - optional list of pre-authorized user_ids
 * @returns {Promise<Array<{user_id, first_name, mobile_number, role_name}>>}
 */
async function getRecipients(location, severity, targetUserIds = null) {
  let query = supabaseAdmin
    .from('user_master')
    .select('user_id, first_name, mobile_number, role_id, role_master!left(name), division_master!left(name), region_master!left(name), zone_master!left(name)')
    .not('mobile_number', 'is', null);

  if (targetUserIds && Array.isArray(targetUserIds) && targetUserIds.length > 0) {
    query = query.in('user_id', targetUserIds);
  }

  const { data: users, error } = await query;
  if (error || !users) {
    console.error('❌ [SMS] Error fetching recipients:', error?.message);
    return [];
  }

  // If specific authorized user IDs were passed, filter only for valid phone numbers
  if (targetUserIds && targetUserIds.length > 0) {
    return users.filter(u => u.mobile_number && String(u.mobile_number).trim().length >= 8);
  }

  if (!location) return [];
  const loc = String(location).trim().toLowerCase();

  return users.filter(u => {
    if (!u.mobile_number || String(u.mobile_number).trim().length < 8) return false;

    const divName = (Array.isArray(u.division_master) ? u.division_master[0]?.name : u.division_master?.name) || '';
    const regName = (Array.isArray(u.region_master) ? u.region_master[0]?.name : u.region_master?.name) || '';
    const zoneName = (Array.isArray(u.zone_master) ? u.zone_master[0]?.name : u.zone_master?.name) || '';
    const userLoc = (divName || regName || zoneName).toLowerCase();

    if (!userLoc) return false;
    return userLoc === loc || rbac.locationMatches(userLoc, loc);
  });
}

/**
 * Send SMS alert to authorized recipients for a location.
 * Uses the approved DLT template ID.
 */
async function sendLocationAlert(location, severity, message, templateId, targetUserIds = null) {
  const finalTemplateId = templateId || DEFAULT_DLT_TEMPLATE_ID;
  const recipients = await getRecipients(location, severity, targetUserIds);
  console.log(`[SMS] Sending alert to ${recipients.length} recipient(s) for location=${location} template=${finalTemplateId}`);
  
  const results = [];
  for (const r of recipients) {
    if (!r.mobile_number) continue;
    const res = await sms.sendAlert(r.mobile_number, message, finalTemplateId);
    results.push({ user_id: r.user_id, phone: r.mobile_number, ...res });
  }
  return results;
}

module.exports = { getRecipients, sendLocationAlert, DEFAULT_DLT_TEMPLATE_ID };
