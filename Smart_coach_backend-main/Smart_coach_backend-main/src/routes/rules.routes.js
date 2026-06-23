const express = require('express');
const router = express.Router();
const { authenticate, authorize } = require('../middleware/auth.middleware');
const rulesController = require('../controllers/rules.controller');

router.post('/', authenticate, rulesController.createRule);
router.get('/alert-types', authenticate, rulesController.getAllAlertTypes);
router.get('/:id', authenticate, rulesController.getRuleById);
router.get('/', authenticate, rulesController.getAllRules);
router.put('/:id', authenticate, rulesController.updateRule);
router.delete('/:id', authenticate, rulesController.deleteRule);

module.exports = router;
