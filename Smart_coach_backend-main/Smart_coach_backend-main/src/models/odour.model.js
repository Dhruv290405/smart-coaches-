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
            const { data, error } = await supabaseAdmin
                .rpc('get_latest_odour_per_device');

            if (error) throw error;
            return data || [];
        } catch (err) {
            console.error("Odour Dashboard Error:", err.message);
            throw err;
        }
    }
}

module.exports = new OdourModel();
