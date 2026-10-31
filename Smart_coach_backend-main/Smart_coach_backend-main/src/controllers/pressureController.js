const PressureModel = require("../models/pressure.model");
const rbac = require('../utils/rbac');
const { broadcastPushNotification } = require('../utils/notificationService');

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

                // 3. BC Pressure: Send alert ONLY if pressure status is critical
                const isBcCritical = String(formattedReading.status || formattedReading.pressure_status || '').toLowerCase() === 'critical'
                    || Number(formattedReading.bc) >= 3.1;

                if (isBcCritical) {
                    const alertTitle = `Alert: BC Pressure Critical in Train ${commonInfo.train_number || 'Unknown'}, Coach_Unique Id ${commonInfo.coach_number || 'Unknown'} | ${formattedReading.timestamp || ''}`;
                    broadcastPushNotification(
                        alertTitle,
                        alertTitle,
                        'BC_PRESSURE',
                        {
                            module: 'bc_pressure',
                            coach_no: commonInfo.coach_number,
                            train_no: commonInfo.train_number,
                            fault_name: 'BC Pressure Critical',
                            severity: 'critical',
                            send_sms: true,
                            location: payload.location || payload.division || 'Danapur'
                        }
                    ).catch(e => console.error('BC Pressure Alert Err:', e.message));
                }
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

            // BC Pressure belongs to Danapur; admins/tester see everything.
            // Other locations may only see rows whose train_no is registered to them.
            const isOwner = rbac.isModuleLocationOwner(req.user, 'bc_pressure');
            let authorizedTrains = null;
            if (!isOwner) {
                const trains = await rbac.getAuthorizedTrainNumbers(req.user);
                if (!trains || trains.length === 0) {
                    return res.status(200).json({ success: true, count: 0, data: [] });
                }
                authorizedTrains = trains.map(String);
            }
            const results = await PressureModel.getLatestData(deviceId, limit, null, authorizedTrains);

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
            // BC Pressure belongs to Danapur; admins/tester see everything.
            // Other locations may only see rows whose train_no is registered to them.
            const isOwner = rbac.isModuleLocationOwner(req.user, 'bc_pressure');
            let authorizedTrains = null;
            if (!isOwner) {
                const trains = await rbac.getAuthorizedTrainNumbers(req.user);
                if (!trains || trains.length === 0) {
                    return res.status(200).json({ success: true, totalDevices: 0, data: [] });
                }
                authorizedTrains = trains.map(String);
            }
            const statusData = await PressureModel.getDashboardStatus(null, authorizedTrains);

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