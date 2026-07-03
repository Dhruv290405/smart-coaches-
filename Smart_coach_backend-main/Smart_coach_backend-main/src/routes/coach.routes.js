const express = require('express');
const { body, param, query } = require('express-validator');
const coachController = require('../controllers/coach.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

const router = express.Router();

router.get('/unmapped', coachController.getUnmappedCoaches);
router.get('/', authenticate, coachController.getAllCoaches);
router.get('/coachfortrain', authenticate, coachController.getCoachForTrain);
router.get('/:id', authenticate, coachController.getCoachById);
router.post(
  '/',
  authenticate,
  coachController.createCoach
);
router.put(
  '/:coach_id',
  authenticate,
  coachController.updateCoach
);
router.delete('/:coach_id', authenticate, coachController.deleteCoach);

// coach_id

// Create new coach (Admin only)
// router.post(
//   '/',
//   authenticate,
//   coachController.createCoach
// );

//!crud

module.exports = router;
