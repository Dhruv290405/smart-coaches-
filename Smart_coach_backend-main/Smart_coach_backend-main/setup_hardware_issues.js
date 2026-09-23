const { Client } = require('pg');
require('dotenv').config();

const PG = {
  host: 'db.zfzpjlxbhvsofhbcoyxr.supabase.co',
  port: 5432,
  database: 'postgres',
  user: 'postgres',
  password: process.env.DB_PG_PASSWORD || 'Happy_user@2310',
};

const TRAIN_NO = '20917/20916';
const INSTALL_DATE = '2026-10-05';

const DDL = `
-- device <-> compartment mapping (1 device per compartment)
CREATE TABLE IF NOT EXISTS device_compartment_mapping (
  id BIGSERIAL PRIMARY KEY,
  device_id TEXT NOT NULL UNIQUE,
  train_no TEXT NOT NULL,
  coach_no TEXT NOT NULL,
  compartment_no TEXT NOT NULL,
  installation_date DATE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- hardware issue events
CREATE TABLE IF NOT EXISTS hardware_issues (
  id BIGSERIAL PRIMARY KEY,
  device_id TEXT NOT NULL,
  train_no TEXT NOT NULL,
  coach_no TEXT NOT NULL,
  compartment_no TEXT NOT NULL,
  issue_type TEXT NOT NULL CHECK (issue_type IN ('linen','cleaning')),
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','closed')),
  opened_at TIMESTAMPTZ,
  closed_at TIMESTAMPTZ,
  response_seconds BIGINT,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_hardware_issues_device ON hardware_issues(device_id);
CREATE INDEX IF NOT EXISTS idx_hardware_issues_opened ON hardware_issues(opened_at);
`;

function buildDeviceSeed() {
  const rows = [];
  const seed = { A1: 8, A2: 8, B1: 9, B2: 9, B3: 9 };
  for (const [coach, count] of Object.entries(seed)) {
    for (let c = 1; c <= count; c++) {
      const deviceId = `DEV-${coach}-${String(c).padStart(2, '0')}`;
      rows.push([deviceId, TRAIN_NO, coach, String(c), INSTALL_DATE]);
    }
  }
  return rows;
}

async function main() {
  const client = new Client(PG);
  await client.connect();
  console.log('Connected to Project 1 Postgres');

  await client.query(DDL);
  console.log('Tables ready: device_compartment_mapping, hardware_issues');

  const seed = buildDeviceSeed();
  const { rowCount } = await client.query(
    `INSERT INTO device_compartment_mapping (device_id, train_no, coach_no, compartment_no, installation_date)
     SELECT * FROM unnest($1::text[], $2::text[], $3::text[], $4::text[], $5::date[])
     ON CONFLICT (device_id) DO NOTHING`,
    [
      seed.map(r => r[0]),
      seed.map(r => r[1]),
      seed.map(r => r[2]),
      seed.map(r => r[3]),
      seed.map(r => r[4]),
    ]
  );
  console.log(`Device mapping seeded: ${rowCount} inserted (43 expected)`);

  const { rows: check } = await client.query('SELECT coach_no, COUNT(*) AS comps FROM device_compartment_mapping GROUP BY coach_no ORDER BY coach_no');
  console.log('Coach -> compartments:', JSON.stringify(check));

  const { rows: trainCheck } = await client.query(
    `SELECT train_id FROM train_master WHERE train_number = $1 LIMIT 1`, [TRAIN_NO]);
  console.log('train_master has 20917/20916?', trainCheck.length ? JSON.stringify(trainCheck[0]) : 'NOT PRESENT');

  await client.end();
}

main().catch(e => { console.error('FATAL:', e.message); process.exit(1); });