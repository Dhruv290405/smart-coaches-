const { Client } = require('pg');

const PG = {
  host: 'db.ajikchaxkmxcyuecqmce.supabase.co',
  port: 5432,
  database: 'postgres',
  user: 'postgres',
  password: 'Happy_user@2310',
};

// Tables to DROP then recreate (mismatched schemas)
const TABLES_TO_FIX = [
  'role_master', 'coach_make', 'coach_type', 'sensor_make',
  'train_master', 'device_master', 'sensor_master', 'sensor_config',
  'rule_master', 'stations', 'coach_master', 'region_master',
  // Related tables (need to drop FK-dependents first)
  'rule_device_mapping', 'rule_sensor_mapping', 'rule_condition_master',
  'rule_sub_condition', 'alert_type_master',
  'sensor_unit_mapping', 'sensor_device_mapping', 'unit_master',
  'value_type_master', 'module_device_mapping',
  'user_region_mapping', 'user_train_mapping', 'train_coach_mapping',
  'coaches', 'device_type', 'master_module',
];

// MySQL-compatible CREATE TABLE statements
const CREATE_SQL = `

-- role_master
DROP TABLE IF EXISTS role_master CASCADE;
CREATE TABLE role_master (
  role_id BIGINT PRIMARY KEY,
  name TEXT,
  is_active SMALLINT DEFAULT 1,
  train_id TEXT
);

-- coach_make
DROP TABLE IF EXISTS coach_make CASCADE;
CREATE TABLE coach_make (
  id BIGINT PRIMARY KEY,
  name TEXT,
  is_active SMALLINT DEFAULT 1,
  created_at TEXT,
  updated_at TEXT
);

-- coach_type
DROP TABLE IF EXISTS coach_type CASCADE;
CREATE TABLE coach_type (
  id BIGINT PRIMARY KEY,
  code TEXT,
  name TEXT,
  is_active SMALLINT DEFAULT 1,
  created_at TEXT
);

-- sensor_make
DROP TABLE IF EXISTS sensor_make CASCADE;
CREATE TABLE sensor_make (
  sensor_make_id BIGINT PRIMARY KEY,
  make_name TEXT,
  description TEXT,
  created_at TEXT
);

-- zone_master (already correct, recreate to be clean)
DROP TABLE IF EXISTS zone_master CASCADE;
CREATE TABLE zone_master (
  zone_id BIGINT PRIMARY KEY,
  name TEXT,
  is_active SMALLINT DEFAULT 1
);

-- division_master
DROP TABLE IF EXISTS division_master CASCADE;
CREATE TABLE division_master (
  division_id BIGINT PRIMARY KEY,
  zone_id INTEGER,
  name TEXT,
  is_active SMALLINT DEFAULT 1
);

-- region_master
DROP TABLE IF EXISTS region_master CASCADE;
CREATE TABLE region_master (
  region_id BIGINT PRIMARY KEY,
  division_id INTEGER,
  name TEXT,
  is_active SMALLINT DEFAULT 1,
  code TEXT,
  is_region SMALLINT DEFAULT 0,
  is_station SMALLINT DEFAULT 0
);

-- stations
DROP TABLE IF EXISTS stations CASCADE;
CREATE TABLE stations (
  region_id BIGINT PRIMARY KEY,
  name TEXT,
  division_id INTEGER,
  is_active SMALLINT DEFAULT 1,
  is_region SMALLINT DEFAULT 0,
  is_station SMALLINT DEFAULT 0
);

-- train_master
DROP TABLE IF EXISTS train_master CASCADE;
CREATE TABLE train_master (
  train_id BIGINT PRIMARY KEY,
  train_number TEXT,
  train_name TEXT,
  origination_region_id INTEGER,
  region_id INTEGER,
  departure_station_id INTEGER,
  destination_station_id INTEGER,
  line TEXT,
  train_operator TEXT,
  engine_number TEXT,
  created_at TEXT,
  updated_at TEXT,
  created_by TEXT,
  updated_by TEXT,
  origination_region_name TEXT,
  region_name TEXT,
  departure_station_name TEXT,
  destination_station_name TEXT,
  coaches TEXT
);

-- device_master
DROP TABLE IF EXISTS device_master CASCADE;
CREATE TABLE device_master (
  id BIGINT PRIMARY KEY,
  device_id TEXT,
  device_unique_id TEXT,
  data_type TEXT,
  time_unit TEXT,
  description TEXT,
  created_by TEXT,
  created_at TEXT,
  updated_by TEXT,
  updated_at TEXT,
  is_active SMALLINT DEFAULT 1,
  frequency_secs INTEGER,
  full_name TEXT,
  short_name TEXT,
  no_of_sensors INTEGER,
  master_module_id INTEGER,
  status TEXT,
  tech_coach_no TEXT,
  comm_coach_no TEXT,
  installation_date TEXT,
  train_no TEXT,
  train_location TEXT,
  power_car_no TEXT,
  master_module_serial TEXT,
  coach_unique_id TEXT,
  train_number TEXT,
  train_name TEXT,
  device_type_name TEXT,
  device_model TEXT
);

-- unit_master
DROP TABLE IF EXISTS unit_master CASCADE;
CREATE TABLE unit_master (
  unit_id BIGINT PRIMARY KEY,
  unit TEXT
);

-- sensor_unit_mapping
DROP TABLE IF EXISTS sensor_unit_mapping CASCADE;
CREATE TABLE sensor_unit_mapping (
  id BIGINT PRIMARY KEY,
  sensor_id INTEGER,
  unit_id INTEGER
);

-- sensor_device_mapping
DROP TABLE IF EXISTS sensor_device_mapping CASCADE;
CREATE TABLE sensor_device_mapping (
  id BIGINT PRIMARY KEY,
  sensor_id INTEGER,
  device_id INTEGER
);

-- value_type_master
DROP TABLE IF EXISTS value_type_master CASCADE;
CREATE TABLE value_type_master (
  value_type_id BIGINT PRIMARY KEY,
  name TEXT
);

-- sensor_master
DROP TABLE IF EXISTS sensor_master CASCADE;
CREATE TABLE sensor_master (
  sensor_type_id BIGINT PRIMARY KEY,
  sensor_type_name TEXT,
  category INTEGER,
  name TEXT,
  description TEXT,
  value_format TEXT,
  min_expected_value TEXT,
  max_expected_value TEXT,
  sampling_frequency TEXT,
  time_interval TEXT,
  is_active SMALLINT DEFAULT 1,
  created_at TEXT,
  updated_at TEXT,
  created_by TEXT,
  updated_by TEXT,
  units TEXT,
  devices TEXT
);

-- sensor_config
DROP TABLE IF EXISTS sensor_config CASCADE;
CREATE TABLE sensor_config (
  sensor_config_id BIGINT PRIMARY KEY,
  sensor_id INTEGER,
  device_id INTEGER,
  sensor_type_id INTEGER,
  install_date TEXT,
  placement TEXT,
  remarks TEXT,
  master_module_id INTEGER,
  coach_id INTEGER,
  created_at TEXT,
  is_active SMALLINT DEFAULT 1,
  dual_profile_supported SMALLINT DEFAULT 0,
  lora_enabled SMALLINT DEFAULT 0,
  esim_enabled SMALLINT DEFAULT 0,
  tech_coach_no TEXT,
  comm_coach_no TEXT,
  train_no TEXT,
  location TEXT,
  status TEXT,
  updated_at TEXT,
  total_devices_attached INTEGER
);

-- rule_master
DROP TABLE IF EXISTS rule_master CASCADE;
CREATE TABLE rule_master (
  rule_id BIGINT PRIMARY KEY,
  rule_name TEXT,
  evaluation_frequency TEXT,
  evaluation_unit TEXT,
  is_active SMALLINT DEFAULT 1,
  created_by TEXT,
  updated_by TEXT,
  created_at TEXT,
  updated_at TEXT,
  devices TEXT,
  sensor_types TEXT,
  conditions TEXT
);

-- rule_device_mapping
DROP TABLE IF EXISTS rule_device_mapping CASCADE;
CREATE TABLE rule_device_mapping (
  id BIGINT PRIMARY KEY,
  rule_id INTEGER,
  device_id INTEGER
);

-- rule_sensor_mapping
DROP TABLE IF EXISTS rule_sensor_mapping CASCADE;
CREATE TABLE rule_sensor_mapping (
  id BIGINT PRIMARY KEY,
  rule_id INTEGER,
  sensor_type_id INTEGER
);

-- rule_condition_master
DROP TABLE IF EXISTS rule_condition_master CASCADE;
CREATE TABLE rule_condition_master (
  condition_id BIGINT PRIMARY KEY,
  rule_id INTEGER,
  value_type_id INTEGER,
  value_format TEXT,
  connector TEXT,
  alert_message_template TEXT,
  si_unit_id INTEGER,
  alert_type_id INTEGER
);

-- rule_sub_condition
DROP TABLE IF EXISTS rule_sub_condition CASCADE;
CREATE TABLE rule_sub_condition (
  sub_condition_id BIGINT PRIMARY KEY,
  condition_id INTEGER,
  field TEXT,
  operator TEXT,
  value TEXT,
  sort_order INTEGER
);

-- alert_type_master
DROP TABLE IF EXISTS alert_type_master CASCADE;
CREATE TABLE alert_type_master (
  alert_type_id BIGINT PRIMARY KEY,
  alert_type_name TEXT
);

-- user_region_mapping
DROP TABLE IF EXISTS user_region_mapping CASCADE;
CREATE TABLE user_region_mapping (
  id BIGINT PRIMARY KEY,
  user_id INTEGER,
  region_id INTEGER
);

-- user_train_mapping
DROP TABLE IF EXISTS user_train_mapping CASCADE;
CREATE TABLE user_train_mapping (
  id BIGINT PRIMARY KEY,
  user_id INTEGER,
  train_id INTEGER
);

-- train_coach_mapping
DROP TABLE IF EXISTS train_coach_mapping CASCADE;
CREATE TABLE train_coach_mapping (
  id BIGINT PRIMARY KEY,
  train_id INTEGER,
  coach_id INTEGER
);

-- coaches
DROP TABLE IF EXISTS coaches CASCADE;
CREATE TABLE coaches (
  id BIGINT PRIMARY KEY,
  coach_number TEXT,
  train_id INTEGER
);

-- device_type
DROP TABLE IF EXISTS device_type CASCADE;
CREATE TABLE device_type (
  id BIGINT PRIMARY KEY,
  full_name TEXT,
  short_name TEXT
);

-- master_module
DROP TABLE IF EXISTS master_module CASCADE;
CREATE TABLE master_module (
  module_id BIGINT PRIMARY KEY,
  coach_id INTEGER,
  module_unique_id TEXT,
  location TEXT,
  seriel_number TEXT
);

-- module_device_mapping
DROP TABLE IF EXISTS module_device_mapping CASCADE;
CREATE TABLE module_device_mapping (
  id BIGINT PRIMARY KEY,
  module_id INTEGER,
  device_id INTEGER
);

-- coach_master
DROP TABLE IF EXISTS coach_master CASCADE;
CREATE TABLE coach_master (
  coach_id BIGINT PRIMARY KEY,
  coach_unique_id TEXT,
  coach_display_id TEXT,
  position INTEGER,
  no_of_master_module INTEGER,
  created_by TEXT,
  coach_status TEXT,
  entity_type TEXT,
  manufacturing_year TEXT,
  created_by_name TEXT,
  created_date TEXT,
  updated_by TEXT,
  updated_by_name TEXT,
  updated_date TEXT,
  make_of_coach_name TEXT,
  make_of_coach_id INTEGER,
  type_of_coach_code TEXT,
  type_of_coach_id INTEGER,
  train_id INTEGER
);

-- user_master (add any missing columns)
ALTER TABLE user_master ADD COLUMN IF NOT EXISTS updated_date TEXT;
ALTER TABLE user_master ADD COLUMN IF NOT EXISTS role_name TEXT;
ALTER TABLE user_master ADD COLUMN IF NOT EXISTS zone_name TEXT;
ALTER TABLE user_master ADD COLUMN IF NOT EXISTS division_name TEXT;
ALTER TABLE user_master ADD COLUMN IF NOT EXISTS region_name TEXT;
ALTER TABLE user_master ADD COLUMN IF NOT EXISTS password_hash TEXT;
`;

async function main() {
  const client = new Client(PG);
  await client.connect();
  console.log('Connected to Supabase PostgreSQL\n');

  try {
    // Execute the SQL
    const statements = CREATE_SQL.split(';').filter(s => s.trim() && !s.trim().startsWith('--'));
    for (const stmt of statements) {
      try {
        await client.query(stmt + ';');
        const firstLine = stmt.trim().split('\n')[0].trim();
        console.log(`OK: ${firstLine.substring(0, 80)}`);
      } catch (e) {
        console.log(`ERR: ${e.message.substring(0, 100)}`);
      }
    }

    console.log('\nAll tables recreated. Verifying...');
    const { rows } = await client.query("SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE' ORDER BY table_name");
    console.log(`Tables: ${rows.map(r => r.table_name).join(', ')}`);
  } finally {
    await client.end();
  }
}

main().catch(e => console.error('FATAL:', e));
