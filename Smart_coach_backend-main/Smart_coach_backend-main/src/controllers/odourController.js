const OdourModel = require("../models/odour.model");

const odourController = {
    receiveData: async (req, res) => {
        try {
            const payload = req.body;
            if (req.query.confirmationToken) return res.status(200).send("OK");

            let formattedTime = (payload.coach_data?.timestamp || payload.timestamp || new Date().toISOString())
                .replace('T', ' ').replace(/\..*Z|Z/, '');

            const dataToSave = {
                master_sensor_id: payload.source?.SensorId || null,
                device_id: payload.source?.deviceId || null,
                
                train_number: payload.train_info?.train_number || null,
                coach_number: payload.coach_data?.coach_number || null,
                coach_type: payload.coach_data?.coach_type || null,
                
                toilet_position: payload.coach_data?.toilet_position || "N/A",
                odour_reading: payload.coach_data?.reading || payload.coach_data?.Reading || 0,
                device_status: payload.coach_data?.status || "Unknown",
                
                voc: payload.coach_data?.voc || 0,
                h2s: payload.coach_data?.h2s || 0,
                nh3: payload.coach_data?.nh3 || 0,
                smoke: payload.coach_data?.smoke || 0,
                temperature: payload.coach_data?.temperature || null,
                humidity: payload.coach_data?.humidity || null,
                latitude: payload.coach_data?.latitude || null,
                longitude: payload.coach_data?.longitude || null,
                
                timestamp: formattedTime
            };

            const insertId = await OdourModel.saveDynamicLog(dataToSave);

            return res.status(201).json({ 
                success: true, 
                message: "Odour log stored successfully", 
                id: insertId 
            });

        } catch (error) {
            console.error("Odour Controller Error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    }
};

module.exports = odourController;