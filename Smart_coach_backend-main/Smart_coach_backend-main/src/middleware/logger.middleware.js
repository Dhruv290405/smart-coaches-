/**
 * Structured Logging Middleware
 *
 * Logs userId, roleId, zoneId, divisionId, regionId, endpoint, method,
 * execution time, and errors for every API request.
 */

function logRequest(req, res, next) {
  const start = Date.now();
  const user = req.user || {};
  const logData = {
    userId: user.user_id || 'anonymous',
    roleId: user.role_id || 'N/A',
    zoneId: user.zone_id || 'N/A',
    divisionId: user.division_id || 'N/A',
    regionId: user.region_id || 'N/A',
    method: req.method,
    endpoint: req.originalUrl || req.url,
    timestamp: new Date().toISOString()
  };

  // Capture response finish
  res.on('finish', () => {
    const duration = Date.now() - start;
    logData.statusCode = res.statusCode;
    logData.duration = `${duration}ms`;
    console.log(`[AUDIT] ${JSON.stringify(logData)}`);
  });

  // Capture errors
  res.on('close', () => {
    if (res.statusCode >= 400) {
      console.error(`[ERROR] ${JSON.stringify({ ...logData, statusCode: res.statusCode })}`);
    }
  });

  next();
}

module.exports = { logRequest };
