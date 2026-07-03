// src/config/supabaseAcp.js
// Dedicated Supabase client for the ACP IoT project (separate from the main Supabase project)
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const acpSupabaseUrl = process.env.ACP_SUPABASE_URL;
const acpSupabaseKey = process.env.ACP_SUPABASE_SERVICE_KEY || process.env.ACP_SUPABASE_ANON_KEY;

let acpSupabase = null;

if (acpSupabaseUrl && acpSupabaseKey) {
    acpSupabase = createClient(acpSupabaseUrl, acpSupabaseKey);
    console.log('✅ ACP Supabase client initialized (project: qcycuwfohxmdatrtawlw).');
} else {
    console.warn('⚠️  ACP_SUPABASE_URL or ACP_SUPABASE_SERVICE_KEY not set. ACP IoT real-time data will not work.');
}

module.exports = acpSupabase;
