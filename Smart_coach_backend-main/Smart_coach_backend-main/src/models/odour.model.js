const supabaseAdmin = require("../config/supabaseAdmin");
const { dualInsert } = require("../config/dualWrite");

class OdourModel {
    async saveDynamicLog(data) {
        try {
            const inserted = await dualInsert('odour_logs', [data]);
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
