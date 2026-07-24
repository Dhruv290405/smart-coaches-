const supabaseAdmin = require('../src/config/supabaseAdmin');

async function check() {
  const { data, error } = await supabaseAdmin.from('user_master').select('*').eq('email', 'nagpur@test.com');
  console.log('User:', data[0], error);
}

check();
