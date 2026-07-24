const { validationResult } = require('express-validator');
const userModel = require('../models/user.model');
const { successResponse, errorResponse } = require('../utils/response');
const roleModel = require('../models/role.model.js');
const smsService = require('../utils/smsService');


const authController = {
  async register(req, res, next) {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email, region_id, train_ids } = req.body;

    const existingUser = await userModel.findByEmail(email);
    if (existingUser) {
      return errorResponse(res, 'User already exists with this email', 400);
    }

    const registrationData = {
      ...req.body,
      region_id: Array.isArray(region_id) ? region_id : (region_id ? [region_id] : []),
      train_ids: Array.isArray(train_ids) ? train_ids : (req.body.train_id ? [req.body.train_id] : [])
    };

    const newUser = await userModel.create(registrationData);

    return successResponse(
      res,
      'Registration successful. Please wait for admin approval.',
      { 
        id: newUser.user_id, 
        name: `${req.body.first_name} ${req.body.last_name || ''}`.trim(), 
        email: email 
      },
      201
    );
  } catch (error) {
    console.error("Registration Error:", error);
    next(error);
  }
},

  async login(req, res, next) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { email, password } = req.body;

      const user = await userModel.findByEmail(email);
      if (!user) {
        return errorResponse(res, 'Invalid credentials', 401);
      }

      const fullUserData = await userModel.getFullUserDetail(user.user_id);

      if (user.approval_status == "Pending") {
        return errorResponse(res, 'Your account is pending approval from admin', 403);
      } else if (user.approval_status === "Rejected") {
        return errorResponse(res, 'Your account has been rejected by admin', 403);
      }

      const isMatch = await userModel.validatePassword(user, password);
      if (!isMatch) {
        return errorResponse(res, 'Invalid credentials', 401);
      }

      const token = userModel.generateAuthToken(user);

      const { password_hash, ...userData } = fullUserData;

      return successResponse(res, 'Login successful', {
        user: userData,
        token
      });
    } catch (error) {
      next(error);
    }
  },

  async getPendingUsers(req, res, next) {
    try {
      const currentUser = req.user;
      const filters = {
        status: req.query.status,
        organisation_type: req.query.organisation_type,
        from_date: req.query.from_date,
        to_date: req.query.to_date,
      };

      const users = await userModel.getPendingUsersByScope(currentUser, filters);
      return successResponse(res, 'Pending users fetched', users);
    } catch (error) {
      next(error);
    }
  },


  async approveUserWithRoleChange(req, res, next) {
    try {
      const { approval_status, role_id, target_user_id } = req.body;
      const currentUser = req.user;

      const targetUser = await userModel.findOne({ user_id: target_user_id });
      if (!targetUser) return errorResponse(res, 'User not found', 404);

      if (target_user_id === currentUser.user_id) {
        return errorResponse(res, 'You cannot approve your own account', 400);
      }

      const currentUserRole = await roleModel.getRoleNameById(currentUser.role_id);
      const targetUserRole = await roleModel.getRoleNameById(targetUser.role_id);

      if (currentUserRole === targetUserRole) {
        return errorResponse(res, 'Cannot approve users with the same role', 400);
      }

      const authorized = await userModel.isApproverAuthorized(currentUser, targetUser, currentUserRole);
      if (!authorized) return errorResponse(res, 'Not authorized to approve this user', 403);

      await userModel.approveUserWithRoleChange(target_user_id, approval_status, role_id);
      return successResponse(res, `User ${approval_status} successfully`);
    } catch (error) {
      next(error);
    }
  },

  async bulkApproveUsers(req, res, next) {
    try {
      const { users } = req.body;
      const currentUser = req.user;

      if (!Array.isArray(users) || users.length === 0) {
        return errorResponse(res, 'Users array is required', 400);
      }

      const results = [];

      for (const user of users) {
        const { target_user_id, role_id, approval_status } = user;

        if (target_user_id === currentUser.user_id) {
          results.push({ target_user_id, status: 'failed', reason: 'Cannot approve your own account' });
          continue;
        }

        const targetUser = await userModel.findOne({ user_id: target_user_id });
        if (!targetUser) {
          results.push({ target_user_id, status: 'failed', reason: 'User not found' });
          continue;
        }

        const currentUserRole = await roleModel.getRoleNameById(currentUser.role_id);
        const targetUserRole = await roleModel.getRoleNameById(targetUser.role_id);

        if (currentUserRole === targetUserRole) {
          results.push({ target_user_id, status: 'failed', reason: 'Cannot approve users with the same role' });
          continue;
        }

        const authorized = await userModel.isApproverAuthorized(currentUser, targetUser, currentUserRole);
        if (!authorized) {
          results.push({ target_user_id, status: 'failed', reason: 'Not authorized' });
          continue;
        }

        await userModel.approveUserWithRoleChange(target_user_id, approval_status, role_id);
        results.push({ target_user_id, status: 'success' });
      }

      return successResponse(res, 'Bulk approval process completed', { results });

    } catch (error) {
      next(error);
    }
  },

  async getProfile(req, res, next) {
    try {
      const userId = req.user.user_id;
      const user = await userModel.findOne({ user_id: userId });

      if (!user) {
        return errorResponse(res, 'User not found', 404);
      }

      const { password_hash, ...userData } = user;
      return successResponse(res, 'Profile fetched successfully', userData);
    } catch (error) {
      next(error);
    }
  },

  async updateProfile(req, res, next) {
    try {
      const userId = req.user.user_id;
      const updateData = req.body;

      delete updateData.password_hash;
      delete updateData.role_id;
      delete updateData.approval_status;

      const updatedUser = await userModel.update(userId, updateData);
      
      const user = await userModel.findOne({ user_id: userId });
      const { password_hash, ...userData } = user;

      return successResponse(res, 'Profile updated successfully', userData);
    } catch (error) {
      next(error);
    }
  },

  async sendOtp(req, res, next) {
    try {
      const { mobile_number } = req.body;
      if (!mobile_number) return errorResponse(res, 'Mobile number is required', 400);
      const result = await smsService.sendOtp(mobile_number);
      return successResponse(res, result.message, { otp: result.otp });
    } catch (error) {
      next(error);
    }
  },

  async verifyOtp(req, res, next) {
    try {
      const { mobile_number, otp } = req.body;
      if (!mobile_number || !otp) return errorResponse(res, 'Mobile number and OTP are required', 400);
      const result = smsService.verifyOtp(mobile_number, otp);
      if (!result.success) return errorResponse(res, result.message, 400);
      return successResponse(res, result.message);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = authController;