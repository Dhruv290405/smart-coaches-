/**
 * Role-Based Access Control Filtering Engine
 *
 * Centralized location-based filtering for all monitoring modules.
 * Admin (role_id=1) bypasses all location filters.
 * Non-admin users are scoped to their assigned zone/division/region.
 */

const supabaseAdmin = require('../config/supabaseAdmin');

/**
 * Get the user's location(s) — returns an array of unique locations (division, region, zone)
 */
function getUserLocations(user) {
  if (!user) return [];
  const locs = [];
  if (user.division_name) locs.push(user.division_name);
  if (user.region_name && !locs.includes(user.region_name)) locs.push(user.region_name);
  if (user.zone_name && !locs.includes(user.zone_name)) locs.push(user.zone_name);
  return locs.length > 0 ? locs : [];
}

/**
 * Get primary location string (division > region > zone)
 */
function getUserLocation(user) {
  const locs = getUserLocations(user);
  return locs.length > 0 ? locs[0] : null;
}

/**
 * Check if user is MasterAdmin (role_id=1)
 */
function isAdmin(user) {
  if (!user) return false;
  return (
    user.role_id === 1 ||
    user.role_id === 2 ||
    user.role === 'Master' ||
    user.role === 'Super Admin' ||
    user.role_name === 'Master' ||
    user.role_name === 'Super Admin'
  );
}

/**
 * The shared tester account keeps full visibility (used by QA / demos).
 */
function isTester(user) {
  return !!user && String(user.email || '').trim().toLowerCase() === 'tester@example.com';
}

/**
 * Users that must never be location-restricted (admins + tester).
 */
function isUnrestrictedUser(user) {
  return isAdmin(user) || (user && user.role_id === 2) || isTester(user);
}

function _normaliseLocation(value) {
  return value == null ? '' : String(value).trim().toLowerCase();
}

/**
 * Case-insensitive location match, tolerant of suffixes such as
 * "Jaipur_N1" or "Nagpur Division" (same rule used for brake-binding).
 */
function locationMatches(value, target) {
  const a = _normaliseLocation(value);
  const b = _normaliseLocation(target);
  if (!a || !b) return false;
  return (
    a === b ||
    a.startsWith(b + '_') || a.startsWith(b + ' ') ||
    b.startsWith(a + '_') || b.startsWith(a + ' ')
  );
}

/**
 * Locations that own a module, per the division -> module map.
 * e.g. hot_axle_section1 -> ['Nagpur'], hot_axle_section2 -> ['Danapur'].
 */
function getModuleOwnerLocations(moduleKey) {
  return Object.entries(DIVISION_MODULE_MAP)
    .filter(([, modules]) => modules.includes(moduleKey))
    .map(([location]) => location);
}

/**
 * Strict ownership check for a module: the user must belong to one of the
 * locations that own the module. Unlike isModuleAuthorized this does NOT
 * return true for unmapped divisions, so unrelated locations cannot see
 * another location's telemetry.
 */
function isModuleLocationOwner(user, moduleKey) {
  if (!user) return false;
  if (isUnrestrictedUser(user)) return true;
  const owners = getModuleOwnerLocations(moduleKey);
  if (owners.length === 0) return false;
  const userLocations = getUserLocations(user);
  return userLocations.some(loc => owners.some(owner => locationMatches(loc, owner)));
}

/**
 * Region ids that belong to the user's division/region (used to scope config
 * lists). Returns null when the user is unrestricted, and [] when their
 * location cannot be resolved.
 */
async function getScopedRegionIds(user) {
  if (!user || isUnrestrictedUser(user)) return null;
  const locs = getUserLocations(user);
  if (locs.length === 0) return [];
  for (const loc of locs) {
    const { data: divisions } = await supabaseAdmin
      .from('division_master')
      .select('division_id')
      .ilike('name', loc);
    const divisionIds = (divisions || []).map(d => d.division_id);
    if (divisionIds.length > 0) {
      const { data: regions } = await supabaseAdmin
        .from('region_master')
        .select('region_id')
        .in('division_id', divisionIds);
      const ids = (regions || []).map(r => r.region_id);
      if (ids.length > 0) return ids;
    }
    const { data: regionRow } = await supabaseAdmin
      .from('region_master')
      .select('region_id')
      .ilike('name', loc)
      .limit(1);
    if (regionRow && regionRow.length > 0) return [regionRow[0].region_id];
  }
  return [];
}

/**
 * Map of train_id -> { region_id, origination_region_id } used to attribute
 * config rows (coaches/devices) to a region without hiding rows that have no
 * known region.
 */
async function getTrainRegionMap() {
  const { data } = await supabaseAdmin
    .from('train_master')
    .select('train_id, region_id, origination_region_id');
  const map = {};
  for (const t of data || []) map[t.train_id] = t;
  return map;
}

/**
 * true/false when a train is positively attributed to a region,
 * null when the region is unknown (caller should keep the row visible).
 */
function trainBelongsToRegions(trainMap, trainId, scopedRegionIds) {
  if (!trainId) return null;
  const train = trainMap[trainId];
  if (!train) return null;
  const regions = [train.region_id, train.origination_region_id].filter(Boolean);
  if (regions.length === 0) return null;
  const scoped = new Set(scopedRegionIds);
  return regions.some(r => scoped.has(r));
}

/**
 * Division-level module authorization mapping.
 * Specifies which telemetry modules each division is allowed to view.
 */
const DIVISION_MODULE_MAP = {
  'Danapur': ['acp', 'hot_axle_section2', 'bc_pressure', 'sensor_config'],
  'Nagpur': ['brake_binding', 'hot_axle_section1', 'sensor_config', 'odour'],
  'Howrah': ['brake_binding'],
  'Kolkata': ['brake_binding'],
  'South Eastern': ['brake_binding'],
  'Jaipur': ['brake_binding']
};

/**
 * Check if a user's location is authorized to access a specific module.
 */
function isModuleAuthorized(user, moduleKey) {
  if (isAdmin(user)) return true;
  const loc = getUserLocation(user);
  if (!loc) return false;
  
  const normalizedLoc = Object.keys(DIVISION_MODULE_MAP).find(
    k => k.toLowerCase() === loc.toLowerCase() || loc.toLowerCase().startsWith(k.toLowerCase())
  );
  if (!normalizedLoc) {
    if (moduleKey === 'odour') return false; // Bad Odour is strictly restricted to Nagpur
    return true;
  }
  return DIVISION_MODULE_MAP[normalizedLoc].includes(moduleKey);
}

/**
 * Guard: returns true if the user can proceed.
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
 * Build a filter condition object for in-memory filtering.
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
 * Get authorized device IDs for the user's location (case-insensitive).
 */
async function getAuthorizedDeviceIdsForLocation(user) {
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
 * Get coach numbers that belong to the user's location from coaches_railway.
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
    .select('Train_no')
    .ilike('Location', loc);
  return [...new Set((data || []).map(r => r.Train_no).filter(Boolean))];
}

/**
 * Express middleware: attach location info to req.user if present in JWT.
 */
function rbacMiddleware(req, res, next) {
  if (req.user && !req.user.region_name && req.user.region_id) {
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
  getUserLocations,
  getUserLocation,
  isAdmin,
  isTester,
  isUnrestrictedUser,
  locationMatches,
  getModuleOwnerLocations,
  isModuleLocationOwner,
  getScopedRegionIds,
  getTrainRegionMap,
  trainBelongsToRegions,
  requireLocation,
  isModuleAuthorized,
  DIVISION_MODULE_MAP,
  applyCoachLocationFilter,
  buildLocationCondition,
  filterByLocation,
  getAuthorizedCoachNumbers,
  getAuthorizedDeviceIds,
  getAuthorizedDeviceIdsForLocation,
  getAuthorizedTrainNumbers,
  rbacMiddleware
};
