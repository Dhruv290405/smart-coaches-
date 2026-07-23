process.env.SUPABASE_URL = 'https://zfzpjlxbhvsofhbcoyxr.supabase.co';
process.env.SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpmenBqbHxiaHZzb2ZoYmNveXhyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MzA5MTY5NywiZXhwIjoyMDk4NjY3Njk3fQ.7UET_XEoM4mOC1j7uey3zDSvgxf3_B7p9ONZz0DsshM';

const supabaseAdmin = require('../src/config/supabaseAdmin');
const fs = require('fs');

async function inspectCoachesDetail() {
  let logContent = '';
  const log = (msg, obj) => {
    if (obj) {
      logContent += msg + ' ' + JSON.stringify(obj, null, 2) + '\n';
    } else {
      logContent += msg + '\n';
    }
  };
  try {
    const r1 = await supabaseAdmin.from('coaches_railway').select('*');
    log('coaches_railway count: ' + (r1.data ? r1.data.length : 0));
    if (r1.error) log('coaches_railway error:', r1.error);

    const r2 = await supabaseAdmin.from('coaches_hams').select('*');
    log('coaches_hams count: ' + (r2.data ? r2.data.length : 0));
    if (r2.error) log('coaches_hams error:', r2.error);

    const r3 = await supabaseAdmin.from('hot_axle_logs').select('*').limit(5);
    log('hot_axle_logs count: ' + (r3.data ? r3.data.length : 0));
    if (r3.error) log('hot_axle_logs error:', r3.error);

    // Let's also check if user_master is populated
    const r4 = await supabaseAdmin.from('user_master').select('*');
    log('user_master count: ' + (r4.data ? r4.data.length : 0));
    if (r4.error) log('user_master error:', r4.error);

  } catch (err) {
    log('Exception in script: ' + err.message);
  }
  fs.writeFileSync('scripts/inspect_coaches_detail.log', logContent);
}

inspectCoachesDetail();
