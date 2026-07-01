const supabaseAdmin = require("../config/supabaseAdmin");

class OdourModel {
    async saveDynamicLog(data) {
        try {
            const { data: inserted, error } = await supabaseAdmin
                .from('odour_logs')
                .insert([data])
                .select();
            if (error) throw error;
            return inserted[0].id;
        } catch (err) {
            console.error("Odour Model Error:", err.message);
            throw err;
        }
    }

    async getLatestStatusForAllCoaches() {
        try {
            const { data: allRows, error } = await supabaseAdmin
                .from('odour_logs')
                .select('id, device_id, master_sensor_id, train_number, coach_number, coach_type, toilet_position, odour_reading, device_status, voc, h2s, nh3, smoke, temperature, humidity, timestamp')
                .order('id', { ascending: false });

            if (error) throw error;

            const seen = new Set();
            const result = [];
            for (const row of allRows || []) {
                if (row.device_id && !seen.has(row.device_id)) {
                    seen.add(row.device_id);
                    result.push(row);
                }
            }
            return result;
        } catch (err) {
            console.error("Odour Dashboard Error:", err.message);
            throw err;
        }
    }
}

module.exports = new OdourModel();
