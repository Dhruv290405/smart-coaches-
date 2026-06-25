const express = require('express');
const { body, param } = require('express-validator');
const authController = require('../controllers/auth.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

const router = express.Router();

const validateRegister = [
  body('first_name').trim().notEmpty().withMessage('First name is required'),
  body('last_name').trim().optional(),
  body('email').isEmail().withMessage('Please include a valid email'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long'),

  body('mobile_number')
    .notEmpty()
    .withMessage('Mobile number is required')
    .isNumeric()
    .withMessage('Mobile number must be numeric'),

  body('organisation_type')
    .notEmpty()
    .withMessage('Organisation type is required'),

  body('zone_id')
    .notEmpty()
    .isInt()
    .withMessage('Zone ID must be an integer'),

  body('division_id')
    .notEmpty()
    .isInt()
    .withMessage('Division ID must be an integer'),

  body('region_id')
    .notEmpty()
    .isArray()
    .withMessage('Region ID must be an array'),

  body('train_ids')
    .optional()
    .isArray()
    .withMessage('Train IDs must be an array'),

  body('role_id')
    .notEmpty()
    .isInt()
    .withMessage('Role ID must be an integer'),
    
  body('gender').optional(),
  body('employee_id').optional(),
  body('pan_card_no').optional(),
  body('company_id').optional(),
  body('aadhar_no').optional(),
];

const validateLogin = [
  body('email').isEmail().withMessage('Please include a valid email'),
  body('password').exists().withMessage('Password is required')
];

// --- ROUTES ---

router.post('/register', validateRegister, authController.register);
router.post('/login', validateLogin, authController.login);
router.post('/send-otp', authController.sendOtp);
router.post('/verify-otp', authController.verifyOtp);

// Updated Roles in Authorization as per your DB Update
router.get(
  '/users/pending',
  authenticate,
  authorize(['Master', 'Super Admin', 'Regional Master', 'Train Operator']),
  authController.getPendingUsers
);

router.put(
  '/users/approve',
  authenticate,
  authorize(['Master', 'Super Admin', 'Regional Master', 'Train Operator']),
  authController.approveUserWithRoleChange
);

router.put(
  '/users/approve/bulk',
  authenticate,
  authorize(['Master', 'Super Admin', 'Regional Master', 'Train Operator']),
  authController.bulkApproveUsers
);

router.get('/profile', authenticate, authController.getProfile);
router.put('/profile', authenticate, authController.updateProfile);

module.exports = router;