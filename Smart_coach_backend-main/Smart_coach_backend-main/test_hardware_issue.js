const { Client } = require('pg');
require('dotenv').config();
const c = new Client({ host: 'db.zfzpjlxbhvsofhbcoyxr.supabase.co', port: 5432, database: 'postgres', user: 'postgres', password: 'Happy_user@2310' });
const devices = require('./src/models/hardwareIssue.model');

(async () => {
  await c.connect();
  const m = await c.query('SELECT device_id, train_no, coach_no, compartment_no FROM device_compartment_mapping LIMIT 3');
  console.log('sample devices:', JSON.stringify(m.rows));

  // simulate: linen press on A1-1
  const dev = m.rows[0].device_id;
  const opened = await devices.recordIssue(dev, 'linen');
  console.log('OPENED:', JSON.stringify(opened));

  // duplicate press should be blocked
  try {
    await devices.recordIssue(dev, 'linen');
    console.log('DUPLICATE: NOT BLOCKED (bad)');
  } catch (e) {
    console.log('DUPLICATE blocked ok:', e.message);
  }

  // wait 1.5s then reset
  await new Promise(r => setTimeout(r, 1500));
  const closed = await devices.resetIssue(dev);
  console.log('CLOSED:', JSON.stringify({ id: closed.id, status: closed.status, response_seconds: closed.response_seconds }));

  // report summary
  const rep = await devices.getReportSummary({});
  console.log('REPORT:', JSON.stringify({ total: rep.totalCount, open: rep.openCount, closed: rep.closedCount, linen: rep.linenCount, cleaning: rep.cleaningCount, avgSec: rep.avgResponseSeconds, share: rep.shareByType, peakLen: rep.peakHours.length }));

  await c.end();
})().catch(e => { console.error('FATAL', e.message); process.exit(1); });