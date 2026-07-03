require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const supabaseAdmin = require('./src/config/supabaseAdmin');
const { errorResponse } = require('./src/utils/response');
const { createServer } = require('http');
const { Server } = require('socket.io');
const sensorRoutes = require('./src/routes/sensor_data.routes');
const pneumaticRoutes = require('./src/routes/pneumatic.routes');
const hotAxleRoutes = require('./src/routes/hotAxle.routes');
const pressureRoutes = require('./src/routes/pressure.routes');
const acpRoutes = require('./src/routes/ACP.routes'); 
const notificationRoutes = require('./src/routes/notification.routes');

const { apiLimiter } = require('./src/middleware/rateLimiter');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors({ origin: true, credentials: true }));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true, parameterLimit: 50000 }));
app.use('/smart_coach_api/api', apiLimiter);

if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('dev'));
}

const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: { origin: "*" }
});

global._io = io;

io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);
  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

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

app.get('/test', async (req, res) => {
  let dbStatus = 'not checked';
  let supabaseUrl = process.env.SUPABASE_URL || 'not set';
  let wliCount = 0;
  let tables = [];
  let userCount = 0;
  try {
    const { count: wliCnt, error: wliErr } = await supabaseAdmin.from('wli_logs').select('*', { count: 'exact', head: true });
    if (wliErr) throw wliErr;
    wliCount = wliCnt;
    const { count: userCnt, error: userErr } = await supabaseAdmin.from('user_master').select('*', { count: 'exact', head: true });
    if (userErr) throw userErr;
    userCount = userCnt + ' users';
    const { data: tbls, error: tblErr } = await supabaseAdmin.from('information_schema.tables').select('table_name').eq('table_schema', 'public');
    if (!tblErr && tbls) tables = tbls.map(r => r.table_name);
    dbStatus = 'connected';
  } catch (e) {
    dbStatus = 'failed: ' + e.message;
  }
  res.json({ status: 'Test route works!', db: dbStatus, supabaseUrl, wliLogs: wliCount, tables, users: userCount });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', message: 'Server is running' });
});

app.get('/db-data', async (req, res) => {
  try {
    const tables = ['zone_master', 'division_master', 'region_master', 'role_master', 'user_master', 'coach_make', 'coach_type', 'sensor_make', 'train_master', 'device_master', 'coach_master', 'sensor_master', 'sensor_config', 'rule_master', 'stations', 'wli_logs', 'hot_axle_logs', 'pressure_logs', 'fsds_logs', 'iot_water_level'];
    const info = {};
    for (const t of tables) {
      const { count, error } = await supabaseAdmin.from(t).select('*', { count: 'exact', head: true });
      info[t] = error ? `error: ${error.message}` : count;
    }
    res.json({ tables: info });
  } catch (e) { res.json({ error: e.message }); }
});

let migrateLog = [];
const logR = (msg) => { migrateLog.push('[' + new Date().toISOString().slice(11,19) + '] ' + msg); console.log('[MIGRATE] ' + msg); };

app.get('/migrate-log', (req, res) => res.json(migrateLog.slice(-100)));

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

    const insertData = async (table, rows) => {
      if (!rows || !rows.length) { logR(`${table}: 0 rows`); return; }
      let ok = 0, fail = 0;
      for (const row of rows) {
        try {
          const { error } = await supabaseAdmin.from(table).insert(row).maybeSingle();
          if (error) throw error;
          ok++;
        } catch (e) {
          fail++;
          if (fail <= 2) logR(`${table} err: ${e.message}`);
        }
      }
      logR(`${table}: ${ok} OK, ${fail} failed`);
    };

    const migrate = async (name, path) => {
      logR(`Fetching ${name}...`);
      const d = await GET(path);
      if (d && d.length) { await insertData(name, d); }
    };

    logR('--- Starting Master Data Migration ---');

    for (const [name, path] of [
      ['zone_master', '/masters/zones'], ['role_master', '/masters/roles'],
      ['coach_make', '/coach-makes'], ['coach_type', '/coach-types'],
      ['sensor_make', '/sensors-make'], ['train_master', '/trains'],
      ['device_master', '/devices'],
      ['sensor_master', '/sensors'], ['sensor_config', '/sensors-config'],
      ['rule_master', '/rules'], ['stations', '/stations'],
    ]) { await migrate(name, path); }

    try {
      const raw = await GET('/coaches');
      if (raw && raw.length) {
        const fixed = raw.map(r => {
          const o = { ...r };
          if ('make_of_coach_id' in o) { o.make_of_coach = o.make_of_coach_id; delete o.make_of_coach_id; }
          if ('type_of_coach_id' in o) { o.type_of_coach = o.type_of_coach_id; delete o.type_of_coach_id; }
          return o;
        });
        await insertData('coach_master', fixed);
      }
    } catch (e) { logR('coach_master err: ' + e.message); }

    try {
      const { data: zones } = await supabaseAdmin.from('zone_master').select('zone_id');
      const allDivs = [];
      for (const z of (zones || [])) {
        const divs = await GET(`/masters/divisions?zone_id=${z.zone_id}`);
        if (divs) allDivs.push(...divs);
      }
      if (allDivs.length) { await insertData('division_master', allDivs); }
    } catch (e) { logR('division_master err: ' + e.message); }

    try {
      const allRegs = [];
      const regs = await GET('/regions');
      if (regs) allRegs.push(...regs);
      if (!allRegs.length) {
        const { data: divs } = await supabaseAdmin.from('division_master').select('division_id');
        for (const d of (divs || [])) { const r = await GET(`/masters/regions?division_id=${d.division_id}`); if (r) allRegs.push(...r); }
      }
      if (allRegs.length) { await insertData('region_master', allRegs); }
    } catch (e) { logR('region_master err: ' + e.message); }

    try {
      const { error } = await supabaseAdmin.from('user_master').insert({
        user_id: 1, first_name: 'Tester', last_name: 'Backend',
        email: 'tester@example.com', mobile_number: '9000000000', gender: 'Male',
        organisation_type: 'Railway', organisation_name: 'Indian Railways',
        zone_id: 1, division_id: 10, role_id: 1, status: 'Active',
        approval_status: 'Approved', employee_id: 'EMP12345',
        pan_card_no: 'ABCDE1234F', aadhar_no: '123456789012', company_id: '1',
        created_date: new Date().toISOString(),
        password_hash: '$2b$10$5GoOa5baUkZRMjRCAwOhbudp6n8Ww2l0DPu6vNGhMeCGg0su1cakW'
      }).maybeSingle();
      if (error && !error.message.includes('duplicate')) logR('user insert err: ' + error.message);
      else logR('user_master: tester user inserted with password_hash');
    } catch (e) { logR('user insert err: ' + e.message); }

    logR('--- Migration Complete ---');
  })();
});

app.get('/create-fsds-table', async (req, res) => {
  try {
    const { error } = await supabaseAdmin.from('fsds_logs').select('id').limit(1);
    if (error) {
      res.json({ success: false, error: error.message, message: 'fsds_logs table may not exist' });
    } else {
      res.json({ success: true, message: 'fsds_logs table exists' });
    }
  } catch (e) {
    res.json({ success: false, error: e.message });
  }
});

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
    err.message || 'Internal server error', 
    500, 
    err
  );
});

const startServer = async () => {
  try {
    console.log(' Starting server with Supabase backend...');
    const { error } = await supabaseAdmin.from('device_master').select('device_id').limit(1);
    if (error) {
      console.error(' Supabase connection failed:', error.message);
    } else {
      console.log(' Supabase connection verified.');
    }

    const server = httpServer.listen(PORT, () => {
      console.log(`\nServer live: http://localhost:${PORT}`);
      console.log(`Env: ${process.env.NODE_ENV || 'production'}`);
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
