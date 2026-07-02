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
            const { data, error } = await supabaseAdmin
                .rpc('get_latest_wli_per_device');

            if (error) throw error;
            return data || [];
        } catch (err) {
            console.error("WLI Dashboard Error:", err.message);
            throw err;
        }
    }
}

module.exports = new WliModel();
