const express = require('express');
const { body, param, query } = require('express-validator');
const masterModuleController = require('../controllers/master-module.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

const router = express.Router();

router.post('/', authenticate, masterModuleController.createMasterModule);
router.get('/user', authenticate, masterModuleController.getMasterModulesByUser);
router.put('/:id', authenticate, masterModuleController.updateMasterModule);
router.delete('/:id', authenticate, masterModuleController.deleteMasterModule);
router.get('/coach', authenticate, masterModuleController.getMasterModulesByCoachId);


module.exports = router;
