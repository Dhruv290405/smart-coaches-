const supabaseAdmin = require("../config/supabaseAdmin");
const { dualInsert } = require("../config/dualWrite");

class WliModel {
    async saveDynamicLog(data) {
        try {
            const inserted = await dualInsert('wli_logs', [data]);
            if (!inserted || !inserted[0]) throw new Error("Insert returned no data");
            return inserted[0].id;
        } catch (err) {
            console.error("WLI Model Error:", err.message);
            throw err;
        }
    }

    async getHistoryForDevice({ deviceId, coachId, since, limit = 5000 } = {}) {
        try {
            let query = supabaseAdmin.from('wli_logs').select('*');
            if (deviceId) query = query.eq('device_id', deviceId);
            else if (coachId) query = query.eq('coach_id', coachId);
            if (since) query = query.gte('timestamp', since);

            const { data, error } = await query
                .order('timestamp', { ascending: true })
                .limit(limit);
            if (error) throw error;
            return data || [];
        } catch (err) {
            console.error("WLI History Error:", err.message);
            throw err;
        }
    }

    async getLatestStatusForAllCoaches(authorizedCoaches = null) {
        try {
            const { data, error } = await supabaseAdmin
                .rpc('get_latest_wli_per_device');

            if (error) throw error;

            let results = data || [];

            if (authorizedCoaches !== null && authorizedCoaches.length === 0) {
                return [];
            }

            if (authorizedCoaches !== null && authorizedCoaches.length > 0) {
                results = results.filter(r => authorizedCoaches.includes(r.coach_name));
            }

            return results;
        } catch (err) {
            console.error("WLI Dashboard Error:", err.message);
            throw err;
        }
    }
}

module.exports = new WliModel();
