require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const { testConnection, pool } = require('./src/config/db');
const { errorResponse } = require('./src/utils/response');
const { createServer } = require('http');
const { Server } = require('socket.io');
const sensorRoutes = require('./src/routes/sensor_data.routes');
const pneumaticRoutes = require('./src/routes/pneumatic.routes');
const hotAxleRoutes = require('./src/routes/hotAxle.routes');
const pressureRoutes = require('./src/routes/pressure.routes');
const acpRoutes = require('./src/routes/ACP.routes'); 
const notificationRoutes = require('./src/routes/notification.routes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors({ origin: true, credentials: true }));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true, parameterLimit: 50000 }));

// Logging middleware (only in development)
if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('dev'));
}

const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: { origin: "*" }
});

//  Store io instance globally
global._io = io;

// API Routes
app.use('/smart_coach_api/api/auth', require('./src/routes/auth.routes'));
app.use('/smart_coach_api/api/masters', require('./src/routes/master.routes'));
app.use('/smart_coach_api/api/trains', require('./src/routes/train.routes'));
app.use('/smart_coach_api/api/roles', require('./src/routes/roles.routes'));
app.use('/smart_coach_api/api/coaches', require('./src/routes/coach.routes'));
app.use('/smart_coach_api/api/master-modules', require('./src/routes/master-module.routes'));
app.use('/smart_coach_api/api/coach-makes', require('./src/routes/coach_make.routes'));
app.use('/smart_coach_api/api/coach-types', require('./src/routes/coach_type.routes'));
app.use('/smart_coach_api/api/devices', require('./src/routes/device.routes'));
app.use('/smart_coach_api/api/sensors', require('./src/routes/sensor.routes'));
app.use('/smart_coach_api/api/sensors-make', require('./src/routes/sensor_make.routes'));
app.use('/smart_coach_api/api/sensors-config', require('./src/routes/sensor_config.routes'));
app.use('/smart_coach_api/api/rules', require('./src/routes/rules.routes'));
app.use('/smart_coach_api/api/regions', require('./src/routes/regions.routes'));
app.use('/smart_coach_api/api/stations', require('./src/routes/stations.routes'));
app.use('/smart_coach_api/api/iot_water_level', require('./src/routes/iot_water_level.routes'));
app.use('/smart_coach_api/api/iot_odour', require('./src/routes/iot_odour.routes'));
app.use('/smart_coach_api/api/fcm', require('./src/routes/fcm_token.routes'));
app.use('/smart_coach_api/api/acp', acpRoutes);
app.use('/smart_coach_api/api/pneumatic', pneumaticRoutes);
app.use('/smart_coach_api/api/hot-axle', hotAxleRoutes);
app.use('/smart_coach_api/api/pressure', pressureRoutes);
app.use('/smart_coach_api/api/sensor_data', sensorRoutes(io));
app.use("/smart_coach_api/api/wli", require("./src/routes/wli.routes"));
app.use("/smart_coach_api/api/odour-logs", require("./src/routes/odour.routes"));
app.use("/smart_coach_api/api/fsds", require("./src/routes/fsds.routes"));
app.use("/smart_coach_api/api/coach-config", require("./src/routes/coachConfig.routes.js"));
app.use('/smart_coach_api/api/notifications', notificationRoutes);
app.use('/smart_coach_api/api/diesel', require('./src/routes/diesel.routes'));
// Test routes
app.get('/test', async (req, res) => {
  let dbStatus = 'not checked';
  let dbHost = process.env.MYSQLHOST || 'not set';
  let wliCount = 0;
  let tables = [];
  let userCount = 0;
  let pwExists = false;
  try {
    const connection = await pool.getConnection();
    dbStatus = 'connected';
    const [rows] = await connection.query("SELECT COUNT(*) as cnt FROM wli_logs");
    wliCount = rows[0].cnt;
    const [tbls] = await connection.query("SHOW TABLES");
    tables = tbls.map(r => Object.values(r)[0]);
    try { const [u] = await connection.query("SELECT COUNT(*) as total, SUM(password_hash IS NOT NULL) as with_pw FROM user_master"); userCount = u[0].total + ' users, ' + u[0].with_pw + ' with pw'; pwExists = u[0].with_pw > 0; } catch (_) { userCount = 'err'; }
    connection.release();
  } catch (e) {
    dbStatus = 'failed: ' + e.message;
  }
  res.json({ status: 'Test route works!', db: dbStatus, host: dbHost, wliLogs: wliCount, tables: tables, users: userCount, pwSet: pwExists });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', message: 'Server is running' });
});
app.get('/db-data', async (req, res) => {
  try {
    const conn = await pool.getConnection();
    const [tbls] = await conn.query("SHOW TABLES");
    const tables = tbls.map(r => Object.values(r)[0]);
    const info = {};
    for (const t of tables) {
      const [cnt] = await conn.query(`SELECT COUNT(*) as c FROM \`${t}\``);
      info[t] = cnt[0].c;
    }
    conn.release();
    res.json({ tables: info });
  } catch (e) { res.json({ error: e.message }); }
});

// In-memory migration log (for debugging)
let migrateLog = [];
const logR = (msg) => { migrateLog.push('[' + new Date().toISOString().slice(11,19) + '] ' + msg); console.log('[MIGRATE] ' + msg); };

app.get('/migrate-log', (req, res) => res.json(migrateLog.slice(-100)));

// --- MASTER DATA MIGRATION (one-time trigger, runs async) ---
app.post('/migrate-all', (req, res) => {
  res.json({ status: 'Migration started in background, check server logs' });
  migrateLog = [];

  (async () => {
    const OLD = 'https://smart-coach-api-production.up.railway.app/smart_coach_api/api';
    const LOGIN = { email: 'tester@example.com', password: '123456' };

    let token;
    try {
      const r = await fetch(OLD + '/auth/login', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(LOGIN) });
      const j = await r.json(); token = j.data.token;
      logR('Login OK');
    } catch (e) { logR('Login FAILED: ' + e.message); return; }

    const GET = async (path) => {
      const r = await fetch(OLD + path, { headers: { Authorization: 'Bearer ' + token } });
      if (!r.ok) { logR(`GET ${path} FAILED ${r.status}`); return null; }
      const body = await r.json();
      let data = body.data || body;
      if (data && data.items && Array.isArray(data.items)) data = data.items;
      else if (data && data.regions && Array.isArray(data.regions)) data = data.regions;
      else if (data && data.stations && Array.isArray(data.stations)) data = data.stations;
      return data;
    };

    const q = (s) => '`' + s.replace(/`/g, '') + '`';
    const dropKeys = ['created_by_name', 'updated_by_name', 'make_of_coach_name', 'type_of_coach_code', 'master_module_ids', 'master_module_locations'];

    const insertData = async (table, rows) => {
      if (!rows || !rows.length) { logR(`${table}: 0 rows`); return; }
      const cols = Object.keys(rows[0]).filter(k => !dropKeys.includes(k));
      const ph = cols.map(() => '?').join(',');
      const cn = cols.map(q).join(',');
      let ok = 0, fail = 0;
      for (const row of rows) {
        const vals = cols.map(c => row[c] === undefined || row[c] === null ? null : String(row[c]));
        try { await pool.query(`INSERT IGNORE INTO \`${table}\` (${cn}) VALUES (${ph})`, vals); ok++; }
        catch (e) { fail++; if (fail <= 2) logR(`${table} err: ${e.message}`); }
      }
      logR(`${table}: ${ok} OK, ${fail} failed`);
    };

    const createTable = async (name, sample) => {
      if (!sample) return;
      const cols = Object.keys(sample).filter(k => !dropKeys.includes(k)).map(k => `\`${k}\` VARCHAR(255)`).join(', ');
      try { await pool.query(`CREATE TABLE IF NOT EXISTS \`${name}\` (${cols})`); }
      catch (e) { logR(`${name} create err: ${e.message}`); }
    };

    const migrate = async (name, path) => {
      logR(`Fetching ${name}...`);
      const d = await GET(path);
      if (d) { await createTable(name, d[0]); await insertData(name, d); }
    };

    logR('--- Starting Master Data Migration ---');

    // Static schema tables (include all tables referenced by JOINs)
    for (const [sql] of [
      [`CREATE TABLE IF NOT EXISTS zone_master (zone_id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100), is_active TINYINT DEFAULT 1)`],
      [`CREATE TABLE IF NOT EXISTS division_master (division_id INT PRIMARY KEY AUTO_INCREMENT, zone_id INT, name VARCHAR(100), is_active TINYINT DEFAULT 1)`],
      [`CREATE TABLE IF NOT EXISTS role_master (role_id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100), is_active TINYINT DEFAULT 1)`],
      [`CREATE TABLE IF NOT EXISTS coach_make (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100))`],
      [`CREATE TABLE IF NOT EXISTS coach_type (id INT PRIMARY KEY AUTO_INCREMENT, code VARCHAR(50), name VARCHAR(100))`],
      [`CREATE TABLE IF NOT EXISTS sensor_make (sensor_make_id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100))`],
      [`CREATE TABLE IF NOT EXISTS region_master (region_id INT PRIMARY KEY AUTO_INCREMENT, division_id INT, name VARCHAR(100), is_active TINYINT DEFAULT 1, code VARCHAR(50))`],
      [`CREATE TABLE IF NOT EXISTS user_train_mapping (id INT PRIMARY KEY AUTO_INCREMENT, user_id INT, train_id INT)`],
      [`CREATE TABLE IF NOT EXISTS user_region_mapping (id INT PRIMARY KEY AUTO_INCREMENT, user_id INT, region_id INT)`],
      [`CREATE TABLE IF NOT EXISTS user_master (user_id INT PRIMARY KEY AUTO_INCREMENT, first_name VARCHAR(100), last_name VARCHAR(100), email VARCHAR(100), mobile_number VARCHAR(20), gender VARCHAR(20), organisation_type VARCHAR(100), organisation_name VARCHAR(100), zone_id INT, division_id INT, region_id INT, role_id INT, status VARCHAR(20) DEFAULT 'Active', approval_status VARCHAR(20) DEFAULT 'Approved', employee_id VARCHAR(50), pan_card_no VARCHAR(50), aadhar_no VARCHAR(50), company_id VARCHAR(50), created_date VARCHAR(50), updated_date VARCHAR(50), role_name VARCHAR(100), zone_name VARCHAR(100), division_name VARCHAR(100), region_name VARCHAR(100), password_hash VARCHAR(255))`],
    ]) { try { await pool.query(sql); } catch (_) {} }

    // Drop problem tables so dynamic createTable re-creates with correct columns
    for (const t of ['zone_master', 'division_master', 'region_master', 'role_master',
      'coach_make', 'coach_type', 'sensor_make', 'stations', 'coach_master']) {
      try { await pool.query(`DROP TABLE IF EXISTS \`${t}\``); } catch (_) {}
    }
    // Create tables needed by queries but not populated from API
    for (const sql of [
      `CREATE TABLE IF NOT EXISTS master_module (module_id INT PRIMARY KEY AUTO_INCREMENT, coach_id INT, module_unique_id VARCHAR(255), location VARCHAR(255), seriel_number VARCHAR(255))`,
      `CREATE TABLE IF NOT EXISTS module_device_mapping (id INT PRIMARY KEY AUTO_INCREMENT, module_id INT, device_id INT)`,
      `CREATE TABLE IF NOT EXISTS value_type_master (value_type_id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100))`,
      `CREATE TABLE IF NOT EXISTS unit_master (unit_id INT PRIMARY KEY AUTO_INCREMENT, unit VARCHAR(50))`,
      `CREATE TABLE IF NOT EXISTS sensor_unit_mapping (id INT PRIMARY KEY AUTO_INCREMENT, sensor_id INT, unit_id INT)`,
      `CREATE TABLE IF NOT EXISTS sensor_device_mapping (id INT PRIMARY KEY AUTO_INCREMENT, sensor_id INT, device_id INT)`,
      `CREATE TABLE IF NOT EXISTS rule_device_mapping (id INT PRIMARY KEY AUTO_INCREMENT, rule_id INT, device_id INT)`,
      `CREATE TABLE IF NOT EXISTS rule_sensor_mapping (id INT PRIMARY KEY AUTO_INCREMENT, rule_id INT, sensor_type_id INT)`,
      `CREATE TABLE IF NOT EXISTS rule_condition_master (condition_id INT PRIMARY KEY AUTO_INCREMENT, rule_id INT, value_type_id INT, value_format VARCHAR(50), connector VARCHAR(50), alert_message_template TEXT, si_unit_id INT, alert_type_id INT)`,
      `CREATE TABLE IF NOT EXISTS rule_sub_condition (sub_condition_id INT PRIMARY KEY AUTO_INCREMENT, condition_id INT, field VARCHAR(100), operator VARCHAR(20), value VARCHAR(255), sort_order INT)`,
      `CREATE TABLE IF NOT EXISTS alert_type_master (alert_type_id INT PRIMARY KEY AUTO_INCREMENT, alert_type_name VARCHAR(100))`,
      `CREATE TABLE IF NOT EXISTS train_coach_mapping (id INT PRIMARY KEY AUTO_INCREMENT, train_id INT, coach_id INT)`,
      `CREATE TABLE IF NOT EXISTS coaches (id INT PRIMARY KEY AUTO_INCREMENT, coach_number VARCHAR(50), train_id INT)`,
      `CREATE TABLE IF NOT EXISTS device_type (id INT PRIMARY KEY AUTO_INCREMENT, full_name VARCHAR(100), short_name VARCHAR(50))`,
    ]) { try { await pool.query(sql); logR('Table created: ' + (sql.split('`')[1] || '?')); } catch (e) { logR('Table creation err: ' + e.message); } }

    // Fetch and insert — order matters (zones before divisions before regions)
    for (const [name, path] of [
      ['zone_master', '/masters/zones'], ['role_master', '/masters/roles'],
      ['coach_make', '/coach-makes'], ['coach_type', '/coach-types'],
      ['sensor_make', '/sensors-make'], ['train_master', '/trains'],
      ['device_master', '/devices'],
      ['sensor_master', '/sensors'], ['sensor_config', '/sensors-config'],
      ['rule_master', '/rules'], ['stations', '/stations'],
    ]) { await migrate(name, path); }

    // Coaches: rename columns before insert
    try {
      const raw = await GET('/coaches');
      if (raw && raw.length) {
        const fixed = raw.map(r => {
          const o = { ...r };
          if ('make_of_coach_id' in o) { o.make_of_coach = o.make_of_coach_id; delete o.make_of_coach_id; }
          if ('type_of_coach_id' in o) { o.type_of_coach = o.type_of_coach_id; delete o.type_of_coach_id; }
          return o;
        });
        await createTable('coach_master', fixed[0]);
        await insertData('coach_master', fixed);
      }
    } catch (e) { logR('coach_master err: ' + e.message); }

    // Divisions: iterate zones to get all divisions
    try {
      const [zones] = await pool.query("SELECT zone_id FROM zone_master");
      const allDivs = [];
      for (const z of zones) {
        const divs = await GET(`/masters/divisions?zone_id=${z.zone_id}`);
        if (divs) allDivs.push(...divs);
      }
      if (allDivs.length) { await createTable('division_master', allDivs[0]); await insertData('division_master', allDivs); }
    } catch (e) { logR('division_master err: ' + e.message); }

    // Regions: iterate divisions and also fetch /regions
    try {
      const allRegs = [];
      const regs = await GET('/regions');
      if (regs) allRegs.push(...regs);
      if (!allRegs.length) { // fallback: fetch per division
        const [divs] = await pool.query("SELECT division_id FROM division_master");
        for (const d of divs) { const r = await GET(`/masters/regions?division_id=${d.division_id}`); if (r) allRegs.push(...r); }
      }
      if (allRegs.length) { await createTable('region_master', allRegs[0]); await insertData('region_master', allRegs); }
    } catch (e) { logR('region_master err: ' + e.message); }

    // Insert tester user directly (password: 123456)
    try {
      await pool.query(`INSERT IGNORE INTO user_master (user_id, first_name, last_name, email, mobile_number, gender, organisation_type, organisation_name, zone_id, division_id, role_id, status, approval_status, employee_id, pan_card_no, aadhar_no, company_id, created_date, password_hash) VALUES (1, 'Tester', 'Backend', 'tester@example.com', '9000000000', 'Male', 'Railway', 'Indian Railways', 1, 10, 1, 'Active', 'Approved', 'EMP12345', 'ABCDE1234F', '123456789012', '1', NOW(), '\$2b\$10\$5GoOa5baUkZRMjRCAwOhbudp6n8Ww2l0DPu6vNGhMeCGg0su1cakW')`);
      logR('user_master: tester user inserted with password_hash');
    } catch (e) { logR('user insert err: ' + e.message); }

    logR('--- Migration Complete ---');
  })();
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Global error handler:', err);
  if (err.name === 'JsonWebTokenError') {
    return errorResponse(res, 'Invalid token', 401);
  }
  if (err.name === 'ValidationError') {
    return errorResponse(res, 'Validation Error', 400, err);
  }
  return errorResponse(
    res, 
    'Internal server error', 
    500, 
    process.env.NODE_ENV === 'development' ? err : {}
  );
});

// --- SIMULATION LOGIC ---

let sensorStates = {}; 

async function insertSensorData(sensorId, waterLevel) {
  try {
    const query = `
      INSERT INTO iot_water_level (sensor_id, water_level, timestamp) 
      VALUES (?, ?, NOW())
    `;
    await pool.query(query, [sensorId, waterLevel]);
    console.log(` Data Inserted -> ${sensorId}: ${waterLevel}`);
  } catch (err) {
    console.error(" DB Insertion Error:", err.message);
  }
}

async function simulateSensor(sensorId) {
  if (!sensorStates[sensorId]) {
    sensorStates[sensorId] = { 
      value: Math.floor(Math.random() * 100), 
      direction: "up" 
    };
  }

  let sensor = sensorStates[sensorId];
  let change = Math.floor(Math.random() * 10);

  if (sensor.direction === "up") {
    sensor.value += change;
    if (sensor.value >= 100) {
      sensor.value = 100;
      sensor.direction = "down";
    }
  } else {
    sensor.value -= change;
    if (sensor.value <= 0) {
      sensor.value = 0;
      sensor.direction = "up";
    }
  }

  await insertSensorData(sensorId, sensor.value);
}

function startSensorSimulation(sensorIds) {
  sensorIds.forEach(id => simulateSensor(id));
  
  setInterval(() => {
    sensorIds.forEach(id => simulateSensor(id));
  }, 15 * 60 * 1000); 
}

async function getSensorIds() {
  try {
    const [rows] = await pool.query("SELECT sensor_id FROM sensor_config WHERE sensor_type_id = 5");
    return rows.map(row => row.sensor_id);
  } catch (err) {
    console.error(" Error fetching sensor IDs:", err.message);
    return [];
  }
}



// --- SERVER STARTUP ---

const startServer = async () => {
  try {
    // 1. Database Connection Check
    const isConnected = await testConnection();
    
    if (isConnected) {
      console.log(' Database connection verified.');

      // Auto-create required tables
      const tableDefs = [
        { name: 'wli_logs', sql: `CREATE TABLE IF NOT EXISTS wli_logs (
          id INT AUTO_INCREMENT PRIMARY KEY,
          device_id VARCHAR(100), coach_id VARCHAR(50), coach_name VARCHAR(100),
          placement_type VARCHAR(50), asset_id VARCHAR(100), asset_name VARCHAR(100),
          raw_value DECIMAL(10,2), level_cm DECIMAL(10,2), volume_liters DECIMAL(10,2),
          percent_full DECIMAL(5,2), timestamp VARCHAR(50),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          INDEX idx_device_id (device_id), INDEX idx_timestamp (timestamp)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4` },
        { name: 'hot_axle_logs', sql: `CREATE TABLE IF NOT EXISTS hot_axle_logs (
          id INT AUTO_INCREMENT PRIMARY KEY,
          device_id VARCHAR(100), coach_number VARCHAR(50), coach_type VARCHAR(50),
          owning_rly VARCHAR(20), timestamp VARCHAR(50), alert_status VARCHAR(20),
          a11_temp DECIMAL(10,2), a12_temp DECIMAL(10,2),
          a21_temp DECIMAL(10,2), a22_temp DECIMAL(10,2),
          a31_temp DECIMAL(10,2), a32_temp DECIMAL(10,2),
          a41_temp DECIMAL(10,2), a42_temp DECIMAL(10,2),
          battery_percentage INT, signal_strength INT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          INDEX idx_device_id (device_id), INDEX idx_timestamp (timestamp)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4` },
        { name: 'pressure_logs', sql: `CREATE TABLE IF NOT EXISTS pressure_logs (
          id INT AUTO_INCREMENT PRIMARY KEY,
          device_id VARCHAR(100), coach_number VARCHAR(50), coach_type VARCHAR(50),
          owning_rly VARCHAR(20), train_number VARCHAR(20),
          bp_pressure DECIMAL(10,2), current_pressure DECIMAL(10,2),
          charging_time VARCHAR(50), discharging_time VARCHAR(50),
          brake_applied_time VARCHAR(50), brake_released_time VARCHAR(50),
          brake_response_time VARCHAR(50),
          battery_percentage INT, signal_strength INT,
          timestamp VARCHAR(50), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          INDEX idx_device_id (device_id), INDEX idx_timestamp (timestamp)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4` },
      ];
      for (const t of tableDefs) {
        try { await pool.query(t.sql); console.log(` ${t.name} table ready`); }
        catch (err) { console.error(` ${t.name} table creation failed:`, err.message); }
      }
      // Ensure pressure_logs has all columns from old system
      const alterCols = [
        'ALTER TABLE pressure_logs ADD COLUMN bp_pressure DECIMAL(10,2)',
        'ALTER TABLE pressure_logs ADD COLUMN current_pressure DECIMAL(10,2)',
        'ALTER TABLE pressure_logs ADD COLUMN charging_time VARCHAR(50)',
        'ALTER TABLE pressure_logs ADD COLUMN discharging_time VARCHAR(50)',
        'ALTER TABLE pressure_logs ADD COLUMN brake_response_time VARCHAR(50)',
      ];
      for (const a of alterCols) {
        try { await pool.query(a); console.log(`  ALTER: column added`); } catch (_) {}
      }

      // 2. Start Simulation only if DB is ready
      const sensorIds = await getSensorIds();
      if (sensorIds.length > 0) {
        startSensorSimulation(sensorIds);
        console.log(" Simulation started for IDs:", sensorIds);
      } else {
        console.log(" No active sensors found in DB for simulation.");
      }

    } else {
      console.error(' Critical: Database connection failed. Simulation skipped.');
    }
    
    // 3. Start Express Server
    const server = httpServer.listen(PORT, () => {
      console.log(`\nServer live: http://localhost:${PORT}`);
      console.log(`Env: ${process.env.NODE_ENV || 'production'}`);
      // Railway compatibility logs
      console.log(`🔌 DB Config: ${process.env.MYSQLHOST || 'N/A'}:${process.env.MYSQLPORT || 3306}/${process.env.MYSQLDATABASE || 'N/A'}`);
    });

    server.on('error', (error) => {
      if (error.code === 'EADDRINUSE') {
        console.error(`Port ${PORT} is busy.`);
      } else {
        console.error('Server crash:', error);
      }
      process.exit(1);
    });

  } catch (error) {
    console.error(' Startup failed:', error);
    process.exit(1);
  }
};

if (require.main === module) {
  startServer();
}

module.exports = app;