const HotAxleModel = require("../models/hotAxle.model");

const hotAxleController = {
    receiveData: async (req, res) => {
        try {
            const payload = req.body;

            if (req.query.confirmationToken) {
                console.log("AWS Confirmation Handshake Received for Hot Axle");
                return res.status(200).send("OK");
            }

            if (!payload || Object.keys(payload).length === 0) {
                return res.status(400).json({ success: false, message: "Empty payload received" });
            }

            if (payload.timestamp) {
                payload.timestamp = payload.timestamp.replace('T', ' ').replace(/\..*Z/, '');
            }

            let status = 'Good';
            const tempKeys = Object.keys(payload).filter(key => key.includes('_temp'));
            
            for (let key of tempKeys) {
                const tempValue = parseFloat(payload[key]);
                if (tempValue >= 80) {
                    status = 'Critical';
                    break; 
                } else if (tempValue >= 60) {
                    status = 'Warning';
                }
            }

            const dataToSave = { 
                ...payload, 
                alert_status: status 
            };

            const insertId = await HotAxleModel.saveDynamicLog(dataToSave);

            return res.status(201).json({ 
                success: true, 
                message: "Hot Axle data stored successfully", 
                id: insertId,
                calculated_status: status
            });

        } catch (error) {
            console.error("Critical: HotAxle Controller Error ->", error.message);
            res.status(500).json({ 
                success: false, 
                error: error.message 
            });
        }
    },

    // 2. GET API: Fetch stored device data from SQL
    getHotAxleData: async (req, res) => {
        try {
            const filterDeviceId = req.query.deviceId || null;
            const historyLimit = parseInt(req.query.limit) || 10;

            const readings = await HotAxleModel.getData(filterDeviceId, historyLimit);

            if (!readings || readings.length === 0) {
                return res.status(404).json({
                    success: false,
                    message: filterDeviceId ? `No data found for device: ${filterDeviceId}` : "No records found"
                });
            }

            return res.status(200).json({
                success: true,
                count: readings.length,
                deviceId: filterDeviceId || "All Devices",
                data: readings
            });

        } catch (error) {
            console.error("HotAxle GET Controller Error ->", error.message);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    },

        getHistory: async (req, res) => {
    try {
        // Query params se filters uthana
        const { 
            deviceId, 
            coachNumber, 
            startDate, 
            endDate, 
            page = 1, 
            limit = 30 
        } = req.query;

        const offset = (parseInt(page) - 1) * parseInt(limit);

        const result = await HotAxleModel.getHistoryData({
            deviceId: deviceId || 'All',
            coachNumber: coachNumber || 'All',
            startDate: startDate || null,
            endDate: endDate || null,
            limit: limit,
            offset: offset
        });

        return res.status(200).json({
            success: true,
            meta: {
                totalRecords: result.total,
                currentPage: parseInt(page),
                totalPages: Math.ceil(result.total / limit),
                limit: parseInt(limit)
            },
            data: result.data
        });

    } catch (error) {
        console.error("History Controller Error ->", error.message);
        res.status(500).json({ success: false, error: error.message });
    }
},

    getDashboardStatus: async (req, res) => {
        try {
            const statusData = await HotAxleModel.getLatestStatusForAllCoaches();

            return res.status(200).json({
                success: true,
                totalCoaches: statusData.length,
                data: statusData
            });

        } catch (error) {
            console.error("Dashboard Controller Error ->", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    }
};

module.exports = hotAxleController;