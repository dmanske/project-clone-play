
import { createClient } from '@supabase/supabase-js';
import { Database } from '@/types/supabase';

// Use the same values as in the integrations file
const supabaseUrl = 'https://uflozqxlbkkqaghmzsyt.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVmbG96cXhsYmtrcWFnaG16c3l0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY3Njg3NzksImV4cCI6MjA3MjM0NDc3OX0.0WOHzhG_g9LGSAhxI0MGGJZ0qhK-4ry-uvNGrAJo-IE';

export const supabase = createClient<Database>(
  supabaseUrl,
  supabaseAnonKey
);
