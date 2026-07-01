const { pool } = require("../config/db");

class FsdsModel {
    constructor() {
        this._ensureTable();
    }

    async _ensureTable() {
        try {
            await pool.query(`CREATE TABLE IF NOT EXISTS fsds_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                device_id VARCHAR(100), loc_id VARCHAR(100), loc_name VARCHAR(255),
                asset_id VARCHAR(100), asset_name VARCHAR(255),
                fire_status INT DEFAULT 0, smoke_level INT DEFAULT 0,
                timestamp VARCHAR(50),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_device_id (device_id), INDEX idx_timestamp (timestamp)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4`);
        } catch (err) {
            console.error("FSDS ensure table error:", err.message);
        }
    }

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