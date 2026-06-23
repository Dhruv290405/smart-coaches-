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
}

module.exports = new OdourModel();