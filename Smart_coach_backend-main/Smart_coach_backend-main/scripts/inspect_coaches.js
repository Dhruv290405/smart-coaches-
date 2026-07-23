process.env.SUPABASE_URL = 'https://zfzpjlxbhvsofhbcoyxr.supabase.co';
process.env.SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpmenBqbHxiaHZzb2ZoYmNveXhyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MzA5MTY5NywiZXhwIjoyMDk4NjY3Njk3fQ.7UET_XEoM4mOC1j7uey3zDSvgxf3_B7p9ONZz0DsshM';

const supabaseAdmin = require('../src/config/supabaseAdmin');
const fs = require('fs');

async function inspectCoaches() {
  let logContent = '';
  const log = (msg, obj) => {
    if (obj) {
      logContent += msg + ' ' + JSON.stringify(obj, null, 2) + '\n';
    } else {
      logContent += msg + '\n';
    }
  };
  try {
    // Check coaches_railway
    const { data: railCoaches, error: err1 } = await supabaseAdmin
      .from('coaches_railway')
      .select('*');
    log('coaches_railway count: ' + (railCoaches ? railCoaches.length : 0));
    log('coaches_railway sample:', (railCoaches || []).slice(0, 10));

    // Check distinct Locations in coaches_railway
    const locations = [...new Set((railCoaches || []).map(r => r.Location).filter(Boolean))];
    log('coaches_railway unique Locations:', locations);

    // Check coaches_hams
    const { data: hamsCoaches, error: err2 } = await supabaseAdmin
      .from('coaches_hams')
      .select('*');
    log('coaches_hams count: ' + (hamsCoaches ? hamsCoaches.length : 0));
    log('coaches_hams sample:', (hamsCoaches || []).slice(0, 10));

    // Check hot_axle_logs
    const { data: recentLogs, error: err3 } = await supabaseAdmin
      .from('hot_axle_logs')
      .select('*')
      .order('timestamp', { ascending: false })
      .limit(10);
    log('hot_axle_logs recent sample:', recentLogs);

    // Check count of hot_axle_logs
    const { count, error: errCount } = await supabaseAdmin
      .from('hot_axle_logs')
      .select('*', { count: 'exact', head: true });
    log('hot_axle_logs total count:', count);

  } catch (err) {
    log('Error: ' + err.message);
  }
  fs.writeFileSync('scripts/inspect_coaches.log', logContent);
}

inspectCoaches();
