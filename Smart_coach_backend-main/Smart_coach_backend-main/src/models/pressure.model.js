const { pool } = require("../config/db");

class PressureModel {
    async saveDynamicLog(data) {
        const keysArray = Object.keys(data);
        const valuesArray = Object.values(data);

        const columns = keysArray.join(", ");
        const placeholders = keysArray.map(() => "?").join(", ");

        const query = `INSERT INTO pressure_logs (${columns}) VALUES (${placeholders})`;

        try {
            const [result] = await pool.query(query, valuesArray);
            return result.insertId;
        } catch (err) {
            console.error("Pressure Model Save Error:", err.message);
            throw err;
        }
    }

    // 2. Function to fetch raw data (Latest readings for history/logs)
    async getLatestData(deviceId = null, limit = 30) {
        try {
            let query = `SELECT * FROM pressure_logs`;
            let params = [];

            if (deviceId) {
                query += ` WHERE device_id = ?`;
                params.push(deviceId);
            }

            query += ` ORDER BY timestamp DESC LIMIT ?`;
            params.push(limit);

            const [rows] = await pool.query(query, params);
            return rows;
        } catch (err) {
            console.error("Pressure Model Fetch Error:", err.message);
            throw err;
        }
    }

    // 3. Dashboard Status - OPTIMIZED FOR ALL DEVICES (NO BLOCKLIST)
    async getDashboardStatus() {
        const query = `
            SELECT 
                p.*
            FROM pressure_logs p
            INNER JOIN (
                SELECT coach_number, MAX(id) as latest_id 
                FROM pressure_logs 
                WHERE coach_number IS NOT NULL AND coach_number != ''
                GROUP BY coach_number
            ) latest_logs ON p.id = latest_logs.latest_id
            ORDER BY p.timestamp DESC
        `;

        try {
            const [rows] = await pool.query(query);
            return rows;
        } catch (err) {
            console.error("Pressure Dashboard Model Error:", err.message);
            throw err;
        }
    }

    // 4. Filtered History - FIXED ALL CRASH BUGS & DYNAMIC COUNT
    async getFilteredHistory(filters) {
        const { coachNumber, startDate, endDate, limit = 10, offset = 0 } = filters;
        
        let conditions = ` WHERE 1=1`;
        let params = [];

        if (coachNumber) {
            conditions += ` AND coach_number = ?`;
            params.push(coachNumber);
        }

        if (startDate && endDate) {
            conditions += ` AND timestamp BETWEEN ? AND ?`;
            params.push(`${startDate} 00:00:00`, `${endDate} 23:59:59`);
        } else if (startDate) {
            conditions += ` AND timestamp >= ?`;
            params.push(`${startDate} 00:00:00`);
        }

        const query = `SELECT * FROM pressure_logs ${conditions} ORDER BY timestamp DESC LIMIT ${parseInt(limit)} OFFSET ${parseInt(offset)}`;
        
        const countQuery = `SELECT COUNT(*) as total FROM pressure_logs ${conditions}`;
        
        try {
            const [rows] = await pool.query(query, params);
            const [countResult] = await pool.query(countQuery, params); // Same params pass kiye taaki query match kare
            
            return {
                data: rows,
                total: countResult[0]?.total || 0
            };
        } catch (err) {
            console.error("Pressure History Filter Error:", err.message);
            throw err;
        }
    }
}

module.exports = new PressureModel();