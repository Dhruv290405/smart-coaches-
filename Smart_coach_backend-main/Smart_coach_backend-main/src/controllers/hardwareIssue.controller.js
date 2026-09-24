const HardwareIssueModel = require("../models/hardwareIssue.model");
const { successResponse, errorResponse } = require("../utils/response");

const hardwareIssueController = {
  // Hardware device button press (no auth — device posts directly)
  async event(req, res) {
    try {
      const { device_id, event_type } = req.body;

      if (!device_id || !event_type) {
        return errorResponse(res, "device_id and event_type are required", 400);
      }

      const type = String(event_type).toLowerCase();

      if (type === "linen" || type === "cleaning") {
        try {
          const issue = await HardwareIssueModel.recordIssue(device_id, type);
          try { if (global._io) global._io.emit("hardware_issue:new", issue); } catch (_) {}
          return res.status(201).json({
            success: true,
            message: `${type} issue recorded`,
            data: issue,
          });
        } catch (err) {
          if (err.code === "UNKNOWN_DEVICE") {
            return errorResponse(res, err.message, 404);
          }
          if (err.code === "OPEN_EXISTS") {
            return res.status(200).json({
              success: true,
              message: "Compartment already has an open issue",
              data: err.existing,
            });
          }
          throw err;
        }
      }

      if (type === "reset") {
        const closed = await HardwareIssueModel.resetIssue(device_id);
        if (!closed) {
          return res.json({ success: true, message: "No open issue to close" });
        }
        try { if (global._io) global._io.emit("hardware_issue:update", closed); } catch (_) {}
        return res.json({ success: true, message: "Issue closed", data: closed });
      }

      return errorResponse(res, "event_type must be linen, cleaning, or reset", 400);
    } catch (error) {
      console.error("HardwareIssue event error:", error.message);
      return res.status(500).json({ success: false, error: error.message });
    }
  },

  async getAll(req, res) {
    try {
      const { status, coachNo, trainNo, compartmentNo, deviceId, issueType, dateFrom, dateTo } = req.query;
      const data = await HardwareIssueModel.getAll({
        status,
        coachNo,
        trainNo,
        compartmentNo,
        deviceId,
        issueType,
        dateFrom,
        dateTo,
      });
      return successResponse(res, "Hardware issues fetched", { issues: data });
    } catch (error) {
      console.error("HardwareIssue getAll error:", error.message);
      return res.status(500).json({ success: false, error: error.message });
    }
  },

  async getReport(req, res) {
    try {
      const { dateFrom, dateTo, trainNo, coachNo, compartmentNo, deviceId, issueType } = req.query;
      const report = await HardwareIssueModel.getReportSummary({
        dateFrom,
        dateTo,
        trainNo,
        coachNo,
        compartmentNo,
        deviceId,
        issueType,
      });
      return successResponse(res, "Hardware issue report generated", report);
    } catch (error) {
      console.error("HardwareIssue getReport error:", error.message);
      return res.status(500).json({ success: false, error: error.message });
    }
  },

  async getMapping(req, res) {
    try {
      const { data, error } = await require("../config/supabaseAdmin")
        .from("device_compartment_mapping")
        .select("*")
        .order("coach_no")
        .order("compartment_no");
      if (error) throw error;
      return successResponse(res, "Device mapping fetched", { devices: data || [] });
    } catch (error) {
      console.error("HardwareIssue getMapping error:", error.message);
      return res.status(500).json({ success: false, error: error.message });
    }
  },
};

module.exports = hardwareIssueController;