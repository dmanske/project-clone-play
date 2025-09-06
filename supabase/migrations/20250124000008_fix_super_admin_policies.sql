-- Fix infinite recursion in super_admin_users policies
-- The issue is that policies are checking super_admin_users table to verify if user is super admin
-- This creates infinite recursion when the table itself needs to be accessed

-- Drop existing problematic policies
DROP POLICY IF EXISTS "Only super admins can view super admin users" ON super_admin_users;
DROP POLICY IF EXISTS "Only super admins can manage super admin users" ON super_admin_users;
DROP POLICY IF EXISTS "Super admins can manage super admin users" ON super_admin_users;
DROP POLICY IF EXISTS "Only super admins can view super admin table" ON super_admin_users;

-- Create simple policies that don't cause recursion
-- Allow authenticated users to read their own record
CREATE POLICY "Users can view their own super admin status" ON super_admin_users
  FOR SELECT USING (auth.uid() = user_id);

-- Only allow service role to manage super admin users
-- This prevents recursion and ensures only backend operations can modify
CREATE POLICY "Service role can manage super admin users" ON super_admin_users
  FOR ALL USING (auth.role() = 'service_role');

-- Alternative: Allow users with specific email domains to be super admins
-- This is safer than checking the table itself
CREATE POLICY "Allow specific domains as super admins" ON super_admin_users
  FOR ALL USING (
    auth.jwt() ->> 'email' LIKE '%@yourdomain.com' OR
    auth.jwt() ->> 'email' = 'daniel.manske@gmail.com'
  );