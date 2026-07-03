// src/services/supabaseListener.js
// Listens to Supabase Realtime for new ACP IoT rows inserted by AWS Lambda
const acpSupabase = require('../config/supabaseAcp');

function startSupabaseListener() {
    if (!acpSupabase) {
        console.error("⚠️ ACP Supabase client not initialized. Cannot start ACP IoT listener.");
        return;
    }

    const TABLE = process.env.ACP_SUPABASE_TABLE || 'acp_metrics_data';
    console.log(`📡 Listening to ACP Supabase Realtime on table '${TABLE}' for AWS IoT ACP data...`);

    acpSupabase
        .channel('acp-iot-live-channel')
        .on(
            'postgres_changes',
            { event: 'INSERT', schema: 'public', table: TABLE },
            (payload) => {
                const row = payload.new;
                console.log(`🔥 New ACP event from IoT — Coach: ${row.coach_no}, Count: ${row.current_count}, Train: ${row.loc_name}`);

                try {
                    const result = {
                        timestamp: row.event_timestamp || new Date().toISOString(),
                        coachNo: row.asset_name || row.coach_no,
                        tech_coach_no: row.coach_no,
                        acp_status: row.current_count,
                        total_count: row.total_count,
                        train_location: row.loc_name,
                        raw_asset_name: row.asset_name,
                        source: 'supabase_realtime'
                    };

                    // Emit ACP update via Socket.IO to all connected frontend clients
                    if (global._io) {
                        global._io.emit('acp:update', result);
                        console.log(`✅ Emitted acp:update to Socket.IO for coach ${row.coach_no}`);
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
                console.log(`ℹ️ ACP Supabase subscription status: ${status}`);
            }
        });
}

module.exports = { startSupabaseListener };
