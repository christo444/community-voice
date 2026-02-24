"""
Setup Admin Table in Supabase
This script creates the admin table and default admin account using Supabase Python client.
Run this if you can't execute SQL migrations directly.
"""

from supabase import create_client, Client
import bcrypt
import os
from dotenv import load_dotenv

load_dotenv()

# Initialize Supabase
SUPABASE_URL = os.getenv('SUPABASE_URL', 'https://wzpfhmngcfwrbgzcdymv.supabase.co')
SUPABASE_KEY = os.getenv('SUPABASE_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6cGZobW5nY2Z3cmJnemNkeW12Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyNjA5NjgsImV4cCI6MjA4NTgzNjk2OH0.x_ivRdyK1HPT43vJq8B0p0D2jcZXO0dunnipMAPcP7E')

# SQL to create the admin table
CREATE_TABLE_SQL = """
-- Create Admin Table for Admin Dashboard Authentication

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

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
DROP POLICY IF EXISTS "Allow all for admins" ON admins;
CREATE POLICY "Allow all for admins" ON admins FOR ALL USING (true);

-- Add comments for documentation
COMMENT ON TABLE admins IS 'Stores admin users who can login to the admin dashboard';
COMMENT ON COLUMN admins.is_super_admin IS 'Super admin has additional privileges like creating other admins';
COMMENT ON COLUMN admins.created_by IS 'Reference to the admin who created this admin account';
"""

def hash_password(password):
    """Hash a password using bcrypt"""
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def setup_admin_table():
    """Create admin table and default admin account"""
    try:
        print("=" * 60)
        print("SUPABASE ADMIN TABLE SETUP")
        print("=" * 60)
        print()
        
        print("📋 Step 1: Connecting to Supabase...")
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("✅ Connected successfully!")
        print()
        
        print("📋 Step 2: Creating admin table...")
        print()
        print("⚠️  IMPORTANT: You need to run the SQL migration manually.")
        print("   The Supabase Python client cannot create tables directly.")
        print()
        print("=" * 60)
        print("OPTION 1: Using Supabase Dashboard (RECOMMENDED)")
        print("=" * 60)
        print("1. Go to: https://supabase.com/dashboard/project/wzpfhmngcfwrbgzcdymv/sql")
        print("2. Create a new query")
        print("3. Copy and paste the SQL from:")
        print("   supabase/migrations/003_create_admin_table.sql")
        print("4. Click 'Run' to execute")
        print()
        
        print("=" * 60)
        print("OPTION 2: Copy SQL Below")
        print("=" * 60)
        print()
        print(CREATE_TABLE_SQL)
        print()
        
        input("Press Enter after you've created the table in Supabase...")
        print()
        
        print("📋 Step 3: Checking if admin table exists...")
        try:
            result = supabase.table('admins').select('count').execute()
            print("✅ Admin table exists!")
            print()
        except Exception as e:
            print(f"❌ Admin table not found: {str(e)}")
            print("   Please create the table using the SQL above.")
            return False
        
        print("📋 Step 4: Creating default admin account...")
        
        # Check if default admin already exists
        existing = supabase.table('admins').select('id').eq('email', 'admin@communityvoice.com').execute()
        
        if existing.data and len(existing.data) > 0:
            print("⚠️  Default admin already exists!")
            print()
        else:
            # Create default admin
            password = "Admin@123"
            password_hash = hash_password(password)
            
            admin_data = {
                'email': 'admin@communityvoice.com',
                'password_hash': password_hash,
                'full_name': 'System Administrator',
                'is_super_admin': True,
                'is_active': True
            }
            
            result = supabase.table('admins').insert(admin_data).execute()
            
            if result.data:
                print("✅ Default admin account created successfully!")
                print()
        
        print("=" * 60)
        print("SETUP COMPLETE!")
        print("=" * 60)
        print()
        print("📧 Email: admin@communityvoice.com")
        print("🔑 Password: Admin@123")
        print()
        print("⚠️  Please change this password after first login!")
        print()
        print("🚀 You can now start the admin API server:")
        print("   python admin_app.py")
        print()
        
        return True
        
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return False

if __name__ == '__main__':
    setup_admin_table()
