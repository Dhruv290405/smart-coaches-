// src/config/supabaseOdour2.js
// Dedicated Supabase client for the Bad Odour "Section 2" project (separate DB)
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const odour2SupabaseUrl = process.env.ODOUR2_SUPABASE_URL;
const odour2SupabaseKey = process.env.ODOUR2_SUPABASE_SERVICE_KEY || process.env.ODOUR2_SUPABASE_ANON_KEY;

let odour2Supabase = null;

if (odour2SupabaseUrl && odour2SupabaseKey) {
    odour2Supabase = createClient(odour2SupabaseUrl, odour2SupabaseKey);
    console.log('✅ Odour Section 2 Supabase client initialized (project: cxzzmfqxyxondlzledjn).');
} else {
    console.warn('⚠️  ODOUR2_SUPABASE_URL or ODOUR2_SUPABASE_SERVICE_KEY not set. Odour Section 2 data will not work.');
}

module.exports = odour2Supabase;
