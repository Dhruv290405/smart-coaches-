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
        const { 
            deviceId, 
            coachNumber, 
            startDate, 
            endDate, 
            page = 1, 
            limit = 30 
        } = req.query;

        if (coachNumber && coachNumber.startsWith('Master: ')) {
            const masterId = coachNumber.replace('Master: ', '').trim();
            const sOld = require('../config/supabaseOld');
            if (!sOld) {
                return res.status(500).json({ success: false, message: "Old Supabase not configured" });
            }

            let query = sOld.from('hams_data').select('*');
            query = query.eq('master_id', masterId);

            if (startDate && endDate) {
                query = query
                    .gte('received_timestamp', `${startDate}T00:00:00`)
                    .lte('received_timestamp', `${endDate}T23:59:59`);
            }

            const { data, error } = await query
                .order('received_timestamp', { ascending: false })
                .limit(2000);

            if (error) throw error;

            const grouped = {};
            for (let d of (data || [])) {
                if (!d.received_timestamp) continue;
                const dateObj = new Date(d.received_timestamp);
                if (isNaN(dateObj.getTime())) continue;
                const min = dateObj.getMinutes();
                const roundedMin = min - (min % 15);
                dateObj.setMinutes(roundedMin, 0, 0);
                const bucket = dateObj.toISOString();
                if (!grouped[bucket]) grouped[bucket] = [];
                grouped[bucket].push(d);
            }

            let mappedHistory = [];
            for (let bucket in grouped) {
                const devices = grouped[bucket];
                const axleDevices = [...devices];
                axleDevices.sort((a, b) => a.device_id.localeCompare(b.device_id));

                let temps = [0,0,0,0,0,0,0,0,0];
                let maxTemp = 0;
                for (let i = 0; i < axleDevices.length && i < 9; i++) {
                    temps[i] = axleDevices[i].temperature || 0;
                    if (temps[i] > maxTemp) maxTemp = temps[i];
                }

                let bat = 50;
                let firstWithBat = devices.find(d => d.battery_status);
                if (firstWithBat) {
                    const bs = firstWithBat.battery_status.toLowerCase();
                    if (bs === 'low') bat = 15;
                    else if (bs === 'moderate') bat = 40;
                    else if (bs === 'high') bat = 80;
                }

                mappedHistory.push({
                    timestamp: bucket,
                    device_id: masterId,
                    coach_number: coachNumber,
                    coach_type: 'HAMS',
                    owning_rly: 'VASP',
                    a11_temp: temps[0], a12_temp: temps[1],
                    a21_temp: temps[2], a22_temp: temps[3],
                    a31_temp: temps[4], a32_temp: temps[5],
                    a41_temp: temps[6], a42_temp: temps[7],
                    battery_percentage: bat,
                    signal_strength: 0,
                    alert_status: maxTemp > 60 ? 'Warning' : 'Good',
                });
            }

            mappedHistory.sort((a, b) => b.timestamp.localeCompare(a.timestamp));

            const total = mappedHistory.length;
            const startIdx = (parseInt(page) - 1) * parseInt(limit);
            const paged = mappedHistory.slice(startIdx, startIdx + parseInt(limit));

            return res.status(200).json({
                success: true,
                meta: {
                    totalRecords: total,
                    currentPage: parseInt(page),
                    totalPages: Math.ceil(total / parseInt(limit)),
                    limit: parseInt(limit)
                },
                data: paged
            });
        }

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

            const filtered = (data || []).filter(d => d.master_id === 'HAMS-M1-001');

            return res.status(200).json({
                success: true,
                totalCoaches: filtered.length,
                data: filtered
            });
        } catch (error) {
            console.error("New Company Data Error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    }
};

module.exports = hotAxleController;