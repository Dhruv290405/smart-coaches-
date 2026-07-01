const supabaseAdmin = require("../config/supabaseAdmin");

class FsdsModel {
    async saveDynamicLog(data) {
        try {
            const { data: inserted, error } = await supabaseAdmin
                .from('fsds_logs')
                .insert([data])
                .select();

            if (error) throw error;
            return inserted?.[0]?.id;
        } catch (err) {
            console.error("FSDS Model Error:", err.message);
            throw err;
        }
    }

    async getLogs({ limit, offset, trainNo, locName } = {}) {
        try {
            let query = supabaseAdmin
                .from('fsds_logs')
                .select('*', { count: 'exact' });

            if (trainNo) {
                query = query.ilike('loc_name', `%${trainNo}%`);
            }
            if (locName) {
                query = query.ilike('loc_name', `%${locName}%`);
            }

            query = query.order('timestamp', { ascending: false });

            if (limit) query = query.limit(limit);
            if (offset) query = query.range(offset, offset + (limit || 100) - 1);

            const { data, error } = await query;
            if (error) throw error;
            return data || [];
        } catch (err) {
            console.error("FSDS Model Get Logs Error:", err.message);
            throw err;
        }
    }
}

module.exports = new FsdsModel();
