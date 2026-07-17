const { createClient } = require('@supabase/supabase-js');

const NEW_URL = 'https://zfzpjlxbhvsofhbcoyxr.supabase.co';
const NEW_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpmenBqbHhiaHZzb2ZoYmNveXhyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MzA5MTY5NywiZXhwIjoyMDk4NjY3Njk3fQ.7UET_XEoM4mOC1j7uey3zDSvgxf3_B7p9ONZz0DsshM';

const OLD_URL = 'https://ajikchaxkmxcyuecqmce.supabase.co';
const OLD_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFqaWtjaGF4a214Y3l1ZWNxbWNlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTk5Mjg5NSwiZXhwIjoyMDg3NTY4ODk1fQ.f8_AK5RIRXSwsq3RiVAE3LLseo-tiJUgULRzTnAnW70';

const newSb = createClient(NEW_URL, NEW_KEY);
const oldSb = createClient(OLD_URL, OLD_KEY);

const tables = [
  'bpc_pressure',
  'brake_fault_event',
  'coaches_hams',
  'coaches_railway',
  'event_publish',
  'pressure_calibration',
  'pressure_logs'
];

const BATCH = 500;

async function transferTable(table) {
  try {
    const { count } = await newSb.from(table).select('*', { count: 'exact', head: true });
    if (!count || count === 0) {
      console.log(`${table}: 0 rows in new, skip`);
      return;
    }

    let offset = 0;
    let inserted = 0;

    while (offset < count) {
      const { data: rows, error: readErr } = await newSb.from(table).select('*').range(offset, offset + BATCH - 1);
      if (readErr || !rows || rows.length === 0) {
        console.log(`${table}: read error at ${offset} - ${readErr?.message}`);
        break;
      }

      const { error: writeErr } = await oldSb.from(table).insert(rows);
      if (writeErr) {
        console.log(`${table}: write error at ${offset} - ${writeErr.message}`);
        break;
      }

      inserted += rows.length;
      offset += BATCH;
    }

    console.log(`${table}: ${inserted}/${count} rows transferred`);
  } catch (e) {
    console.log(`${table}: ERROR - ${e.message}`);
  }
}

async function main() {
  console.log('Transferring 7 tables from new Supabase to old Supabase...\n');
  for (const table of tables) {
    await transferTable(table);
  }
  console.log('\nDONE');
}

main().catch(console.error);
