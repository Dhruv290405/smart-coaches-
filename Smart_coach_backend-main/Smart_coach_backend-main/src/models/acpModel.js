const { pool } = require('../config/db');
const BLOCKED_COACH = '205063';

const AcpModel = {
    updateLiveStatus: async (data, type) => {
        try {

            const [latestHistory] = await pool.query(
                `SELECT MAX(total_count) as total, 
             (SELECT COUNT(DISTINCT total_count) FROM acp_critical_events 
              WHERE tech_coach_no = ? AND DATE(event_time) = CURDATE()) as today 
             FROM acp_critical_events WHERE tech_coach_no = ?`,
                [data.tech_coach_no, data.tech_coach_no]
            );

            const totalCount = latestHistory[0].total || data.total_count;
            const todayCount = latestHistory[0].today || data.today_count;

            const isPulled = todayCount > 0 ? 'Pulled' : 'Not Pulled';
            const isTrigger = (type === 'TRIGGER');

            const query = `
            INSERT INTO device_live_summary 
            (tech_coach_no, last_heartbeat, last_trigger, today_count, total_count, status)
            VALUES (?, NOW(), IF(? = 1, NOW(), NULL), ?, ?, ?)
            ON DUPLICATE KEY UPDATE 
                total_count = VALUES(total_count),
                today_count = VALUES(today_count),
                last_heartbeat = NOW(),
                last_trigger = IF(? = 1, NOW(), last_trigger),
                status = VALUES(status);
        `;

            const params = [
                data.tech_coach_no,
                isTrigger ? 1 : 0,
                todayCount,
                totalCount,
                isPulled,
                isTrigger ? 1 : 0,
                isPulled
            ];

            await pool.query(query, params);

        } catch (error) {
            console.error("Error in AcpModel.updateLiveStatus:", error.message);
            throw error;
        }
    },
    // AcpModel mein ye function add karo
    getBlockedCoaches: async () => {
        try {
            const [rows] = await pool.query('SELECT tech_coach_no FROM blocked_devices');
            // Sirf IDs ka array return karega [ '171806', '182941/C', ... ]
            return rows.map(row => row.tech_coach_no);
        } catch (error) {
            console.error("Error fetching blocked devices:", error.message);
            return [];
        }
    },

    saveLatestHeartbeat: async (data) => {
        try {
            const query = `
                INSERT INTO device_latest_status (tech_coach_no, data, last_updated)
                VALUES (?, ?, NOW())
                ON DUPLICATE KEY UPDATE data = VALUES(data), last_updated = NOW();
            `;
            await pool.query(query, [data.tech_coach_no, JSON.stringify(data)]);
        } catch (error) {
            console.error("Error in AcpModel.saveLatestHeartbeat:", error.message);
            throw error;
        }
    },
    // 1. For getting all logs     
    getAllLogs: async () => {
        try {
            const query = `
                SELECT 
                    id AS log_id,
                    created_at AS last_updated,
                    raw_asset_name,
                    acp_status,
                    total_count,
                    train_location,
                    train_no,
                    comm_coach_no,
                    tech_coach_no,
                    power_car_no
                FROM acp_critical_events
                WHERE tech_coach_no != ? 
                ORDER BY created_at DESC 
                LIMIT 100;
            `;
            const [rows] = await pool.query(query, [BLOCKED_COACH]);
            return rows;
        } catch (error) {
            console.error("Error in AcpModel.getAllLogs:", error.message);
            throw error;
        }
    },

    // 2. AWS Data Save karte waqt Mapping ke liye (With Fail-safe)
    getTrainByMapping: async (deviceId, techCoachNo) => {
        try {
            const query = `
                SELECT train_no 
                FROM device_master 
                WHERE device_id = ? OR tech_coach_no = ? 
                LIMIT 1
            `;
            const [rows] = await pool.query(query, [deviceId, techCoachNo]);
            return rows[0] || null;
        } catch (error) {
            console.error("Error in AcpModel.getTrainByMapping:", error.message);
            throw error;
        }
    },

    // 3. Normal Heartbeat save karne ke liye (Ab alag columns mein structured save hoga)
    saveHeartbeat: async (data) => {
        try {
            const query = `
                INSERT INTO acp_heartbeat_logs 
                (train_location, raw_asset_name, acp_status, total_count, msg_type, train_no, comm_coach_no, tech_coach_no, power_car_no) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            `;
            const [result] = await pool.query(query, [
                data.train_location, data.raw_asset_name, data.acp_status, data.total_count,
                data.msg_type, data.train_no, data.comm_coach_no, data.tech_coach_no, data.power_car_no
            ]);
            return result.insertId;
        } catch (error) {
            console.error("Error in AcpModel.saveHeartbeat:", error.message);
            throw error;
        }
    },

    saveCriticalEvent: async (data) => {
        if (data.acp_status !== 1) return null;

        try {

            const checkQuery = `SELECT total_count FROM acp_critical_events 
                            WHERE tech_coach_no = ? ORDER BY id DESC LIMIT 1`;
            const [existing] = await pool.query(checkQuery, [data.tech_coach_no]);

            if (existing.length > 0 && data.total_count <= existing[0].total_count) {
                console.log(`Skipping duplicate/old event for coach ${data.tech_coach_no}`);
                return null;
            }

            const insertQuery = `
            INSERT INTO acp_critical_events 
            (train_location, raw_asset_name, acp_status, total_count, train_no, tech_coach_no, power_car_no, event_time) 
            VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
        `;
            const [result] = await pool.query(insertQuery, [
                data.train_location, data.raw_asset_name, data.acp_status,
                data.total_count, data.train_no, data.tech_coach_no, data.power_car_no
            ]);
            return result.insertId;
        } catch (error) {
            console.error("Error in AcpModel.saveCriticalEvent:", error.message);
            throw error;
        }
    },

    // 5. Unique Trains ki list (Dropdown 1)
    getUniqueTrains: async () => {
        try {
            const query = `SELECT DISTINCT train_no FROM device_master WHERE train_no IS NOT NULL ORDER BY train_no ASC`;
            const [rows] = await pool.query(query);
            return rows;
        } catch (error) {
            throw new Error("Error fetching unique trains: " + error.message);
        }
    },

    // 6. Selected Train ke liye Coach Types (Dropdown 2)
    getCoachTypesByTrain: async (trainNo) => {
        try {
            const query = `
                SELECT DISTINCT 
                    COALESCE(cm.coach_display_id, dm.comm_coach_no) AS comm_coach_no
                FROM device_master dm
                LEFT JOIN train_master tm ON dm.train_no = tm.train_number
                LEFT JOIN coach_master cm ON tm.train_id = cm.train_id AND dm.tech_coach_no = cm.coach_unique_id
                WHERE dm.train_no = ? 
                ORDER BY comm_coach_no ASC
            `;
            const [rows] = await pool.query(query, [trainNo]);
            return rows;
        } catch (error) {
            throw new Error("Error fetching coach types: " + error.message);
        }
    },

    // 7. Selected Train aur Coach Type ke liye specific Coach Numbers (Dropdown 3)
    getCoachNumbers: async (trainNo, coachType) => {
        try {
            const query = `SELECT DISTINCT tech_coach_no FROM device_master WHERE train_no = ? AND comm_coach_no = ? AND tech_coach_no != ? ORDER BY tech_coach_no ASC`;
            const [rows] = await pool.query(query, [trainNo, coachType, BLOCKED_COACH]);
            return rows;
        } catch (error) {
            throw new Error("Error fetching coach numbers: " + error.message);
        }
    },

    getSummaryLogs: async () => {
        try {
            const query = `
            SELECT 
                dm.train_no, 
                COALESCE(cm.coach_display_id, dm.comm_coach_no) AS comm_coach_no,
                dm.tech_coach_no, 
                dm.device_id,
                DATE_FORMAT(CONVERT_TZ(dls.last_heartbeat, '+00:00', '+05:30'), '%Y-%m-%d %H:%i:%s') AS last_heartbeat,
                DATE_FORMAT(CONVERT_TZ(dls.last_trigger, '+00:00', '+05:30'), '%Y-%m-%d %H:%i:%s') AS last_trigger,
                COALESCE(dls.today_count, 0) AS today_count,
                COALESCE(dls.total_count, 0) AS total_count,
                (SELECT train_location FROM acp_critical_events 
                 WHERE tech_coach_no = dm.tech_coach_no 
                 ORDER BY id DESC LIMIT 1) AS train_location,
                CASE 
                    WHEN COALESCE(dls.today_count, 0) = 0 THEN 'Not Pulled'
                    ELSE COALESCE(dls.status, 'Not Pulled')
                END AS status
            FROM device_master dm
            LEFT JOIN device_live_summary dls ON dm.tech_coach_no = dls.tech_coach_no
            LEFT JOIN train_master tm ON dm.train_no = tm.train_number
            LEFT JOIN coach_master cm ON tm.train_id = cm.train_id AND dm.tech_coach_no = cm.coach_unique_id
            WHERE dm.tech_coach_no != ?
            ORDER BY dm.train_no ASC, comm_coach_no ASC;
        `;

            const [rows] = await pool.query(query, [BLOCKED_COACH]);
            return rows;
        } catch (error) {
            console.error("Error in getSummaryLogs:", error.message);
            throw error;
        }
    },

    getCoachAcpHistory: async (techCoachNo, startDate, endDate, limit = 100, offset = 0) => {
        try {
            if (techCoachNo === BLOCKED_COACH) return [];

            let dateFilter = "";
            let dateParams = [];

            if (startDate && endDate) {
                dateFilter = ` AND event_time BETWEEN ? AND ? `;
                dateParams = [`${startDate} 00:00:00`, `${endDate} 23:59:59`];
            }

            const query = `
            SELECT 
                id AS log_id,
                DATE_FORMAT(CONVERT_TZ(event_time, '+00:00', '+05:30'), '%Y-%m-%d %H:%i:%s') AS event_time,
                acp_status,
                train_location,
                raw_asset_name,
                total_count AS history_sequence_no,
                /* Summary Table se Lifetime Pulls */
                COALESCE((SELECT total_count FROM device_live_summary WHERE tech_coach_no = ?), 0) AS total_lifetime_pulls,
                /* FIX: COALESCE use kiya taaki NULL ki jagah 0 aaye */
                COALESCE((SELECT today_count FROM device_live_summary WHERE tech_coach_no = ?), 0) AS today_pulls_count
            FROM acp_critical_events 
            WHERE tech_coach_no = ?
            ${dateFilter}
            ORDER BY id DESC 
            LIMIT ? OFFSET ?;
        `;

            const queryParams = [
                techCoachNo,
                techCoachNo,
                techCoachNo,
                ...dateParams,
                parseInt(limit),
                parseInt(offset)
            ];

            const [rows] = await pool.query(query, queryParams);
            return rows;
        } catch (error) {
            console.error("Error in getCoachAcpHistory:", error.message);
            throw error;
        }
    },

  getFilteredLogs: async (trainNo, techCoachNo) => {
    try {
        const query = `
            SELECT 
                dm.train_no, 
                COALESCE(cm.coach_display_id, dm.comm_coach_no) AS comm_coach_no, 
                dm.tech_coach_no, 
                dm.device_id,
                DATE_FORMAT(CONVERT_TZ(dls.last_heartbeat, '+00:00', '+05:30'), '%Y-%m-%d %H:%i:%s') AS last_heartbeat,
                DATE_FORMAT(CONVERT_TZ(dls.last_trigger, '+00:00', '+05:30'), '%Y-%m-%d %H:%i:%s') AS last_trigger,
                COALESCE(dls.today_count, 0) AS today_count,
                COALESCE(dls.total_count, 0) AS total_count,
                (SELECT train_location FROM acp_critical_events 
                 WHERE tech_coach_no = dm.tech_coach_no 
                 ORDER BY id DESC LIMIT 1) AS train_location,
                CASE 
                    WHEN COALESCE(dls.today_count, 0) = 0 THEN 'Not Pulled'
                    ELSE COALESCE(dls.status, 'Not Pulled')
                END AS status
            FROM device_master dm
            LEFT JOIN device_live_summary dls ON dm.tech_coach_no = dls.tech_coach_no
            LEFT JOIN train_master tm ON dm.train_no = tm.train_number
            LEFT JOIN coach_master cm ON tm.train_id = cm.train_id AND dm.tech_coach_no = cm.coach_unique_id
            WHERE dm.train_no = ? 
            AND dm.tech_coach_no = ?;
        `;
        
        const [rows] = await pool.query(query, [trainNo, techCoachNo]);
        return rows;
    } catch (error) {
        throw new Error("Error fetching filtered logs: " + error.message);
    }
}
};

module.exports = AcpModel;