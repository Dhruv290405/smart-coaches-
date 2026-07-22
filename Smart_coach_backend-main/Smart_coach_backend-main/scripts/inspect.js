process.env.SUPABASE_URL = 'https://zfzpjlxbhvsofhbcoyxr.supabase.co';
process.env.SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpmenBqbHhiaHZzb2ZoYmNveXhyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MzA5MTY5NywiZXhwIjoyMDk4NjY3Njk3fQ.7UET_XEoM4mOC1j7uey3zDSvgxf3_B7p9ONZz0DsshM';

const supabaseAdmin = require('../src/config/supabaseAdmin');
const fs = require('fs');

async function test() {
  let logContent = "";
  const log = (msg, obj) => {
    if (obj) {
      logContent += msg + " " + JSON.stringify(obj, null, 2) + "\n";
    } else {
      logContent += msg + "\n";
    }
  };

  try {
     const { data: configs } = await supabaseAdmin
       .from('sensor_config')
       .select('*')
       .ilike('location', '%Nagpur%');
     
     log("Nagpur configs in sensor_config:", configs);

     const { data: configsAll } = await supabaseAdmin
       .from('sensor_config')
       .select('*');
     
     const hasNagpurInRemarks = configsAll.filter(c => (c.remarks || '').toLowerCase().includes('nagpur'));
     log("Nagpur remarks in sensor_config:", hasNagpurInRemarks);

     const hasNagpurInTrain = configsAll.filter(c => (c.train_no || '').toLowerCase().includes('nagpur'));
     log("Nagpur train_no in sensor_config:", hasNagpurInTrain);

     const hasNagpurInTech = configsAll.filter(c => (c.tech_coach_no || '').toLowerCase().includes('b2') || (c.tech_coach_no || '').toLowerCase().includes('c3'));
     log("B2 or C3 in tech_coach_no:", hasNagpurInTech);

  } catch (err) {
     log("Error: " + err.message);
  }
  fs.writeFileSync('scripts/inspect.log', logContent);
}

test();
