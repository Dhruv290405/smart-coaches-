const { createClient } = require('@supabase/supabase-js');
const supabaseAdmin = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

const OLD = 'https://smart-coach-api-production.up.railway.app/smart_coach_api/api';
const LOGIN = { email: 'tester@example.com', password: '123456' };

async function main() {
  // Login to old API
  const r = await fetch(OLD + '/auth/login', { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(LOGIN) });
  const j = await r.json();
  const token = j.data?.token;

  const GET = async (path) => {
    const r2 = await fetch(OLD+path, {headers:{Authorization:'Bearer '+token}});
    if (!r2.ok) return null;
    const b = await r2.json();
    let d = b.data||b;
    if (d?.items) d = d.items; else if (d?.regions) d = d.regions; else if (d?.stations) d = d.stations;
    return d;
  };

  // Get sample row from each API table to see MySQL columns
  const apiInfo = {};
  const apiTables = [
    ['zone_master','/masters/zones'],['role_master','/masters/roles'],['coach_make','/coach-makes'],
    ['coach_type','/coach-types'],['sensor_make','/sensors-make'],['train_master','/trains'],
    ['device_master','/devices'],['sensor_master','/sensors'],['sensor_config','/sensors-config'],
    ['rule_master','/rules'],['stations','/stations'],
  ];
  for (const [name, path] of apiTables) {
    const data = await GET(path);
    if (data && data.length) {
      apiInfo[name] = { cols: Object.keys(data[0]), types: {}, sample: data[0] };
      for (const [k,v] of Object.entries(data[0])) apiInfo[name].types[k] = typeof v;
    }
  }

  // Also check coach_master, division_master, region_master
  try {
    const coaches = await GET('/coaches');
    if (coaches?.length) { apiInfo['coach_master'] = { cols: Object.keys(coaches[0]), types: {}, sample: coaches[0] }; for (const [k,v] of Object.entries(coaches[0])) apiInfo['coach_master'].types[k] = typeof v; }
  } catch(_) {}

  try {
    const { data: zones } = await supabaseAdmin.from('zone_master').select('zone_id');
    const all = [];
    for (const z of (zones||[])) { const d = await GET(`/masters/divisions?zone_id=${z.zone_id}`); if (d) all.push(...d); }
    if (all.length) { apiInfo['division_master'] = { cols: Object.keys(all[0]), types: {}, sample: all[0] }; for (const [k,v] of Object.entries(all[0])) apiInfo['division_master'].types[k] = typeof v; }
  } catch(_) {}

  try {
    const regs = await GET('/regions');
    if (regs?.length) { apiInfo['region_master'] = { cols: Object.keys(regs[0]), types: {}, sample: regs[0] }; for (const [k,v] of Object.entries(regs[0])) apiInfo['region_master'].types[k] = typeof v; }
  } catch(_) {}

  // Now try to get Supabase column info via raw SQL
  console.log('=== COLUMN COMPARISON ===\n');
  for (const [table, info] of Object.entries(apiInfo)) {
    console.log(`\n--- ${table} ---`);
    console.log('MySQL cols:', info.cols.join(', '));

    // Try inserting a row with just one column to get error about missing column
    // This reveals Supabase's actual schema
    const testCol = info.cols[0];
    const testVal = info.sample[testCol];
    const testRow = { [testCol]: testVal };
    
    const { error } = await supabaseAdmin.from(table).insert(testRow).maybeSingle();
    if (error) {
      console.log('Supabase err:', error.message);
      // Error might tell us what's wrong
    } else {
      // Success! Clean up
      await supabaseAdmin.from(table).delete().eq(testCol, testVal);
      console.log('Supabase has col:', testCol, '(type: ok)');
    }
  }

  // Get Supabase column info through a different approach
  console.log('\n=== QUERYING SUPABASE SCHEMA ===\n');
  for (const table of Object.keys(apiInfo)) {
    try {
      const { data, error } = await supabaseAdmin.from(table).select('*', { count: 'exact', head: true });
      if (!error) {
        // Try inserting a dummy row to see what columns Supabase expects
        const sample = apiInfo[table].sample;
        // Attempt insert with all columns - catch error
        const { error: insErr } = await supabaseAdmin.from(table).insert(sample).maybeSingle();
        if (insErr) {
          console.log(`${table}: ${insErr.message}`);
          // Extract column names from error
          const cols = [...insErr.message.matchAll(/'(\w+)'/g)].map(m => m[1]);
          if (cols.length) console.log(`  Supabase bad cols: ${[...new Set(cols)].join(', ')}`);
        } else {
          console.log(`${table}: INSERT OK (no schema issues)`);
          // Clean up
          const pk = table === 'zone_master' ? 'zone_id' : table === 'role_master' ? 'role_id' : null;
          if (pk && sample[pk]) await supabaseAdmin.from(table).delete().eq(pk, sample[pk]);
        }
      }
    } catch(e) {
      console.log(`${table}: err - ${e.message}`);
    }
  }
}

main().catch(e => console.log('FATAL:', e.message));
