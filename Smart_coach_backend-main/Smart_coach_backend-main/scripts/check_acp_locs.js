const acpSupabase = require('../src/config/supabaseAcp');

async function test() {
  const { data, error } = await acpSupabase.from('railway_acp_data').select('loc_name, asset_name').limit(100);
  console.log('Error:', error);
  console.log('Unique locations:');
  const locs = new Set();
  const pairs = [];
  for (const r of (data || [])) {
    locs.add(r.loc_name);
    pairs.push(`${r.loc_name} | ${r.asset_name}`);
  }
  console.log([...locs]);
  console.log('Sample rows:', pairs.slice(0, 20));
}

test();
