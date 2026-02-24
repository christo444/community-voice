-- Create Admin Table for Admin Dashboard Authentication
-- Created: 2026-02-23

-- 1. Admin Table
CREATE TABLE IF NOT EXISTS admins (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name TEXT NOT NULL,
  is_super_admin BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login TIMESTAMP WITH TIME ZONE,
  created_by UUID REFERENCES admins(id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_admins_email ON admins(email);
CREATE INDEX IF NOT EXISTS idx_admins_is_active ON admins(is_active);

-- Enable Row Level Security
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- Create policies (allow all for development - refine in production)
-- Use DO block to safely create policy without destructive DROP
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'admins' 
    AND policyname = 'Allow all for admins'
  ) THEN
    CREATE POLICY "Allow all for admins" ON admins FOR ALL USING (true);
  END IF;
END $$;

-- Add comments for documentation
COMMENT ON TABLE admins IS 'Stores admin users who can login to the admin dashboard';
COMMENT ON COLUMN admins.is_super_admin IS 'Super admin has additional privileges like creating other admins';
COMMENT ON COLUMN admins.created_by IS 'Reference to the admin who created this admin account';

-- Note: Default admin account creation
-- The password hash below is for 'Admin@123'
-- If this doesn't work, use the create_admin_account.py script to create the default admin

-- Insert default super admin (password: Admin@123)
INSERT INTO admins (email, password_hash, full_name, is_super_admin, is_active)
VALUES (
  'admin@communityvoice.com',
  '$2b$12$LQv3c1yqBWVHxkd0LHAkMOvKvHZnZZdQGMvJBZJhZx8KqjPvK7XPe',
  'System Administrator',
  true,
  true
)
ON CONFLICT (email) DO NOTHING;
