const supabaseAdmin = require("../config/supabaseAdmin");
const { dualInsert } = require("../config/dualWrite");

class HotAxleModel {
    async saveDynamicLog(data) {
        try {
            const inserted = await dualInsert('hot_axle_logs', [data]);
            if (!inserted || !inserted[0]) throw new Error("Insert returned no data");
            return inserted[0].id;
        } catch (err) {
            console.error("Database Dynamic Insert Error:", err.message);
            throw err;
        }
    }

    async getData(deviceId, limit, authorizedCoaches = null) {
        try {
            if (authorizedCoaches !== null && authorizedCoaches.length === 0) {
                return [];
            }

            let query = supabaseAdmin
                .from('hot_axle_logs')
                .select('*');

            if (deviceId) {
                query = query.eq('device_id', deviceId);
            }

            if (authorizedCoaches && authorizedCoaches.length > 0) {
                query = query.in('coach_number', authorizedCoaches);
            }

            const { data, error } = await query
                .order('id', { ascending: false })
                .range(0, limit - 1);

            if (error) throw error;
            return data;
        } catch (err) {
            console.error("Database Select Error:", err.message);
            throw err;
        }
    }

    async getHistoryData({ deviceId, coachNumber, startDate, endDate, limit, offset, authorizedCoaches = null }) {
        try {
            if (authorizedCoaches !== null && authorizedCoaches.length === 0) {
                return { data: [], total: 0 };
            }

            let query = supabaseAdmin
                .from('hot_axle_logs')
                .select('*', { count: 'exact' });

            if (deviceId && deviceId !== 'All') {
                query = query.eq('device_id', deviceId);
            }

            if (coachNumber && coachNumber !== 'All') {
                query = query.eq('coach_number', coachNumber);
            }

            if (authorizedCoaches && authorizedCoaches.length > 0) {
                query = query.in('coach_number', authorizedCoaches);
            }

            if (startDate && endDate) {
                query = query
                    .gte('timestamp', `${startDate} 00:00:00`)
                    .lte('timestamp', `${endDate} 23:59:59`);
            }

            const { data, count, error } = await query
                .order('timestamp', { ascending: false })
                .range(parseInt(offset), parseInt(offset) + parseInt(limit) - 1);

            if (error) throw error;
            return { data, total: count };
        } catch (err) {
            console.error("History Model Error:", err.message);
            throw err;
        }
    }

    async getFilterOptions() {
        try {
            const { data, error } = await supabaseAdmin
                .from('hot_axle_logs')
                .select('device_id, coach_type, owning_rly, coach_number, train_no');
            if (error) throw error;
            const deviceIds = [...new Set((data || []).map(r => r.device_id).filter(Boolean))].sort();
            const coachTypes = [...new Set((data || []).map(r => r.coach_type).filter(Boolean))].sort();
            const owningRlys = [...new Set((data || []).map(r => r.owning_rly).filter(Boolean))].sort();
            const trainNos = [...new Set((data || []).filter(r => r.coach_type !== 'HAMS').map(r => r.train_no).filter(Boolean))].sort();
            const coachNumbers = [...new Set((data || []).map(r => r.coach_number).filter(Boolean))].sort();
            return { deviceIds, coachTypes, owningRlys, trainNos, coachNumbers };
        } catch (err) {
            console.error("Filter Options Error:", err.message);
            throw err;
        }
    }

    async getLatestStatusForAllCoaches(filters = {}, authorizedCoaches = null) {
        try {
            if (authorizedCoaches !== null && authorizedCoaches.length === 0) {
                return [];
            }

            const { data, error } = await supabaseAdmin
                .rpc('get_latest_per_device');

            if (error) throw error;

            let result = data || [];

            if (authorizedCoaches && authorizedCoaches.length > 0) {
                result = result.filter(r => authorizedCoaches.includes(r.coach_number));
            }

            if (filters.trainNo && filters.trainNo !== 'All Trains') {
                result = result.filter(r => r.train_no?.toString() === filters.trainNo);
            }

            if (filters.deviceId) {
                result = result.filter(r => r.device_id === filters.deviceId);
            }

            if (filters.coachType && filters.coachType !== 'All Types') {
                result = result.filter(r => r.coach_type === filters.coachType);
            }

            if (filters.owningRly && filters.owningRly !== 'All Railways') {
                result = result.filter(r => r.owning_rly === filters.owningRly);
            }

            if (filters.coachNumber && filters.coachNumber !== 'All Coach Numbers') {
                result = result.filter(r => r.coach_number === filters.coachNumber);
            }

            return result;
        } catch (err) {
            console.error("Dashboard Status Error:", err.message);
            throw err;
        }
    }
}

module.exports = new HotAxleModel();
