const { createClient } = require('@supabase/supabase-js');

const OLD_URL = 'https://ajikchaxkmxcyuecqmce.supabase.co';
const OLD_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFqaWtjaGF4a214Y3l1ZWNxbWNlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTk5Mjg5NSwiZXhwIjoyMDg3NTY4ODk1fQ.f8_AK5RIRXSwsq3RiVAE3LLseo-tiJUgULRzTnAnW70';

const NEW_URL = 'https://zfzpjlxbhvsofhbcoyxr.supabase.co';
const NEW_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpmenBqbHhiaHZzb2ZoYmNveXhyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MzA5MTY5NywiZXhwIjoyMDk4NjY3Njk3fQ.7UET_XEoM4mOC1j7uey3zDSvgxf3_B7p9ONZz0DsshM';

const oldSb = createClient(OLD_URL, OLD_KEY);
const newSb = createClient(NEW_URL, NEW_KEY);

const BATCH = 500;

const tables = [
  'zone_master','division_master','region_master','role_master',
  'coach_make','coach_type','sensor_make','train_master','device_master',
  'sensor_master','sensor_config','rule_master','stations','coach_master',
  'user_master','master_module','module_device_mapping','sensor_device_mapping',
  'sensor_unit_mapping','rule_condition_master','rule_device_mapping',
  'rule_sub_condition','value_type_master','unit_master','alert_type_master',
  'device_type','coach_configurations','device_live_summary','device_latest_status',
  'blocked_devices','pressure_calibration','train_coach_mapping',
  'user_train_mapping','user_region_mapping','user_fcm_tokens','user_notifications',
  'event_publish','brake_fault_event','bpc_pressure','hams_data','coaches','coaches_railway','coaches_hams',
  'iot_odour_level','iot_water_level',
  'hot_axle_logs','pressure_logs','acp_critical_events','acp_heartbeat_logs',
  'odour_logs','wli_logs','fsds_logs','sensor_data','sensor_alerts',
];

async function migrateTable(table) {
  try {
    const { count: oldCount, error: countErr } = await oldSb.from(table).select('*', { count: 'exact', head: true });
    if (countErr) {
      console.log(`${table}: count error - ${countErr.message}`);
      return;
    }
    if (!oldCount || oldCount === 0) {
      console.log(`${table}: 0 rows`);
      return;
    }

    let offset = 0;
    let inserted = 0;
    let failed = false;

    while (offset < oldCount) {
      const { data: rows, error: readErr } = await oldSb.from(table).select('*').range(offset, offset + BATCH - 1);
      if (readErr || !rows || rows.length === 0) {
        console.log(`${table}: read error at ${offset} - ${readErr?.message}`);
        failed = true;
        break;
      }

      const { error: writeErr } = await newSb.from(table).insert(rows);
      if (writeErr) {
        console.log(`${table}: write error at ${offset} - ${writeErr.message}`);
        failed = true;
        break;
      }

      inserted += rows.length;
      offset += BATCH;
      if (inserted % 5000 === 0) console.log(`  ${table}: ${inserted}/${oldCount}...`);
    }

    console.log(`${table}: ${inserted}/${oldCount} rows${failed ? ' (PARTIAL)' : ''}`);
  } catch (e) {
    console.log(`${table}: EXCEPTION - ${e.message}`);
  }
}

async function main() {
  console.log(`Migrating ${tables.length} tables from old to new Supabase...\n`);
  const start = Date.now();

  for (const table of tables) {
    await migrateTable(table);
  }

  const elapsed = ((Date.now() - start) / 1000).toFixed(1);
  console.log(`\nDONE in ${elapsed}s`);
}

main().catch(console.error);
