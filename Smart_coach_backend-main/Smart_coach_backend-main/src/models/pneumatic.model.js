const supabase = require('../config/supabaseOld');
const supabaseAdmin = require('../config/supabaseAdmin');

const PNEUMATIC_COLUMNS_BP = `timestamp, bp, fp, cr, bc, brake_status, brake_duration, brake_fault, coach_no, device_id, brake_applied_time, brake_released_time`;
const PRESSURE_COLUMNS_PL = `timestamp, bp_pressure, coach_number, device_id, brake_applied_time, brake_released_time`;

function normalizeRow(row) {
    if (!row) return row;
    if (row.coach_number && !row.coach_no) {
        row.coach_no = row.coach_number;
    }
    if (row.bp_pressure != null && row.bp == null) {
        row.bp = row.bp_pressure;
    }
    return row;
}

const HISTORY_PAGE_SIZE = 1000;
const HISTORY_PARALLEL_THRESHOLD = 5000;
const HISTORY_PAGE_CONCURRENCY = 6;
const MAX_HISTORY_ROWS = 50000;

function getDateBounds(fromDate, toDate) {
    const dateOnly = /^\d{4}-\d{2}-\d{2}$/;
    let start = null;
    let endInclusive = null;
    let endExclusive = null;

    if (fromDate) {
        const value = String(fromDate).trim();
        const parsed = new Date(dateOnly.test(value) ? `${value}T00:00:00+05:30` : value);
        if (!Number.isNaN(parsed.getTime())) start = parsed.toISOString();
    }

    if (toDate) {
        const value = String(toDate).trim();
        const parsed = new Date(dateOnly.test(value) ? `${value}T00:00:00+05:30` : value);
        if (!Number.isNaN(parsed.getTime())) {
            if (dateOnly.test(value)) {
                parsed.setUTCDate(parsed.getUTCDate() + 1);
                endExclusive = parsed.toISOString();
            } else {
                endInclusive = parsed.toISOString();
            }
        }
    }

    return { start, endInclusive, endExclusive };
}

async function fetchSequentialRows(buildQuery, rowLimit) {
    const rows = [];
    for (let offset = 0; offset < rowLimit; offset += HISTORY_PAGE_SIZE) {
        const end = Math.min(offset + HISTORY_PAGE_SIZE - 1, rowLimit - 1);
        const { data, error } = await buildQuery().range(offset, end);
        if (error) return { data: null, error };

        const page = data || [];
        rows.push(...page);
        if (page.length < end - offset + 1) break;
    }
    return { data: rows, error: null };
}

async function fetchParallelRows(buildQuery, rowLimit) {
    const pageCount = Math.ceil(rowLimit / HISTORY_PAGE_SIZE);
    const pages = new Array(pageCount);
    let nextPage = 0;
    let stop = false;
    let firstError = null;

    const worker = async () => {
        while (!stop) {
            const pageIndex = nextPage++;
            if (pageIndex >= pageCount) return;

            const offset = pageIndex * HISTORY_PAGE_SIZE;
            const end = Math.min(offset + HISTORY_PAGE_SIZE - 1, rowLimit - 1);
            const { data, error } = await buildQuery().range(offset, end);

            if (error) {
                firstError = error;
                stop = true;
                return;
            }

            const page = data || [];
            pages[pageIndex] = page;
            if (page.length < end - offset + 1) stop = true;
        }
    };

    const workerCount = Math.min(HISTORY_PAGE_CONCURRENCY, pageCount);
    await Promise.all(Array.from({ length: workerCount }, () => worker()));

    if (firstError) return { data: null, error: firstError };

    const rows = [];
    for (let index = 0; index < pageCount; index += 1) {
        const page = pages[index];
        if (!page || page.length === 0) break;
        rows.push(...page);
        if (page.length < HISTORY_PAGE_SIZE) break;
    }
    return { data: rows, error: null };
}

async function fetchPagedRows(buildQuery, rowLimit) {
    if (rowLimit >= HISTORY_PARALLEL_THRESHOLD) {
        return fetchParallelRows(buildQuery, rowLimit);
    }
    return fetchSequentialRows(buildQuery, rowLimit);
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
            const finalLimit = Math.min(Math.max(parseInt(limit, 10) || 10, 1), MAX_HISTORY_ROWS);
            const finalOffset = Math.max(parseInt(offset, 10) || 0, 0);
            const rowLimit = Math.min(finalOffset + finalLimit, MAX_HISTORY_ROWS);
            const dateBounds = getDateBounds(fromDate, toDate);

            let data = null;
            let usedFallback = false;
            let authorizedDeviceIds = null;

            const rbac = require('../utils/rbac');
            if (user && !rbac.isUnrestrictedUser(user)) {
                const userLoc = rbac.getUserLocation(user);
                if (!userLoc) return [];

                let allowedCoachRows = [];
                if (supabase) {
                    const { data: rows } = await supabase.from('coaches_railway').select('device_id, Location');
                    if (rows && rows.length > 0) allowedCoachRows = rows;
                }
                if (allowedCoachRows.length === 0 && supabaseAdmin) {
                    const { data: rows } = await supabaseAdmin.from('coaches_railway').select('device_id, Location');
                    if (rows && rows.length > 0) allowedCoachRows = rows;
                }

                const normUserLoc = String(userLoc).trim().toLowerCase();
                const matchesLoc = (loc) => {
                    if (!loc) return false;
                    const normLoc = String(loc).trim().toLowerCase();
                    if (
                        (normLoc.includes('kolkata') || normLoc.includes('kolkatta') || normLoc.includes('howrah')) &&
                        (normUserLoc.includes('kolkata') || normUserLoc.includes('kolkatta') || normUserLoc.includes('howrah'))
                    ) return true;
                    return (
                        normLoc === normUserLoc ||
                        normLoc.startsWith(`${normUserLoc}_`) ||
                        normLoc.startsWith(`${normUserLoc} `) ||
                        normUserLoc.startsWith(`${normLoc}_`) ||
                        normUserLoc.startsWith(`${normLoc} `)
                    );
                };

                authorizedDeviceIds = allowedCoachRows
                    .filter(c => matchesLoc(c.Location))
                    .map(c => c.device_id)
                    .filter(Boolean);

                if (authorizedDeviceIds.length === 0) return [];
                if (deviceId && !authorizedDeviceIds.includes(deviceId)) return [];
            }

            const buildQuery = (client, table, columns) => () => {
                let query = client.from(table).select(columns);
                if (deviceId) query = query.eq('device_id', deviceId);
                if (authorizedDeviceIds) query = query.in('device_id', authorizedDeviceIds);
                if (dateBounds.start) query = query.gte('timestamp', dateBounds.start);
                if (dateBounds.endExclusive) query = query.lt('timestamp', dateBounds.endExclusive);
                else if (dateBounds.endInclusive) query = query.lte('timestamp', dateBounds.endInclusive);
                return query.order('timestamp', { ascending: false });
            };

            if (supabase) {
                const primary = await fetchPagedRows(
                    buildQuery(supabase, 'bpc_pressure', PNEUMATIC_COLUMNS_BP),
                    rowLimit
                );

                if (primary.data && primary.data.length > 0) {
                    data = primary.data.map(normalizeRow);
                } else if (primary.error && (primary.error.code === '42P01' || primary.error.message?.includes('does not exist') || primary.error.message?.includes('not found'))) {
                    usedFallback = true;
                } else if (primary.error) {
                    usedFallback = true;
                }
            } else {
                usedFallback = true;
            }

            if (!data && usedFallback && supabaseAdmin) {
                const fallback = await fetchPagedRows(
                    buildQuery(supabaseAdmin, 'pressure_logs', PRESSURE_COLUMNS_PL),
                    rowLimit
                );
                if (fallback.error) {
                    console.warn("pressure_logs fallback error:", fallback.error.message);
                }
                data = (fallback.data || []).map(normalizeRow);
            }

            if (!data || data.length === 0) return [];
            data.sort((a, b) => new Date(b.timestamp || 0) - new Date(a.timestamp || 0));
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
                const { data: fbData, error: fbErr } = await supabaseAdmin.from('pressure_logs').select(`timestamp, bp_pressure, device_id, coach_number as coach_no`);
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
