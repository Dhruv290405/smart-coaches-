const supabaseAdmin = require('../src/config/supabaseAdmin');

async function run() {
  console.log('Deleting 226965...');
  const { data: dData, error: dError } = await supabaseAdmin.from('coaches_hams').delete().eq('technical_id', '226965');
  console.log('Delete result:', dData, dError);

  console.log('Inserting 226965...');
  const { data: iData, error: iError } = await supabaseAdmin.from('coaches_hams').insert({
    technical_id: '226965',
    coach_no: 'LWSCZAC',
    device_id: 'Raspberry4_7',
    train_no: '1207069',
    location: 'Nagpur',
    actual_id: 'HAMS-M1-001'
  }).select();

  console.log('Insert result:', iData, iError);
}

run();
