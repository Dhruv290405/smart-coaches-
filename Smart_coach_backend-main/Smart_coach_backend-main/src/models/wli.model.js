const { pool } = require("../config/db");

class WliModel {
    async saveDynamicLog(data) {
        const keysArray = Object.keys(data);
        const valuesArray = Object.values(data);

        const columns = keysArray.join(", ");
        const placeholders = keysArray.map(() => "?").join(", ");

        const query = `INSERT INTO wli_logs (${columns}) VALUES (${placeholders})`;

        try {
            const [result] = await pool.query(query, valuesArray);
            return result.insertId;
        } catch (err) {
            console.error("WLI Model Error:", err.message);
            throw err;
        }
    }

    async getLatestStatusForAllCoaches() {
        const query = `
            SELECT 
                l.id, l.device_id, l.coach_name, l.coach_id,
                l.asset_id, l.asset_name, l.level_cm, l.volume_liters,
                l.percent_full, l.raw_value, l.placement_type, l.timestamp
            FROM wli_logs l
            INNER JOIN (
                SELECT MAX(id) as latest_id 
                FROM wli_logs 
                GROUP BY device_id
            ) latest ON l.id = latest.latest_id
            ORDER BY l.timestamp DESC
        `;

        try {
            const [rows] = await pool.query(query);
            return rows;
        } catch (err) {
            console.error("WLI Dashboard Error:", err.message);
            throw err;
        }
    }
}

module.exports = new WliModel();