const OdourModel = require("../models/odour.model");
const rbac = require('../utils/rbac');
const { broadcastPushNotification } = require('../utils/notificationService');
const { evaluateOdourReading } = require('../utils/odourIndex');

// Tracks last alert state per device to avoid spamming pushes on every reading.
const _odourAlertState = {};

const odourController = {
    receiveData: async (req, res) => {
        try {
            const payload = req.body;
            if (req.query.confirmationToken) return res.status(200).send("OK");

            const formattedTime = (payload.timestamp || new Date().toISOString())
                .replace('T', ' ').replace(/\..*Z|Z/, '');

            const dataToSave = {
                device_id: payload.device_id || null,
                sensor_id: payload.sensor_id || null,
                train_number: payload.train_number || null,
                coach_number: payload.coach_number || null,
                coach_type: payload.coach_type || null,
                toilet_position: payload.toilet_position || "N/A",
                temperature: payload.temperature != null ? Number(payload.temperature) : null,
                humidity: payload.humidity != null ? Number(payload.humidity) : null,
                voc_index: payload.voc_index != null ? Math.round(Number(payload.voc_index)) : 0,
                methane_ppm: payload.methane_ppm != null ? Number(payload.methane_ppm) : 0,
                h2s_ppm: payload.h2s_ppm != null ? Number(payload.h2s_ppm) : 0,
                nh3_ppm: payload.nh3_ppm != null ? Number(payload.nh3_ppm) : 0,
                sraw_voc: payload.sraw_voc != null ? String(payload.sraw_voc) : "0",
                h2s_raw: payload.h2s_raw != null ? String(payload.h2s_raw) : "0",
                nh3_raw: payload.nh3_raw != null ? String(payload.nh3_raw) : "0",
                long_lock_count: payload.long_lock_count != null ? Math.round(Number(payload.long_lock_count)) : 0,
                status: payload.status || "Active",
                timestamp: formattedTime
            };

            const insertId = await OdourModel.saveLog(dataToSave);

            // BODR spec: CRITICAL when NH3 > 10, CH4 > 15 or H2S > 5 ppm, or
            // Combined Odour Index [(NH3/10 + CH4/15 + H2S/5)/3 x 100] >= 250.
            // Only CRITICAL notifies (in-app + push + email + SMS), once per entry.
            const ev = evaluateOdourReading(dataToSave);
            const odourIndex = ev.index;
            const lvl = { level: ev.level };
            const odourDesc = 'Bad Odour Alert';
            const severity = 'critical';
            const sendSms = true;

            const deviceKey = dataToSave.device_id || dataToSave.coach_number || 'unknown';
            const lastLevel = _odourAlertState[deviceKey] || 'Normal';
            if (lvl.level === 'Critical' && lastLevel !== 'Critical') {
                const coachNo = dataToSave.coach_number || 'Unknown';
                const trainNo = dataToSave.train_number || 'Unknown';
                const alertText = `Alert: ${odourDesc} in Train ${trainNo}, Coach_Unique Id ${coachNo} | ${formattedTime}`;
                await broadcastPushNotification(
                    alertText,
                    alertText,
                    'ODOUR',
                    {
                        module: 'odour',
                        coach_no: coachNo,
                        train_no: trainNo,
                        fault_name: odourDesc,
                        odour_index: odourIndex,
                        severity,
                        send_sms: sendSms,
                        location: dataToSave.location || dataToSave.train_location || dataToSave.locName || dataToSave.division,
                    },
                    {
                        location: dataToSave.location || dataToSave.train_location || dataToSave.locName || dataToSave.division,
                        division: dataToSave.division || dataToSave.location,
                        severity,
                        send_sms: sendSms,
                    }
                );
            }
            _odourAlertState[deviceKey] = lvl.level;

            if (global._io) {
                global._io.emit('odour_data_update', dataToSave);
            }

            return res.status(201).json({
                success: true,
                message: "Odour log stored successfully",
                id: insertId
            });

        } catch (error) {
            console.error("Odour Controller Error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    },

    getDashboardStatus: async (req, res) => {
        try {
            if (!rbac.isModuleLocationOwner(req.user, 'odour')) {
                return res.status(200).json({ success: true, totalCoaches: 0, data: [] });
            }
            // Admins bypass location filtering to view all system devices; non-admins are scoped to their assigned division.
            const location = rbac.isUnrestrictedUser(req.user) ? (req.query.location || null) : rbac.getUserLocation(req.user);
            const statusData = await OdourModel.getLatestStatusForAllCoaches(location);

            return res.status(200).json({
                success: true,
                totalCoaches: statusData.length,
                data: statusData
            });

        } catch (error) {
            console.error("Odour Dashboard Controller Error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    },

    getHistory: async (req, res) => {
        try {
            if (!rbac.isModuleLocationOwner(req.user, 'odour')) {
                return res.status(200).json({ success: true, data: [] });
            }
            const deviceId = req.query.deviceId;
            // Accept '2', 'Section 2', 'section2', etc. — anything mentioning 2.
            const rawSection = (req.query.section ?? '').toString().toLowerCase();
            const section = rawSection.includes('2') ? '2' : '1';
            if (!deviceId) {
                return res.status(400).json({ success: false, error: 'deviceId is required' });
            }
            const { startDate, endDate } = req.query;

            const data = section === '2'
                ? await OdourModel.getSection2History(deviceId)
                : await OdourModel.getSection1History(deviceId, 1000, startDate || null, endDate || null);

            return res.status(200).json({ success: true, data });
        } catch (error) {
            console.error("Odour History Controller Error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    },

    getReportData: async (req, res) => {
        try {
            if (!rbac.isModuleLocationOwner(req.user, 'odour')) {
                return res.status(200).json({ success: true, devices: [], data: {} });
            }
            const location = rbac.isUnrestrictedUser(req.user) ? (req.query.location || null) : rbac.getUserLocation(req.user);
            const { startDate, endDate } = req.query;
            if (!startDate || !endDate) {
                return res.status(400).json({ success: false, error: 'startDate and endDate are required' });
            }
            const result = await OdourModel.getReportData(location, startDate, endDate);
            return res.status(200).json({ success: true, ...result });
        } catch (error) {
            console.error("Odour Report Data Controller Error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    },

    getSection2Data: async (req, res) => {
        try {
            // Bad Odour is strictly restricted to Nagpur installed devices (Section 1).
            // Section 2 is disabled so unrelated non-Nagpur test devices are not displayed.
            return res.status(200).json({
                success: true,
                totalCoaches: 0,
                data: []
            });
        } catch (error) {
            console.error("Odour Section 2 Controller Error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    }
};

module.exports = odourController;