const express = require('express');
const { body, param, query } = require('express-validator');
const trainController = require('../controllers/train.controller');
const { authenticate, authorize, authorizeByToken } = require('../middleware/auth.middleware');

const router = express.Router();

router.post('/', authenticate, trainController.createTrain);
router.get('/', authenticate, trainController.getTrains);
router.get('/getAllTrains', trainController.getAllTrains);
router.put('/:id', authenticate, trainController.updateTrain);
router.delete('/:id', authenticate, trainController.deleteTrain);


// Get trains mapped to user
router.get(
  '/usertrains',
  authenticate,
  trainController.getTrainsMappedToUser
);


router.get(
  '/getTrainsForUsers',
  authenticate,
  trainController.getTrainsForUsers
)

// Update train user mapping
router.put(
  '/update/usertrains',
  authenticate,
  // authorizeByToken(['Master Admin', 'Super Admin', 'Admin', 'Manager', 'Editor']),
  // [
  //   body('train_ids').isArray().withMessage('Train IDs must be an array')
  // ],
  trainController.updateTrainUserMapping
);

// Get single train
router.get(
  '/:id',
  authenticate,
  [
    param('id').isInt().withMessage('Train ID must be an integer')
  ],
  trainController.getTrainById
);

// Create new train (Admin only)
router.post(
  '/',
  authenticate,
  authorizeByToken(['Master Admin', 'Super Admin', 'Admin', 'Manager', 'Editor']),
  trainController.createTrain
);

// Delete train (Admin only)
router.delete(
  '/:id',
  authenticate,
  authorize(['admin']),
  [
    param('id').isInt().withMessage('Train ID must be an integer')
  ],
  trainController.deleteTrain
);

module.exports = router;
