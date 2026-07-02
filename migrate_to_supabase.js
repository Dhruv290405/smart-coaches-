const { createClient } = require('@supabase/supabase-js');
const supabaseAdmin = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

const OLD = 'https://smart-coach-api-production.up.railway.app/smart_coach_api/api';
const LOGIN = { email: 'tester@example.com', password: '123456' };

let ok = 0, fail = 0;

async function run() {
  console.log('Logging into old API...');
  const r = await fetch(OLD + '/auth/login', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(LOGIN) });
  const j = await r.json();
  const token = j.data?.token;
  if (!token) { console.log('Login failed:', j); return; }
  console.log('Logged in OK');

  const GET = async (path) => {
    const r = await fetch(OLD + path, { headers: { Authorization: 'Bearer ' + token } });
    if (!r.ok) { console.log(`GET ${path} FAILED ${r.status}`); return null; }
    const body = await r.json();
    let data = body.data || body;
    if (data && data.items && Array.isArray(data.items)) data = data.items;
    else if (data && data.regions && Array.isArray(data.regions)) data = data.regions;
    else if (data && data.stations && Array.isArray(data.stations)) data = data.stations;
    return data;
  };

  const insert = async (table, rows) => {
    if (!rows || !rows.length) { console.log(`${table}: 0 rows`); return; }
    for (const row of rows) {
      const { error } = await supabaseAdmin.from(table).insert(row).maybeSingle();
      if (error && !error.message.includes('duplicate')) {
        fail++; if (fail <= 5) console.log(`  ${table} err: ${error.message}`);
      } else { ok++; }
    }
    console.log(`${table}: ${ok} OK so far, ${fail} failed`);
  };

  const tables = [
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

  for (const [name, path] of tables) {
    console.log(`Fetching ${name}...`);
    const data = await GET(path);
    if (data && data.length) await insert(name, data);
  }

  // coaches
  try {
    const raw = await GET('/coaches');
    if (raw && raw.length) {
      const fixed = raw.map(r => { const o = { ...r }; if ('make_of_coach_id' in o) { o.make_of_coach = o.make_of_coach_id; delete o.make_of_coach_id; } if ('type_of_coach_id' in o) { o.type_of_coach = o.type_of_coach_id; delete o.type_of_coach_id; } return o; });
      await insert('coach_master', fixed);
    }
  } catch (e) { console.log('coach_master err:', e.message); }

  // divisions
  try {
    const { data: zones } = await supabaseAdmin.from('zone_master').select('zone_id');
    const allDivs = [];
    for (const z of (zones || [])) {
      const divs = await GET(`/masters/divisions?zone_id=${z.zone_id}`);
      if (divs) allDivs.push(...divs);
    }
    if (allDivs.length) await insert('division_master', allDivs);
  } catch (e) { console.log('division_master err:', e.message); }

  // regions
  try {
    const regs = await GET('/regions');
    if (regs && regs.length) {
      await insert('region_master', regs);
    } else {
      const { data: divs } = await supabaseAdmin.from('division_master').select('division_id');
      const allRegs = [];
      for (const d of (divs || [])) {
        const r = await GET(`/masters/regions?division_id=${d.division_id}`);
        if (r) allRegs.push(...r);
      }
      if (allRegs.length) await insert('region_master', allRegs);
    }
  } catch (e) { console.log('region_master err:', e.message); }

  // user
  try {
    const { error: ue } = await supabaseAdmin.from('user_master').insert({
      user_id: 1, first_name: 'Tester', last_name: 'Backend',
      email: 'tester@example.com', mobile_number: '9000000000', gender: 'Male',
      organisation_type: 'Railway', organisation_name: 'Indian Railways',
      zone_id: 1, division_id: 10, role_id: 1, status: 'Active',
      approval_status: 'Approved', employee_id: 'EMP12345',
      pan_card_no: 'ABCDE1234F', aadhar_no: '123456789012', company_id: '1',
      created_date: new Date().toISOString(),
      password_hash: '$2b$10$5GoOa5baUkZRMjRCAwOhbudp6n8W8w2l0DPu6vNGhMeCGg0su1cakW'
    }).maybeSingle();
    if (ue && !ue.message.includes('duplicate')) console.log('user insert err:', ue.message);
    else console.log('user_master: tester user OK');
  } catch (e) { console.log('user insert err:', e.message); }

  console.log(`\nDone. ${ok} rows inserted, ${fail} failed`);
}

run().catch(e => console.error('Script failed:', e));
