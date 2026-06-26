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
  try {
    const connection = await pool.getConnection();
    dbStatus = 'connected';
    const [rows] = await connection.query("SELECT COUNT(*) as cnt FROM wli_logs");
    wliCount = rows[0].cnt;
    const [tbls] = await connection.query("SHOW TABLES");
    tables = tbls.map(r => Object.values(r)[0]);
    connection.release();
  } catch (e) {
    dbStatus = 'failed: ' + e.message;
  }
  res.json({ status: 'Test route works!', db: dbStatus, host: dbHost, wliLogs: wliCount, tables: tables });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', message: 'Server is running' });
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
          timestamp VARCHAR(50), brake_pipe_pressure DECIMAL(10,2),
          brake_cylinder_pressure DECIMAL(10,2), main_reservoir_pressure DECIMAL(10,2),
          brake_applied_time VARCHAR(50), brake_released_time VARCHAR(50),
          brake_status VARCHAR(20), battery_percentage INT, signal_strength INT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          INDEX idx_device_id (device_id), INDEX idx_timestamp (timestamp)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4` },
      ];
      for (const t of tableDefs) {
        try { await pool.query(t.sql); console.log(` ${t.name} table ready`); }
        catch (err) { console.error(` ${t.name} table creation failed:`, err.message); }
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