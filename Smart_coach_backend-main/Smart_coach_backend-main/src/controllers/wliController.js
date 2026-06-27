const WliModel = require("../models/wli.model");
const OLD = 'https://smart-coach-api-production.up.railway.app/smart_coach_api/api';

const wliController = {
    receiveData: async (req, res) => {
        try {
            if (req.query.confirmationToken) return res.status(200).send("OK");

            const payload = req.body;
            if (!payload || !payload.assets || !Array.isArray(payload.assets)) {
                return res.status(400).json({ success: false, message: "No asset data found" });
            }

            const formattedTimestamp = payload.timestamp 
                ? payload.timestamp.replace('T', ' ').replace(/\..*Z|Z/, '') 
                : new Date().toISOString().slice(0, 19).replace('T', ' ');

            const savePromises = payload.assets.map(async (asset) => {
                const dataToSave = {
                    device_id: payload.source?.deviceId,
                    coach_id: payload.location?.coachId,
                    coach_name: payload.location?.coachName,
                    placement_type: payload.placement?.type,
                    asset_id: asset.assetId,
                    asset_name: asset.assetName,
                    raw_value: asset.rawValue,
                    level_cm: asset.levelCm,
                    volume_liters: asset.volumeLiters,
                    percent_full: asset.percentFull,
                    timestamp: formattedTimestamp
                };

                return await WliModel.saveDynamicLog(dataToSave);
            });

            const ids = await Promise.all(savePromises);

            // Dual-write: forward to old backend (fire-and-forget)
            fetch(OLD + '/wli/receive-data', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            }).catch(() => {});

            return res.status(201).json({ 
                success: true, 
                message: "WLI Data stored successfully", 
                ids: ids 
            });

        } catch (error) {
            console.error("WLI Controller Error:", error.message);
            res.status(200).json({ success: true, message: "WLI Data acknowledged", ids: [] });
        }
    },

    getDashboardStatus: async (req, res) => {
        try {
            const statusData = await WliModel.getLatestStatusForAllCoaches();

            return res.status(200).json({
                success: true,
                totalCoaches: statusData.length,
                data: statusData
            });

        } catch (error) {
            console.error("WLI Dashboard Controller Error:", error.message);
            res.status(200).json({ success: true, totalCoaches: 0, data: [] });
        }
    }
};

module.exports = wliController;