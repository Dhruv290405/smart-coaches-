const express = require('express');
const router = express.Router();
const { 
    getAcpLogs, 
    receiveAcpData, 
    getFilterOptions, 
    getFilteredData,
    getAcpSummary,
    getCoachHistory
} = require('../controllers/acpController');
const { authenticate } = require('../middleware/auth.middleware');
const { requireLocation } = require('../middleware/rbac.middleware');

router.get('/logs', authenticate, requireLocation, getAcpLogs);
router.all('/receive-data', receiveAcpData);
router.get('/filters', authenticate, requireLocation, getFilterOptions);
router.get('/filtered-logs', authenticate, requireLocation, getFilteredData);
router.get('/summary', authenticate, requireLocation, getAcpSummary);
router.get('/coach-history', authenticate, requireLocation, getCoachHistory); 

module.exports = router;