const { Client } = require('pg');
require('dotenv').config();
const c = new Client({ host: 'db.zfzpjlxbhvsofhbcoyxr.supabase.co', port: 5432, database: 'postgres', user: 'postgres', password: 'Happy_user@2310' });
(async () => {
  await c.connect();
  const tm = await c.query("SELECT column_name, data_type, column_default FROM information_schema.columns WHERE table_name IN ('train_master','coach_master') ORDER BY table_name, ordinal_position");
  let cur = '';
  for (const r of tm.rows) {
    if (r.table_name !== cur) { console.log(`\n=== ${r.table_name} ===`); cur = r.table_name; }
    console.log(`  ${r.column_name} ${r.data_type} ${r.column_default || ''}`);
  }
  await c.end();
})().catch(e => { console.error('FATAL', e.message); process.exit(1); });