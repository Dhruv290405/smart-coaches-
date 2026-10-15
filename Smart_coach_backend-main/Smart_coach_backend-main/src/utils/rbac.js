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
  return user && user.role_id === 1;
}

/**
 * Division-level module authorization mapping.
 * Specifies which telemetry modules each division is allowed to view.
 */
const DIVISION_MODULE_MAP = {
  'Danapur': ['acp', 'hot_axle_section2', 'bc_pressure', 'sensor_config', 'odour'],
  'Nagpur': ['brake_binding', 'hot_axle_section1', 'sensor_config', 'odour'],
  'Howrah': ['brake_binding', 'odour'],
  'Kolkata': ['brake_binding', 'odour'],
  'South Eastern': ['brake_binding', 'odour'],
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
    k => k.toLowerCase() === loc.toLowerCase()
  );
  if (!normalizedLoc) return true;
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
 * Resolve the region_ids that belong to a user's location, using the
 * region > division > zone hierarchy. Used to scope master/config data
 * (trains, coaches, devices, sensors) that is tagged only with region_id.
 *
 * Returns:
 *   - null  -> no filtering should be applied (admin, or user has no
 *              region/division/zone at all — avoid blanking the dashboard)
 *   - array -> the region_ids to match against (may be empty)
 */
async function getScopedRegionIds(user) {
  if (!user) return null;
  if (isAdmin(user)) return null;
  if (!user.region_id && !user.division_id && !user.zone_id) return null;

  const regionIds = new Set();

  // Use the most specific level available: division > region > zone.
  let divisionIds = [];
  if (user.division_id) {
    divisionIds = [user.division_id];
  } else if (user.region_id) {
    regionIds.add(String(user.region_id));
  } else if (user.zone_id) {
    const { data: divs } = await supabaseAdmin
      .from('division_master')
      .select('division_id')
      .eq('zone_id', user.zone_id);
    divisionIds = (divs || []).map((d) => d.division_id);
  }

  // A division user resolves to every region inside that division;
  // a region user only sees their own region.
  if (divisionIds.length > 0) {
    const { data: regions } = await supabaseAdmin
      .from('region_master')
      .select('region_id')
      .in('division_id', divisionIds);
    for (const r of regions || []) regionIds.add(String(r.region_id));
  }

  return [...regionIds];
}

/**
 * Resolve the trains (by id and number) that belong to the user's location.
 *
 * Returns:
 *   - null  -> no filtering (admin / no location) — caller should not filter
 *   - { trainIds: [], trainNumbers: [] } -> filtered set (may be empty)
 */
async function getScopedTrains(user) {
  const regionIds = await getScopedRegionIds(user);
  if (regionIds === null) return null;

  const { data: trains } = await supabaseAdmin
    .from('train_master')
    .select('train_id, train_number, region_id, origination_region_id');

  const regionSet = new Set(regionIds);
  const scoped = (trains || []).filter(
    (t) =>
      (t.region_id && regionSet.has(String(t.region_id))) ||
      (t.origination_region_id && regionSet.has(String(t.origination_region_id)))
  );

  return {
    trainIds: scoped.map((t) => t.train_id),
    trainNumbers: scoped.map((t) => t.train_number).filter(Boolean),
  };
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
  getScopedRegionIds,
  getScopedTrains,
  rbacMiddleware
};
