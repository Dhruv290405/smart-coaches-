const jwt = require('jsonwebtoken');
const { errorResponse } = require('../utils/response');
const userModel = require('../models/user.model');
const roleModel = require('../models/role.model');

// Middleware to verify JWT token
const authenticate = async (req, res, next) => {
  try {
    // Get token from header
    const authHeader = req.header('Authorization');
    const token = authHeader?.split(' ')[1];
    
    if (!token) {
      return errorResponse(res, 'No token, authorization denied', 401);
    }

    // Verify token
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your_jwt_secret');
      
      // Check if user still exists
      console.log('Decoded token:', decoded);
      const user = await userModel.findOne({ email: decoded.email });
      if (!user) {
        return errorResponse(res, 'User not found', 404);
      }

      // Check if user is approved
      if (user.approval_status !== 'Approved') {
        return errorResponse(res, 'Your account is pending approval', 403);
      }

      // Attach user to request object
      req.user = user;
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