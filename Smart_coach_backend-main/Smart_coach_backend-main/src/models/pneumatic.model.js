const supabase = require('../config/supabaseOld');
const supabaseAdmin = require('../config/supabaseAdmin');

const PNEUMATIC_COLUMNS_BP = `timestamp, bp, fp, cr, bc, brake_status, brake_duration, brake_fault, coach_no, device_id, brake_applied_time, brake_released_time`;
const PRESSURE_COLUMNS_PL = `timestamp, bp, fp, cr, bc, brake_status, brake_duration, brake_fault, coach_number as coach_no, device_id, brake_applied_time, brake_released_time`;

function normalizeRow(row) {
    if (!row) return row;
    if (row.coach_number && !row.coach_no) {
        row.coach_no = row.coach_number;
    }
    return row;
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

            let data = null;
            let usedFallback = false;

            if (supabase) {
                let primaryQuery = supabase.from('bpc_pressure').select(PNEUMATIC_COLUMNS_BP);
                if (deviceId) primaryQuery = primaryQuery.eq('device_id', deviceId);
                const { data: pData, error: pErr } = await primaryQuery;

                if (pData && pData.length > 0) {
                    data = pData.map(normalizeRow);
                } else if (pErr && (pErr.code === '42P01' || pErr.message?.includes('does not exist') || pErr.message?.includes('not found'))) {
                    usedFallback = true;
                } else if (pErr) {
                    usedFallback = true;
                }
            } else {
                usedFallback = true;
            }

            if (!data && usedFallback && supabaseAdmin) {
                let fbQuery = supabaseAdmin.from('pressure_logs').select(PRESSURE_COLUMNS_PL);
                if (deviceId) fbQuery = fbQuery.eq('device_id', deviceId);
                const { data: fbData, error: fbErr } = await fbQuery;
                if (fbErr) {
                    console.warn("pressure_logs fallback error:", fbErr.message);
                }
                data = (fbData || []).map(normalizeRow);
            }

            if (!data || data.length === 0) return [];

            if (user && user.role_id !== 1) {
                const userLoc = user.division_name || user.region_name;
                if (userLoc) {
                    let allowedDevices = null;
                    if (!usedFallback && supabase) {
                        const r = await supabase.from('coaches_railway').select('device_id').ilike('Location', userLoc);
                        allowedDevices = r.data;
                    }
                    if ((!allowedDevices || allowedDevices.length === 0) && supabaseAdmin) {
                        const r = await supabaseAdmin.from('coaches_railway').select('device_id').ilike('Location', userLoc);
                        allowedDevices = r.data;
                    }
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
            let data = null;
            let usedFallback = false;

            if (supabase) {
                const { data: pData, error: pErr } = await supabase.from('bpc_pressure').select(`timestamp, bp, fp, cr, bc, brake_status, device_id`);
                if (pData && pData.length > 0) {
                    data = pData.map(normalizeRow);
                } else {
                    usedFallback = true;
                }
            } else {
                usedFallback = true;
            }

            if (!data && usedFallback && supabaseAdmin) {
                const { data: fbData, error: fbErr } = await supabaseAdmin.from('pressure_logs').select(`timestamp, bp, fp, cr, bc, brake_status, device_id, coach_number as coach_no`);
                if (fbErr) console.warn("pressure_logs fallback error:", fbErr.message);
                data = (fbData || []).map(normalizeRow);
            }

            if (!data || data.length === 0) return [];

            if (user && user.role_id !== 1) {
                const userLoc = user.division_name || user.region_name;
                if (userLoc) {
                    let allowedDevices = null;
                    if (!usedFallback && supabase) {
                        const r = await supabase.from('coaches_railway').select('device_id').ilike('Location', userLoc);
                        allowedDevices = r.data;
                    }
                    if ((!allowedDevices || allowedDevices.length === 0) && supabaseAdmin) {
                        const r = await supabaseAdmin.from('coaches_railway').select('device_id').ilike('Location', userLoc);
                        allowedDevices = r.data;
                    }
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