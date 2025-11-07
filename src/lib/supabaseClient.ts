import { createClient } from '@supabase/supabase-js';

// ✅ Support both VITE_ (current) and PUBLIC_ (future SvelteKit)
const supabaseUrl =
  import.meta.env.VITE_SUPABASE_URL || import.meta.env.PUBLIC_SUPABASE_URL;
const supabaseKey =
  import.meta.env.VITE_SUPABASE_ANON_KEY || import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Missing Supabase environment variables.');
  throw new Error('Supabase configuration missing.');
}

export const supabase = createClient(supabaseUrl, supabaseKey);
