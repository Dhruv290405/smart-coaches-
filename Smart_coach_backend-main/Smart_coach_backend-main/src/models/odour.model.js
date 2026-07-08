const supabaseAdmin = require("../config/supabaseAdmin");

class OdourModel {
    async saveLog(data) {
        try {
            const { data: inserted, error } = await supabaseAdmin
                .from('odour_management_live')
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
            const { data, error } = await supabaseAdmin
                .from('odour_management_live')
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
            const { data, error } = await supabaseAdmin
                .from('odour_management_live')
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
