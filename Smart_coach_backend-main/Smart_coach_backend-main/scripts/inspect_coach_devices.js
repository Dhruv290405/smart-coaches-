const supabaseAdmin = require('../src/config/supabaseAdmin');

async function run() {
  const { data: coaches, error: e1 } = await supabaseAdmin.from('coach_master').select('*');
  console.log('--- COACHES ---');
  console.log(coaches);

  for (const coach of (coaches || [])) {
    console.log(`\nChecking coach: ${coach.coach_unique_id} (ID: ${coach.coach_id})`);
    
    // Fetch master_module
    const { data: modules, error: e2 } = await supabaseAdmin
      .from('master_module')
      .select('*')
      .eq('coach_id', coach.coach_id);
    console.log('Modules:', modules);

    for (const mod of (modules || [])) {
      // Fetch devices mapped
      const { data: mappings, error: e3 } = await supabaseAdmin
        .from('module_device_mapping')
        .select(`
          module_device_mapping_id,
          device_master (
            device_id,
            short_name,
            full_name,
            device_unique_id
          )
        `)
        .eq('module_id', mod.module_id);
      console.log(`Device mappings for module ${mod.module_id}:`, JSON.stringify(mappings));
    }
  }
}

run();
