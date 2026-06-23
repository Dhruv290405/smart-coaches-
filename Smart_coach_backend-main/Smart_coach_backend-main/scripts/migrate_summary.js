const mysql = require('mysql2/promise');

async function migrateData() {
    let pool;
    try {
        pool = mysql.createPool({
            host: 'metro.proxy.rlwy.net',
            user: 'root', 
            password: 'ohgVacOJKaZvIimafPAsEzPaTImTqzmK',
            database: 'railway', 
            port: 58130, 
            ssl: { rejectUnauthorized: false }
        });

        console.log("Migration start...");

        // TRUNCATE ke bajaye hum direct upsert (INSERT...ON DUPLICATE) karenge 
        // taaki data consistency bani rahe.
        const query = `
    INSERT INTO device_live_summary 
    (tech_coach_no, today_count, total_count, last_trigger, last_heartbeat)
    SELECT 
        dm.tech_coach_no,
        -- Hum JSON_TABLE ka use karke 'value' nikalenge jahan name matching ho
        (SELECT val.value FROM JSON_TABLE(il.data, '$.assets[*].metrics.values[*]' COLUMNS(name VARCHAR(100) PATH '$.name', value INT PATH '$.value')) AS val WHERE val.name LIKE 'COUNT-LIGHT-COUNTS-3' LIMIT 1),
        (SELECT val.value FROM JSON_TABLE(il.data, '$.assets[*].metrics.values[*]' COLUMNS(name VARCHAR(100) PATH '$.name', value INT PATH '$.value')) AS val WHERE val.name LIKE 'TOTALIZED_COUNT-LIGHT-COUNTS-4' LIMIT 1),
        il.created_at,
        il.created_at
    FROM (SELECT DISTINCT tech_coach_no FROM device_master) AS dm
    INNER JOIN iot_logs il ON dm.tech_coach_no = il.tech_coach_no_virtual
    WHERE il.id = (
        SELECT MAX(id) FROM iot_logs il2 
        WHERE il2.tech_coach_no_virtual = dm.tech_coach_no
    )
    ON DUPLICATE KEY UPDATE 
        today_count = COALESCE(VALUES(today_count), today_count),
        total_count = COALESCE(VALUES(total_count), total_count),
        last_trigger = VALUES(last_trigger),
        last_heartbeat = VALUES(last_heartbeat)
`;

        await pool.query(query);

        console.log("Migration complete!");
        await pool.end();
        process.exit();
    } catch (error) {
        console.error("Migration error:", error);
        if (pool) await pool.end();
        process.exit(1);
    }
}

migrateData();