const AcpModel = require('../models/acpModel');
const rbac = require('../utils/rbac');
const BLOCKED_COACHES = ['205063'];
let cachedBlockedCoaches = new Set();
let lastCacheUpdate = 0;
const CACHE_TTL = 5 * 60 * 1000;

function applyLocationFilter(logs, user) {
    if (!user || user.role_id === 1 || !logs || logs.length === 0) return logs;
    const userLocs = rbac.getUserLocations(user).map(l => l.toLowerCase());
    if (userLocs.length === 0) return logs;
    const filtered = logs.filter(log => {
        const logLoc = (log.train_location || "").toLowerCase();
        return userLocs.some(uLoc => logLoc.includes(uLoc) || uLoc.includes(logLoc));
    });
    return filtered.length > 0 ? filtered : logs;
}

// 1. For getting all critical logs (GET endpoint - optimized for partitioned table)
const getAcpLogs = async (req, res) => {
    try {
        if (!rbac.isModuleAuthorized(req.user, 'acp')) {
            return res.status(200).json({ success: true, count: 0, data: [] });
        }

        let logs = await AcpModel.getAllLogs();
        logs = applyLocationFilter(logs, req.user);

        res.status(200).json({
            success: true,
            count: logs.length,
            data: logs
        });
    } catch (error) {
        console.error("Controller Error in getAcpLogs:", error.message);
        res.status(500).json({ success: false, error: error.message });
    }
};

const receiveAcpData = async (req, res) => {
    try {
        if (Date.now() - lastCacheUpdate > CACHE_TTL) {
            const blocked = await AcpModel.getBlockedCoaches(); 
            cachedBlockedCoaches = new Set(blocked);
            lastCacheUpdate = Date.now();
        }
        const payload = req.body;
        
        if (!payload) return res.status(400).json({ success: false, message: "Empty payload" });
        if (req.query.confirmationToken) return res.status(200).send("OK");

        const processAsset = async (asset) => {
            const rawAssetName = asset.assetName || "";
            const assetParts = rawAssetName.split(" ");
            const techCoachNo = assetParts[1] || null;

            if (!techCoachNo) return null;

            // Yahan check karo - Ab ye sahi kaam karega
            if (cachedBlockedCoaches.has(String(techCoachNo)) || BLOCKED_COACHES.includes(String(techCoachNo))) {
                return null; 
            }

            const metrics = asset.metrics?.values || [];
            const currentCount = metrics.find(m => m.metricType === "COUNT")?.value ?? 0;
            const totalCount = metrics.find(m => m.metricType === "TOTALIZED_COUNT")?.value ?? 0;

            const assetData = {
                tech_coach_no: techCoachNo,
                acp_status: currentCount,
                total_count: totalCount,
                train_location: payload.locName || "Unknown",
                raw_asset_name: rawAssetName,
                train_no: payload.trainNo || "Unknown"
            };

            const result = { ...assetData, timestamp: new Date().toISOString(), coachNo: rawAssetName };

            if (currentCount > 0) {
                await AcpModel.saveCriticalEvent(assetData);
                await AcpModel.updateLiveStatus(assetData, 'TRIGGER');
            } else {
                await AcpModel.updateLiveStatus(assetData, 'HEARTBEAT');
            }

            try { if (global._io) global._io.emit('acp:update', result); } catch (_) {}
            return "OK";
        };

        if (payload.assets && Array.isArray(payload.assets)) {
            await Promise.all(payload.assets.map(asset => processAsset(asset)));
        } else {
            await processAsset(payload); 
        }

        return res.status(201).json({ success: true, message: "Processed" });
    } catch (error) {
        console.error("Controller Error:", error.message);
        res.status(500).json({ success: false, error: error.message });
    }
};


// 3. Fetch data for dropdowns based on query parameters
const getFilterOptions = async (req, res) => {
    try {
        const { trainNo, coachType } = req.query;

        if (!trainNo) {
            let trains = await AcpModel.getUniqueTrains();
            trains = applyLocationFilter(trains.map(t => ({ train_location: t.train_no })), req.user)
                .filter(t => t.train_location)
                .map(t => ({ train_no: t.train_location }));
            if (trains.length === 0) trains = await AcpModel.getUniqueTrains();
            return res.status(200).json({ success: true, data: trains });
        }

        if (trainNo && !coachType) {
            const types = await AcpModel.getCoachTypesByTrain(trainNo);
            return res.status(200).json({ success: true, data: types });
        }

        if (trainNo && coachType) {
            const coachNumbers = await AcpModel.getCoachNumbers(trainNo, coachType);
            return res.status(200).json({ success: true, data: coachNumbers });
        }

    } catch (error) {
        console.error("Error in getFilterOptions:", error.message);
        res.status(500).json({ success: false, error: error.message });
    }
};

// 4. Filtered Logs fetch karna
const getFilteredData = async (req, res) => {
    try {
        const { trainNo, techCoachNo } = req.query;

        if (!trainNo || !techCoachNo) {
            return res.status(400).json({
                success: false,
                message: "Please provide both trainNo and techCoachNo"
            });
        }

        let logs = await AcpModel.getFilteredLogs(trainNo, techCoachNo);
        logs = applyLocationFilter(logs, req.user);

        res.status(200).json({
            success: true,
            count: logs.length,
            data: logs
        });
    } catch (error) {
        console.error("Error in getFilteredData:", error.message);
        res.status(500).json({ success: false, error: error.message });
    }
};

// 5. Get summary configuration of registered devices
const getAcpSummary = async (req, res) => {
    try {
        if (!rbac.isModuleAuthorized(req.user, 'acp')) {
            return res.status(200).json({
                success: true,
                total_registered_devices: 0,
                data: []
            });
        }
        let summary = await AcpModel.getSummaryLogs();
        summary = applyLocationFilter(summary, req.user);

        res.status(200).json({
            success: true,
            total_registered_devices: summary.length,
            data: summary
        });
    } catch (error) {
        console.error("Error in getAcpSummary:", error.message);
        res.status(500).json({ success: false, error: error.message });
    }
};

// 6. Coach ACP history with range filter & partitioning support
const getCoachHistory = async (req, res) => {
    try {
        const { coachNo, fromDate, toDate, page = 1, limit = 100 } = req.query;

        if (!coachNo) {
            return res.status(400).json({ success: false, message: "coachNo is required" });
        }

        const offset = (parseInt(page) - 1) * parseInt(limit);

        let rows = await AcpModel.getCoachAcpHistory(coachNo, fromDate, toDate, parseInt(limit), offset);
        rows = applyLocationFilter(rows, req.user);

        res.status(200).json({
            success: true,
            message: `History fetched successfully for coach ${coachNo}`,
            page: parseInt(page),
            limit: parseInt(limit),
            total_events_returned: rows.length,
            data: rows
        });

    } catch (error) {
        console.error("Error in getCoachHistory:", error.message);
        res.status(500).json({ success: false, error: error.message });
    }
};

module.exports = {
    getAcpLogs,
    receiveAcpData,
    getFilterOptions,
    getFilteredData,
    getAcpSummary,
    getCoachHistory
};