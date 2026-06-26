const { pool } = require("../config/db");

class HotAxleModel {
    // 1. POST API logic: Dynamic Insert
    async saveDynamicLog(data) {
        const keysArray = Object.keys(data);
        const valuesArray = Object.values(data);

        const columns = keysArray.join(", ");
        const placeholders = keysArray.map(() => "?").join(", ");

        const query = `INSERT INTO hot_axle_logs (${columns}) VALUES (${placeholders})`;

        try {
            const [result] = await pool.query(query, valuesArray);
            return result.insertId;
        } catch (err) {
            console.error("Database Dynamic Insert Error:", err.message);
            throw err;
        }
    }

    // 2. GET API logic: Fetch data by linking logs -> device_master -> coaches
    async getData(deviceId, limit) {
        
        let query = `
            SELECT 
                l.*, 
                dm.tech_coach_no, 
                c.train_id AS train_no 
            FROM hot_axle_logs l
            LEFT JOIN device_master dm ON l.device_id = dm.device_id
            LEFT JOIN coaches c ON dm.tech_coach_no = c.coach_number
        `;
        let params = [];

        if (deviceId) {
            query += " WHERE l.device_id = ?";
            params.push(deviceId);
        }

        query += " ORDER BY l.timestamp DESC LIMIT ?";
        params.push(limit);

        try {
            const [rows] = await pool.query(query, params);
            return rows;
        } catch (err) {
            console.error("Database Select Error:", err.message);
            throw err;
        }
    }

    async getHistoryData({ deviceId, coachNumber, startDate, endDate, limit, offset }) {
    // Base Query with COALESCE to handle NULLs gracefully
    let query = `
        SELECT 
            l.id, l.device_id, l.coach_number, l.coach_type, l.owning_rly, 
            l.timestamp, l.alert_status, l.a11_temp, l.a12_temp, l.a21_temp, 
            l.a22_temp, l.a31_temp, l.a32_temp, l.a41_temp, l.a42_temp, 
            l.battery_percentage, l.signal_strength,
            COALESCE(dm.tech_coach_no, 'Not Mapped') AS tech_coach_no, 
            COALESCE(c.train_id, 'NA') AS train_no 
        FROM hot_axle_logs l
        LEFT JOIN device_master dm ON l.device_id = dm.device_id
        LEFT JOIN coaches c ON dm.tech_coach_no = c.coach_number
        WHERE 1=1
    `;
    let params = [];

    // Filter Logic: Agar value "All" hai ya empty hai toh skip karega
    if (deviceId && deviceId !== 'All') {
        query += " AND l.device_id = ?";
        params.push(deviceId);
    }

    if (coachNumber && coachNumber !== 'All') {
        // Dono jagah check karega: logs table aur mapping table
        query += " AND (l.coach_number = ? OR dm.tech_coach_no = ?)";
        params.push(coachNumber, coachNumber);
    }

    if (startDate && endDate) {
        query += " AND l.timestamp BETWEEN ? AND ?";
        params.push(`${startDate} 00:00:00`, `${endDate} 23:59:59`);
    }

    // Sorting and Pagination
    query += " ORDER BY l.timestamp DESC LIMIT ? OFFSET ?";
    params.push(parseInt(limit), parseInt(offset));

    try {
        const [rows] = await pool.query(query, params);
        
        // Count query for pagination meta-data
        const [countResult] = await pool.query("SELECT COUNT(*) as total FROM hot_axle_logs");
        
        return { data: rows, total: countResult[0].total };
    } catch (err) {
        console.error("History Model Error:", err.message);
        throw err;
    }
}   

    async getLatestStatusForAllCoaches() {
    const query = `
        SELECT 
            l.id, l.device_id, l.coach_number, l.coach_type, l.owning_rly, 
            l.timestamp, l.alert_status, l.a11_temp, l.a12_temp, l.a21_temp, 
            l.a22_temp, l.a31_temp, l.a32_temp, l.a41_temp, l.a42_temp, 
            l.battery_percentage, l.signal_strength
        FROM hot_axle_logs l
        INNER JOIN (
            SELECT MAX(id) as latest_id 
            FROM hot_axle_logs 
            GROUP BY device_id
        ) latest_logs ON l.id = latest_logs.latest_id
        ORDER BY l.timestamp DESC
    `;

    try {
        const [rows] = await pool.query(query);
        return rows;
    } catch (err) {
        console.error("Dashboard Status Error:", err.message);
        throw err;
    }
}

}

module.exports = new HotAxleModel();