const supabaseAdmin = require('../src/config/supabaseAdmin');
const supabaseOld = require('../src/config/supabaseOld');

async function check() {
  const { data: hamsRegs, error: rErr } = await supabaseAdmin
      .from('coaches_hams')
      .select('coach_no, train_no, technical_id, location, actual_id, device_id');

  console.log('coaches_hams error:', rErr);
  console.log('coaches_hams rows:', hamsRegs);

  if (hamsRegs && hamsRegs.length > 0) {
    const rawIds = hamsRegs.map(r => r.actual_id).filter(Boolean);
    console.log('Checking actual_ids in hams_data:', rawIds);
    const filter = [];
    for (const id of rawIds) {
      filter.push(id, id.toLowerCase(), id.toUpperCase());
    }
    const { data: hamsData, error: dErr } = await supabaseOld
        .from('hams_data')
        .select('*')
        .in('master_id', filter)
        .order('created_at', { ascending: false });
    
    console.log('hams_data error:', dErr);
    console.log('hams_data row count:', hamsData ? hamsData.length : 0);
    if (hamsData && hamsData.length > 0) {
      console.log('Unique master_ids in hams_data:', [...new Set(hamsData.map(d => d.master_id))]);
      console.log('Sample row:', hamsData[0]);
    }
  }
}

check();
