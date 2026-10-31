const Pneumatic = require('../models/pneumatic.model');
const supabase = require('../config/supabaseOld');
const supabaseAdmin = require('../config/supabaseAdmin');
const { dualInsert } = require('../config/dualWrite');
const { saveInAppNotificationForAllUsers } = require('../utils/notificationService');
const { generatePneumaticHistoryPdf, generatePneumaticFaultsPdf } = require('../utils/pneumaticPdfGenerator');

// Tracks last CR-overcharge state per device to only notify on a green->red change.
const _crOverchargeState = {};
const rbac = require('../utils/rbac');
const OLD_BACKEND = 'https://smart-coach-api-production.up.railway.app';

async function forwardToOldBackend(req, res, path) {
    try {
        const queryString = req.url.split('?')[1] || '';
        const url = `${OLD_BACKEND}/smart_coach_api/api${path}${queryString ? '?' + queryString : ''}`;
        const headers = {};
        if (req.headers.authorization) headers['Authorization'] = req.headers.authorization;
        const response = await fetch(url, { headers });
        const data = await response.json();
        return res.status(response.status).json(data);
    } catch (err) {
        console.error(`Forward to old backend failed for ${path}:`, err.message);
        return res.status(502).json({ success: false, error: 'Backend fallback failed' });
    }
}

exports.receiveData = async (req, res) => {
    try {
        const payload = req.body;
        if (req.query.confirmationToken) return res.status(200).send("OK");
        if (!payload) return res.status(400).json({ success: false, message: "Empty payload" });

        const formattedTime = (payload.timestamp || new Date().toISOString())
            .replace('T', ' ').replace(/\..*Z|Z/, '');

        const bpcRow = {
            device_id: payload.device_id || null,
            coach_no: payload.coach_no || payload.coach_number || null,
            bp: payload.bp != null ? parseFloat(payload.bp) : 0,
            fp: payload.fp != null ? parseFloat(payload.fp) : 0,
            bc: payload.bc != null ? parseFloat(payload.bc) : 0,
            cr: payload.cr != null ? parseFloat(payload.cr) : 0,
            brake_status: payload.brake_status || 'Normal',
            brake_duration: payload.brake_duration || 0,
            brake_applied_time: payload.brake_applied_time || 0,
            brake_released_time: payload.brake_released_time || 0,
            brake_fault: payload.brake_fault || null,
            timestamp: formattedTime
        };

        const pressureLogsRow = {
            device_id: payload.device_id || null,
            coach_number: payload.coach_no || payload.coach_number || null,
            bp_pressure: payload.bp != null ? parseFloat(payload.bp) : 0,
            current_pressure: payload.bc != null ? parseFloat(payload.bc) : 0,
            brake_applied_time: payload.brake_applied_time || null,
            brake_released_time: payload.brake_released_time || null,
            timestamp: formattedTime,
            train_no: payload.train_no || payload.train_number || null,
            coach_type: payload.coach_type || null,
            owning_rly: payload.owning_rly || null
        };

        let insertedId = null;
        if (supabase) {
            const { data: insOld, error: errOld } = await supabase.from('bpc_pressure').insert([bpcRow]).select();
            if (errOld) console.error("[bpc_pressure insert error]:", errOld.message);
            else if (insOld?.[0]?.id) insertedId = insOld[0].id;
        }

        if (supabaseAdmin) {
            const { data: insNew, error: errNew } = await supabaseAdmin.from('pressure_logs').insert([pressureLogsRow]).select();
            if (errNew) console.error("[pressure_logs insert error]:", errNew.message);
            else if (!insertedId && insNew?.[0]?.id) insertedId = insNew[0].id;
        }

        if (global._io) {
            global._io.emit('pneumatic:update', { 
                ...bpcRow, 
                id: insertedId 
            });
        }

        return res.status(201).json({ success: true, message: "Pneumatic data stored", id: insertedId });
    } catch (error) {
        console.error("Pneumatic Receive Error:", error.message);
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.getBreakBindingData = async (req, res) => {
    if (!rbac.isModuleAuthorized(req.user, 'brake_binding')) {
        return res.status(404).json({
            success: false,
            message: "No brake binding data found or access restricted for your location"
        });
    }
    if (!supabase) {
        return forwardToOldBackend(req, res, '/pneumatic/status');
    }
    try {
        let filterDeviceId = req.query.deviceId || null; 
        const fromDate = req.query.from_date || null;
        const toDate = req.query.to_date || null;

        const requestedLimit = Math.max(parseInt(req.query.limit, 10) || 10, 1);
        // The app requests 10,000 rows for date-range exports. Some coaches
        // produce more than 10,000 readings in a day, so allow a larger
        // bounded result only for those bulk date-range requests.
        const isBulkDateExport = Boolean(fromDate && toDate && requestedLimit >= 10000);
        const historyLimit = isBulkDateExport
            ? 50000
            : Math.min(parseInt(req.query.limit, 10) || 10000, 10000);
        const limit = isBulkDateExport ? 50000 : Math.min(requestedLimit, 10000);
        const offset = Math.max(parseInt(req.query.offset, 10) || 0, 0);

        const readings = await Pneumatic.getLatestReading(filterDeviceId, req.user, limit, offset, fromDate, toDate);

        if (!readings || readings.length === 0) {
            if (!filterDeviceId && req.user && req.user.role_id !== 1) {
                const userLoc = rbac.getUserLocation(req.user);
                if (userLoc && supabase) {
                    const { data: devs } = await supabase
                        .from('coaches_railway')
                        .select('device_id')
                        .ilike('Location', userLoc)
                        .limit(1);
                    if (devs && devs.length === 0) {
                        const { data: devs2 } = await supabaseAdmin
                            .from('coaches_railway')
                            .select('device_id')
                            .ilike('Location', userLoc)
                            .limit(1);
                        if (devs2 && devs2.length > 0) filterDeviceId = devs2[0].device_id;
                    } else if (devs && devs.length > 0) {
                        filterDeviceId = devs[0].device_id;
                    }
                }
            }
            if (filterDeviceId) {
                const activeDeviceId = filterDeviceId;
            let eventQuery = supabase.from('event_publish')
                .select('id, timestamp, event_status, coach_no, event_message')
                .eq('device_id', activeDeviceId)
                .order('timestamp', { ascending: false })
                .limit(historyLimit);
            let faultQuery = supabase.from('brake_fault_event')
                .select('device_id, fault_name, timestamp, event_message')
                .eq('device_id', activeDeviceId)
                .order('timestamp', { ascending: false })
                .limit(historyLimit);
                const [evtResult, fltResult] = await Promise.all([eventQuery, faultQuery]);

                let evtData = evtResult;
                let fltData = fltResult;

                if (evtResult.error && supabaseAdmin) {
                    evtData = await supabaseAdmin.from('event_publish')
                        .select('id, timestamp, event_status, coach_no, event_message')
                        .eq('device_id', activeDeviceId)
                        .order('timestamp', { ascending: false })
                        .limit(historyLimit);
                }
                if (fltResult.error && supabaseAdmin) {
                    fltData = await supabaseAdmin.from('brake_fault_event')
                        .select('device_id, fault_name, timestamp, event_message')
                        .eq('device_id', activeDeviceId)
                        .order('timestamp', { ascending: false })
                        .limit(historyLimit);
                }

                return res.status(200).json({
                    success: true,
                    state: 'No Sensor Data',
                    readings: { bp: 0, fp: 0, bc: 0, cr: 0, dropRate: 0, brakeDuration: 0, appliedTime: 0, releasedTime: 0 },
                    recentEvents: (evtData.data || []).map(e => ({ id: e.id, time: e.timestamp, status: e.event_status, coach: e.coach_no, reason: e.event_message })),
                    activeFaults: (fltData.data || []).map(f => ({ deviceId: f.device_id, type: f.fault_name, severity: 'High', description: f.event_message, timestamp: f.timestamp })),
                    lastUpdated: new Date().toISOString()
                });
            }
            return res.status(404).json({ 
                success: false, 
                message: filterDeviceId ? `No data found for device: ${filterDeviceId}` : "No data found or access restricted" 
            });
        }

        const getStableValue = (sensorKey) => {
            if (readings.length < 2) return readings[0][sensorKey];
            const frequencyMap = {};
            let maxFreq = 0;
            let mostFrequentValue = readings[0][sensorKey];
            const analysisSet = readings.slice(0, 7); 
            
            analysisSet.forEach((r) => {
                const val = parseFloat(r[sensorKey]).toFixed(1);
                frequencyMap[val] = (frequencyMap[val] || 0) + 1;
                if (frequencyMap[val] > maxFreq) {
                    maxFreq = frequencyMap[val];
                    mostFrequentValue = val;
                }
            });

            const latestVal = parseFloat(readings[0][sensorKey]).toFixed(1);
            if (latestVal !== mostFrequentValue && maxFreq >= 2) {
                return mostFrequentValue; 
            }
            return readings[0][sensorKey];
        };

        const data = {
            ...readings[0],
            bp: getStableValue('bp'),
            fp: getStableValue('fp'),
            bc: getStableValue('bc'),
            cr: getStableValue('cr')
        };

        const lastData = readings[1] || readings[0];
        const checkSpike = (newVal, lastVal) => {
            return Math.abs(parseFloat(newVal) - parseFloat(lastVal)) > 7000 ? lastVal : newVal;
        };

        const finalData = {
            ...data,
            bp: checkSpike(data.bp, lastData.bp),
            fp: checkSpike(data.fp, lastData.fp),
            bc: checkSpike(data.bc, lastData.bc),
            cr: checkSpike(data.cr, lastData.cr)
        };

        const prevData = lastData;
        const activeDeviceId = filterDeviceId || finalData.device_id;

        let coachQuery = supabase.from('coaches_railway')
            .select('technical_id, coach_no, Train_no, Location')
            .eq('device_id', activeDeviceId);

        let { data: dbCoach } = await coachQuery.maybeSingle();

        if (!dbCoach && supabaseAdmin) {
            let fbCoachQuery = supabaseAdmin.from('coaches_railway')
                .select('technical_id, coach_no, Train_no, Location')
                .eq('device_id', activeDeviceId);
            const { data: fbCoach } = await fbCoachQuery.maybeSingle();
            if (fbCoach) dbCoach = fbCoach;
        }

        if (filterDeviceId && !dbCoach) {
            const deviceMapping = {
                'SCBB NP001': { technical_id: 'NP001', coach_no: 'NP1', Train_no: 'NAGPUR01', Location: 'Nagpur' },
                'SCBB NP002': { technical_id: 'NP002', coach_no: 'NP2', Train_no: 'NAGPUR01', Location: 'Nagpur' },
                'SCBB NP003': { technical_id: 'NP003', coach_no: 'NP3', Train_no: 'NAGPUR01', Location: 'Nagpur' },
                'Raspberry4_5': { technical_id: '19771', coach_no: 'B2', Train_no: '12345', Location: 'Nagpur' },
                'Raspberry4_6': { technical_id: '226965', coach_no: 'C3', Train_no: '12069', Location: 'Nagpur' },
                'Raspberry4_4': { technical_id: '231035', coach_no: 'M3', Train_no: '13071', Location: 'Kolkata' },
                'Raspberry4_1': { technical_id: '231545', coach_no: 'S4', Train_no: '13277', Location: 'Jaipur' },
                'Raspberry4_2': { technical_id: '193431', coach_no: 'S3', Train_no: '12578', Location: 'Howrah' },
                'Raspberry4_3': { technical_id: '197832', coach_no: 'D3', Train_no: '65214', Location: 'Howrah' }
            };
            dbCoach = deviceMapping[activeDeviceId] || null;
        }

        let eventQuery = supabase.from('event_publish')
            .select('id, timestamp, event_status, coach_no, bp, bc, event_message')
            .eq('device_id', activeDeviceId)
            .order('timestamp', { ascending: false })
            .limit(historyLimit);

        let faultQuery = supabase.from('brake_fault_event')
            .select('device_id, fault_name, timestamp, event_message')
            .eq('device_id', activeDeviceId)
            .order('timestamp', { ascending: false })
            .limit(historyLimit);


        if (fromDate) {
            const start = `${fromDate}T00:00:00`;
            eventQuery = eventQuery.gte('timestamp', start);
            faultQuery = faultQuery.gte('timestamp', start);
        }
        if (toDate) {
            const end = `${toDate}T23:59:59`;
            eventQuery = eventQuery.lte('timestamp', end);
            faultQuery = faultQuery.lte('timestamp', end);
        }

        const [eventData, faultData] = await Promise.all([
            eventQuery,
            faultQuery
        ]);

        const deviceMapping = {
            'SCBB NP001': { technical_id: 'NP001', coach_no: 'NP1', Train_no: 'NAGPUR01', Location: 'Nagpur' },
            'SCBB NP002': { technical_id: 'NP002', coach_no: 'NP2', Train_no: 'NAGPUR01', Location: 'Nagpur' },
            'SCBB NP003': { technical_id: 'NP003', coach_no: 'NP3', Train_no: 'NAGPUR01', Location: 'Nagpur' },
            'Raspberry4_5': { technical_id: '19771', coach_no: 'B2', Train_no: '12345', Location: 'Nagpur' },
            'Raspberry4_6': { technical_id: '226965', coach_no: 'C3', Train_no: '12069', Location: 'Nagpur' },
            'Raspberry4_4': { technical_id: '231035', coach_no: 'M3', Train_no: '13071', Location: 'Kolkata' },
            'Raspberry4_1': { technical_id: '231545', coach_no: 'S4', Train_no: '13277', Location: 'Jaipur' },
            'Raspberry4_2': { technical_id: '193431', coach_no: 'S3', Train_no: '12578', Location: 'Howrah' },
            'Raspberry4_3': { technical_id: '197832', coach_no: 'D3', Train_no: '65214', Location: 'Howrah' }
        };
        const fallback = deviceMapping[activeDeviceId] || {};

        const finalCoachInfo = {
            technical_id: dbCoach?.technical_id || fallback.technical_id || "N/A",
            coach_no: dbCoach?.coach_no || fallback.coach_no || finalData.coach_no || "Unknown",
            Train_no: dbCoach?.Train_no || fallback.Train_no || "Unknown",
            Location: dbCoach?.Location || fallback.Location || "Unknown"
        };

        const bp = parseFloat(finalData.bp) || 0;
        const fp = parseFloat(finalData.fp) || 0;
        const bc = parseFloat(finalData.bc) || 0;
        const cr = parseFloat(finalData.cr) || 0;
        const prevBP = parseFloat(prevData.bp) || 0;

        const lastSeen = new Date(finalData.timestamp);
        const now = new Date();
        const timeDiff = Math.max((lastSeen - new Date(prevData.timestamp)) / 1000, 1); 
        const bpDropRate = (prevBP - bp) / timeDiff;

        let detectedState = finalData.brake_status || 'Normal';
        if ((now - lastSeen) > 300000) detectedState = 'Sensor Offline';

        let newAlerts = { 
            binding_residual: (bc > 0.1 && bp >= 4.8) ? 'red' : 'green', 
            binding_severe: (bc >= 3.1) ? 'warning' : 'green',
            leakage: (bc <= 0.1 && (bp <= 4.8 || fp <= 5.8)) ? 'warning' : 'green',
            cr_overcharge: (cr >= 5.2) ? 'red' : 'green',
            dv_defect: (bpDropRate >= 0.6 && bc <= 1.2) ? 'warning' : 'green',
            emergency: (bpDropRate >= 0.6) ? 'yellow' : 'green'
        };

        if (detectedState === 'Normal' || detectedState === 'IDLE') {
            if (newAlerts.binding_residual === 'red' || newAlerts.binding_severe === 'warning') {
                detectedState = 'Brake Binding';
            } else if (newAlerts.emergency === 'yellow') {
                detectedState = 'Emergency Brake';
            } else if (newAlerts.leakage === 'warning') {
                detectedState = 'Air Leakage';
            } else if (newAlerts.dv_defect === 'warning') {
                detectedState = 'DV Defect';
            } else if (newAlerts.cr_overcharge === 'red') {
                detectedState = 'Overcharge';
            }
        }

        if (faultData.data && faultData.data.length > 0) {
            const latestFault = faultData.data[0]; 
            const faultTime = new Date(latestFault.timestamp);
            const timeDifferenceInSeconds = (now - faultTime) / 1000;

            if (timeDifferenceInSeconds <= 120) {
                const faultName = latestFault.fault_name || 'Brake Binding';
                const fnUpper = faultName.toUpperCase();
                // Check if fault matches one of the five diagnostic flags
                const isDiagFlag = fnUpper.includes('BRAKE BINDING')
                    || fnUpper.includes('CR OVERCHARG')
                    || fnUpper.includes('EMERGENCY')
                    || fnUpper.includes('DV BC')
                    || fnUpper.includes('DEFECT');

                const nowStr = new Date().toISOString().replace('T', ' ').slice(0, 19);
                const title = `Alert: ${faultName} in Train ${finalCoachInfo.Train_no}, Coach_Unique Id ${finalCoachInfo.coach_no} | ${nowStr}`;
                const body = title;

                const location = finalCoachInfo.Location
                    || finalCoachInfo.location
                    || finalCoachInfo.division
                    || finalCoachInfo.division_name
                    || null;
                saveInAppNotificationForAllUsers(title, body, 'BRAKE_BINDING', {
                    module: 'brake_binding',
                    location,
                    coach_no: finalCoachInfo.coach_no,
                    train_no: finalCoachInfo.Train_no,
                    fault_name: faultName,
                    is_diagnostic_flag: isDiagFlag,
                    severity: fnUpper.includes('SEVERE') ? 'critical' : 'warning'
                });
            }
        }

        if (newAlerts.cr_overcharge === 'red') {
            const crKey = String(activeDeviceId || finalCoachInfo.coach_no);
            const lastState = _crOverchargeState[crKey];
            const lastTime = (typeof lastState === 'object' && lastState) ? lastState.time : 0;
            const currentState = (typeof lastState === 'object' && lastState) ? lastState.state : lastState;
            const nowTime = Date.now();

            // 30 minutes throttle between duplicate CR overcharge notifications
            if (currentState !== 'red' || (nowTime - lastTime) > (30 * 60 * 1000)) {
                const nowStr = new Date().toISOString().replace('T', ' ').slice(0, 19);
                const crTitle = `Alert: CR Overcharging in Train ${finalCoachInfo.Train_no}, Coach_Unique Id ${finalCoachInfo.coach_no} | ${nowStr}`;
                const crBody = crTitle;
                const location = finalCoachInfo.Location
                    || finalCoachInfo.location
                    || finalCoachInfo.division
                    || finalCoachInfo.division_name
                    || null;
                saveInAppNotificationForAllUsers(crTitle, crBody, 'CR_OVERCHARGE', {
                    module: 'brake_binding',
                    location,
                    coach_no: finalCoachInfo.coach_no,
                    train_no: finalCoachInfo.Train_no,
                    fault_name: 'CR Overcharging',
                    is_diagnostic_flag: true,
                    severity: 'warning'
                });
            }
            _crOverchargeState[crKey] = { state: 'red', time: nowTime };
        } else {
            const crKey = String(activeDeviceId || finalCoachInfo.coach_no);
            _crOverchargeState[crKey] = { state: 'green', time: Date.now() };
        }

        res.status(200).json({
            success: true,
            context: { 
                deviceId: activeDeviceId,
                technical_id: finalCoachInfo.technical_id,
                coach_no: finalCoachInfo.coach_no,
                Train_no: finalCoachInfo.Train_no,
                location: finalCoachInfo.Location || finalCoachInfo.location || "Unknown"
            },
            state: detectedState,
            brakeStatus: finalData.brake_status || "IDLE",
            alerts: newAlerts,
            readings: {
                bp, fp, bc, cr,
                dropRate: Math.abs(bpDropRate).toFixed(2),
                brakeDuration: finalData.brake_duration || 0,
                appliedTime: finalData.brake_applied_time || 0,
                releasedTime: finalData.brake_released_time || 0
            },
            recentEvents: (eventData.data || []).map(evt => ({
                id: evt.id,
                time: evt.timestamp,
                status: evt.event_status || "LOG", 
                coach: evt.coach_no || finalCoachInfo.coach_no,
                bp: evt.bp, bc: evt.bc,
                reason: evt.event_message || "System Log"
            })),
            activeFaults: (faultData.data || []).map(f => ({
                deviceId: f.device_id, 
                type: f.fault_name || "System Fault", 
                severity: "High",
                description: f.event_message || f.fault_name,
                timestamp: f.timestamp
            })),
            history: {
                limit: historyLimit,
                data: readings.slice(0, historyLimit).map(row => ({
                    timestamp: row.timestamp,
                    device_id: row.device_id,
                    location: row.Location || row.location || finalCoachInfo.location, 
                    train_no: row.Train_no || row.train_no || finalCoachInfo.Train_no,
                    coach_no: row.coach_no,
                    bp: row.bp,
                    fp: row.fp,
                    bc: row.bc,
                    cr: row.cr,
                    brake_status: row.brake_status,
                    brake_applied_time: row.brake_applied_time || 0,
                    brake_released_time: row.brake_released_time || 0,
                    brake_duration: row.brake_duration || 0
                }))
            },
            lastUpdated: finalData.timestamp
        });

    } catch (err) {
        console.error("Controller Error:", err);
        res.status(500).json({ success: false, error: err.message });
    }
};

exports.getCoachesByLocation = async (req, res) => {
    if (!rbac.isModuleAuthorized(req.user, 'brake_binding')) {
        return res.status(200).json({
            success: true,
            message: "No coaches accessible for your location",
            count: 0,
            data: []
        });
    }
    if (!supabase) {
        const deviceMapping = {
            'SCBB NP001': { technical_id: 'NP001', coach_no: 'NP1', Train_no: 'NAGPUR01', location: 'Nagpur' },
            'SCBB NP002': { technical_id: 'NP002', coach_no: 'NP2', Train_no: 'NAGPUR01', location: 'Nagpur' },
            'SCBB NP003': { technical_id: 'NP003', coach_no: 'NP3', Train_no: 'NAGPUR01', location: 'Nagpur' },
            'Raspberry4_4': { technical_id: '231035', coach_no: 'M3', Train_no: '13071', location: 'Kolkatta' },
            'Raspberry4_1': { technical_id: '231545', coach_no: 'S4', Train_no: '13277', location: 'Jaipur' },
            'Raspberry4_2': { technical_id: '234534', coach_no: 'S3', Train_no: '12578', location: 'Jaipur' },
            'Raspberry4_3': { technical_id: '211245', coach_no: 'S2', Train_no: '65214', location: 'Jaipur' }
        };
        const userLoc = (req.user?.division_name || req.user?.region_name || '').toLowerCase();
        const filtered = Object.entries(deviceMapping).filter(([_, info]) =>
            !userLoc || info.location.toLowerCase() === userLoc
        );
        const data = filtered.map(([deviceId, info], idx) => ({
            id: idx + 1,
            technical_id: info.technical_id,
            coach_no: info.coach_no,
            device_id: deviceId,
            Train_no: info.Train_no,
            Location: info.location,
            Actual_id: info.technical_id
        }));
        return res.status(200).json({
            success: true,
            message: `Coaches fetched (fallback) for location: ${userLoc || 'all'}`,
            count: data.length,
            data
        });
    }
    try {
        if (!req.user) {
            return res.status(401).json({ 
                success: false, 
                message: "Unauthorized: User details not found in token" 
            });
        }

        const { role_id } = req.user;

        const userLocation = role_id !== 1 ? rbac.getUserLocation(req.user) : null;
        if (role_id !== 1 && !userLocation) {
            return res.status(403).json({
                success: false,
                message: "Access denied: No region or division mapped to this user account"
            });
        }

        // Case-insensitive location match that also accepts suffixed locations (e.g. Jaipur_N1)
        // and Eastern Railway clusters (Kolkata / Howrah).
        const matchesLocation = (location) => {
            if (!location || !userLocation) return false;
            const rowLoc = String(location).trim().toLowerCase();
            const userLoc = String(userLocation).trim().toLowerCase();
            if (
                (rowLoc.includes('kolkata') || rowLoc.includes('kolkatta') || rowLoc.includes('howrah')) &&
                (userLoc.includes('kolkata') || userLoc.includes('kolkatta') || userLoc.includes('howrah'))
            ) {
                return true;
            }
            return (
                rowLoc === userLoc ||
                rowLoc.startsWith(`${userLoc}_`) ||
                rowLoc.startsWith(`${userLoc} `) ||
                userLoc.startsWith(`${rowLoc}_`) ||
                userLoc.startsWith(`${rowLoc} `)
            );
        };

        const COACH_COLUMNS =
            'id, technical_id, coach_no, device_id, Train_no, Location, Actual_id';

        // Try Project 2 (supabaseOld) first
        let coaches = [];
        const { data: coachesOld, error } = await supabase
            .from('coaches_railway')
            .select(COACH_COLUMNS);

        if (error) throw error;

        const coachesOldFiltered = (coachesOld || []).filter(
            (c) => role_id === 1 || matchesLocation(c.Location)
        );
        if (coachesOldFiltered.length > 0) {
            coaches = coachesOldFiltered;
        } else if (supabaseAdmin) {
            // Fallback: try Project 1 (supabaseAdmin)
            const { data: coachesAdmin } = await supabaseAdmin
                .from('coaches_railway')
                .select(COACH_COLUMNS);
            const coachesAdminFiltered = (coachesAdmin || []).filter(
                (c) => role_id === 1 || matchesLocation(c.Location)
            );
            if (coachesAdminFiltered.length > 0) {
                coaches = coachesAdminFiltered;
            }
        }

        if (!coaches || coaches.length === 0) {
            // Last resort: hardcoded device mapping
            const deviceMapping = {
                'Raspberry4_3': { technical_id: '197832', coach_no: 'D3', Train_no: '13009', Location: 'Howrah' },
                'Raspberry4_2': { technical_id: '193431', coach_no: 'S3', Train_no: '12273', Location: 'Howrah' },
                'Raspberry5_5': { technical_id: '231035', coach_no: 'S5', Train_no: '12273', Location: 'Howrah' },
                'Raspberry4_5': { technical_id: '19771', coach_no: 'B2', Train_no: '12345', Location: 'Jaipur_N1' },
                'Raspberry4_6': { technical_id: '232620', coach_no: 'S3', Train_no: '19711', Location: 'Jaipur_N2' },
                'Raspberry4_7': { technical_id: '226965', coach_no: 'LWSCZ-AC', Train_no: '1207069', Location: 'Nagpur' },
                'Raspberry4_8': { technical_id: '135784', coach_no: 'B2', Train_no: '240697', Location: 'Mumbai' },
                'SCBB NP001': { technical_id: 'NP001', coach_no: 'NP1', Train_no: 'NAGPUR01', Location: 'Nagpur' },
                'SCBB NP002': { technical_id: 'NP002', coach_no: 'NP2', Train_no: 'NAGPUR01', Location: 'Nagpur' },
                'SCBB NP003': { technical_id: 'NP003', coach_no: 'NP3', Train_no: 'NAGPUR01', Location: 'Nagpur' },
            };
            if (role_id !== 1) {
                const filtered = Object.entries(deviceMapping).filter(([_, info]) =>
                    matchesLocation(info.Location)
                );
                coaches = filtered.map(([deviceId, info], idx) => ({
                    id: idx + 1,
                    technical_id: info.technical_id,
                    coach_no: info.coach_no,
                    device_id: deviceId,
                    Train_no: info.Train_no,
                    Location: info.Location,
                    Actual_id: info.technical_id
                }));
            } else {
                coaches = Object.entries(deviceMapping).map(([deviceId, info], idx) => ({
                    id: idx + 1,
                    technical_id: info.technical_id,
                    coach_no: info.coach_no,
                    device_id: deviceId,
                    Train_no: info.Train_no,
                    Location: info.Location,
                    Actual_id: info.technical_id
                }));
            }
        }

        if (!coaches || coaches.length === 0) {
            return res.status(200).json({
                success: true,
                message: "No coaches registered or accessible for your location",
                count: 0,
                data: []
            });
        }

        const userLoc = rbac.getUserLocation(req.user);
        return res.status(200).json({
            success: true,
            message: role_id === 1 ? "All coaches fetched (Admin View)" : `Coaches fetched for location: ${userLoc}`,
            count: coaches.length,
            data: coaches
        });

    } catch (err) {
        console.error("Error in getCoachesByLocation:", err.message);
        return res.status(500).json({ 
            success: false, 
            error: err.message 
        });
    }
};

exports.exportHistoryPdf = async (req, res) => {
    if (!rbac.isModuleAuthorized(req.user, 'brake_binding')) {
        return res.status(403).json({ success: false, message: 'Access restricted' });
    }
    try {
        const fromDate = req.query.from_date || null;
        const toDate   = req.query.to_date   || null;
        const deviceId = req.query.deviceId  || null;
        const reqLimit = Math.min(Math.max(parseInt(req.query.limit, 10) || 50000, 1), 50000);
        const rows = await Pneumatic.getLatestReading(deviceId, req.user, reqLimit, 0, fromDate, toDate);
        if (!rows || rows.length === 0) {
            return res.status(404).json({ success: false, message: 'No data found for selected range' });
        }
        const fmtDate = (d) => {
            if (!d) return '';
            try {
                const dt = new Date(d);
                const p = (n) => String(n).padStart(2, '0');
                return `${p(dt.getDate())}/${p(dt.getMonth() + 1)}/${dt.getFullYear()}`;
            } catch (_) { return String(d); }
        };
        const now = new Date();
        const p = (n) => String(n).padStart(2, '0');
        const ts = `${now.getFullYear()}${p(now.getMonth()+1)}${p(now.getDate())}_${p(now.getHours())}${p(now.getMinutes())}${p(now.getSeconds())}`;
        generatePneumaticHistoryPdf(res, {
            rows,
            meta: {
                title:     'Brake Binding History Report',
                period:    fromDate && toDate ? `Period: ${fmtDate(fromDate)} to ${fmtDate(toDate)}` : `Period: Latest ${rows.length} records`,
                metadata:  `Train: ${rows[0]?.train_no || rows[0]?.Train_no || 'N/A'}  |  Location: ${rows[0]?.location || rows[0]?.Location || 'N/A'}  |  Device: ${deviceId || 'All Devices'}`,
                generated: `Generated: ${p(now.getDate())}/${p(now.getMonth()+1)}/${now.getFullYear()} ${p(now.getHours())}:${p(now.getMinutes())}  |  Total Records: ${rows.length}`,
                filename:  `brake_binding_history_${ts}.pdf`,
            },
        });
    } catch (err) {
        console.error('exportHistoryPdf error:', err.message);
        if (!res.headersSent) res.status(500).json({ success: false, error: err.message });
    }
};

exports.exportFaultsPdf = async (req, res) => {
    if (!rbac.isModuleAuthorized(req.user, 'brake_binding')) {
        return res.status(403).json({ success: false, message: 'Access restricted' });
    }
    try {
        const fromDate = req.query.from_date || null;
        const toDate   = req.query.to_date   || null;
        const deviceId = req.query.deviceId  || null;
        const reqLimit = Math.min(Math.max(parseInt(req.query.limit, 10) || 50000, 1), 50000);
        if (!supabase && !supabaseAdmin) return res.status(503).json({ success: false, message: 'Database unavailable' });
        const db = supabase || supabaseAdmin;
        let faultQuery = db.from('brake_fault_event')
            .select('device_id, fault_name, timestamp, event_message')
            .order('timestamp', { ascending: false })
            .limit(reqLimit);
        if (deviceId) faultQuery = faultQuery.eq('device_id', deviceId);
        if (fromDate)  faultQuery = faultQuery.gte('timestamp', `${fromDate}T00:00:00`);
        if (toDate)    faultQuery = faultQuery.lte('timestamp', `${toDate}T23:59:59`);
        if (req.user && req.user.role_id !== 1) {
            const userLoc = rbac.getUserLocation(req.user);
            if (!userLoc) return res.status(403).json({ success: false, message: 'No location mapped' });
            const { data: devRows } = await (supabase || supabaseAdmin).from('coaches_railway').select('device_id').ilike('Location', userLoc);
            const allowedIds = (devRows || []).map((d) => d.device_id).filter(Boolean);
            if (allowedIds.length === 0) return res.status(404).json({ success: false, message: 'No data for your location' });
            faultQuery = faultQuery.in('device_id', allowedIds);
        }
        const { data: faults, error } = await faultQuery;
        if (error) throw error;
        if (!faults || faults.length === 0) return res.status(404).json({ success: false, message: 'No fault data found' });
        const now = new Date();
        const p = (n) => String(n).padStart(2, '0');
        const ts = `${now.getFullYear()}${p(now.getMonth()+1)}${p(now.getDate())}_${p(now.getHours())}${p(now.getMinutes())}${p(now.getSeconds())}`;
        generatePneumaticFaultsPdf(res, {
            faults,
            meta: {
                title:     'Active Faults Report',
                period:    fromDate && toDate ? `Period: ${fromDate} to ${toDate}` : 'Latest faults',
                metadata:  `Device: ${deviceId || 'All'}`,
                generated: `Generated: ${p(now.getDate())}/${p(now.getMonth()+1)}/${now.getFullYear()} ${p(now.getHours())}:${p(now.getMinutes())}  |  Total Faults: ${faults.length}`,
                filename:  `active_faults_${ts}.pdf`,
            },
        });
    } catch (err) {
        console.error('exportFaultsPdf error:', err.message);
        if (!res.headersSent) res.status(500).json({ success: false, error: err.message });
    }
};
