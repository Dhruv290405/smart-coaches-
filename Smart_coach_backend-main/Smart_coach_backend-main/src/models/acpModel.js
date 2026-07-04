const supabaseAdmin = require('../config/supabaseAdmin');
const { dualInsert, dualUpdate, dualUpsert } = require('../config/dualWrite');
const BLOCKED_COACH = '205063';
const fmtBin = (v) => (v === 1 || v === '1') ? 'On' : 'Off';

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

const AcpModel = {
    updateLiveStatus: async (data, type) => {
        try {
            const { data: maxRows, error: maxErr } = await supabaseAdmin
                .from('acp_critical_events')
                .select('total_count')
                .eq('tech_coach_no', data.tech_coach_no)
                .order('total_count', { ascending: false })
                .limit(1);

            if (maxErr) throw maxErr;

            const todayStart = new Date();
            todayStart.setHours(0, 0, 0, 0);
            const todayEnd = new Date();
            todayEnd.setHours(23, 59, 59, 999);

            const { data: todayRows, error: todayErr } = await supabaseAdmin
                .from('acp_critical_events')
                .select('total_count')
                .eq('tech_coach_no', data.tech_coach_no)
                .gte('event_time', todayStart.toISOString())
                .lte('event_time', todayEnd.toISOString());

            if (todayErr) throw todayErr;

            const totalCount = (maxRows && maxRows[0] && maxRows[0].total_count) || data.total_count;
            const uniqueToday = new Set((todayRows || []).map(r => r.total_count));
            const todayCount = uniqueToday.size;

            const isPulled = todayCount > 0 ? 'Pulled' : 'Not Pulled';
            const isTrigger = (type === 'TRIGGER');

            const { data: existing, error: existErr } = await supabaseAdmin
                .from('device_live_summary')
                .select('tech_coach_no')
                .eq('tech_coach_no', data.tech_coach_no)
                .maybeSingle();

            if (existErr) throw existErr;

            const now = new Date().toISOString();

            if (existing) {
                const updateData = {
                    total_count: totalCount,
                    today_count: todayCount,
                    last_heartbeat: now,
                    status: isPulled
                };
                if (isTrigger) updateData.last_trigger = now;
                await dualUpdate('device_live_summary', 'tech_coach_no', data.tech_coach_no, updateData);
            } else {
                await dualInsert('device_live_summary', [{
                    tech_coach_no: data.tech_coach_no,
                    last_heartbeat: now,
                    last_trigger: isTrigger ? now : null,
                    today_count: todayCount,
                    total_count: totalCount,
                    status: isPulled
                }]);
            }
        } catch (error) {
            console.error("Error in AcpModel.updateLiveStatus:", error.message);
            throw error;
        }
    },

    getBlockedCoaches: async () => {
        try {
            const { data, error } = await supabaseAdmin
                .from('blocked_devices')
                .select('tech_coach_no');
            if (error) throw error;
            return (data || []).map(row => row.tech_coach_no);
        } catch (error) {
            console.error("Error fetching blocked devices:", error.message);
            return [];
        }
    },

    saveLatestHeartbeat: async (data) => {
        try {
            await dualUpsert('device_latest_status', [{
                tech_coach_no: data.tech_coach_no,
                data: JSON.stringify(data),
                last_updated: new Date().toISOString()
            }], 'tech_coach_no');
        } catch (error) {
            console.error("Error in AcpModel.saveLatestHeartbeat:", error.message);
            throw error;
        }
    },

    getAllLogs: async () => {
        try {
            const { data, error } = await supabaseAdmin
                .from('acp_critical_events')
                .select('id, created_at, raw_asset_name, acp_status, total_count, train_location, train_no, comm_coach_no, tech_coach_no, power_car_no')
                .neq('tech_coach_no', BLOCKED_COACH)
                .order('created_at', { ascending: false })
                .limit(100);

            if (error) throw error;
            return (data || []).map(row => ({
                log_id: row.id,
                last_updated: row.created_at,
                raw_asset_name: row.raw_asset_name,
                acp_status: row.acp_status,
                total_count: row.total_count,
                train_location: row.train_location,
                train_no: row.train_no,
                comm_coach_no: row.comm_coach_no,
                tech_coach_no: row.tech_coach_no,
                power_car_no: row.power_car_no
            }));
        } catch (error) {
            console.error("Error in AcpModel.getAllLogs:", error.message);
            throw error;
        }
    },

    getTrainByMapping: async (deviceId, techCoachNo) => {
        try {
            const { data, error } = await supabaseAdmin
                .from('device_master')
                .select('train_no')
                .or(`device_id.eq.${deviceId},tech_coach_no.eq.${techCoachNo}`)
                .limit(1)
                .maybeSingle();

            if (error) throw error;
            return data || null;
        } catch (error) {
            console.error("Error in AcpModel.getTrainByMapping:", error.message);
            throw error;
        }
    },

    saveHeartbeat: async (data) => {
        try {
            const inserted = await dualInsert('acp_heartbeat_logs', [{
                train_location: data.train_location,
                raw_asset_name: data.raw_asset_name,
                acp_status: data.acp_status,
                total_count: data.total_count,
                msg_type: data.msg_type,
                train_no: data.train_no,
                comm_coach_no: data.comm_coach_no,
                tech_coach_no: data.tech_coach_no,
                power_car_no: data.power_car_no
            }]);

            if (!inserted || !inserted[0]) throw new Error("Insert returned no data");
            return inserted[0].id;
        } catch (error) {
            console.error("Error in AcpModel.saveHeartbeat:", error.message);
            throw error;
        }
    },

    saveCriticalEvent: async (data) => {
        if (data.acp_status !== 1) return null;

        try {
            const { data: existing, error: checkErr } = await supabaseAdmin
                .from('acp_critical_events')
                .select('total_count')
                .eq('tech_coach_no', data.tech_coach_no)
                .order('id', { ascending: false })
                .limit(1);

            if (checkErr) throw checkErr;

            if (existing.length > 0 && data.total_count <= existing[0].total_count) {
                console.log(`Skipping duplicate/old event for coach ${data.tech_coach_no}`);
                return null;
            }

            const inserted = await dualInsert('acp_critical_events', [{
                    train_location: data.train_location,
                    raw_asset_name: data.raw_asset_name,
                    acp_status: data.acp_status,
                    total_count: data.total_count,
                    train_no: data.train_no,
                    tech_coach_no: data.tech_coach_no,
                    power_car_no: data.power_car_no,
                    event_time: new Date().toISOString()
                }]);

            if (!inserted || !inserted[0]) throw new Error("Insert returned no data");
            return inserted[0].id;
        } catch (error) {
            console.error("Error in AcpModel.saveCriticalEvent:", error.message);
            throw error;
        }
    },

    getUniqueTrains: async () => {
        try {
            const { data, error } = await supabaseAdmin
                .from('device_master')
                .select('train_no')
                .not('train_no', 'is', null)
                .order('train_no', { ascending: true });

            if (error) throw error;
            const unique = [...new Set((data || []).map(r => r.train_no))];
            return unique.map(train_no => ({ train_no }));
        } catch (error) {
            throw new Error("Error fetching unique trains: " + error.message);
        }
    },

    getCoachTypesByTrain: async (trainNo) => {
        try {
            const { data: dmData, error: dmErr } = await supabaseAdmin
                .from('device_master')
                .select('comm_coach_no, tech_coach_no, train_no')
                .eq('train_no', trainNo);

            if (dmErr) throw dmErr;

            const { data: tmData, error: tmErr } = await supabaseAdmin
                .from('train_master')
                .select('train_id, train_number')
                .eq('train_number', trainNo)
                .maybeSingle();

            if (tmErr) throw tmErr;

            let cmData = [];
            if (tmData) {
                const { data, error: cmErr } = await supabaseAdmin
                    .from('coach_master')
                    .select('coach_display_id, coach_unique_id')
                    .eq('train_id', tmData.train_id);
                if (cmErr) throw cmErr;
                cmData = data || [];
            }

            const cmMap = {};
            for (const cm of cmData) {
                cmMap[cm.coach_unique_id] = cm.coach_display_id;
            }

            const uniqueCoaches = new Set();
            for (const dm of (dmData || [])) {
                const display = cmMap[dm.tech_coach_no] || dm.comm_coach_no;
                if (display) uniqueCoaches.add(display);
            }

            return [...uniqueCoaches].sort().map(v => ({ comm_coach_no: v }));
        } catch (error) {
            throw new Error("Error fetching coach types: " + error.message);
        }
    },

    getCoachNumbers: async (trainNo, coachType) => {
        try {
            const { data, error } = await supabaseAdmin
                .from('device_master')
                .select('tech_coach_no')
                .eq('train_no', trainNo)
                .eq('comm_coach_no', coachType)
                .neq('tech_coach_no', BLOCKED_COACH)
                .order('tech_coach_no', { ascending: true });

            if (error) throw error;
            const unique = [...new Set((data || []).map(r => r.tech_coach_no))];
            return unique.map(v => ({ tech_coach_no: v }));
        } catch (error) {
            throw new Error("Error fetching coach numbers: " + error.message);
        }
    },

    getSummaryLogs: async () => {
        try {
            const { data: dmRows, error: dmErr } = await supabaseAdmin
                .from('device_master')
                .select('train_no, tech_coach_no, device_id, comm_coach_no')
                .neq('tech_coach_no', BLOCKED_COACH)
                .order('train_no', { ascending: true });

            if (dmErr) throw dmErr;
            if (!dmRows || dmRows.length === 0) return [];

            const techCoaches = dmRows.map(r => r.tech_coach_no);
            const deviceIds = dmRows.map(r => r.device_id).filter(Boolean);

            let dlsData = [];
            if (techCoaches.length > 0) {
                const { data, error: dlsErr } = await supabaseAdmin
                    .from('device_live_summary')
                    .select('tech_coach_no, last_heartbeat, last_trigger, today_count, total_count, status')
                    .in('tech_coach_no', techCoaches);
                if (dlsErr) throw dlsErr;
                dlsData = data || [];
            }

            const { data: tmRows, error: tmErr } = await supabaseAdmin
                .from('train_master')
                .select('train_id, train_number');

            if (tmErr) throw tmErr;

            const tmMap = {};
            for (const tm of (tmRows || [])) {
                tmMap[tm.train_number] = tm;
            }

            let cmRows = [];
            const trainIds = (tmRows || []).map(r => r.train_id).filter(Boolean);
            if (trainIds.length > 0) {
                const { data, error: cmErr } = await supabaseAdmin
                    .from('coach_master')
                    .select('coach_display_id, coach_unique_id, train_id')
                    .in('train_id', trainIds);
                if (cmErr) throw cmErr;
                cmRows = data || [];
            }

            const cmMap = {};
            for (const cm of cmRows) {
                cmMap[cm.coach_unique_id] = cm;
            }

            const { data: locData, error: locErr } = await supabaseAdmin
                .from('acp_critical_events')
                .select('id, tech_coach_no, train_location')
                .in('tech_coach_no', techCoaches)
                .order('id', { ascending: false });

            if (locErr) throw locErr;

            const latestLoc = {};
            for (const row of (locData || [])) {
                if (!latestLoc[row.tech_coach_no]) {
                    latestLoc[row.tech_coach_no] = row.train_location;
                }
            }

            let fsdsData = [];
            if (deviceIds.length > 0) {
                const { data, error: fsdsErr } = await supabaseAdmin
                    .from('fsds_logs')
                    .select('id, device_id, fire_status, bypass_status, timestamp')
                    .in('device_id', deviceIds)
                    .order('id', { ascending: false });
                if (fsdsErr) throw fsdsErr;
                fsdsData = data || [];
            }

            const latestFsds = {};
            for (const row of fsdsData) {
                if (!latestFsds[row.device_id]) {
                    latestFsds[row.device_id] = {
                        fsds_status: fmtBin(row.fire_status),
                        fsds_bypass: fmtBin(row.bypass_status),
                        fsds_timestamp: row.timestamp
                    };
                }
            }

            const dlsMap = {};
            for (const row of (dlsData || [])) {
                dlsMap[row.tech_coach_no] = row;
            }

            const result = (dmRows || []).map(dm => {
                const dls = dlsMap[dm.tech_coach_no] || {};
                const tm = tmMap[dm.train_no];
                const cm = cmMap[dm.tech_coach_no];
                const coachDisplay = (cm && cm.train_id === (tm && tm.train_id)) ? cm.coach_display_id : null;
                const todayCount = dls.today_count || 0;
                const fsds = latestFsds[dm.device_id] || {};

                return {
                    train_no: dm.train_no,
                    comm_coach_no: coachDisplay || dm.comm_coach_no,
                    tech_coach_no: dm.tech_coach_no,
                    device_id: dm.device_id,
                    last_heartbeat: toIST(dls.last_heartbeat),
                    last_trigger: toIST(dls.last_trigger),
                    today_count: todayCount,
                    total_count: dls.total_count || 0,
                    train_location: latestLoc[dm.tech_coach_no] || null,
                    status: todayCount === 0 ? 'Not Pulled' : (dls.status || 'Not Pulled'),
                    fsds_status: fsds.fsds_status || null,
                    fsds_bypass: fsds.fsds_bypass || null,
                    fsds_timestamp: fsds.fsds_timestamp || null
                };
            });

            return result;
        } catch (error) {
            console.error("Error in getSummaryLogs:", error.message);
            throw error;
        }
    },

    getCoachAcpHistory: async (techCoachNo, startDate, endDate, limit = 100, offset = 0) => {
        try {
            if (techCoachNo === BLOCKED_COACH) return [];

            let query = supabaseAdmin
                .from('acp_critical_events')
                .select('id, event_time, acp_status, train_location, raw_asset_name, total_count')
                .eq('tech_coach_no', techCoachNo);

            if (startDate && endDate) {
                query = query
                    .gte('event_time', `${startDate} 00:00:00`)
                    .lte('event_time', `${endDate} 23:59:59`);
            }

            query = query
                .order('id', { ascending: false })
                .range(offset, offset + parseInt(limit) - 1);

            const { data: rows, error } = await query;
            if (error) throw error;

            const { data: dls, error: dlsErr } = await supabaseAdmin
                .from('device_live_summary')
                .select('total_count, today_count')
                .eq('tech_coach_no', techCoachNo)
                .maybeSingle();

            if (dlsErr) throw dlsErr;

            const totalLifetimePulls = (dls && dls.total_count) || 0;
            const todayPullsCount = (dls && dls.today_count) || 0;

            return (rows || []).map(row => ({
                log_id: row.id,
                event_time: toIST(row.event_time),
                acp_status: row.acp_status,
                train_location: row.train_location,
                raw_asset_name: row.raw_asset_name,
                history_sequence_no: row.total_count,
                total_lifetime_pulls: totalLifetimePulls,
                today_pulls_count: todayPullsCount
            }));
        } catch (error) {
            console.error("Error in getCoachAcpHistory:", error.message);
            throw error;
        }
    },

    getFilteredLogs: async (trainNo, techCoachNo) => {
        try {
            const { data: dmRows, error: dmErr } = await supabaseAdmin
                .from('device_master')
                .select('train_no, tech_coach_no, device_id, comm_coach_no')
                .eq('train_no', trainNo)
                .eq('tech_coach_no', techCoachNo);

            if (dmErr) throw dmErr;
            if (!dmRows || dmRows.length === 0) return [];

            const techCoaches = dmRows.map(r => r.tech_coach_no);
            const deviceIds = dmRows.map(r => r.device_id).filter(Boolean);

            let dlsData = [];
            if (techCoaches.length > 0) {
                const { data, error: dlsErr } = await supabaseAdmin
                    .from('device_live_summary')
                    .select('tech_coach_no, last_heartbeat, last_trigger, today_count, total_count, status')
                    .in('tech_coach_no', techCoaches);
                if (dlsErr) throw dlsErr;
                dlsData = data || [];
            }

            const { data: tmRows, error: tmErr } = await supabaseAdmin
                .from('train_master')
                .select('train_id, train_number');

            if (tmErr) throw tmErr;

            const tmMap = {};
            for (const tm of (tmRows || [])) {
                tmMap[tm.train_number] = tm;
            }

            let cmRows = [];
            const trainIds = (tmRows || []).map(r => r.train_id).filter(Boolean);
            if (trainIds.length > 0) {
                const { data, error: cmErr } = await supabaseAdmin
                    .from('coach_master')
                    .select('coach_display_id, coach_unique_id, train_id')
                    .in('train_id', trainIds);
                if (cmErr) throw cmErr;
                cmRows = data || [];
            }

            const cmMap = {};
            for (const cm of cmRows) {
                cmMap[cm.coach_unique_id] = cm;
            }

            const { data: locData, error: locErr } = await supabaseAdmin
                .from('acp_critical_events')
                .select('id, tech_coach_no, train_location')
                .in('tech_coach_no', techCoaches)
                .order('id', { ascending: false });

            if (locErr) throw locErr;

            const latestLoc = {};
            for (const row of (locData || [])) {
                if (!latestLoc[row.tech_coach_no]) {
                    latestLoc[row.tech_coach_no] = row.train_location;
                }
            }

            let fsdsData = [];
            if (deviceIds.length > 0) {
                const { data, error: fsdsErr } = await supabaseAdmin
                    .from('fsds_logs')
                    .select('id, device_id, fire_status, bypass_status, timestamp')
                    .in('device_id', deviceIds)
                    .order('id', { ascending: false });
                if (fsdsErr) throw fsdsErr;
                fsdsData = data || [];
            }

            const latestFsds = {};
            for (const row of fsdsData) {
                if (!latestFsds[row.device_id]) {
                    latestFsds[row.device_id] = {
                        fsds_status: fmtBin(row.fire_status),
                        fsds_bypass: fmtBin(row.bypass_status),
                        fsds_timestamp: row.timestamp
                    };
                }
            }

            const dlsMap = {};
            for (const row of (dlsData || [])) {
                dlsMap[row.tech_coach_no] = row;
            }

            const result = (dmRows || []).map(dm => {
                const dls = dlsMap[dm.tech_coach_no] || {};
                const tm = tmMap[dm.train_no];
                const cm = cmMap[dm.tech_coach_no];
                const coachDisplay = (cm && cm.train_id === (tm && tm.train_id)) ? cm.coach_display_id : null;
                const todayCount = dls.today_count || 0;
                const fsds = latestFsds[dm.device_id] || {};

                return {
                    train_no: dm.train_no,
                    comm_coach_no: coachDisplay || dm.comm_coach_no,
                    tech_coach_no: dm.tech_coach_no,
                    device_id: dm.device_id,
                    last_heartbeat: toIST(dls.last_heartbeat),
                    last_trigger: toIST(dls.last_trigger),
                    today_count: todayCount,
                    total_count: dls.total_count || 0,
                    train_location: latestLoc[dm.tech_coach_no] || null,
                    status: todayCount === 0 ? 'Not Pulled' : (dls.status || 'Not Pulled'),
                    fsds_status: fsds.fsds_status || null,
                    fsds_bypass: fsds.fsds_bypass || null,
                    fsds_timestamp: fsds.fsds_timestamp || null
                };
            });

            return result;
        } catch (error) {
            throw new Error("Error fetching filtered logs: " + error.message);
        }
    }
};

module.exports = AcpModel;
