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

router.get('/logs', getAcpLogs);
router.all('/receive-data', receiveAcpData);
router.get('/filters', getFilterOptions);
router.get('/filtered-logs', getFilteredData);
router.get('/summary', getAcpSummary);
router.get('/coach-history', getCoachHistory); 

module.exports = router;