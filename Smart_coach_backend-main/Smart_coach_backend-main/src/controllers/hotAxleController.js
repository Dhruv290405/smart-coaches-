const HotAxleModel = require("../models/hotAxle.model");
const supabaseAdmin = require("../config/supabaseAdmin");
const rbac = require("../utils/rbac");
const sOld = require('../config/supabaseOld');

async function getRailwayTechnicalIds() {
    const deviceMapping = {
        'SCBB NP001': 'NP001',
        'SCBB NP002': 'NP002',
        'SCBB NP003': 'NP003',
        'Raspberry4_4': '231035',
        'Raspberry4_1': '231545',
        'Raspberry4_2': '234534',
        'Raspberry4_3': '211245'
    };
    const railwayMeta = { ...deviceMapping };
    if (sOld) {
        try {
            const { data: regs } = await sOld
                .from('coaches_railway')
                .select('technical_id, device_id');
            for (const reg of (regs || [])) {
                if (reg.device_id) {
                    railwayMeta[reg.device_id] = reg.technical_id;
                }
            }
        } catch (e) {
            console.error("Error fetching coaches_railway:", e.message);
        }
    }
    return railwayMeta;
}

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
            const authorizedCoaches = await rbac.getAuthorizedCoachNumbers(req.user);

            const readings = await HotAxleModel.getData(filterDeviceId, historyLimit, authorizedCoaches);

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
            axleNumber,
            coachNumber, 
            coachType,
            coachDeviceId,
            startDate, 
            endDate, 
            page = 1, 
            limit = 30 
        } = req.query;

        const isHams = (coachType && coachType.toLowerCase() === 'hams') || (coachNumber && coachNumber.startsWith('Master: '));

        if (isHams && !rbac.isModuleAuthorized(req.user, 'hot_axle_section1')) {
            return res.status(200).json({
                success: true,
                meta: { totalRecords: 0, currentPage: parseInt(page), totalPages: 0, limit: parseInt(limit) },
                data: []
            });
        }

        if (!isHams && !rbac.isModuleAuthorized(req.user, 'hot_axle_section2')) {
            return res.status(200).json({
                success: true,
                meta: { totalRecords: 0, currentPage: parseInt(page), totalPages: 0, limit: parseInt(limit) },
                data: []
            });
        }

        if (isHams) {
            const sOld = require('../config/supabaseOld');
            if (!sOld) {
                return res.status(500).json({ success: false, message: "Old Supabase not configured" });
            }

            // Fetch HAMS registration metadata from coaches_hams - match by actual_id
            // coaches_hams schema: id, technical_id, coach_no, device_id, train_no, location, actual_id
            // device_id here = brake binding device (SCBB-NP-003)
            // coach_no = coach number shown as Technical ID (B1)
            const { data: hamsRegs } = await supabaseAdmin
                .from('coaches_hams')
                .select('coach_no, train_no, technical_id, location, actual_id, device_id');

            // Build lookup maps by actual_id and technical_id (lowercased)
            const hamsMetaMap = {};
            const hamsMetaMapByTechId = {};
            for (const reg of (hamsRegs || [])) {
                const k = (reg.actual_id || '').trim().toLowerCase();
                if (k) hamsMetaMap[k] = reg;
                const t = (reg.technical_id || '').trim().toLowerCase();
                if (t) hamsMetaMapByTechId[t] = reg;
            }

            // Try to find the best matching registration
            const masterIdParam = (coachDeviceId || coachNumber || '').toLowerCase().replace('master: ', '');
            const hamsReg = hamsMetaMap[masterIdParam] || hamsMetaMapByTechId[masterIdParam] || hamsMetaMap['hams-m1-001'] || (hamsRegs && hamsRegs[0]) || null;
            const dbMasterId = hamsReg ? hamsReg.actual_id : 'hams-m1-001';
            const isHamsM1 = (dbMasterId || '').toLowerCase() === 'hams-m1-001';

            // Fetch coach_type from coaches_railway using the brake binding device_id
            let coachTypeFromDB = isHamsM1 ? 'LWSCZ - AC' : 'B1';
            if (!isHamsM1 && hamsReg?.device_id) {
                const { data: railReg } = await supabaseAdmin
                    .from('coaches_railway')
                    .select('coach_type')
                    .eq('device_id', hamsReg.device_id)
                    .maybeSingle();
                if (railReg?.coach_type) coachTypeFromDB = railReg.coach_type;
            }

            let query = sOld.from('hams_data')
                .select('*')
                .in('master_id', [dbMasterId, dbMasterId.toLowerCase(), dbMasterId.toUpperCase()]);

            // Filter by specific sensor device if provided
            if (deviceId && deviceId !== 'All') {
                query = query.eq('device_id', deviceId);
            }

            if (startDate && endDate) {
                query = query
                    .gte('received_timestamp', `${startDate}T00:00:00`)
                    .lte('received_timestamp', `${endDate}T23:59:59`);
            }

            const { data, error } = await query
                .order('received_timestamp', { ascending: false })
                .limit(2000);

            // Field mapping:
            // coach_no  → shown as coach number (technical_id from registration)
            // device_id → shown as device_id (SCBB-NP-26-003, the brake binding device)
            // train_no  → from DB
            const coachNo = isHamsM1 ? '226965' : (hamsReg?.technical_id || '');
            const trainNo = isHamsM1 ? '1207069' : (hamsReg?.train_no || '');
            const technicalId = coachNo;
            const brakeDeviceId = isHamsM1 ? 'SCBB-NP-26-003' : (hamsReg?.device_id || '');
            const location = hamsReg?.location || 'N/A';
            const coachType = coachTypeFromDB;

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

            const hamsOrder = ['HAMS001', 'HAMS002', 'HAMS003', 'HAMS004', 'HAMS005', 'HAMS006', 'HAMS008', 'HAMS009'];
            let mappedHistory = [];
            
            // Build axle-specific device lookup map
            const axleDevices = {};
            for (const r of (hamsRegs || [])) {
                if (r.actual_id) {
                    axleDevices[r.actual_id.toLowerCase()] = r.device_id || '';
                }
            }
            const sensorToActualId = {
                'A11': 'axel_1a', 'A12': 'axel_1b',
                'A21': 'axel_2a', 'A22': 'axel_2b',
                'A31': 'axel_3a', 'A32': 'axel_3b',
                'A41': 'axel_4a', 'A42': 'axel_4b'
            };

            if (deviceId && deviceId !== 'All') {
                for (let bucket in grouped) {
                    const devices = grouped[bucket];
                    const match = devices.find(d => d.device_id === deviceId);
                    if (!match) continue; // Skip to prevent repeating timing/data issue when sensor was not active

                    const temp = match.temperature || 0;
                    let bat = 50;
                    if (match.battery_status) {
                        const bs = match.battery_status.toLowerCase();
                        if (bs === 'low') bat = 15;
                        else if (bs === 'moderate') bat = 40;
                        else if (bs === 'high') bat = 80;
                    }

                    let temps = [0,0,0,0,0,0,0,0];
                    let devIdx = hamsOrder.indexOf(deviceId);
                    if (devIdx === -1) {
                        const num = parseInt(deviceId.replace(/\D/g, ''));
                        if (!isNaN(num)) {
                            if (num <= 6) devIdx = num - 1;
                            else if (num >= 8 && num <= 9) devIdx = num - 2;
                        }
                    }
                    if (devIdx >= 0 && devIdx < 8) {
                        temps[devIdx] = temp;
                    } else {
                        temps[0] = temp;
                    }

                    let actualAxleDeviceId = deviceId;
                    if (deviceId.startsWith('A')) {
                        const actual = sensorToActualId[deviceId.toUpperCase()];
                        if (actual && axleDevices[actual]) {
                            actualAxleDeviceId = axleDevices[actual];
                        }
                    }

                    mappedHistory.push({
                        timestamp: bucket,
                        device_id: actualAxleDeviceId, // Axle-specific device ID
                        master_id: dbMasterId,
                        coach_number: coachNo,
                        train_no: trainNo,
                        technical_id: technicalId,
                        brake_device_id: brakeDeviceId,
                        coach_type: coachType,
                        owning_rly: 'VASP',
                        location: location,
                        a11_temp: temps[0], a12_temp: temps[1],
                        a21_temp: temps[2], a22_temp: temps[3],
                        a31_temp: temps[4], a32_temp: temps[5],
                        a41_temp: temps[6], a42_temp: temps[7],
                        battery_percentage: bat,
                        signal_strength: 0,
                        alert_status: temp > 60 ? 'Warning' : 'Good',
                    });
                }
            } else {
                for (let bucket in grouped) {
                    const devices = grouped[bucket];
                    const axleDevices = [...devices].filter(d => d.device_id !== 'HAMS007');

                    let temps = [0,0,0,0,0,0,0,0];
                    let maxTemp = 0;
                    for (let dev of axleDevices) {
                        let idx = hamsOrder.indexOf(dev.device_id);
                        if (idx === -1) {
                            const num = parseInt(dev.device_id.replace(/\D/g, ''));
                            if (!isNaN(num)) {
                                if (num <= 6) idx = num - 1;
                                else if (num >= 8 && num <= 9) idx = num - 2;
                            }
                        }
                        if (idx >= 0 && idx < 8) {
                            temps[idx] = dev.temperature || 0;
                            if (temps[idx] > maxTemp) maxTemp = temps[idx];
                        }
                    }

                    let bat = 50;
                    if (axleDevices[0] && axleDevices[0].battery_status) {
                        const bs = axleDevices[0].battery_status.toLowerCase();
                        if (bs === 'low') bat = 15;
                        else if (bs === 'moderate') bat = 40;
                        else if (bs === 'high') bat = 80;
                    }

                    mappedHistory.push({
                        timestamp: bucket,
                        device_id: brakeDeviceId || coachNo || dbMasterId,  // SCBB-NP-26-003
                        master_id: dbMasterId,
                        coach_number: coachNo,
                        train_no: trainNo,
                        technical_id: technicalId,
                        brake_device_id: brakeDeviceId,
                        coach_type: coachType,
                        owning_rly: 'VASP',
                        location: location,
                        a11_temp: temps[0], a12_temp: temps[1],
                        a21_temp: temps[2], a22_temp: temps[3],
                        a31_temp: temps[4], a32_temp: temps[5],
                        a41_temp: temps[6], a42_temp: temps[7],
                        battery_percentage: bat,
                        signal_strength: 0,
                        alert_status: maxTemp > 60 ? 'Warning' : 'Good',
                    });
                }
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
        const authorizedCoaches = await rbac.getAuthorizedCoachNumbers(req.user);

        const result = await HotAxleModel.getHistoryData({
            deviceId: deviceId || 'All',
            coachNumber: coachNumber || 'All',
            startDate: startDate || null,
            endDate: endDate || null,
            limit: 2000,
            offset: 0,
            authorizedCoaches
        });

        const technicalIdsMap = await getRailwayTechnicalIds();
        const rawItems = (result.data || []).map(item => ({
            ...item,
            technical_id: technicalIdsMap[item.device_id] || ''
        }));
        const axleColumns = ['a11_temp','a12_temp','a21_temp','a22_temp','a31_temp','a32_temp','a41_temp','a42_temp'];

        if (axleNumber && !isNaN(parseInt(axleNumber))) {
            const aIdx = parseInt(axleNumber) - 1;
            const col = axleColumns[aIdx] || 'a11_temp';
            const filtered = rawItems.map(d => {
                const val = d[col] || 0;
                const temps = [0,0,0,0,0,0,0,0];
                temps[aIdx] = val;
                return { ...d,
                    a11_temp: temps[0], a12_temp: temps[1],
                    a21_temp: temps[2], a22_temp: temps[3],
                    a31_temp: temps[4], a32_temp: temps[5],
                    a41_temp: temps[6], a42_temp: temps[7],
                };
            });
            const bucketed = {};
            for (let d of filtered) {
                if (!d.timestamp) continue;
                const dateObj = new Date(d.timestamp);
                if (isNaN(dateObj.getTime())) continue;
                const min = dateObj.getMinutes();
                const roundedMin = min - (min % 15);
                dateObj.setMinutes(roundedMin, 0, 0);
                const bucket = dateObj.toISOString();
                if (!bucketed[bucket] || new Date(d.timestamp) > new Date(bucketed[bucket].timestamp)) {
                    bucketed[bucket] = d;
                }
            }
            let paged2 = Object.values(bucketed);
            paged2.sort((a, b) => (b.timestamp || '').localeCompare(a.timestamp || ''));
            const total2 = paged2.length;
            const startIdx2 = (parseInt(page) - 1) * parseInt(limit);
            const slice2 = paged2.slice(startIdx2, startIdx2 + parseInt(limit));
            return res.status(200).json({
                success: true,
                meta: {
                    totalRecords: total2,
                    currentPage: parseInt(page),
                    totalPages: Math.ceil(total2 / parseInt(limit)),
                    limit: parseInt(limit)
                },
                data: slice2
            });
        }

        const grouped = {};
        for (let d of rawItems) {
            if (!d.timestamp) continue;
            const dateObj = new Date(d.timestamp);
            if (isNaN(dateObj.getTime())) continue;
            const min = dateObj.getMinutes();
            const roundedMin = min - (min % 15);
            dateObj.setMinutes(roundedMin, 0, 0);
            const bucket = dateObj.toISOString();
            if (!grouped[bucket] || new Date(d.timestamp) > new Date(grouped[bucket].timestamp)) {
                grouped[bucket] = d;
            }
        }

        let bucketed = Object.values(grouped);
        bucketed.sort((a, b) => (b.timestamp || '').localeCompare(a.timestamp || ''));

        const total = bucketed.length;
        const startIdx = (parseInt(page) - 1) * parseInt(limit);
        const paged = bucketed.slice(startIdx, startIdx + parseInt(limit));

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
            const authorizedCoaches = await rbac.getAuthorizedCoachNumbers(req.user);
            const statusData = await HotAxleModel.getLatestStatusForAllCoaches({
                trainNo, deviceId, coachType, owningRly, coachNumber
            }, authorizedCoaches);

            const technicalIdsMap = await getRailwayTechnicalIds();
            const enriched = (statusData || []).map(item => ({
                ...item,
                technical_id: technicalIdsMap[item.device_id] || ''
            }));

            return res.status(200).json({
                success: true,
                totalCoaches: enriched.length,
                data: enriched
            });

        } catch (error) {
            console.error("Dashboard Controller Error ->", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    },

    getNewCompanyData: async (req, res) => {
        try {
            const isDanapur = rbac.isModuleAuthorized(req.user, 'hot_axle_section2');

            if (isDanapur) {
                let authorizedCoaches = await rbac.getAuthorizedCoachNumbers(req.user);
                let query = supabaseAdmin
                    .from('hot_axle_logs')
                    .select('*')
                    .order('id', { ascending: false })
                    .limit(500);

                if (authorizedCoaches && authorizedCoaches.length > 0) {
                    query = query.in('coach_number', authorizedCoaches);
                }

                const { data, error } = await query;

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

            // Use coaches_hams as the registration source for Section 1 HAMS devices
            const { data: hamsRegs } = await supabaseAdmin
                .from('coaches_hams')
                .select('coach_no, train_no, technical_id, location, actual_id, device_id');

            // Fetch coach types from coaches_railway
            const { data: railRegs } = await supabaseAdmin
                .from('coaches_railway')
                .select('device_id, coach_type');
            
            const railCoachTypeMap = {};
            for (const r of (railRegs || [])) {
                if (r.device_id && r.coach_type) {
                    railCoachTypeMap[r.device_id] = r.coach_type;
                }
            }

            // Build a lookup for coach-level meta (use first valid entry as master fallback for now)
            // Also build an axle-level device ID map: actual_id -> device_id
            const hamsMeta = {};
            const axleDevices = {};
            for (const reg of (hamsRegs || [])) {
                const key = (reg.actual_id || '').trim();
                if (key) {
                    const isHamsM1 = key.toLowerCase() === 'hams-m1-001';
                    axleDevices[key.toLowerCase()] = reg.device_id || '';
                    hamsMeta[key] = {
                        coach_no: reg.coach_no || '',
                        train_no: isHamsM1 ? '1207069' : (reg.train_no || ''),
                        technical_id: isHamsM1 ? '226965' : (reg.technical_id || ''),
                        location: reg.location || 'N/A',
                        device_id: isHamsM1 ? 'SCBB-NP-26-003' : (reg.device_id || ''),
                        coach_type: isHamsM1 ? 'LWSCZ - AC' : (railCoachTypeMap[reg.device_id] || 'B1'),
                    };
                }
            }

            // Fallback: use first registration for all rows if no direct match
            const firstReg = hamsRegs && hamsRegs[0];
            const isHamsM1Fallback = firstReg && (firstReg.actual_id || '').toLowerCase() === 'hams-m1-001';
            const defaultMeta = hamsRegs && hamsRegs.length > 0 ? {
                coach_no: firstReg.coach_no || '',
                train_no: isHamsM1Fallback ? '1207069' : (firstReg.train_no || ''),
                technical_id: isHamsM1Fallback ? '226965' : (firstReg.technical_id || ''),
                location: firstReg.location || 'N/A',
                device_id: isHamsM1Fallback ? 'SCBB-NP-26-003' : (firstReg.device_id || ''),
                coach_type: isHamsM1Fallback ? 'LWSCZ - AC' : (railCoachTypeMap[firstReg.device_id] || 'B1'),
            } : null;

            const registeredMasterIds = (hamsRegs || []).map(r => r.actual_id).filter(Boolean);
            const masterFilterSet = new Set();
            for (const id of registeredMasterIds) {
                masterFilterSet.add(id);
                masterFilterSet.add(id.toLowerCase());
                masterFilterSet.add(id.toUpperCase());
            }
            if (masterFilterSet.size === 0) {
                masterFilterSet.add('hams-m1-001');
                masterFilterSet.add('HAMS-M1-001');
            }
            const masterFilter = [...masterFilterSet];

            const { data: hamsData, error: hamsError } = await supabaseOld
                .from('hams_data')
                .select('*')
                .in('master_id', masterFilter)
                .order('created_at', { ascending: false });

            if (hamsError) throw hamsError;

            const enriched = (hamsData || []).map(d => {
                const meta = hamsMeta[d.master_id] || defaultMeta || {};
                const isHamsM1 = (d.master_id || '').toLowerCase() === 'hams-m1-001';
                return {
                    ...d,
                    device_id: d.device_id || '',
                    master_id: d.master_id || 'HAMS-M1-001',
                    coach_number: isHamsM1 ? '226965' : (meta.technical_id || ''),
                    train_no: isHamsM1 ? '1207069' : (meta.train_no || ''),
                    coach_type: isHamsM1 ? 'LWSCZ - AC' : (meta.coach_type || 'B1'),
                    brake_device_id: isHamsM1 ? 'SCBB-NP-26-003' : (meta.device_id || ''),
                    location: meta.location || 'N/A',
                    axle_devices: axleDevices,
                };
            });

            return res.status(200).json({
                success: true,
                totalCoaches: enriched.length,
                data: enriched,
            });
        } catch (error) {
            console.error("New Company Data Error:", error.message);
            res.status(500).json({ success: false, error: error.message });
        }
    }
};

module.exports = hotAxleController;