const supabaseAdmin = require("./supabaseAdmin");

// Writing ONLY to new Supabase (primary)
// Old Supabase is no longer used for writes
console.log('✅ Writing to new Supabase only (old Supabase removed)');

async function dualInsert(table, rows) {
  const { data, error } = await supabaseAdmin.from(table).insert(rows).select();
  if (error) console.error(`[NEW] insert ${table}:`, error.message);
  return data;
}

async function dualUpdate(table, matchCol, matchVal, updateData) {
  const { error } = await supabaseAdmin.from(table).update(updateData).eq(matchCol, matchVal);
  if (error) console.error(`[NEW] update ${table}:`, error.message);
}

async function dualUpsert(table, rows, onConflict) {
  const { error } = await supabaseAdmin.from(table).upsert(rows, { onConflict });
  if (error) console.error(`[NEW] upsert ${table}:`, error.message);
}

module.exports = { dualInsert, dualUpdate, dualUpsert };
