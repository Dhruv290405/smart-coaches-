const supabase = require('../config/supabaseOld');

const Pneumatic = {
    
    applyScopeFilters: (query, user) => {
        if (!user || user.role_id === 1) return query;

        const userLocation = user.division_name || user.region_name;

        if (userLocation) {
            
            return query.ilike('coaches_railway.Location', userLocation);
        }

        return query;
    },

    getLatestReading: async (deviceId = null, user = null, limit = 10, offset = 0, fromDate = null, toDate = null) => {
        try {
            const finalLimit = parseInt(limit) || 10;
            const finalOffset = parseInt(offset) || 0;
            if (!supabase) throw new Error("Supabase client is not initialized.");

            let query = supabase.from('bpc_pressure').select(`
                timestamp, bp, fp, cr, bc, 
                brake_status, brake_duration, brake_fault, 
                coach_no, device_id, brake_applied_time, 
                brake_released_time
            `);

            const reverseDeviceMap = {
                'SCBB-JP-26-001': 'Raspberry4_1',
                'SCBB-HWH-26-001': 'Raspberry4_2',
                'SCBB-HWH-26-002': 'Raspberry4_3',
                'SCBB-JP-26-002': 'Raspberry4_4',
                'SCBB-NP-26-001': 'Raspberry4_5'
            };

            if (deviceId) {
                const mappedDeviceId = reverseDeviceMap[deviceId] || deviceId;
                query = query.eq('device_id', mappedDeviceId);
            }

            if (user && user.role_id !== 1) {
                const userLoc = user.division_name || user.region_name;
                
                if (userLoc) {
                    const { data: allowedDevices } = await supabase
                        .from('coaches_railway')
                        .select('device_id')
                        .ilike('Location', userLoc);

                    let finalAllowedIds = [];
                    if (allowedDevices && allowedDevices.length > 0) {
                        const deviceIds = allowedDevices.map(d => d.device_id);
                        const mappedDeviceIds = deviceIds.map(d => reverseDeviceMap[d] || d);
                        finalAllowedIds = [...new Set([...deviceIds, ...mappedDeviceIds])];
                    } else {
                        // Fallback mapping if DB is empty for location
                        const fallbackMapping = {
                            'Raspberry4_4': 'Kolkatta',
                            'Raspberry4_1': 'Jaipur',
                            'Raspberry4_2': 'Kolkatta',
                            'Raspberry4_3': 'Kolkatta',
                            'SCBB NP001': 'Nagpur',
                            'SCBB NP002': 'Nagpur',
                            'SCBB NP003': 'Nagpur'
                        };
                        const userLocLower = userLoc.toLowerCase();
                        const fallbackIds = Object.entries(fallbackMapping)
                            .filter(([_, loc]) => loc.toLowerCase() === userLocLower)
                            .map(([id, _]) => id);
                        
                        if (fallbackIds.length > 0) {
                            finalAllowedIds = fallbackIds;
                        } else {
                            return [];
                        }
                    }
                    query = query.in('device_id', finalAllowedIds);
                }
            }

            if (fromDate) {
                query = query.gte('timestamp', `${fromDate}T00:00:00`);
            }
            if (toDate) {
                query = query.lte('timestamp', `${toDate}T23:59:59`);
            }


            const { data, error } = await query
                .order('timestamp', { ascending: false })
                .range(finalOffset, finalOffset + (finalLimit - 1)); 

            if (error) throw error;
            return data || [];

        } catch (err) {
            console.error("Model Error [getLatestReading]:", err.message);
            if (err.message && (err.message.includes('404') || err.message.includes('not found') || err.message.includes('does not exist'))) {
                return [];
            }
            throw err;
        }
    },

    getHistory: async (limit = 30, user = null) => {
        try {
            let query = supabase.from('bpc_pressure').select(`
                timestamp, bp, fp, cr, bc, brake_status, device_id
            `);

            if (user && user.role_id !== 1) {
                const userLoc = user.division_name || user.region_name;
                if (userLoc) {
                    const { data: allowedDevices } = await supabase
                        .from('coaches_railway')
                        .select('device_id')
                        .ilike('Location', userLoc);

                    let finalAllowedIds = [];
                    if (allowedDevices && allowedDevices.length > 0) {
                        const deviceIds = allowedDevices.map(d => d.device_id);
                        const reverseDeviceMap = {
                            'SCBB-JP-26-001': 'Raspberry4_1',
                            'SCBB-HWH-26-001': 'Raspberry4_2',
                            'SCBB-HWH-26-002': 'Raspberry4_3',
                            'SCBB-JP-26-002': 'Raspberry4_4',
                            'SCBB-NP-26-001': 'Raspberry4_5'
                        };
                        const mappedDeviceIds = deviceIds.map(d => reverseDeviceMap[d] || d);
                        finalAllowedIds = [...new Set([...deviceIds, ...mappedDeviceIds])];
                    } else {
                        const fallbackMapping = {
                            'Raspberry4_4': 'Kolkatta',
                            'Raspberry4_1': 'Jaipur',
                            'Raspberry4_2': 'Kolkatta',
                            'Raspberry4_3': 'Kolkatta',
                            'SCBB NP001': 'Nagpur',
                            'SCBB NP002': 'Nagpur',
                            'SCBB NP003': 'Nagpur'
                        };
                        const userLocLower = userLoc.toLowerCase();
                        const fallbackIds = Object.entries(fallbackMapping)
                            .filter(([_, loc]) => loc.toLowerCase() === userLocLower)
                            .map(([id, _]) => id);
                        
                        if (fallbackIds.length > 0) {
                            finalAllowedIds = fallbackIds;
                        } else {
                            return [];
                        }
                    }
                    query = query.in('device_id', finalAllowedIds);
                }
            }

            const { data, error } = await query
                .order('timestamp', { ascending: false })
                .limit(limit);

            if (error) throw error;
            return data || [];
        } catch (err) {
            console.error("Model Error [getHistory]:", err.message);
            throw err;
        }
    }
};

module.exports = Pneumatic;