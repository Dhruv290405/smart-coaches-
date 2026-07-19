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
            const deviceId = req.query.deviceId || null;
            const limit = parseInt(req.query.limit) || 10;
            const authorizedCoaches = await rbac.getAuthorizedCoachNumbers(req.user);
            const results = await PressureModel.getLatestData(deviceId, limit, authorizedCoaches);

            if (!results || results.length === 0) {
                return res.status(404).json({
                    success: false,
                    message: deviceId ? `No data found for device: ${deviceId}` : "No pressure data found"
                });
            }

            return res.status(200).json({
                success: true,
                count: results.length,
                data: results
            });

        } catch (error) {
            console.error("Get Pressure Data Controller Error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    },

    // 3. NEW GET API - FETCH ALL COACHES WITH THEIR LATEST TIMESTAMP & READING
    getDashboardStatus: async (req, res) => {
        try {
            // Model se har active device ka sabse latest single record fetch karega
            const authorizedCoaches = await rbac.getAuthorizedCoachNumbers(req.user);
            const statusData = await PressureModel.getDashboardStatus(authorizedCoaches);

            if (!statusData || statusData.length === 0) {
                return res.status(404).json({
                    success: false,
                    message: "No live device data found in the system"
                });
            }

            return res.status(200).json({
                success: true,
                totalDevices: statusData.length,
                data: statusData
            });
        } catch (error) {
            console.error("Pressure Dashboard Controller Error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    }
};

module.exports = pressureController;