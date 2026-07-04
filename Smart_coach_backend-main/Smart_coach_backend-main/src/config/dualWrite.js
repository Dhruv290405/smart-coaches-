const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseNew = require('./supabaseAdmin');

let supabaseOld = null;
if (process.env.OLD_SUPABASE_URL && process.env.OLD_SUPABASE_SERVICE_ROLE_KEY) {
  supabaseOld = createClient(
    process.env.OLD_SUPABASE_URL,
    process.env.OLD_SUPABASE_SERVICE_ROLE_KEY
  );
  console.log('✅ Dual-write active: old + new Supabase');
} else {
  console.log('⚠️ OLD_SUPABASE not set');
}

async function dualInsert(table, rows) {
  const { data, error: errNew } = await supabaseNew.from(table).insert(rows).select();
  if (errNew) console.error(`[NEW] insert ${table}:`, errNew.message);

  if (supabaseOld) {
    const { error: errOld } = await supabaseOld.from(table).insert(rows);
    if (errOld) console.error(`[OLD] insert ${table}:`, errOld.message);
  }
  return data;
}

async function dualUpdate(table, matchCol, matchVal, updateData) {
  const { error: errNew } = await supabaseNew.from(table).update(updateData).eq(matchCol, matchVal);
  if (errNew) console.error(`[NEW] update ${table}:`, errNew.message);

  if (supabaseOld) {
    const { error: errOld } = await supabaseOld.from(table).update(updateData).eq(matchCol, matchVal);
    if (errOld) console.error(`[OLD] update ${table}:`, errOld.message);
  }
}

async function dualUpsert(table, rows, onConflict) {
  const { error: errNew } = await supabaseNew.from(table).upsert(rows, { onConflict });
  if (errNew) console.error(`[NEW] upsert ${table}:`, errNew.message);

  if (supabaseOld) {
    const { error: errOld } = await supabaseOld.from(table).upsert(rows, { onConflict });
    if (errOld) console.error(`[OLD] upsert ${table}:`, errOld.message);
  }
}

module.exports = { dualInsert, dualUpdate, dualUpsert };
