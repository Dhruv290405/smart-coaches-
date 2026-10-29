const { supabaseAdmin } = require('../config/supabaseAdmin');
const rbac = require('../utils/rbac');
const sms = require('./sms.service');

/**
 * Resolve SMS recipients for an alert based on location + severity.
 * @param {string} location - division/region/zone name
 * @param {string} severity - 'critical' | 'warning' | 'info'
 * @returns {Promise<Array<{user_id, first_name, mobile_number, role_name}>>}
 */
async function getRecipients(location, severity) {
  if (!location) return [];
  const loc = location.toLowerCase();
  const { data: users, error } = await supabaseAdmin
    .from('user_master')
    .select('user_id, first_name, mobile_number, role_id, role_master!left(name), division_master!left(name), region_master!left(name), zone_master!left(name)')
    .not('mobile_number', 'is', null);
  if (error || !users) return [];

  const criticalRoles = ['master', 'regional master', 'admin', 'superadmin'];
  const opsRoles = ['operator', 'supervisor', 'manager'];

  return users.filter(u => {
    const userLoc = (u.division_master?.name || u.region_master?.name || u.zone_master?.name || '').toLowerCase();
    if (userLoc !== loc) return false;
    const roleName = (u.role_master?.name || '').toLowerCase();
    if (severity === 'critical') return criticalRoles.includes(roleName) || opsRoles.includes(roleName);
    return opsRoles.includes(roleName);
  });
}

/**
 * Send SMS alert to authorized recipients for a location.
 */
async function sendLocationAlert(location, severity, message, templateId) {
  const recipients = await getRecipients(location, severity);
  const results = [];
  for (const r of recipients) {
    if (!r.mobile_number) continue;
    const res = await sms.sendAlert(r.mobile_number, message, templateId);
    results.push({ user_id: r.user_id, phone: r.mobile_number, ...res });
  }
  return results;
}

module.exports = { getRecipients, sendLocationAlert };
PY