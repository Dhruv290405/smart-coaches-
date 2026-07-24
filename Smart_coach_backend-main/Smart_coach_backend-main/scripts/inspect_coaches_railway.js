const supabaseAdmin = require('../src/config/supabaseAdmin');

async function run() {
  const { data, error } = await supabaseAdmin.from('coaches_railway').select('*');
  console.log('coaches_railway rows:', data, error);
}

run();
