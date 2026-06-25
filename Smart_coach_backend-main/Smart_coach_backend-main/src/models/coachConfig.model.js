const { pool } = require("../config/db");

class CoachConfigModel {
    async getDetailsByCoach(coachNo) {
        // Get coach info, master modules, and actual fitted devices
        const query = `
          SELECT 
            cm.coach_id,
            cm.coach_unique_id AS coach_no,
            cm.coach_display_id AS coach_type,
            t.train_number AS rake_no,
            'N/A' AS wsp_make,
            dm.device_id,
            dm.short_name,
            dm.full_name,
            dm.device_unique_id,
            dm.is_active,
            mm.module_id,
            mm.module_unique_id,
            mdm.module_device_mapping_id
          FROM coach_master cm
          LEFT JOIN train_master t ON cm.train_id = t.train_id
          LEFT JOIN master_module mm ON mm.coach_id = cm.coach_id
          LEFT JOIN module_device_mapping mdm ON mdm.module_id = mm.module_id
          LEFT JOIN device_master dm ON mdm.device_id = dm.device_id
          WHERE cm.coach_unique_id = ?
        `;
        const [rows] = await pool.query(query, [coachNo]);

        if (!rows || rows.length === 0) {
            const fallbackQuery = `SELECT * FROM coach_configurations WHERE coach_no = ?`;
            const [fallbackRows] = await pool.query(fallbackQuery, [coachNo]);
            return fallbackRows[0] || null;
        }

        const coachInfo = rows[0];
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
            coach_no: coachInfo.coach_no,
            coach_type: coachInfo.coach_type || '',
            rake_no: coachInfo.rake_no || '',
            wsp_make: coachInfo.wsp_make || 'N/A',
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
