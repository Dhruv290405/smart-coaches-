const supabaseAdmin = require("../config/supabaseAdmin");

class HotAxleModel {
    async saveDynamicLog(data) {
        try {
            const { data: inserted, error } = await supabaseAdmin
                .from('hot_axle_logs')
                .insert([data])
                .select();

            if (error) throw error;
            return inserted[0].id;
        } catch (err) {
            console.error("Database Dynamic Insert Error:", err.message);
            throw err;
        }
    }

    async getData(deviceId, limit) {
        try {
            let query = supabaseAdmin
                .from('hot_axle_logs')
                .select('*');

            if (deviceId) {
                query = query.eq('device_id', deviceId);
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

    async getHistoryData({ deviceId, coachNumber, startDate, endDate, limit, offset }) {
        try {
            let query = supabaseAdmin
                .from('hot_axle_logs')
                .select('*', { count: 'exact' });

            if (deviceId && deviceId !== 'All') {
                query = query.eq('device_id', deviceId);
            }

            if (coachNumber && coachNumber !== 'All') {
                query = query.eq('coach_number', coachNumber);
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

    async getLatestStatusForAllCoaches() {
        try {
            const { data, error } = await supabaseAdmin
                .rpc('get_latest_per_device');

            if (error) throw error;
            return data || [];
        } catch (err) {
            console.error("Dashboard Status Error:", err.message);
            throw err;
        }
    }
}

module.exports = new HotAxleModel();
