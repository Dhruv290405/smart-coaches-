const bcrypt = require('bcryptjs');
const supabaseAdmin = require('../src/config/supabaseAdmin');

async function createUser() {
  try {
    const password = '123456';
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const userData = {
      first_name: 'shagun',
      last_name: 'sharma',
      email: 'shagunsharma9761@gmail.com',
      password_hash: hashedPassword,
      mobile_number: '9012312957',
      gender: 'female',
      organisation_type: 'Railway',
      organisation_name: 'Indian Railways',
      zone_id: 12,
      division_id: 59,
      region_id: 120,
      role_id: 3,
      zone_name: 'South East Central Railway',
      division_name: 'Nagpur (SECR)',
      region_name: 'Nagpur SECR',
      role_name: 'Regional Master',
      status: 'Active',
      approval_status: 'Approved',
      employee_id: '123456',
      pan_card_no: 'ABCEFD123F',
      company_id: '12345',
      created_date: new Date(),
    };

    const { data: user, error } = await supabaseAdmin
      .from('user_master')
      .insert(userData)
      .select()
      .single();

    if (error) throw error;

    const userId = user.user_id;
    console.log('User created with ID:', userId);

    // Insert region mapping
    const { data: maxRow } = await supabaseAdmin
      .from('user_region_mapping')
      .select('id')
      .order('id', { ascending: false })
      .limit(1)
      .maybeSingle();

    let nextId = maxRow?.id ? maxRow.id + 1 : 1;
    const { error: regionError } = await supabaseAdmin
      .from('user_region_mapping')
      .insert([{ id: nextId, user_id: userId, region_id: 120 }]);

    if (regionError) throw regionError;
    console.log('Region mapping inserted');

    console.log('User shagun created successfully!');
    console.log('Email: shagunsharma9761@gmail.com');
    console.log('Password: 123456');
    process.exit(0);
  } catch (e) {
    console.error('Error creating user:', e.message || e);
    process.exit(1);
  }
}

createUser();
