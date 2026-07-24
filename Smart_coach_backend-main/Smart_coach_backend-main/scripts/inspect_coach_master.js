const supabaseAdmin = require('../src/config/supabaseAdmin');

async function run() {
  const { data, error } = await supabaseAdmin.from('coach_master').select('*').limit(5);
  console.log('coach_master:', data, error);
}

run();
