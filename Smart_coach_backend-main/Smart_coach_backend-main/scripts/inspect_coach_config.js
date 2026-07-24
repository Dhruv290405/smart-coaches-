const supabaseAdmin = require('../src/config/supabaseAdmin');

async function run() {
  const { data, error } = await supabaseAdmin.from('coach_configurations').select('*').limit(5);
  console.log('coach_configurations:', data, error);
}

run();
