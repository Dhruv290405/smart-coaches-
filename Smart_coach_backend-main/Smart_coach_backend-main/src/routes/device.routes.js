const express = require('express');
const { body, param, query } = require('express-validator');
const deviceController = require('../controllers/device.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

const router = express.Router();

// Get all devices
router.get(
  '/',
  authenticate,
  deviceController.getAllDevices
);
router.get(
  '/master-module/:master_module_id',
  authenticate,
  deviceController.getDevicesByMasterModuleId
);

// Get single device
router.get(
  '/:id',
  authenticate,
  [
    param('id').isInt().withMessage('Device ID must be an integer')
  ],
  deviceController.getDeviceById
);

// Get device status
router.get(
  '/:id/status',
  authenticate,
  [
    param('id').isInt().withMessage('Device ID must be an integer')
  ],
  deviceController.getDeviceStatus
);

// Create new device (Admin only)
router.post(
  '/',
  authenticate,
  // authorize(['admin']),
  deviceController.createDevice
);

// Update device (Admin only)
router.put(
  '/:id',
  authenticate,
//  authorize(['admin']),
  [
    param('id').isInt().withMessage('Device ID must be an integer'),
  ],
  deviceController.updateDevice
);

// Delete device (Admin only)
router.delete(
  '/:id',
  authenticate,
//   authorize(['admin']),
  [
    param('id').isInt().withMessage('Device ID must be an integer')
  ],
  deviceController.deleteDevice
);

module.exports = router;
