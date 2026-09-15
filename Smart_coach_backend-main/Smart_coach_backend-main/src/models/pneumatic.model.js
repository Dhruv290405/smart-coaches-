const supabase = require('../config/supabaseOld');
const supabaseAdmin = require('../config/supabaseAdmin');

async function queryWithFallback(primaryTable, fallbackTable, columns, options = {}) {
    const { deviceId, user, limit = 10, offset = 0, fromDate, toDate, orderCol = 'timestamp' } = options;
    const finalLimit = parseInt(limit) || 10;
    const finalOffset = parseInt(offset) || 0;

    let db = supabase;
    let table = primaryTable;
    let { data, error } = await db.from(table).select(columns);

    if (error && (error.code === '42P01' || error.message.includes('does not exist') || error.message.includes('not found'))) {
        console.warn(`Table '${primaryTable}' not found in Project 2, falling back to '${fallbackTable}' in Project 1.`);
        db = supabaseAdmin;
        table = fallbackTable;
        const fb = await db.from(table).select(columns);
        data = fb.data;
        error = fb.error;
    }

    if (error) throw error;

    if (!data || data.length === 0) return { data: [], db, table };

    return { data, db, table };
}

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

            const columns = `timestamp, bp, fp, cr, bc, brake_status, brake_duration, brake_fault, coach_no, device_id, brake_applied_time, brake_released_time`;
            let db, table;

            let primaryQuery = supabase.from('bpc_pressure').select(columns);
            if (deviceId) primaryQuery = primaryQuery.eq('device_id', deviceId);

            let result = await primaryQuery;
            let data = result.data;
            let error = result.error;

            if (error && (error.code === '42P01' || error.message.includes('does not exist') || error.message.includes('not found'))) {
                console.warn("Table 'bpc_pressure' not found in Project 2, falling back to 'pressure_logs' in Project 1.");
                db = supabaseAdmin;
                table = 'pressure_logs';
                let fbQuery = db.from(table).select(columns);
                if (deviceId) fbQuery = fbQuery.eq('device_id', deviceId);
                const fb = await fbQuery;
                data = fb.data;
                error = fb.error;
            } else {
                db = supabase;
                table = 'bpc_pressure';
            }

            if (error) throw error;

            if (!data || data.length === 0) return [];

            if (user && user.role_id !== 1) {
                const userLoc = user.division_name || user.region_name;

                if (userLoc) {
                    const { data: allowedDevices } = await supabase
                        .from('coaches_railway')
                        .select('device_id')
                        .ilike('Location', userLoc);

                    if (allowedDevices && allowedDevices.length > 0) {
                        const deviceIds = allowedDevices.map(d => d.device_id);
                        data = data.filter(r => deviceIds.includes(r.device_id));
                    } else {
                        return [];
                    }
                }
            }

            if (fromDate) {
                data = data.filter(r => r.timestamp >= `${fromDate}T00:00:00`);
            }
            if (toDate) {
                data = data.filter(r => r.timestamp <= `${toDate}T23:59:59`);
            }

            data.sort((a, b) => (b.timestamp || '').localeCompare(a.timestamp || ''));
            return data.slice(finalOffset, finalOffset + finalLimit);

        } catch (err) {
            console.error("Model Error [getLatestReading]:", err.message);
            return [];
        }
    },

    getHistory: async (limit = 30, user = null) => {
        try {
            const columns = `timestamp, bp, fp, cr, bc, brake_status, device_id`;

            let primaryQuery = supabase.from('bpc_pressure').select(columns);
            let result = await primaryQuery;
            let data = result.data;
            let error = result.error;

            if (error && (error.code === '42P01' || error.message.includes('does not exist') || error.message.includes('not found'))) {
                console.warn("Table 'bpc_pressure' not found in Project 2, falling back to 'pressure_logs' in Project 1.");
                let fbQuery = supabaseAdmin.from('pressure_logs').select(columns);
                const fb = await fbQuery;
                data = fb.data;
                error = fb.error;
            }

            if (error) throw error;

            if (!data || data.length === 0) return [];

            if (user && user.role_id !== 1) {
                const userLoc = user.division_name || user.region_name;
                if (userLoc) {
                    const { data: allowedDevices } = await supabase
                        .from('coaches_railway')
                        .select('device_id')
                        .ilike('Location', userLoc);

                    if (allowedDevices && allowedDevices.length > 0) {
                        const deviceIds = allowedDevices.map(d => d.device_id);
                        data = data.filter(r => deviceIds.includes(r.device_id));
                    } else {
                        return [];
                    }
                }
            }

            data.sort((a, b) => (b.timestamp || '').localeCompare(a.timestamp || ''));
            return data.slice(0, limit);
        } catch (err) {
            console.error("Model Error [getHistory]:", err.message);
            return [];
        }
    }
};

module.exports = Pneumatic;