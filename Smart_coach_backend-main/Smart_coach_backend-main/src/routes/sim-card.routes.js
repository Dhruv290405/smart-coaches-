const express = require('express');
const { body, param, query } = require('express-validator');
const simCardController = require('../controllers/sim-card.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

const router = express.Router();

// Validation rules
const createUpdateSimCardRules = [
  body('carrier_id')
    .optional()
    .isInt().withMessage('Carrier ID must be an integer'),
  body('master_module_id')
    .optional()
    .isInt().withMessage('Master module ID must be an integer'),
  body('phone_number')
    .trim()
    .notEmpty().withMessage('Phone number is required')
    .isMobilePhone().withMessage('Invalid phone number format'),
  body('iccid')
    .trim()
    .notEmpty().withMessage('ICCID is required')
    .isLength({ min: 19, max: 20 }).withMessage('ICCID must be 19-20 characters'),
  body('imsi')
    .optional()
    .trim()
    .isLength({ min: 14, max: 15 }).withMessage('IMSI must be 14-15 characters'),
  body('apn')
    .optional()
    .trim()
    .isLength({ max: 100 }).withMessage('APN must be less than 100 characters'),
  body('pin1')
    .optional()
    .trim()
    .isLength({ min: 4, max: 8 }).withMessage('PIN1 must be 4-8 characters'),
  body('puk1')
    .optional()
    .trim()
    .isLength({ min: 8, max: 8 }).withMessage('PUK1 must be 8 characters'),
  body('pin2')
    .optional()
    .trim()
    .isLength({ min: 4, max: 8 }).withMessage('PIN2 must be 4-8 characters'),
  body('puk2')
    .optional()
    .trim()
    .isLength({ min: 8, max: 8 }).withMessage('PUK2 must be 8 characters'),
  body('plan_details')
    .optional()
    .trim()
    .isLength({ max: 500 }).withMessage('Plan details must be less than 500 characters'),
  body('activation_date')
    .optional()
    .isISO8601().withMessage('Invalid activation date format. Use YYYY-MM-DD'),
  body('expiry_date')
    .optional()
    .isISO8601().withMessage('Invalid expiry date format. Use YYYY-MM-DD'),
  body('status')
    .optional()
    .isIn(['ACTIVE', 'INACTIVE', 'SUSPENDED', 'TERMINATED'])
    .withMessage('Invalid status'),
  body('notes')
    .optional()
    .trim()
    .isLength({ max: 1000 }).withMessage('Notes must be less than 1000 characters')
];

// Get all SIM cards
router.get(
  '/',
  authenticate,
  [
    query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
    query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
    query('master_module_id').optional().isInt().withMessage('Master module ID must be an integer'),
    query('carrier_id').optional().isInt().withMessage('Carrier ID must be an integer'),
    query('status').optional().isIn(['ACTIVE', 'INACTIVE', 'SUSPENDED', 'TERMINATED']).withMessage('Invalid status'),
    query('search').optional().trim()
  ],
  simCardController.getAllSimCards
);

// Get single SIM card
router.get(
  '/:id',
  authenticate,
  [
    param('id').isInt().withMessage('SIM card ID must be an integer')
  ],
  simCardController.getSimCardById
);

// Create new SIM card (Admin only)
router.post(
  '/',
  authenticate,
  authorize(['admin']),
  createUpdateSimCardRules,
  simCardController.createSimCard
);

// Update SIM card (Admin only)
router.put(
  '/:id',
  authenticate,
  authorize(['admin']),
  [
    param('id').isInt().withMessage('SIM card ID must be an integer'),
    ...createUpdateSimCardRules
  ],
  simCardController.updateSimCard
);

// Delete SIM card (Admin only)
router.delete(
  '/:id',
  authenticate,
  authorize(['admin']),
  [
    param('id').isInt().withMessage('SIM card ID must be an integer')
  ],
  simCardController.deleteSimCard
);

// Assign/Unassign SIM card to master module (Admin only)
router.post(
  '/:id/assign',
  authenticate,
  authorize(['admin']),
  [
    param('id').isInt().withMessage('SIM card ID must be an integer'),
    body('master_module_id')
      .optional()
      .isInt().withMessage('Master module ID must be an integer')
  ],
  simCardController.assignToMasterModule
);

module.exports = router;
