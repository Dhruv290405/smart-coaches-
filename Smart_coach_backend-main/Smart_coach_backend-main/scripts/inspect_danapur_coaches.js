const supabaseAdmin = require('../src/config/supabaseAdmin');

async function run() {
  // Check coaches_railway
  const { data: cw } = await supabaseAdmin.from('coaches_railway').select('*').ilike('Location', '%danapur%');
  console.log('coaches_railway (Danapur):', cw);

  // Check coaches_hams
  const { data: ch } = await supabaseAdmin.from('coaches_hams').select('*').ilike('location', '%danapur%');
  console.log('coaches_hams (Danapur):', ch);

  // Check sensor_config
  const { data: sc } = await supabaseAdmin.from('sensor_config').select('*').ilike('location', '%danapur%');
  console.log('sensor_config (Danapur count):', sc ? sc.length : 0);
  if (sc && sc.length > 0) {
    console.log('Sample sensor_config (Danapur):', sc.slice(0, 3));
  }
}

run();
