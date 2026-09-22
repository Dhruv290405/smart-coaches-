const ServiceRequestModel = require("../models/serviceRequest.model");

const serviceRequestController = {
    // Passenger submits (no auth required)
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
                train_no,
                coach_no,
                seat_berth,
                service_type,
                description,
                passenger_name,
                passenger_phone
            });

            // Emit real-time event for train operators
            try {
                if (global._io) global._io.emit("service_request:new", request);
            } catch (_) {}

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

    // Train operator views all requests (auth required)
    getAll: async (req, res) => {
        try {
            const { status, limit, offset } = req.query;
            const result = await ServiceRequestModel.getAll({
                status,
                limit: parseInt(limit) || 50,
                offset: parseInt(offset) || 0
            });

            return res.json({ success: true, data: result.data, count: result.count });
        } catch (error) {
            console.error("ServiceRequest getAll error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    },

    // Train operator views single request (auth required)
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

    // Train operator updates status (auth required)
    updateStatus: async (req, res) => {
        try {
            const { id } = req.params;
            const { status } = req.body;

            if (!status || !["pending", "in_progress", "resolved"].includes(status)) {
                return res.status(400).json({
                    success: false,
                    message: "Valid status required (pending, in_progress, resolved)"
                });
            }

            const updated = await ServiceRequestModel.updateStatus(id, status, req.user?.user_id);

            // Emit real-time event
            try {
                if (global._io) global._io.emit("service_request:update", updated);
            } catch (_) {}

            return res.json({ success: true, data: updated });
        } catch (error) {
            console.error("ServiceRequest updateStatus error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    }
};

module.exports = serviceRequestController;
