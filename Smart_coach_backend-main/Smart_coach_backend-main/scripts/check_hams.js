const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

const url = 'https://ajikchaxkmxcyuecqmce.supabase.co';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFqaWtjaGF4a214Y3l1ZWNxbWNlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTk5Mjg5NSwiZXhwIjoyMDg3NTY4ODk1fQ.f8_AK5RIRXSwsq3RiVAE3LLseo-tiJUgULRzTnAnW70';

async function checkHams() {
  const client = createClient(url, key);
  const { data, error } = await client.from('coaches_hams').select('*');
  if (error) {
    console.error(error);
    return;
  }
  console.log('coaches_hams data:', data);
}

checkHams();
