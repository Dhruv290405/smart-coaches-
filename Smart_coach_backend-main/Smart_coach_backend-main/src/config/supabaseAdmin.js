const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

// NEW Supabase (primary — all reads go here, has all historical data)
const supabaseAdmin = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

module.exports = supabaseAdmin;
