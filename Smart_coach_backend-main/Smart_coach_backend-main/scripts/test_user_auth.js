const supabaseAdmin = require('../src/config/supabaseAdmin');

async function run() {
  const { data: user, error } = await supabaseAdmin
    .from('user_master')
    .select(`
      user_id, email, role_id, zone_id, division_id, region_id, employee_id,
      approval_status,
      zone_master!left(name),
      division_master!left(name),
      region_master!left(name)
    `)
    .eq('email', 'nagpur@test.com')
    .maybeSingle();

  console.log('Result:', user, error);
}

run();
