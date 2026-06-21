'use strict';

const { createClient } = require('@supabase/supabase-js');
const logger = require('./logger');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY; // service_role key — bypasses RLS for backend use

if (!supabaseUrl || !supabaseKey || supabaseKey === 'your_service_role_key_here') {
  logger.warn('SUPABASE_SERVICE_KEY is not set. Database will not function. Add it to .env');
}

const supabase = createClient(supabaseUrl || 'https://placeholder.supabase.co', supabaseKey || 'placeholder', {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  }
});

module.exports = { supabase };

