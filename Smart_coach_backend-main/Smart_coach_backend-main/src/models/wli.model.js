const supabaseAdmin = require("../config/supabaseAdmin");

class WliModel {
    async saveDynamicLog(data) {
        try {
            const { data: inserted, error } = await supabaseAdmin
                .from('wli_logs')
                .insert([data])
                .select();
            if (error) throw error;
            return inserted[0].id;
        } catch (err) {
            console.error("WLI Model Error:", err.message);
            throw err;
        }
    }

    async getLatestStatusForAllCoaches() {
        try {
            const { data: allRows, error } = await supabaseAdmin
                .from('wli_logs')
                .select('id, device_id, coach_name, coach_id, asset_id, asset_name, level_cm, volume_liters, percent_full, raw_value, placement_type, timestamp')
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
            console.error("WLI Dashboard Error:", err.message);
            throw err;
        }
    }
}

module.exports = new WliModel();
