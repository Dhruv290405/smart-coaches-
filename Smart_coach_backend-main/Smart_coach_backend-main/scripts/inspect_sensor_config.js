const supabaseAdmin = require('../src/config/supabaseAdmin');

async function run() {
  const { data, error } = await supabaseAdmin.from('sensor_config').select('*');
  console.log('sensor_config rows:', data, error);
}

run();
