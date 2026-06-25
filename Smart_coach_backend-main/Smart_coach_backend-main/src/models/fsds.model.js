const { pool } = require("../config/db");

class FsdsModel {
    async saveDynamicLog(data) {
        const keysArray = Object.keys(data);
        const valuesArray = Object.values(data);
        const columns = keysArray.join(", ");
        const placeholders = keysArray.map(() => "?").join(", ");

        const query = `INSERT INTO fsds_logs (${columns}) VALUES (${placeholders})`;
        try {
            const [result] = await pool.query(query, valuesArray);
            return result.insertId;
        } catch (err) {
            console.error("FSDS Model Error:", err.message);
            throw err;
        }
    }

    async getLogs({ limit, offset, trainNo, locName } = {}) {
        let query = `SELECT * FROM fsds_logs WHERE 1=1`;
        const params = [];

        if (trainNo) {
            query += ` AND loc_name LIKE ?`;
            params.push(`%${trainNo}%`);
        }
        if (locName) {
            query += ` AND loc_name LIKE ?`;
            params.push(`%${locName}%`);
        }

        query += ` ORDER BY timestamp DESC`;

        if (limit) {
            query += ` LIMIT ?`;
            params.push(limit);
        }
        if (offset) {
            query += ` OFFSET ?`;
            params.push(offset);
        }

        try {
            const [rows] = await pool.query(query, params);
            return rows;
        } catch (err) {
            console.error("FSDS Model Get Logs Error:", err.message);
            throw err;
        }
    }
}

module.exports = new FsdsModel();