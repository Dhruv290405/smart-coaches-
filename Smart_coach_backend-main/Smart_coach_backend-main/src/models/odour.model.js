const _acpSupabase = require('../config/supabaseAcp');
const acpSupabase = _acpSupabase || { from: () => ({ select: () => ({ order: () => ({ in: () => ({ then: (r) => r({ data: [], error: null }), catch: () => {} }) }) }), insert: () => ({ select: () => ({ then: (r) => r({ data: [], error: null }), catch: () => {} }) }) }) };

const _odour2Supabase = require('../config/supabaseOdour2');
const odour2Supabase = _odour2Supabase || null;

const TABLE = 'iot_bad_odour';
const SECTION1_TABLE = 'bad_odour_data';
const SECTION1_COACHES_TABLE = 'coaches_Bad_Odour';
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

    _demoFallbackEnabled() {
        const flag = process.env.SECTION1_DEMO_FALLBACK;
        return flag == null ? true : flag.toLowerCase() !== 'false';
    }

    _section1DemoData() {
        const now = new Date().toISOString();
        return [
            {
                device_id: 'OMD-S1-WS-01',
                sensor_id: 'SENS-S1-001',
                coach_number: 'B1',
                coach_type: '3AC',
                toilet_position: 'Toilet-1-Front-Left',
                status: 'Active',
                voc_index: 950,
                h2s_ppm: 0.08,
                nh3_ppm: 0.8,
                smoke: 6.5,
                temperature: 32.5,
                humidity: 65.0,
                timestamp: now,
                train_number: '12952',
                train_name: 'Rajdhani Express',
                route: 'NDLS-BCT',
                address: 'Demo',
                door_status: 'Closed',
                door_open_events_today: 142,
                u_count: 0,
                f_count: 0,
                last_opened_time: 'N/A',
                last_closed_time: 'N/A',
                total_door_cycles_today: 142,
                average_open_duration: 'N/A',
                longest_open_duration: 'N/A',
                hygiene_score: null,
                voc_status: 'Good',
                nh3_status: null,
                h2s_status: null,
                smoke_status: null,
                temp_status: null,
                hum_status: null,
            },
            {
                device_id: 'OMD-S1-WS-02',
                sensor_id: 'SENS-S1-002',
                coach_number: 'S1',
                coach_type: 'Sleeper',
                toilet_position: 'Toilet-4-Rear-Right',
                status: 'Active',
                voc_index: 380,
                h2s_ppm: 0.03,
                nh3_ppm: 0.15,
                smoke: 2.0,
                temperature: 29.5,
                humidity: 55.0,
                timestamp: now,
                train_number: '12627',
                train_name: 'Karnataka Express',
                route: 'SBC-NDLS',
                address: 'Demo',
                door_status: 'Closed',
                door_open_events_today: 54,
                u_count: 0,
                f_count: 0,
                last_opened_time: 'N/A',
                last_closed_time: 'N/A',
                total_door_cycles_today: 54,
                average_open_duration: 'N/A',
                longest_open_duration: 'N/A',
                hygiene_score: null,
                voc_status: 'Good',
                nh3_status: null,
                h2s_status: null,
                smoke_status: null,
                temp_status: null,
                hum_status: null,
            },
        ];
    }

    async getLatestStatusForAllCoaches(location = null) {
        try {
            let normalizedLoc = location ? location.trim() : null;
            if (normalizedLoc && normalizedLoc.toLowerCase().includes('nagpur')) {
                normalizedLoc = 'Nagpur';
            }

            let coachesQuery = acpSupabase
                .from(SECTION1_COACHES_TABLE)
                .select('*');

            if (normalizedLoc) {
                coachesQuery = coachesQuery.ilike('location', `%${normalizedLoc}%`);
            }

            const { data: coaches, error: coachesError } = await coachesQuery;
            if (coachesError) throw coachesError;

            const registeredDeviceIds = (coaches || []).map(c => c.device_ID).filter(Boolean);
            if (registeredDeviceIds.length === 0) {
                return [];
            }

            // Readings are best-effort: if this query fails we still return every
            // registered coach (with zeroed readings) instead of dropping coaches
            // until the next successful poll.
            let data = [];
            try {
                const { data: readings, error } = await acpSupabase
                    .from(SECTION1_TABLE)
                    .select('*')
                    .in('device_ID', registeredDeviceIds)
                    .order('timestamp', { ascending: false })
                    .limit(500);
                if (error) throw error;
                data = readings || [];
            } catch (readingErr) {
                console.warn('Odour Section 1 readings unavailable, returning registered coaches only:', readingErr.message);
            }

            // Latest row per device
            const grouped = {};
            for (const row of data || []) {
                const key = row.device_ID;
                if (!key) continue;
                if (!grouped[key] || new Date(row.timestamp) > new Date(grouped[key].timestamp)) {
                    grouped[key] = row;
                }
            }

            // The registration table is authoritative. Return every registered
            // coach even when that coach has not produced a reading yet.
            const real = (coaches || []).map((coach) => {
                const reading = grouped[coach.device_ID] || {};
                return this._mapBadOdourRow({
                    ...coach,
                    ...reading,
                    device_ID: coach.device_ID,
                    Coach_ID: reading.Coach_ID || coach.Coach_ID || coach.device_ID,
                    Coach_no: reading.Coach_no || coach.Coach_no,
                    coach_type: coach.Coach_no || 'LWCZAC',
                    Train_No: reading.Train_No || coach.Train_No,
                    location: coach.location || reading.location,
                });
            });

            return real;
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
                .order('timestamp', { ascending: false })
                .limit(500);

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

    _section1DemoHistory() {
        const points = [];
        const now = Date.now();
        for (let i = 23; i >= 0; i--) {
            const t = new Date(now - i * 3600 * 1000);
            const wave = Math.sin((23 - i) / 3.5) * 220;
            points.push({
                timestamp: t.toISOString(),
                voc: Math.max(60, Math.round(560 + wave)),
                nh3: +(0.12 + Math.abs(Math.sin((23 - i) / 4)) * 0.22).toFixed(3),
                h2s: +(0.02 + Math.abs(Math.cos((23 - i) / 4)) * 0.04).toFixed(3),
                smoke: +(2 + Math.abs(Math.sin((23 - i) / 5)) * 3).toFixed(2),
                temperature: +(29 + Math.abs(Math.sin((23 - i) / 6)) * 4).toFixed(1),
                humidity: +(56 + Math.abs(Math.cos((23 - i) / 6)) * 10).toFixed(1),
            });
        }
        return points;
    }

    async getSection1History(deviceId, limit = 10000) {
        try {
            if (!deviceId) return [];
            const { data, error } = await acpSupabase
                .from(SECTION1_TABLE)
                .select('timestamp, voc_index, h2s_ppm, nh3_ppm, temperature, humidity')
                .eq('device_ID', deviceId)
                .order('timestamp', { ascending: true })
                .limit(limit);
            if (error) throw error;
            const mapped = (data || []).map((r) => ({
                timestamp: r.timestamp,
                voc: r.voc_index ?? 0,
                nh3: r.nh3_ppm ?? 0,
                h2s: r.h2s_ppm ?? 0,
                smoke: 0,
                temperature: r.temperature ?? 0,
                humidity: r.humidity ?? 0,
            }));
            if (mapped.length === 0 && this._demoFallbackEnabled()) {
                return this._section1DemoHistory();
            }
            return mapped;
        } catch (err) {
            console.error("Odour Section 1 History Error:", err.message);
            if (this._demoFallbackEnabled()) {
                return this._section1DemoHistory();
            }
            return [];
        }
    }

    async getSection2History(deviceId, limit = 10000) {
        try {
            if (!deviceId || !odour2Supabase) return [];
            // Prefer the dedicated history table; fall back to the live table if it
            // does not exist yet (or is empty) using the appropriate column names.
            const candidates = [
                {
                    table: 'odour_management_history',
                    select: 'timestamp, voc, nh3, h2s, smoke, temperature, humidity',
                    map: (r) => ({
                        timestamp: r.timestamp,
                        voc: r.voc ?? 0,
                        nh3: r.nh3 ?? 0,
                        h2s: r.h2s ?? 0,
                        smoke: r.smoke ?? 0,
                        temperature: r.temperature ?? 0,
                        humidity: r.humidity ?? 0,
                    }),
                },
                {
                    table: SECTION2_TABLE,
                    select: 'timestamp, voc_index, nh3_ppm, h2s_ppm, temperature, humidity',
                    map: (r) => ({
                        timestamp: r.timestamp,
                        voc: r.voc_index ?? 0,
                        nh3: r.nh3_ppm ?? 0,
                        h2s: r.h2s_ppm ?? 0,
                        smoke: 0,
                        temperature: r.temperature ?? 0,
                        humidity: r.humidity ?? 0,
                    }),
                },
            ];

            for (const c of candidates) {
                const { data, error } = await odour2Supabase
                    .from(c.table)
                    .select(c.select)
                    .eq('device_id', deviceId)
                    .order('timestamp', { ascending: true })
                    .limit(limit);
                if (!error && data && data.length > 0) {
                    return data.map(c.map);
                }
            }
            return [];
        } catch (err) {
            console.error("Odour Section 2 History Error:", err.message);
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
