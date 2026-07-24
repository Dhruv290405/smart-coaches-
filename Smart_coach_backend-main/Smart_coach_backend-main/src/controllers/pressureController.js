const PressureModel = require("../models/pressure.model");
const rbac = require('../utils/rbac');

const pressureController = {
    // 1. POST API - DEVICE DATA RECEIVER (UNCHANGED)
    receiveData: async (req, res) => {
        try {
            const payload = req.body;
            if (req.query.confirmationToken) return res.status(200).send("OK");

            if (!payload.readings || !Array.isArray(payload.readings)) {
                return res.status(400).json({ success: false, message: "No readings found" });
            }

            const commonInfo = {
                device_id: payload.device_id,
                coach_number: payload.coach_number,
                coach_type: payload.coach_type,
                owning_rly: payload.owning_rly,
                train_number: payload.train_number
            };

            const savePromises = payload.readings.map(async (reading) => {
                const formattedReading = { ...reading };
                const timeFields = ['timestamp', 'brake_applied_time', 'brake_released_time'];
                
                timeFields.forEach(field => {
                    if (formattedReading[field]) {
                        formattedReading[field] = formattedReading[field].replace('T', ' ').replace(/\..*Z|Z/, '');
                    }
                });

                const dataToSave = { ...commonInfo, ...formattedReading };
                return await PressureModel.saveDynamicLog(dataToSave);
            });

            const ids = await Promise.all(savePromises);
            return res.status(201).json({ success: true, message: "All readings saved", record_ids: ids });

        } catch (error) {
            console.error("Pressure Controller Error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    },

    // 2. NEW GET API - FETCH SAVED PRESSURE DATA
    getPressureData: async (req, res) => {
        try {
            if (!rbac.isModuleAuthorized(req.user, 'bc_pressure')) {
                return res.status(200).json({ success: true, count: 0, data: [] });
            }
            const deviceId = req.query.deviceId || null;
            const limit = parseInt(req.query.limit) || 10;
            let authorizedCoaches = await rbac.getAuthorizedCoachNumbers(req.user);
            if (rbac.isModuleAuthorized(req.user, 'bc_pressure') && (!authorizedCoaches || authorizedCoaches.length === 0)) {
                authorizedCoaches = null; // Danapur is authorized for BC Pressure
            }
            const results = await PressureModel.getLatestData(deviceId, limit, authorizedCoaches);

            return res.status(200).json({
                success: true,
                count: (results || []).length,
                data: results || []
            });

        } catch (error) {
            console.error("Get Pressure Data Controller Error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    },

    getDashboardStatus: async (req, res) => {
        try {
            if (!rbac.isModuleAuthorized(req.user, 'bc_pressure')) {
                return res.status(200).json({ success: true, totalDevices: 0, data: [] });
            }
            let authorizedCoaches = await rbac.getAuthorizedCoachNumbers(req.user);
            if (rbac.isModuleAuthorized(req.user, 'bc_pressure') && (!authorizedCoaches || authorizedCoaches.length === 0)) {
                authorizedCoaches = null; // Danapur authorized for BC Pressure
            }
            const statusData = await PressureModel.getDashboardStatus(authorizedCoaches);

            return res.status(200).json({
                success: true,
                totalDevices: (statusData || []).length,
                data: statusData || []
            });
        } catch (error) {
            console.error("Pressure Dashboard Controller Error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    }
};

module.exports = pressureController;