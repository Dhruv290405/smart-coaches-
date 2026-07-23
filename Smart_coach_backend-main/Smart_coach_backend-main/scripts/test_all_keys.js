const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

const dbs = [
  {
    name: 'zfzpjlxbhvsofhbcoyxr (New service key)',
    url: 'https://zfzpjlxbhvsofhbcoyxr.supabase.co',
    key: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpmenBqbHxiaHZzb2ZoYmNveXhyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MzA5MTY5NywiZXhwIjoyMDk4NjY3Njk3fQ.7UET_XEoM4mOC1j7uey3zDSvgxf3_B7p9ONZz0DsshM'
  },
  {
    name: 'ajikchaxkmxcyuecqmce (Old service key)',
    url: 'https://ajikchaxkmxcyuecqmce.supabase.co',
    key: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFqaWtjaGF4a214Y3l1ZWNxbWNlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTk5Mjg5NSwiZXhwIjoyMDg3NTY4ODk1fQ.f8_AK5RIRXSwsq3RiVAE3LLseo-tiJUgULRzTnAnW70'
  },
  {
    name: 'cxzzmfqxyxondlzledjn (Frontend anon key)',
    url: 'https://cxzzmfqxyxondlzledjn.supabase.co',
    key: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN4enptZnF4eXhvbmRsemxlZGpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI1NDExNDMsImV4cCI6MjA5ODExNzE0M30.JcSfMGc6u6PmlSNEzZA96r9IoWdV88C7z-n68RiouMk'
  }
];

async function checkAll() {
  let logContent = '';
  const log = (msg, obj) => {
    if (obj) {
      logContent += msg + ' ' + JSON.stringify(obj, null, 2) + '\n';
    } else {
      logContent += msg + '\n';
    }
  };

  for (const db of dbs) {
    log(`\n=== Checking DB: ${db.name} ===`);
    try {
      const client = createClient(db.url, db.key);
      
      // select from coaches_railway
      const r1 = await client.from('coaches_railway').select('*').limit(5);
      if (r1.error) {
        log(`coaches_railway error: ${r1.error.message}`);
      } else {
        log(`coaches_railway count/sample: ${r1.data.length} rows`);
        if (r1.data.length > 0) log('Sample:', r1.data);
      }

      // select from hot_axle_logs
      const r2 = await client.from('hot_axle_logs').select('*').limit(5);
      if (r2.error) {
        log(`hot_axle_logs error: ${r2.error.message}`);
      } else {
        log(`hot_axle_logs count/sample: ${r2.data.length} rows`);
        if (r2.data.length > 0) log('Sample:', r2.data);
      }

      // select from hams_data
      const r3 = await client.from('hams_data').select('*').limit(5);
      if (r3.error) {
        log(`hams_data error: ${r3.error.message}`);
      } else {
        log(`hams_data count/sample: ${r3.data.length} rows`);
        if (r3.data.length > 0) log('Sample:', r3.data);
      }
    } catch (e) {
      log(`Exception: ${e.message}`);
    }
  }

  fs.writeFileSync('scripts/test_all_keys.log', logContent);
}

checkAll();
