const HotAxleModel = require("../models/hotAxle.model");
const supabaseAdmin = require("../config/supabaseAdmin");

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
                train_no: payload.train_no || payload.train_number || payload.trainNo || null,
                coach_no: payload.coach_no || payload.coach_number || payload.coachNo || null,
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

    getFilterOptions: async (req, res) => {
        try {
            const options = await HotAxleModel.getFilterOptions();
            return res.status(200).json({ success: true, data: options });
        } catch (error) {
            console.error("Filter Options Controller Error ->", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    },

    getDashboardStatus: async (req, res) => {
        try {
            const { trainNo, deviceId, coachType, owningRly, coachNumber } = req.query;
            const statusData = await HotAxleModel.getLatestStatusForAllCoaches({
                trainNo, deviceId, coachType, owningRly, coachNumber
            });

            return res.status(200).json({
                success: true,
                totalCoaches: statusData.length,
                data: statusData
            });

        } catch (error) {
            console.error("Dashboard Controller Error ->", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    },

    getNewCompanyData: async (req, res) => {
        try {
            const userEmail = req.user?.email || '';
            const isDanapur = userEmail === 'danapur.ops@test.com';

            if (isDanapur) {
                const { data, error } = await supabaseAdmin
                    .from('hot_axle_logs')
                    .select('*')
                    .order('id', { ascending: false })
                    .limit(500);

                if (error) throw error;

                const mapped = (data || []).map(item => {
                    const temps = [item.a11_temp, item.a12_temp, item.a21_temp, item.a22_temp,
                                   item.a31_temp, item.a32_temp, item.a41_temp, item.a42_temp]
                                   .filter(t => t != null && t >= 0);
                    const maxTemp = temps.length > 0 ? Math.max(...temps) : 0;
                    let batteryStatus = 'Moderate';
                    if (item.battery_percentage != null) {
                        if (item.battery_percentage <= 20) batteryStatus = 'Low';
                        else if (item.battery_percentage >= 80) batteryStatus = 'High';
                    }
                    return {
                        id: item.id,
                        device_id: item.device_id || '',
                        master_id: item.coach_number || item.device_id || '',
                        temperature: maxTemp,
                        status: item.alert_status || 'Active',
                        temp_state: maxTemp > 80 ? 'Critical' : (maxTemp > 60 ? 'Warning' : 'Normal'),
                        received_timestamp: item.timestamp || '',
                        battery_status: batteryStatus,
                        battery_voltage: 0.0,
                    };
                });

                return res.status(200).json({
                    success: true,
                    totalCoaches: mapped.length,
                    data: mapped
                });
            }

            const supabaseOld = require('../config/supabaseOld');
            if (!supabaseOld) {
                return res.status(500).json({ success: false, message: "Old Supabase not configured" });
            }

            const { data, error } = await supabaseOld
                .from('hams_data')
                .select('*')
                .order('created_at', { ascending: false });

            if (error) throw error;

            return res.status(200).json({
                success: true,
                totalCoaches: (data || []).length,
                data: data || []
            });
        } catch (error) {
            console.error("New Company Data Error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    }
};

module.exports = hotAxleController;