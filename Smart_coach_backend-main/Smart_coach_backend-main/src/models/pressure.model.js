const supabaseAdmin = require("../config/supabaseAdmin");
const { dualInsert } = require("../config/dualWrite");

class PressureModel {
    async saveDynamicLog(data) {
        try {
            const inserted = await dualInsert('pressure_logs', [data]);
            if (!inserted || !inserted[0]) throw new Error("Insert returned no data");
            return inserted[0].id;
        } catch (err) {
            console.error("Pressure Model Save Error:", err.message);
            throw err;
        }
    }

    async getLatestData(deviceId = null, limit = 30) {
        try {
            let query = supabaseAdmin
                .from('pressure_logs')
                .select('*');

            if (deviceId) {
                query = query.eq('device_id', deviceId);
            }

            const { data, error } = await query
                .order('timestamp', { ascending: false })
                .limit(limit);

            if (error) throw error;
            return data;
        } catch (err) {
            console.error("Pressure Model Fetch Error:", err.message);
            throw err;
        }
    }

    async getDashboardStatus() {
        try {
            const { data, error } = await supabaseAdmin
                .rpc('get_latest_per_coach');

            if (error) throw error;
            return data || [];
        } catch (err) {
            console.error("Pressure Dashboard Model Error:", err.message);
            throw err;
        }
    }

    async getFilteredHistory(filters) {
        const { coachNumber, startDate, endDate, limit = 10, offset = 0 } = filters;

        try {
            let query = supabaseAdmin
                .from('pressure_logs')
                .select('*', { count: 'exact' });

            if (coachNumber) {
                query = query.eq('coach_number', coachNumber);
            }

            if (startDate && endDate) {
                query = query
                    .gte('timestamp', `${startDate} 00:00:00`)
                    .lte('timestamp', `${endDate} 23:59:59`);
            } else if (startDate) {
                query = query.gte('timestamp', `${startDate} 00:00:00`);
            }

            const { data, count, error } = await query
                .order('timestamp', { ascending: false })
                .range(parseInt(offset), parseInt(offset) + parseInt(limit) - 1);

            if (error) throw error;

            return {
                data,
                total: count || 0
            };
        } catch (err) {
            console.error("Pressure History Filter Error:", err.message);
            throw err;
        }
    }
}

module.exports = new PressureModel();
