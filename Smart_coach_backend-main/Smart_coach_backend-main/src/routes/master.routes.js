const express = require('express');
const { body, param } = require('express-validator');
const masterController = require('../controllers/master.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

const router = express.Router();

// Common validation rules
const createValidationRules = [
  body('name').trim().notEmpty().withMessage('Name is required'),
  body('code').optional().isString(),
  body('description').optional().isString()
];

// List all items for a master table
router.get(
  '/:type',
  param('type').isIn(['zones', 'divisions', 'regions']),
  masterController.list
);

// Create a new item in a master table (Admin only)
router.post(
  '/:type',
  authenticate,
  param('type').isIn(['zones', 'divisions', 'regions', 'roles']),
  createValidationRules,
  masterController.create
);

// Toggle status of an item (Admin only)
router.patch(
  '/:type/:id/toggle-status',
  authenticate,
  param('type').isIn(['zones', 'divisions', 'regions']),
  param('id').isInt().withMessage('ID must be an integer'),
  masterController.toggleStatus
);

module.exports = router;
