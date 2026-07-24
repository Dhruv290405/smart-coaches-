const supabaseAcp = require('../src/config/supabaseAcp');

async function run() {
  const { data, error } = await supabaseAcp.from('railway_acp_data').select('*').limit(5);
  console.log('ACP data:', data, error);
}

run();
