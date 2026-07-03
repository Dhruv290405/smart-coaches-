const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

let supabaseAdmin = null;

if (supabaseUrl && supabaseServiceKey) {
  supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);
  console.log('✅ Supabase admin client initialized (service_role)');
} else {
  console.warn('⚠️ SUPABASE_SERVICE_ROLE_KEY not set. FSDS writes will fail.');
}

module.exports = supabaseAdmin;
