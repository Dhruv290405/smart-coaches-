const _acpSupabase = require('../config/supabaseAcp');
const acpSupabase = _acpSupabase || { from: () => ({ select: () => ({ order: () => ({ in: () => ({ then: (r) => r({ data: [], error: null }), catch: () => {} }) }) }), insert: () => ({ select: () => ({ then: (r) => r({ data: [], error: null }), catch: () => {} }) }) }) };

const TABLE = 'iot_bad_odour';

class OdourModel {
    async saveLog(data) {
        try {
            const { data: inserted, error } = await acpSupabase
                .from(TABLE)
                .insert([data])
                .select();

            if (error) throw error;
            if (!inserted || !inserted[0]) throw new Error("Insert returned no data");
            return inserted[0].id;
        } catch (err) {
            console.error("Odour Model Error:", err.message);
            throw err;
        }
    }

    async getLatestStatusForAllCoaches() {
        try {
            const { data, error } = await acpSupabase
                .from(TABLE)
                .select('*')
                .order('timestamp', { ascending: false });

            if (error) throw error;

            const grouped = {};
            for (const row of data || []) {
                const key = row.device_id || row.sensor_id;
                if (!grouped[key] || new Date(row.timestamp) > new Date(grouped[key].timestamp)) {
                    grouped[key] = row;
                }
            }

            return Object.values(grouped);
        } catch (err) {
            console.error("Odour Dashboard Error:", err.message);
            throw err;
        }
    }

    async getCoachesByDeviceIds(deviceIds) {
        try {
            if (!deviceIds || deviceIds.length === 0) return [];
            const { data, error } = await acpSupabase
                .from(TABLE)
                .select('*')
                .in('device_id', deviceIds)
                .order('timestamp', { ascending: false });

            if (error) throw error;
            return data || [];
        } catch (err) {
            console.error("Odour Coaches Error:", err.message);
            throw err;
        }
    }
}

module.exports = new OdourModel();
