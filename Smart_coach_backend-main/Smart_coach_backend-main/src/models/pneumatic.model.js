const supabase = require('../config/supabaseOld');

const Pneumatic = {
    
    applyScopeFilters: (query, user) => {
        if (!user || user.role_id === 1) return query;

        const userLocation = user.region_name || user.division_name;

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

            if (deviceId) {
                query = query.eq('device_id', deviceId);
            }

            if (user && user.role_id !== 1) {
                const userLoc = user.region_name || user.division_name;
                
                if (userLoc) {
                    const { data: allowedDevices } = await supabase
                        .from('coaches_railway')
                        .select('device_id')
                        .ilike('Location', userLoc);

                    if (allowedDevices && allowedDevices.length > 0) {
                        const deviceIds = allowedDevices.map(d => d.device_id);
                        query = query.in('device_id', deviceIds);
                    } else {
                        return [];
                    }
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
            throw err;
        }
    },

    getHistory: async (limit = 30, user = null) => {
        try {
            let query = supabase.from('bpc_pressure').select(`
                timestamp, bp, fp, cr, bc, brake_status, device_id
            `);

            if (user && user.role_id !== 1) {
                const userLoc = user.region_name || user.division_name;
                if (userLoc) {
                    const { data: allowedDevices } = await supabase
                        .from('coaches_railway')
                        .select('device_id')
                        .ilike('Location', userLoc);

                    if (allowedDevices && allowedDevices.length > 0) {
                        const deviceIds = allowedDevices.map(d => d.device_id);
                        query = query.in('device_id', deviceIds);
                    } else {
                        return [];
                    }
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