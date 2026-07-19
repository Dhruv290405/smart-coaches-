const rbac = require('../utils/rbac');

/**
 * Middleware: requires the user to have a location (region/division/zone).
 * Admin (role_id=1) always passes. Non-admins without location get 403.
 */
function requireLocation(req, res, next) {
  if (rbac.requireLocation(req.user, res)) {
    next();
  }
}

/**
 * Middleware: filters query results in-memory by the user's location.
 * Pass the field name to filter on (e.g., 'Location', 'loc_name', 'coach_no').
 * Only applies to non-admin users.
 */
function filterByLocation(fieldName) {
  return (req, res, next) => {
    if (rbac.isAdmin(req.user) || !req.user) {
      // Admin passes through — no filtering needed
      // Store a flag so controllers know not to apply location filter
      req.isAdminOrNoFilter = true;
      return next();
    }
    req.userLocation = rbac.getUserLocation(req.user);
    req.locationField = fieldName;
    next();
  };
}

module.exports = { requireLocation, filterByLocation };
