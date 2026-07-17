const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.OLD_SUPABASE_URL;
const supabaseKey = process.env.OLD_SUPABASE_SERVICE_ROLE_KEY;

let supabaseOld = null;

if (supabaseUrl && supabaseKey) {
  supabaseOld = createClient(supabaseUrl, supabaseKey);
  console.log('✅ Old Supabase client initialized.');
} else {
  console.warn('⚠️  OLD_SUPABASE_URL or OLD_SUPABASE_SERVICE_ROLE_KEY not set. Pneumatic endpoints will be limited.');
}

module.exports = supabaseOld;
