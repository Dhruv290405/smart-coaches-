// src/services/supabaseListener.js
// Listens to Supabase Realtime for new ACP IoT rows inserted by AWS Lambda
const acpSupabase = require('../config/supabaseAcp');

const extractCoachNo = (assetName) => {
    if (!assetName) return null;
    const parts = assetName.split(' ');
    if (parts.length >= 4 && parts[2] === 'ACP') return parts[1];
    return assetName;
};

function startSupabaseListener() {
    if (!acpSupabase) {
        console.error("⚠️ ACP Supabase client not initialized. Cannot start ACP IoT listener.");
        return;
    }

    const TABLE = process.env.ACP_SUPABASE_TABLE || 'railway_acp_data';
    console.log(`📡 Listening to ACP Supabase Realtime on table '${TABLE}' for AWS IoT ACP data...`);

    acpSupabase
        .channel('acp-iot-live-channel')
        .on(
            'postgres_changes',
            { event: 'INSERT', schema: 'public', table: TABLE },
            (payload) => {
                const row = payload.new;
                const coachNo = extractCoachNo(row.asset_name);
                console.log(`🔥 New ACP event from IoT — Coach: ${coachNo}, Count: ${row.count_value}, Train: ${row.loc_name}`);

                try {
                    const result = {
                        timestamp: row.metric_timestamp || new Date().toISOString(),
                        coachNo: row.asset_name || coachNo,
                        tech_coach_no: coachNo,
                        acp_status: row.count_value,
                        total_count: row.totalized_count,
                        train_location: row.loc_name,
                        raw_asset_name: row.asset_name,
                        source: 'supabase_realtime'
                    };

                    // Emit ACP update via Socket.IO to all connected frontend clients
                    if (global._io) {
                        global._io.emit('acp:update', result);
                        console.log(`✅ Emitted acp:update to Socket.IO for coach ${coachNo}`);
                    }
                } catch (err) {
                    console.error("Error processing ACP Supabase Realtime event:", err);
                }
            }
        )
        .subscribe((status) => {
            if (status === 'SUBSCRIBED') {
                console.log(`✅ Subscribed to ACP Supabase Realtime on '${TABLE}' table.`);
            } else if (status === 'CHANNEL_ERROR') {
                console.error("❌ ACP Supabase Realtime channel error! Check ACP_SUPABASE_URL, ACP_SUPABASE_SERVICE_KEY, and that Realtime is enabled for the table.");
            } else {
                console.log(`ℹ️ ACP subscription status: ${status}`);
            }
        });
}

module.exports = { startSupabaseListener };
