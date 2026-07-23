process.env.SUPABASE_URL = 'https://zfzpjlxbhvsofhbcoyxr.supabase.co';
process.env.SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpmenBqbHxiaHZzb2ZoYmNveXhyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MzA5MTY5NywiZXhwIjoyMDk4NjY3Njk3fQ.7UET_XEoM4mOC1j7uey3zDSvgxf3_B7p9ONZz0DsshM';

const supabaseAdmin = require('../src/config/supabaseAdmin');
const fs = require('fs');

async function seedDemoData() {
  const log = [];
  try {
    // ---- Users ----
    const { data: userDan, error: errUserDan } = await supabaseAdmin
      .from('user_master')
      .upsert({
        email: 'danapur.ops@test.com',
        region_name: 'Danapur',
        division_name: null,
        role_id: 2 // assume operator role
      }, { onConflict: 'email' });
    log.push({ step: 'upsert Danapur user', result: errUserDan ? errUserDan.message : userDan });

    const { data: userNag, error: errUserNag } = await supabaseAdmin
      .from('user_master')
      .upsert({
        email: 'nagpur.ops@gmail.com',
        region_name: 'Nagpur',
        division_name: null,
        role_id: 2
      }, { onConflict: 'email' });
    log.push({ step: 'upsert Nagpur user', result: errUserNag ? errUserNag.message : userNag });

    // ---- Sensor Config ----
    const configs = [
      // Danapur config – includes ACP, Hot Axle (section 2), BC Pressure
      {
        location: 'Danapur',
        device_name: 'ACP',
        technical_id: 'ACP01',
        train_no: 'DAN001',
        remarks: 'ACP for Danapur',
        sensor_type: 'acp'
      },
      {
        location: 'Danapur',
        device_name: 'Hot Axle',
        technical_id: 'HA02',
        train_no: 'DAN001',
        remarks: 'Hot Axle Section 2',
        sensor_type: 'hot_axle',
        section: '2'
      },
      {
        location: 'Danapur',
        device_name: 'BC Pressure',
        technical_id: 'BC01',
        train_no: 'DAN001',
        remarks: 'BC Pressure monitoring',
        sensor_type: 'bc_pressure'
      },
      // Nagpur config – Brake Binding, Hot Axle (section 1)
      {
        location: 'Nagpur',
        device_name: 'Brake Binding',
        technical_id: 'BR01',
        train_no: 'NAG001',
        remarks: 'ng-brake-binding',
        sensor_type: 'brake_binding'
      },
      {
        location: 'Nagpur',
        device_name: 'Hot Axle',
        technical_id: 'HA01',
        train_no: 'NAG001',
        remarks: 'Hot Axle Section 1',
        sensor_type: 'hot_axle',
        section: '1'
      }
    ];

    const { data: cfgData, error: cfgError } = await supabaseAdmin
      .from('sensor_config')
      .upsert(configs, { onConflict: ['location', 'device_name', 'technical_id'] });
    log.push({ step: 'upsert sensor_config', result: cfgError ? cfgError.message : cfgData });

    // ---- Sensor Data (sample readings) ----
    const now = new Date().toISOString();
    const sensorData = [];
    // Danapur – BC Pressure reading
    sensorData.push({
      location: 'Danapur',
      sensor_type: 'bc_pressure',
      value: 2.5, // within range
      timestamp: now,
      technical_id: 'BC01'
    });
    // Danapur – Hot Axle Section 2 reading (high temp to trigger alert)
    sensorData.push({
      location: 'Danapur',
      sensor_type: 'hot_axle',
      value: 65, // °C, >60 triggers warning
      timestamp: now,
      technical_id: 'HA02',
      section: '2'
    });
    // Nagpur – Brake Binding reading (example value)
    sensorData.push({
      location: 'Nagpur',
      sensor_type: 'brake_binding',
      value: 1.2, // arbitrary
      timestamp: now,
      technical_id: 'BR01'
    });
    // Nagpur – Hot Axle Section 1 reading (normal)
    sensorData.push({
      location: 'Nagpur',
      sensor_type: 'hot_axle',
      value: 45,
      timestamp: now,
      technical_id: 'HA01',
      section: '1'
    });

    const { data: sdData, error: sdError } = await supabaseAdmin
      .from('sensor_data')
      .upsert(sensorData, { onConflict: ['location', 'sensor_type', 'technical_id', 'timestamp'] });
    log.push({ step: 'upsert sensor_data', result: sdError ? sdError.message : sdData });

    // Write log to file for verification
    fs.writeFileSync('scripts/seed_demo_log.json', JSON.stringify(log, null, 2));
    console.log('Demo data seeded successfully');
  } catch (e) {
    console.error('Seeding error:', e);
  }
}

seedDemoData();
