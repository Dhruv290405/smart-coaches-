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

router.get('/logs', authenticate, getAcpLogs);
router.all('/receive-data', receiveAcpData);
router.get('/filters', authenticate, getFilterOptions);
router.get('/filtered-logs', authenticate, getFilteredData);
router.get('/summary', authenticate, getAcpSummary);
router.get('/coach-history', authenticate, getCoachHistory); 

module.exports = router;