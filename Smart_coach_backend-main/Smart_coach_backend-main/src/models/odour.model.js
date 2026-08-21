const _acpSupabase = require('../config/supabaseAcp');
const acpSupabase = _acpSupabase || { from: () => ({ select: () => ({ order: () => ({ in: () => ({ then: (r) => r({ data: [], error: null }), catch: () => {} }) }) }), insert: () => ({ select: () => ({ then: (r) => r({ data: [], error: null }), catch: () => {} }) }) }) };

const _odour2Supabase = require('../config/supabaseOdour2');
const odour2Supabase = _odour2Supabase || null;

const TABLE = 'iot_bad_odour';
const SECTION1_TABLE = 'bad_odour_data';
const SECTION2_TABLE = 'odour_management_live';

class OdourModel {
    async saveLog(data) {
        try {
            const { data: inserted, error } = await acpSupabase
                .from(TABLE)
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

    async getLatestStatusForAllCoaches(location = null) {
        try {
            let query = acpSupabase
                .from(SECTION1_TABLE)
                .select('*');

            const { data, error } = await query.order('timestamp', { ascending: false });

            if (error) throw error;

            // Latest row per device
            const grouped = {};
            for (const row of data || []) {
                const key = row.device_ID || row.Coach_ID || row.Coach_no;
                if (!grouped[key] || new Date(row.timestamp) > new Date(grouped[key].timestamp)) {
                    grouped[key] = row;
                }
            }

            let latest = Object.values(grouped);

            // Location / division scoping (case-insensitive). Admin (no location) sees all.
            if (location) {
                const loc = location.toLowerCase();
                latest = latest.filter((r) => (r.location || '').toString().toLowerCase() === loc);
            }

            return latest.map((r) => this._mapBadOdourRow(r));
        } catch (err) {
            console.error("Odour Dashboard Error:", err.message);
            return [];
        }
    }

    _mapBadOdourRow(row) {
        const dur = (v) => (v != null ? `${v}s` : 'N/A');
        return {
            device_id: row.device_ID ?? null,
            sensor_id: row.Coach_ID ?? row.device_ID ?? null,
            coach_number: row.Coach_no ?? null,
            coach_type: 'Unknown',
            toilet_position: row.Coach_ID ?? 'N/A',
            status: 'Active',
            voc_index: row.voc_index ?? 0,
            h2s_ppm: row.h2s_ppm ?? 0,
            nh3_ppm: row.nh3_ppm ?? 0,
            smoke: 0,
            temperature: row.temperature ?? 0,
            humidity: row.humidity ?? 0,
            timestamp: row.timestamp ?? row.received_at ?? null,
            train_number: row.Train_No ?? null,
            train_name: row.Train_No ?? '--',
            route: row.location ?? '--',
            address: row.location ?? 'Unknown',
            door_status: row.Door_Status ?? 'Closed',
            door_open_events_today: row.Door_Count ?? row.long_lock_count ?? 0,
            u_count: 0,
            f_count: 0,
            last_opened_time: 'N/A',
            last_closed_time: 'N/A',
            total_door_cycles_today: row.Door_Count ?? 0,
            average_open_duration: dur(row.Door_Open_Duration_Seconds),
            longest_open_duration: dur(row.Door_Closed_Duration_Seconds),
            hygiene_score: null,
            voc_status: row.Status_VOC ?? null,
            nh3_status: null,
            h2s_status: null,
            smoke_status: null,
            temp_status: null,
            hum_status: null,
        };
    }

    async getSection2Latest() {
        try {
            if (!odour2Supabase) {
                console.warn("Odour Section 2 Supabase not initialized.");
                return [];
            }

            const { data, error } = await odour2Supabase
                .from(SECTION2_TABLE)
                .select('*')
                .order('timestamp', { ascending: false });

            if (error) throw error;

            // Latest row per device (mirrors getLatestStatusForAllCoaches)
            const grouped = {};
            for (const row of data || []) {
                const key = row.device_id || row.sensor_id;
                if (!grouped[key] || new Date(row.timestamp) > new Date(grouped[key].timestamp)) {
                    grouped[key] = row;
                }
            }

            return Object.values(grouped);
        } catch (err) {
            console.error("Odour Section 2 Dashboard Error:", err.message);
            return [];
        }
    }

    async getCoachesByDeviceIds(deviceIds) {
        try {
            if (!deviceIds || deviceIds.length === 0) return [];
            const { data, error } = await acpSupabase
                .from(TABLE)
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
