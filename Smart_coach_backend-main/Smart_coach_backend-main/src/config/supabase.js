//src/config/supabase.js
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;

let supabase = null;

if (supabaseUrl && supabaseKey) {
  supabase = createClient(supabaseUrl, supabaseKey);
  console.log('✅ Supabase client initialized.');
} else {
  console.warn('⚠️  SUPABASE_URL or SUPABASE_ANON_KEY not set. Pneumatic/Notification Supabase endpoints will be limited.');
}

module.exports = supabase;