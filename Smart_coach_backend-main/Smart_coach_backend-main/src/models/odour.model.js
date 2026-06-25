const { pool } = require("../config/db");

class OdourModel {
    async saveDynamicLog(data) {
        const keysArray = Object.keys(data);
        const valuesArray = Object.values(data);
        const columns = keysArray.join(", ");
        const placeholders = keysArray.map(() => "?").join(", ");

        const query = `INSERT INTO odour_logs (${columns}) VALUES (${placeholders})`;
        try {
            const [result] = await pool.query(query, valuesArray);
            return result.insertId;
        } catch (err) {
            console.error("Odour Model Error:", err.message);
            throw err;
        }
    }

    async getLatestStatusForAllCoaches() {
        const query = `
            SELECT 
                l.id, l.device_id, l.master_sensor_id,
                l.train_number, l.coach_number, l.coach_type,
                l.toilet_position, l.odour_reading, l.device_status,
                l.voc, l.h2s, l.nh3, l.smoke,
                l.temperature, l.humidity, l.timestamp,
                COALESCE(dm.tech_coach_no, l.coach_number) AS tech_coach_no,
                COALESCE(c.train_id, l.train_number) AS train_no
            FROM odour_logs l
            INNER JOIN (
                SELECT MAX(id) as latest_id 
                FROM odour_logs 
                GROUP BY device_id
            ) latest ON l.id = latest.latest_id
            LEFT JOIN device_master dm ON l.device_id = dm.device_id
            LEFT JOIN coaches c ON dm.tech_coach_no = c.coach_number
            ORDER BY l.timestamp DESC
        `;

        try {
            const [rows] = await pool.query(query);
            return rows;
        } catch (err) {
            console.error("Odour Dashboard Error:", err.message);
            throw err;
        }
    }
}

module.exports = new OdourModel();