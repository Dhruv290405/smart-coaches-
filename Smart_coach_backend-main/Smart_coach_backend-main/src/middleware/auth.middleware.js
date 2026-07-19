const jwt = require('jsonwebtoken');
const { errorResponse } = require('../utils/response');
const supabaseAdmin = require('../config/supabaseAdmin');

// Middleware to verify JWT token
const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.header('Authorization');
    const token = authHeader?.split(' ')[1];
    
    if (!token) {
      return errorResponse(res, 'No token, authorization denied', 401);
    }

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your_jwt_secret');
      
      // Lightweight query: check user exists + is approved + get hierarchy names
      const { data: user, error } = await supabaseAdmin
        .from('user_master')
        .select(`
          user_id, email, role_id, zone_id, division_id, region_id, employee_id,
          approval_status,
          zone_master!left(name),
          division_master!left(name),
          region_master!left(name)
        `)
        .eq('user_id', decoded.user_id)
        .maybeSingle();

      if (error) throw error;
      if (!user) {
        return errorResponse(res, 'User not found', 404);
      }

      if (user.approval_status !== 'Approved') {
        return errorResponse(res, 'Your account is pending approval', 403);
      }

      req.user = {
        user_id: user.user_id,
        email: user.email,
        role_id: user.role_id,
        zone_id: user.zone_id,
        division_id: user.division_id,
        region_id: user.region_id,
        employee_id: user.employee_id,
        zone_name: user.zone_master?.name || null,
        division_name: user.division_master?.name || null,
        region_name: user.region_master?.name || null
      };

      // Fallback: resolve region_name from user_region_mapping if not set directly
      if (!req.user.region_name && req.user.region_id) {
        const { data: reg } = await supabaseAdmin
          .from('region_master')
          .select('name')
          .eq('region_id', req.user.region_id)
          .maybeSingle();
        if (reg) req.user.region_name = reg.name;
      }
      if (!req.user.region_name) {
        const { data: mappings } = await supabaseAdmin
          .from('user_region_mapping')
          .select('region_id')
          .eq('user_id', req.user.user_id)
          .limit(1);
        if (mappings && mappings.length > 0) {
          const { data: reg } = await supabaseAdmin
            .from('region_master')
            .select('name')
            .eq('region_id', mappings[0].region_id)
            .maybeSingle();
          if (reg) req.user.region_name = reg.name;
        }
      }
      next();
    } catch (err) {
      if (err.name === 'TokenExpiredError') {
        return errorResponse(res, 'Token has expired', 401);
      }
      if (err.name === 'JsonWebTokenError') {
        return errorResponse(res, 'Invalid token', 401);
      }
      throw err;
    }
  } catch (error) {
    next(error);
  }
};

// Middleware to check user role
const authorize = (roles = [], req) => {
  return async (req, res, next) => {
    try {
      if (!Array.isArray(roles)) {
        roles = [roles];
      }

      if (!req.user) {
        return errorResponse(res, 'User not authenticated', 401);
      }

      if (!roles.includes(await roleModel.getRoleNameById(req.user.role_id))) {
        return errorResponse(
          res,
          'You do not have permission to perform this action',
          403
        );
      }

      next();
    } catch (error) {
      next(error);
    }
  };
};


// Middleware to check user role
const authorizeByToken = (roles = [], req) => {
  return async (req, res, next) => {
    try {
      if (!Array.isArray(roles)) {
        roles = [roles];
      }

      if (!req.user) {
        return errorResponse(res, 'User not authenticated', 401);
      }
      console.log('User role ID:', roles);
      if (!roles.includes(await roleModel.getRoleNameById(req.user.role_id))) {
        return errorResponse(
          res,
          'You do not have permission to perform this action',
          403
        );
      }

      next();
    } catch (error) {
      next(error);
    }
  };
};

const authorizeDashboard = (allowedRoles = []) => {
  return async (req, res, next) => {
    try {
      if (!req.user) {
        return errorResponse(res, 'Authentication required for dashboard', 401);
      }

      const userRole = await roleModel.getRoleNameById(req.user.role_id);
      
      if (allowedRoles.length > 0 && !allowedRoles.includes(userRole)) {
        return errorResponse(res, `Access Denied: ${userRole} cannot view this dashboard`, 403);
      }

      next();
    } catch (error) {
      next(error);
    }
  };
};

module.exports = {
  authenticate,
  authorize,
  authorizeByToken,
  authorizeDashboard
};