process.env.SUPABASE_URL = 'https://zfzpjlxbhvsofhbcoyxr.supabase.co';
process.env.SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpmenBqbHhiaHZzb2ZoYmNveXhyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MzA5MTY5NywiZXhwIjoyMDk4NjY3Njk3fQ.7UET_XEoM4mOC1j7uey3zDSvgxf3_B7p9ONZz0DsshM';

const supabaseAdmin = require('../src/config/supabaseAdmin');
const fs = require('fs');

async function fetchConfigs() {
  let logContent = '';
  const log = (msg, obj) => {
    if (obj) {
      logContent += msg + ' ' + JSON.stringify(obj, null, 2) + '\n';
    } else {
      logContent += msg + '\n';
    }
  };
  try {
    const { data: danConfigs } = await supabaseAdmin
      .from('sensor_config')
      .select('*')
      .ilike('location', '%Danapur%');
    log('Danapur configs:', danConfigs);

    const { data: nagConfigs } = await supabaseAdmin
      .from('sensor_config')
      .select('*')
      .ilike('location', '%Nagpur%');
    log('Nagpur configs:', nagConfigs);
  } catch (err) {
    log('Error: ' + err.message);
  }
  fs.writeFileSync('scripts/inspect_dan_nag.log', logContent);
}

fetchConfigs();
