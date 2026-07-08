const OdourModel = require("../models/odour.model");

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
            const statusData = await OdourModel.getLatestStatusForAllCoaches();

            return res.status(200).json({
                success: true,
                totalCoaches: statusData.length,
                data: statusData
            });

        } catch (error) {
            console.error("Odour Dashboard Controller Error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    }
};

module.exports = odourController;