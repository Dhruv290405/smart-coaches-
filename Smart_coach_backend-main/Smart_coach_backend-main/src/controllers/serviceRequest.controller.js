const ServiceRequestModel = require("../models/serviceRequest.model");

const serviceRequestController = {
    create: async (req, res) => {
        try {
            const { train_no, coach_no, seat_berth, service_type, description, passenger_name, passenger_phone } = req.body;

            if (!train_no || !coach_no || !seat_berth || !service_type) {
                return res.status(400).json({
                    success: false,
                    message: "train_no, coach_no, seat_berth, and service_type are required"
                });
            }

            const request = await ServiceRequestModel.create({
                train_no, coach_no, seat_berth, service_type, description, passenger_name, passenger_phone
            });

            try { if (global._io) global._io.emit("service_request:new", request); } catch (_) {}

            return res.status(201).json({
                success: true,
                message: "Service request submitted successfully",
                data: request
            });
        } catch (error) {
            console.error("ServiceRequest create error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    },

    getAll: async (req, res) => {
        try {
            const { status, limit, offset, dateFrom, dateTo } = req.query;
            const result = await ServiceRequestModel.getAll({
                status,
                limit: parseInt(limit) || 50,
                offset: parseInt(offset) || 0,
                dateFrom,
                dateTo
            });
            return res.json({ success: true, data: result.data, count: result.count });
        } catch (error) {
            console.error("ServiceRequest getAll error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    },

    getById: async (req, res) => {
        try {
            const { id } = req.params;
            const request = await ServiceRequestModel.getById(id);
            return res.json({ success: true, data: request });
        } catch (error) {
            console.error("ServiceRequest getById error:", error.message);
            res.status(404).json({ success: false, message: "Request not found" });
        }
    },

    updateStatus: async (req, res) => {
        try {
            const { id } = req.params;
            const { status, resolution_notes } = req.body;

            if (!status || !["pending", "in_progress", "resolved"].includes(status)) {
                return res.status(400).json({
                    success: false,
                    message: "Valid status required (pending, in_progress, resolved)"
                });
            }

            const updated = await ServiceRequestModel.updateStatus(
                id, status, req.user?.user_id, resolution_notes
            );

            try { if (global._io) global._io.emit("service_request:update", updated); } catch (_) {}

            return res.json({ success: true, data: updated });
        } catch (error) {
            console.error("ServiceRequest updateStatus error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    },

    getReport: async (req, res) => {
        try {
            const { dateFrom, dateTo } = req.query;
            const report = await ServiceRequestModel.getReportSummary({ dateFrom, dateTo });
            return res.json({ success: true, data: report });
        } catch (error) {
            console.error("ServiceRequest getReport error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    }
};

module.exports = serviceRequestController;
