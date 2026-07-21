/**
 * Role-Based Access Control Filtering Engine
 *
 * Centralized location-based filtering for all monitoring modules.
 * Admin (role_id=1) bypasses all location filters.
 * Non-admin users are scoped to their assigned zone/division/region.
 *
 * JWT payload (set at login):
 *   user_id, email, role_id, zone_id, division_id, region_id, employee_id
 *
 * req.user (set by auth middleware via DB lookup) has:
 *   user_id, email, role_id, zone_id, division_id, region_id, employee_id,
 *   zone_name, division_name, region_name
 */

const supabaseAdmin = require('../config/supabaseAdmin');

/**
 * Get the user's location(s) — returns an array of unique locations (region, division, zone)
 * Used for broader matching so users with e.g. region=Danapur + division=Nagpur see both.
 */
function getUserLocations(user) {
  if (!user) return [];
  const locs = [];
  if (user.region_name) locs.push(user.region_name);
  if (user.division_name && !locs.includes(user.division_name)) locs.push(user.division_name);
  if (user.zone_name && !locs.includes(user.zone_name)) locs.push(user.zone_name);
  return locs.length > 0 ? locs : [];
}

/**
 * Get first location string (legacy, kept for backward compatibility)
 */
function getUserLocation(user) {
  const locs = getUserLocations(user);
  return locs.length > 0 ? locs[0] : null;
}

/**
 * Check if user is MasterAdmin (role_id=1)
 */
function isAdmin(user) {
  return user && user.role_id === 1;
}

/**
 * Guard: returns true if the user can proceed.
 * For non-admin users without a location, sends 403 and returns false.
 */
function requireLocation(user, res) {
  if (isAdmin(user)) return true;
  const loc = getUserLocation(user);
  if (!loc) {
    if (!res.headersSent) {
      res.status(403).json({
        success: false,
        message: 'Access denied: No region, division, or zone mapped to your account'
      });
    }
    return false;
  }
  return true;
}

/**
 * Apply location filter to a Supabase query on a table that has a 'Location' column.
 */
async function applyCoachLocationFilter(query, user, locationColumn = 'Location') {
  if (!query || isAdmin(user)) return query;
  const loc = getUserLocation(user);
  if (loc) query = query.ilike(locationColumn, loc);
  return query;
}

/**
 * Build a filter condition object for in-memory filtering (used with RPC results).
 */
function buildLocationCondition(user, locationColumn = 'location') {
  if (isAdmin(user)) return {};
  const loc = getUserLocation(user);
  if (loc) return { column: locationColumn, value: loc.toLowerCase() };
  return {};
}

/**
 * Filter an array of records in-memory by comparing a field against the user's location.
 */
function filterByLocation(records, user, fieldName) {
  if (isAdmin(user) || !records || records.length === 0) return records;
  const loc = getUserLocation(user);
  if (!loc) return [];
  return records.filter(r => {
    const val = r[fieldName];
    return val && val.toString().toLowerCase() === loc.toLowerCase();
  });
}

/**
 * Get coach numbers that belong to the user's location.
 * Returns distinct coach_no values from coaches_railway filtered by Location.
 */
async function getAuthorizedCoachNumbers(user) {
  if (isAdmin(user)) return null;
  const loc = getUserLocation(user);
  if (!loc) return [];
  const { data } = await supabaseAdmin
    .from('coaches_railway')
    .select('coach_no')
    .ilike('Location', loc);
  return (data || []).map(r => r.coach_no).filter(Boolean);
}

/**
 * Get device_ids that belong to the user's location.
 */
async function getAuthorizedDeviceIds(user) {
  if (isAdmin(user)) return null;
  const loc = getUserLocation(user);
  if (!loc) return [];
  const { data } = await supabaseAdmin
    .from('coaches_railway')
    .select('device_id')
    .ilike('Location', loc);
  return (data || []).map(r => r.device_id).filter(Boolean);
}

/**
 * Get train numbers that belong to the user's location.
 */
async function getAuthorizedTrainNumbers(user) {
  if (isAdmin(user)) return null;
  const loc = getUserLocation(user);
  if (!loc) return [];
  const { data } = await supabaseAdmin
    .from('coaches_railway')
    .select('train_number')
    .ilike('Location', loc);
  return [...new Set((data || []).map(r => r.train_number).filter(Boolean))];
}

/**
 * Express middleware: attach location info to req.user if present in JWT.
 * Used after JWT decode, before route handlers.
 */
function rbacMiddleware(req, res, next) {
  if (req.user && !req.user.region_name && req.user.region_id) {
    // Try to resolve region_id to region_name if not already set
    supabaseAdmin
      .from('region_master')
      .select('name')
      .eq('region_id', req.user.region_id)
      .maybeSingle()
      .then(({ data }) => {
        if (data) req.user.region_name = data.name;
        next();
      })
      .catch(() => next());
  } else {
    next();
  }
}

module.exports = {
  getUserLocation,
  isAdmin,
  requireLocation,
  applyCoachLocationFilter,
  buildLocationCondition,
  filterByLocation,
  getAuthorizedCoachNumbers,
  getAuthorizedDeviceIds,
  getAuthorizedTrainNumbers,
  rbacMiddleware
};
