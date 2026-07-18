const _acpSupabase = require('../config/supabaseAcp');

const nullResponse = { data: [], error: null };
const noopChain = () => {};
const chainedHandler = {
    get(_t, prop) {
        if (prop === 'then') return (resolve) => resolve(nullResponse);
        if (prop === 'catch') return noopChain;
        return () => new Proxy({}, chainedHandler);
    }
};
const clientHandler = {
    get(_t, prop) {
        if (prop === 'then') return (resolve) => resolve(nullResponse);
        if (prop === 'catch') return noopChain;
        if (prop === 'from') return () => new Proxy({}, chainedHandler);
        if (prop === 'channel') return () => ({ on: () => ({ subscribe: noopChain }) });
        return () => new Proxy({}, chainedHandler);
    }
};
const nullProxy = new Proxy({}, clientHandler);
const acpSupabase = _acpSupabase || nullProxy;

console.log('🔧 ACP Supabase client:', _acpSupabase ? 'real' : 'null proxy fallback');

const TABLE = 'railway_acp_data';

const toIST = (d) => {
    if (!d) return null;
    const date = new Date(d);
    const ist = new Date(date.getTime() + 5.5 * 60 * 60 * 1000);
    const y = ist.getUTCFullYear();
    const m = String(ist.getUTCMonth() + 1).padStart(2, '0');
    const day = String(ist.getUTCDate()).padStart(2, '0');
    const h = String(ist.getUTCHours()).padStart(2, '0');
    const min = String(ist.getUTCMinutes()).padStart(2, '0');
    const s = String(ist.getUTCSeconds()).padStart(2, '0');
    return `${y}-${m}-${day} ${h}:${min}:${s}`;
};

const extractCoachNo = (assetName) => {
    if (!assetName) return null;
    const parts = assetName.split(' ');
    if (parts.length >= 4 && parts[2] === 'ACP') return parts[1];
    return assetName;
};

const AcpModel = {
    updateLiveStatus: async (data, type) => {
        console.log("updateLiveStatus called (ACP Supabase)");
    },

    getBlockedCoaches: async () => [],

    saveLatestHeartbeat: async (data) => {
        console.log("saveLatestHeartbeat called (ACP Supabase)");
    },

    getAllLogs: async () => {
        try {
            const { data, error } = await acpSupabase
                .from(TABLE)
                .select('id, loc_name, asset_name, msg_type, metric_timestamp, count_value, totalized_count, device_id, created_at')
                .not('loc_name', 'is', null)
                .not('asset_name', 'is', null)
                .eq('msg_type', 'METRICS')
                .order('created_at', { ascending: false })
                .limit(100);

            if (error) throw error;
            return (data || []).map(row => ({
                log_id: row.id,
                last_updated: row.created_at,
                raw_asset_name: row.asset_name || null,
                acp_status: row.count_value ?? 0,
                total_count: row.totalized_count ?? 0,
                train_location: row.loc_name,
                train_no: row.loc_name,
                comm_coach_no: extractCoachNo(row.asset_name),
                tech_coach_no: extractCoachNo(row.asset_name),
                device_id: row.device_id || 'N/A',
                power_car_no: null
            }));
        } catch (error) {
            console.error("Error in AcpModel.getAllLogs:", error.message);
            throw error;
        }
    },

    getTrainByMapping: async () => null,

    saveHeartbeat: async (data) => {
        // Data is written directly by IoT pipeline to railway_acp_data
        console.log("saveHeartbeat called — no-op (data arrives via IoT pipeline)");
    },

    saveCriticalEvent: async (data) => {
        // Data is written directly by IoT pipeline to railway_acp_data
        console.log("saveCriticalEvent called — no-op (data arrives via IoT pipeline)");
    },

    getUniqueTrains: async () => {
        try {
            const { data, error } = await acpSupabase
                .from(TABLE)
                .select('loc_name')
                .not('loc_name', 'is', null)
                .eq('msg_type', 'METRICS');
            if (error) throw error;
            let names = (data || []).map(r => r.loc_name).filter(Boolean);
            if (names.length < 2) {
                const { data: d2, error: e2 } = await acpSupabase
                    .from(TABLE)
                    .select('loc_name, asset_name, metric_timestamp')
                    .not('loc_name', 'is', null)
                    .not('asset_name', 'is', null)
                    .eq('msg_type', 'METRICS')
                    .order('metric_timestamp', { ascending: false });
                if (!e2 && d2) {
                    const latest = {};
                    for (const row of d2) {
                        const cn = extractCoachNo(row.asset_name);
                        if (cn && row.loc_name && !latest[cn]) {
                            latest[cn] = row.loc_name;
                        }
                    }
                    names = Object.values(latest);
                }
            }
            const unique = [...new Set(names.filter(Boolean))].sort();
            return unique.map(loc => ({ train_no: loc }));
        } catch (error) {
            console.error("Error fetching unique trains:", error.message);
            return [];
        }
    },

    getCoachTypesByTrain: async (trainNo) => {
        try {
            let query = acpSupabase
                .from(TABLE)
                .select('asset_name')
                .not('asset_name', 'is', null)
                .eq('msg_type', 'METRICS');
            if (trainNo) query = query.eq('loc_name', trainNo);
            const { data, error } = await query;
            if (error) throw error;
            const unique = [...new Set((data || []).map(r => extractCoachNo(r.asset_name)).filter(Boolean))];
            return unique.map(v => ({ comm_coach_no: v }));
        } catch (error) {
            console.error("Error fetching coach types:", error.message);
            return [];
        }
    },

    getCoachNumbers: async (trainNo, coachType) => {
        try {
            let query = acpSupabase
                .from(TABLE)
                .select('asset_name')
                .not('asset_name', 'is', null)
                .eq('msg_type', 'METRICS');
            if (trainNo) query = query.eq('loc_name', trainNo);
            if (coachType && coachType.trim()) {
                const all = await query;
                if (all.error) throw all.error;
                const filtered = (all.data || []).filter(r => extractCoachNo(r.asset_name) === coachType);
                const unique = [...new Set(filtered.map(r => extractCoachNo(r.asset_name)).filter(Boolean))];
                return unique.map(v => ({ tech_coach_no: v }));
            }
            const { data, error } = await query;
            if (error) throw error;
            const unique = [...new Set((data || []).map(r => extractCoachNo(r.asset_name)).filter(Boolean))];
            return unique.map(v => ({ tech_coach_no: v }));
        } catch (error) {
            console.error("Error fetching coach numbers:", error.message);
            return [];
        }
    },

    getSummaryLogs: async () => {
        try {
            const { data, error } = await acpSupabase
                .from(TABLE)
                .select('id, loc_name, asset_name, msg_type, metric_timestamp, count_value, totalized_count, device_id, created_at')
                .not('loc_name', 'is', null)
                .not('asset_name', 'is', null)
                .eq('msg_type', 'METRICS')
                .order('created_at', { ascending: false });

            if (error) throw error;
            if (!data || data.length === 0) return [];

            const grouped = {};
            const todayStart = new Date();
            todayStart.setHours(0, 0, 0, 0);

            for (const row of data) {
                const coachNo = extractCoachNo(row.asset_name);
                if (!coachNo) continue;
                const key = `${row.loc_name}|${coachNo}`;
                if (!grouped[key]) {
                    grouped[key] = { latest: row, todayCount: 0, totalCount: 0, loc_name: row.loc_name, coach_no: coachNo };
                }
                grouped[key].totalCount++;
                const ts = new Date(row.created_at);
                if (ts >= todayStart) {
                    grouped[key].todayCount++;
                }
            }

            return Object.values(grouped).map((g) => ({
                train_no: g.loc_name || 'Unknown',
                comm_coach_no: g.coach_no,
                tech_coach_no: g.coach_no,
                device_id: g.latest.device_id || 'N/A',
                last_heartbeat: toIST(g.latest.metric_timestamp || g.latest.created_at),
                last_trigger: null,
                today_count: g.todayCount,
                total_count: g.totalCount,
                acp_status: String(g.latest.count_value ?? 0),
                totalized_count: g.latest.totalized_count ?? 0,
                train_location: g.loc_name || null,
                status: g.todayCount > 0 ? 'Active' : 'Inactive',
                fsds_status: null,
                fsds_bypass: null,
                fsds_timestamp: null
            }));
        } catch (error) {
            console.error("Error in getSummaryLogs:", error.message);
            throw error;
        }
    },

    getCoachAcpHistory: async (techCoachNo, startDate, endDate, limit = 100, offset = 0) => {
        try {
            let query = acpSupabase
                .from(TABLE)
                .select('id, loc_name, asset_name, msg_type, metric_timestamp, count_value, device_id, created_at')
                .not('asset_name', 'is', null)
                .eq('msg_type', 'METRICS');

            if (startDate && endDate) {
                query = query
                    .gte('metric_timestamp', `${startDate}T00:00:00Z`)
                    .lte('metric_timestamp', `${endDate}T23:59:59Z`);
            }

            query = query
                .order('metric_timestamp', { ascending: false })
                .range(offset, offset + parseInt(limit) - 1);

            const { data: rows, error } = await query;
            if (error) throw error;

            const rowsForCoach = (rows || []).filter(r => extractCoachNo(r.asset_name) === techCoachNo);
            const totalCount = rowsForCoach.length;
            const todayStart = new Date();
            todayStart.setHours(0, 0, 0, 0);
            const todayCount = rowsForCoach.filter(r => new Date(r.metric_timestamp || r.created_at) >= todayStart).length;

            return rowsForCoach.map((row, i) => ({
                log_id: row.id,
                event_time: toIST(row.metric_timestamp || row.created_at),
                acp_status: row.count_value ?? 0,
                device_id: row.device_id || 'N/A',
                train_location: row.loc_name,
                raw_asset_name: row.asset_name,
                history_sequence_no: totalCount - i,
                total_lifetime_pulls: totalCount,
                today_pulls_count: todayCount
            }));
        } catch (error) {
            console.error("Error in getCoachAcpHistory:", error.message);
            throw error;
        }
    },

    getFilteredLogs: async (trainNo, techCoachNo) => {
        try {
            let query = acpSupabase
                .from(TABLE)
                .select('id, loc_name, asset_name, msg_type, metric_timestamp, count_value, totalized_count, device_id, created_at')
                .not('loc_name', 'is', null)
                .not('asset_name', 'is', null)
                .eq('msg_type', 'METRICS');

            if (trainNo) query = query.eq('loc_name', trainNo);

            query = query.order('created_at', { ascending: false }).limit(200);

            const { data, error } = await query;
            if (error) throw error;
            if (!data || data.length === 0) return [];

            const rows = techCoachNo
                ? data.filter(r => extractCoachNo(r.asset_name) === techCoachNo)
                : data;

            const grouped = {};
            for (const row of rows) {
                const coachNo = extractCoachNo(row.asset_name);
                if (!coachNo) continue;
                const key = `${row.loc_name}|${coachNo}`;
                if (!grouped[key]) {
                    grouped[key] = { latest: row, todayCount: 0, totalCount: 0, loc_name: row.loc_name, coach_no: coachNo };
                }
                grouped[key].totalCount++;
                const ts = new Date(row.created_at);
                const todayStart = new Date();
                todayStart.setHours(0, 0, 0, 0);
                if (ts >= todayStart) grouped[key].todayCount++;
            }

            return Object.values(grouped).map((g) => ({
                train_no: g.loc_name || trainNo || 'Unknown',
                comm_coach_no: g.coach_no,
                tech_coach_no: g.coach_no,
                device_id: g.latest.device_id || 'N/A',
                last_heartbeat: toIST(g.latest.metric_timestamp || g.latest.created_at),
                last_trigger: null,
                today_count: g.todayCount,
                total_count: g.totalCount,
                acp_status: String(g.latest.count_value ?? 0),
                totalized_count: g.latest.totalized_count ?? 0,
                train_location: g.loc_name || null,
                status: g.todayCount > 0 ? 'Active' : 'Inactive',
                fsds_status: null,
                fsds_bypass: null,
                fsds_timestamp: null
            }));
        } catch (error) {
            throw new Error("Error fetching filtered logs: " + error.message);
        }
    }
};

module.exports = AcpModel;
