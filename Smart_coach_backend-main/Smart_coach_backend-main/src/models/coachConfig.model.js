const supabaseAdmin = require("../config/supabaseAdmin");

class CoachConfigModel {
    async getDetailsByCoach(coachNo) {
        const { data: coachRows, error: err1 } = await supabaseAdmin
            .from('coach_master')
            .select('*')
            .eq('coach_unique_id', coachNo);

        if (err1) throw err1;

        if (!coachRows || coachRows.length === 0) {
            const { data: fallbackRows, error: fbErr } = await supabaseAdmin
                .from('coach_configurations')
                .select('*')
                .eq('coach_no', coachNo);
            if (fbErr) throw fbErr;
            return fallbackRows[0] || null;
        }

        const coachInfo = coachRows[0];
        const coachId = coachInfo.coach_id;

        let trainNumber = null;
        if (coachInfo.train_id) {
            const { data: trainRows, error: err2 } = await supabaseAdmin
                .from('train_master')
                .select('train_number')
                .eq('train_id', coachInfo.train_id);
            if (err2) throw err2;
            trainNumber = trainRows[0]?.train_number || null;
        }

        const { data: modules, error: err3 } = await supabaseAdmin
            .from('master_module')
            .select(`
                module_id,
                module_unique_id,
                module_device_mapping!left(
                    module_device_mapping_id,
                    device_master!left(
                        device_id,
                        short_name,
                        full_name,
                        device_unique_id,
                        is_active
                    )
                )
            `)
            .eq('coach_id', coachId);

        if (err3) throw err3;

        const rows = [];
        for (const mod of modules || []) {
            for (const mapping of mod.module_device_mapping || []) {
                const dev = mapping?.device_master;
                rows.push({
                    coach_id: coachInfo.coach_id,
                    coach_unique_id: coachInfo.coach_unique_id,
                    coach_display_id: coachInfo.coach_display_id,
                    train_number: trainNumber,
                    device_id: dev?.device_id || null,
                    short_name: dev?.short_name || null,
                    full_name: dev?.full_name || null,
                    device_unique_id: dev?.device_unique_id || null,
                    is_active: dev?.is_active || null,
                    module_id: mod.module_id,
                    module_unique_id: mod.module_unique_id,
                    module_device_mapping_id: mapping?.module_device_mapping_id || null
                });
            }
        }

        const fittedDevices = [];
        const deviceSet = new Set();

        for (const row of rows) {
            if (row.device_id && !deviceSet.has(row.device_id)) {
                deviceSet.add(row.device_id);
                const deviceName = row.short_name || row.full_name || row.device_unique_id || `Device ${row.device_id}`;
                fittedDevices.push(deviceName);
            }
        }

        return {
            coach_no: coachInfo.coach_unique_id,
            coach_type: coachInfo.coach_display_id || '',
            rake_no: trainNumber || '',
            wsp_make: 'N/A',
            fitted_devices: fittedDevices,
            devices: rows.filter(r => r.device_id).map(r => ({
                device_id: r.device_id,
                short_name: r.short_name,
                full_name: r.full_name,
                device_unique_id: r.device_unique_id,
                is_active: r.is_active,
                module_id: r.module_id,
                module_unique_id: r.module_unique_id
            }))
        };
    }
}

module.exports = new CoachConfigModel();
