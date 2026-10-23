const express = require('express');
const router = express.Router();
const pneumaticController = require('../controllers/pneumatic.controller');
const authMiddleware = require('../middleware/auth.middleware');

const authenticate = typeof authMiddleware === 'function' ? authMiddleware : authMiddleware.authenticate;

router.all('/receive-data', pneumaticController.receiveData);

router.get('/status', authenticate, pneumaticController.getBreakBindingData);

router.get('/coaches-by-location', authenticate, pneumaticController.getCoachesByLocation);

// Server-side PDF export — renders the full PDF on Node.js and streams bytes
// to the client. Drastically faster than client-side Flutter PDF rendering for
// large datasets. Query params: deviceId, from_date, to_date, limit (max 50000)
router.get('/export-pdf',         authenticate, pneumaticController.exportHistoryPdf);
router.get('/export-faults-pdf',  authenticate, pneumaticController.exportFaultsPdf);

module.exports = router;