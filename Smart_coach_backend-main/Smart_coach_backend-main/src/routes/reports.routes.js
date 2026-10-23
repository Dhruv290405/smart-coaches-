const express = require('express');
const { authenticate, authorize } = require('../middleware/auth.middleware');
const weeklyReport = require('../services/weeklyReport.service');

const router = express.Router();

router.get('/weekly/locations', authenticate, authorize(['Master', 'Super Admin']), async (req, res, next) => {
  try {
    const locations = await weeklyReport.getReportLocations();
    return res.status(200).json({
      success: true,
      count: locations.length,
      data: locations.map((entry) => ({
        location: entry.location,
        emails: entry.emails,
        modules: entry.modules,
      })),
    });
  } catch (error) {
    next(error);
  }
});

router.post('/weekly/send', authenticate, authorize(['Master', 'Super Admin']), async (req, res, next) => {
  try {
    const { location, emails, dryRun } = req.body || {};
    const result = await weeklyReport.sendWeeklyReports({
      location: location ? String(location) : null,
      emails: Array.isArray(emails) ? emails : null,
      dryRun: dryRun === true,
    });

    return res.status(200).json({
      success: true,
      ...result,
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
