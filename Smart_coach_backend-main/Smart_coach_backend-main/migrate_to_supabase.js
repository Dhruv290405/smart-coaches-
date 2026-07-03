const { createClient } = require('@supabase/supabase-js');
const supabaseAdmin = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

const OLD = 'https://smart-coach-api-production.up.railway.app/smart_coach_api/api';
const LOGIN = { email: 'tester@example.com', password: '123456' };

const API_TABLES = [
  ['zone_master', '/masters/zones'],
  ['role_master', '/masters/roles'],
  ['coach_make', '/coach-makes'],
  ['coach_type', '/coach-types'],
  ['sensor_make', '/sensors-make'],
  ['train_master', '/trains'],
  ['device_master', '/devices'],
  ['sensor_master', '/sensors'],
  ['sensor_config', '/sensors-config'],
  ['rule_master', '/rules'],
  ['stations', '/stations'],
];

function cleanRow(row) {
  const o = {};
  for (let [k, v] of Object.entries(row)) {
    if (v === null || v === undefined) continue;
    if (typeof v === 'boolean') { o[k] = v ? 1 : 0; }
    else if (v === 'true' || v === 'false') { o[k] = v === 'true' ? 1 : 0; }
    else if (typeof v === 'object') { /* skip objects/arrays */ }
    else if (v === '' && k !== 'device_id' && k !== 'sensor_id') { /* skip empty strings except IDs */ }
    else o[k] = v;
  }
  return o;
}

async function getSupabaseCols(table) {
  try {
    const { data, error } = await supabaseAdmin.from(table).select().limit(1);
    if (!error && data && data.length) return Object.keys(data[0]);
    // If empty, try a query that returns column info via count
    const { error: e2 } = await supabaseAdmin.from(table).select('*', { count: 'exact', head: true });
    // We can't get columns from head query, so return null and let auto-strip handle it
    return null;
  } catch (e) {
    return null;
  }
}

async function insertRows(table, rows) {
  if (!rows || !rows.length) return 0;
  let ok = 0, fail = 0;
  for (const raw of rows) {
    // First clean the data types
    let current = cleanRow(raw);
    if (!Object.keys(current).length) continue;
    
    // Try inserting, stripping bad columns iteratively
    let attempts = 0;
    while (attempts < 30) {
      attempts++;
      try {
        const { error } = await supabaseAdmin.from(table).insert(current).maybeSingle();
        if (!error) { ok++; break; }
        if (error.message.includes('duplicate')) { ok++; break; }
        if (error.message.includes('violates foreign key')) { fail++; break; }
        
        const match = error.message.match(/'(\w+)'/);
        if (match) {
          const { [match[1]]: _, ...rest } = current;
          current = rest;
          if (!Object.keys(current).length) { fail++; break; }
        } else {
          fail++;
          if (fail <= 3) console.log(`  ${table} bad col fix failed: ${error.message}`);
          break;
        }
      } catch (e) {
        fail++;
        if (fail <= 3) console.log(`  ${table} err: ${e.message}`);
        break;
      }
    }
  }
  return ok;
}

async function run() {
  console.log('Logging into old API...');
  const r = await fetch(OLD + '/auth/login', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(LOGIN) });
  const j = await r.json();
  const token = j.data?.token;
  if (!token) { console.log('Login failed:', j); return; }
  console.log('Logged in OK\n');

  const GET = async (path) => {
    const r2 = await fetch(OLD + path, { headers: { Authorization: 'Bearer ' + token } });
    if (!r2.ok) { console.log(`GET ${path} FAILED ${r2.status}`); return null; }
    const body = await r2.json();
    let data = body.data || body;
    if (data && data.items && Array.isArray(data.items)) data = data.items;
    else if (data && data.regions && Array.isArray(data.regions)) data = data.regions;
    else if (data && data.stations && Array.isArray(data.stations)) data = data.stations;
    return data;
  };

  let totalOk = 0;

  for (const [name, path] of API_TABLES) {
    console.log(`Fetching ${name}...`);
    const data = await GET(path);
    if (!data || !data.length) { console.log(`  ${name}: empty\n`); continue; }
    const ok = await insertRows(name, data);
    totalOk += ok;
    console.log(`  ${name}: ${ok}/${data.length} rows\n`);
  }

  // coaches
  console.log('Fetching coach_master...');
  try {
    const raw = await GET('/coaches');
    if (raw && raw.length) {
      const fixed = raw.map(r => {
        const o = { ...r };
        if ('make_of_coach_id' in o) { o.make_of_coach = o.make_of_coach_id; delete o.make_of_coach_id; }
        if ('type_of_coach_id' in o) { o.type_of_coach = o.type_of_coach_id; delete o.type_of_coach_id; }
        return o;
      });
      const ok = await insertRows('coach_master', fixed);
      totalOk += ok;
      console.log(`  coach_master: ${ok}/${fixed.length} rows\n`);
    }
  } catch (e) { console.log('  coach_master err:', e.message, '\n'); }

  // divisions
  console.log('Fetching division_master...');
  try {
    const { data: zones } = await supabaseAdmin.from('zone_master').select('zone_id');
    const allDivs = [];
    for (const z of (zones || [])) {
      const divs = await GET(`/masters/divisions?zone_id=${z.zone_id}`);
      if (divs) allDivs.push(...divs);
    }
    if (allDivs.length) { const ok = await insertRows('division_master', allDivs); totalOk += ok; console.log(`  division_master: ${ok}/${allDivs.length} rows\n`); }
  } catch (e) { console.log('  division_master err:', e.message, '\n'); }

  // regions
  console.log('Fetching region_master...');
  try {
    const regs = await GET('/regions');
    let allRegs = regs || [];
    if (!allRegs.length) {
      const { data: divs } = await supabaseAdmin.from('division_master').select('division_id');
      for (const d of (divs || [])) {
        const r3 = await GET(`/masters/regions?division_id=${d.division_id}`);
        if (r3) allRegs.push(...r3);
      }
    }
    if (allRegs.length) { const ok = await insertRows('region_master', allRegs); totalOk += ok; console.log(`  region_master: ${ok}/${allRegs.length} rows\n`); }
  } catch (e) { console.log('  region_master err:', e.message, '\n'); }

  // test user
  try {
    const { error: ue } = await supabaseAdmin.from('user_master').insert({
      user_id: 1, first_name: 'Tester', last_name: 'Backend',
      email: 'tester@example.com', mobile_number: '9000000000', gender: 'Male',
      organisation_type: 'Railway', organisation_name: 'Indian Railways',
      zone_id: 1, division_id: 10, role_id: 1, status: 'Active',
      approval_status: 'Approved', employee_id: 'EMP12345',
      pan_card_no: 'ABCDE1234F', aadhar_no: '123456789012', company_id: '1',
      created_date: new Date().toISOString(),
      password_hash: '$2b$10$5GoOa5baUkZRMjRCAwOhbudp6n8Ww2l0DPu6vNGhMeCGg0su1cakW'
    }).maybeSingle();
    if (ue && !ue.message.includes('duplicate')) console.log('user_master insert err:', ue.message);
    else console.log('user_master: tester user OK');
  } catch (e) { console.log('user_master err:', e.message); }

  console.log(`\nDone. Total: ${totalOk} rows inserted.`);
}

run().catch(e => console.error('Script failed:', e));
