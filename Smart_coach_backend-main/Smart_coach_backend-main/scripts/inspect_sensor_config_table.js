const supabaseAdmin = require('../src/config/supabaseAdmin');

async function run() {
  const { data, error } = await supabaseAdmin.from('sensor_config').select('*').limit(1);
  if (error) console.error('Error:', error);
  else console.log('Columns:', Object.keys(data[0] || {}));
}

run();
