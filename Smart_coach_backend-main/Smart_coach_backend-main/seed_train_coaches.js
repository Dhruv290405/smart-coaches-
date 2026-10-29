const { Client } = require('pg');
require('dotenv').config();
const c = new Client({ host: 'db.zfzpjlxbhvsofhbcoyxr.supabase.co', port: 5432, database: 'postgres', user: 'postgres', password: 'Happy_user@2310' });

(async () => {
  await c.connect();

  // next train_id
  const maxT = await c.query('SELECT COALESCE(MAX(train_id),0)+1 AS next_id FROM train_master');
  const trainId = maxT.rows[0].next_id;

  const insT = await c.query(
    `INSERT INTO train_master (train_id, train_number, train_name)
     VALUES ($1, '20917/20916', 'Hardware Test Train') ON CONFLICT (train_id) DO NOTHING`,
    [trainId]
  );
  console.log('train insert rows:', insT.rowCount, 'id:', trainId);

  const nextC = await c.query('SELECT COALESCE(MAX(coach_id),0)+1 AS next_id FROM coach_master');
  let coachId = nextC.rows[0].next_id;

  const coaches = ['A1','A2','B1','B2','B3'];
  for (const co of coaches) {
    await c.query(
      `INSERT INTO coach_master (coach_id, coach_unique_id, coach_display_id, position, no_of_master_module, coach_status, entity_type, train_id, type_of_coach_code)
       VALUES ($1, $2, $3, $4, 1, 'Active', 'Coach', $5, $6) ON CONFLICT (coach_id) DO NOTHING`,
      [coachId, `coach-${Date.now().toString().slice(-6)}-${co}`, co, ['A1','A2','B1','B2','B3'].indexOf(co) + 1, trainId, 'GEN']
    );
    console.log('coach inserted:', co, '→ id', coachId);
    coachId++;
  }

  const check = await c.query('SELECT coach_no, compartment_no FROM device_compartment_mapping ORDER BY coach_no, compartment_no::int LIMIT 6');
  console.log('mapping sample:', JSON.stringify(check.rows));
  await c.end();
})().catch(e => { console.error('FATAL', e.message); process.exit(1); });