const Pneumatic = require('../models/pneumatic.model');
const supabase = require('../config/supabaseOld');
const NotificationService = require('../services/notificationService');
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

exports.getBreakBindingData = async (req, res) => {
    if (!supabase) {
        return forwardToOldBackend(req, res, '/pneumatic/status');
    }
    try {
        const filterDeviceId = req.query.deviceId || null; 
        const historyLimit = Math.min(parseInt(req.query.limit) || 10, 1000); 
        const historyOffset = parseInt(req.query.offset) || 0;
        
        const fromDate = req.query.from_date || null;
        const toDate = req.query.to_date || null;

        const limit = parseInt(req.query.limit) || 10;
        const offset = parseInt(req.query.offset) || 0;
        const readings = await Pneumatic.getLatestReading(filterDeviceId, req.user, limit, offset, fromDate, toDate);

        if (!readings || readings.length === 0) {
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
            .select('technical_id, coach_no, train_no, location')
            .eq('device_id', activeDeviceId);

        if (req.user && req.user.role_id !== 1) {
            const userLoc = req.user.division_name || req.user.region_name;
            if (userLoc) coachQuery = coachQuery.ilike('location', userLoc);
        }

        const { data: dbCoach } = await coachQuery.maybeSingle();

        if (filterDeviceId && !dbCoach) {
            return res.status(403).json({ success: false, message: "Access denied: Device location mismatch" });
        }

        let eventQuery = supabase.from('event_publish')
            .select('id, timestamp, event_status, coach_no, bp, bc, event_message')
            .eq('device_id', activeDeviceId)
            .order('timestamp', { ascending: false })
            .limit(30);

        let faultQuery = supabase.from('brake_fault_event')
            .select('device_id, fault_name, timestamp, event_message')
            .eq('device_id', activeDeviceId)
            .order('timestamp', { ascending: false })
            .limit(50);


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
            'SCBB NP001': { technical_id: 'NP001', coach_no: 'NP1', train_no: 'NAGPUR01', location: 'Nagpur' },
            'SCBB NP002': { technical_id: 'NP002', coach_no: 'NP2', train_no: 'NAGPUR01', location: 'Nagpur' },
            'SCBB NP003': { technical_id: 'NP003', coach_no: 'NP3', train_no: 'NAGPUR01', location: 'Nagpur' },
            'Raspberry4_4': { technical_id: '231035', coach_no: 'M3', train_no: '13071', location: 'Kolkatta' },
            'Raspberry4_1': { technical_id: '231545', coach_no: 'S4', train_no: '13277', location: 'Jaipur' },
            'Raspberry4_2': { technical_id: '234534', coach_no: 'S3', train_no: '12578', location: 'Jaipur' },
            'Raspberry4_3': { technical_id: '211245', coach_no: 'S2', train_no: '65214', location: 'Jaipur' }
        };
        const fallback = deviceMapping[activeDeviceId] || {};

        const finalCoachInfo = {
            technical_id: dbCoach?.technical_id || fallback.technical_id || "N/A",
            coach_no: dbCoach?.coach_no || fallback.coach_no || finalData.coach_no || "Unknown",
            train_no: dbCoach?.train_no || fallback.train_no || "Unknown",
            location: dbCoach?.location || fallback.location || "Unknown"
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
            cr_overcharge: (cr >= 5.0) ? 'red' : 'green',
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
                const title = ` New Brake Fault: Coach ${finalCoachInfo.coach_no}`;
                const body = `${latestFault.fault_name || 'Brake Binding Issue'}: ${latestFault.event_message || 'Active fault logged.'}`;
                
                const extraData = {
                    type: 'BRAKE_BINDING',
                    device_id: String(activeDeviceId),
                    coach_no: String(finalCoachInfo.coach_no),
                    train_no: String(finalCoachInfo.Train_no),
                    click_action: 'OPEN_BRAKE_DASHBOARD'
                };

                NotificationService.sendTopicNotification('brake_alerts', title, body, extraData)
                    .catch(err => console.error("Background Push Notification Error:", err.message));
            }
        }

        res.status(200).json({
            success: true,
            context: { deviceId: activeDeviceId, ...finalCoachInfo },
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
        const data = Object.entries(deviceMapping).map(([deviceId, info], idx) => ({
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
            message: "Coaches fetched (fallback)",
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

        const { role_id, division_name, region_name } = req.user;

        let query = supabase
            .from('coaches_railway')
            .select('id, technical_id, coach_no, device_id, train_no, location, actual_id');

        if (role_id !== 1) {
            const userLocation = division_name || region_name;

            if (!userLocation) {
                return res.status(403).json({
                    success: false,
                    message: "Access denied: No region or division mapped to this user account"
                });
            }

            query = query.ilike('location', userLocation);
        }

        const { data: coaches, error } = await query;

        if (error) {
            throw error;
        }

        if (!coaches || coaches.length === 0) {
            return res.status(404).json({
                success: true,
                message: "No coaches registered or accessible for your location",
                count: 0,
                data: []
            });
        }

        return res.status(200).json({
            success: true,
            message: role_id === 1 ? "All coaches fetched (Admin View)" : `Coaches fetched for location: ${region_name || division_name}`,
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