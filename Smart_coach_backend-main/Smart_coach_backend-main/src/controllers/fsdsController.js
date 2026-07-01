const FsdsModel = require("../models/fsds.model");

const fsdsController = {
    receiveData: async (req, res) => {
        try {
            const payload = req.body;
            if (req.query.confirmationToken) return res.status(200).send("OK");

            if (!payload.assets || !Array.isArray(payload.assets)) {
                return res.status(400).json({ success: false, message: "No FSDS assets found" });
            }

            const savePromises = payload.assets.map(async (asset) => {
                const metrics = asset.metrics?.values || [];
                
                // Metrics mapping (ACP format se data nikalna)
                const fireStatus = metrics.find(m => m.name.includes("LIGHT-1"))?.value ?? 0;
                const smokeLevel = metrics.find(m => m.metricType === "COUNT")?.value ?? 0;

                let formattedTime = (asset.metrics?.timestamp || payload.timestamp || new Date().toISOString())
                    .replace('T', ' ').replace(/\..*Z|Z/, '');

                const dataToSave = {
                    device_id: payload.source?.SensorId,
                    loc_id: payload.locId,
                    loc_name: payload.locName,
                    asset_id: asset.assetId,
                    asset_name: asset.assetName,
                    fire_status: fireStatus,
                    smoke_level: smokeLevel,
                    timestamp: formattedTime
                };

                const insertId = await FsdsModel.saveDynamicLog(dataToSave);
                const emitted = { ...dataToSave, id: insertId };
                try { if (global._io) global._io.emit('fsds:update', emitted); } catch (_) {}
                return insertId;
            });

            const ids = await Promise.all(savePromises);
            return res.status(201).json({ success: true, message: "FSDS logs stored", ids });

        } catch (error) {
            console.error("FSDS Controller Error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    },

    getData: async (req, res) => {
        try {
            const { limit, offset, locName, trainNo } = req.query;
            const logs = await FsdsModel.getLogs({
                limit: parseInt(limit) || 100,
                offset: parseInt(offset) || 0,
                locName,
                trainNo,
            });
            return res.json({ success: true, data: logs });
        } catch (error) {
            console.error("FSDS Get Data Error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    }
};

module.exports = fsdsController;