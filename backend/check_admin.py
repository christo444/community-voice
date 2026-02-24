"""
Check and fix admin login issues
"""
from supabase import create_client, Client
import bcrypt
import os
from dotenv import load_dotenv

load_dotenv()

SUPABASE_URL = os.getenv('SUPABASE_URL', 'https://wzpfhmngcfwrbgzcdymv.supabase.co')
SUPABASE_KEY = os.getenv('SUPABASE_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6cGZobW5nY2Z3cmJnemNkeW12Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyNjA5NjgsImV4cCI6MjA4NTgzNjk2OH0.x_ivRdyK1HPT43vJq8B0p0D2jcZXO0dunnipMAPcP7E')

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def hash_password(password):
    """Hash a password using bcrypt"""
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def verify_password(password, hashed):
    """Verify a password against its hash"""
    return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))

print("=" * 60)
print("Admin Account Diagnostics")
print("=" * 60)
print()

# Step 1: Check if table exists
print("📋 Step 1: Checking if admins table exists...")
try:
    result = supabase.table('admins').select('*').execute()
    print(f"✅ Table exists! Found {len(result.data)} admin(s)")
    print()
    
    if len(result.data) > 0:
        print("Current admins:")
        for admin in result.data:
            print(f"  - {admin['email']} ({admin['full_name']})")
        print()
    
except Exception as e:
    print(f"❌ Error: {str(e)}")
    print("   The admins table doesn't exist yet.")
    print("   Please run the SQL migration in Supabase.")
    exit(1)

# Step 2: Check if default admin exists
print("📋 Step 2: Checking default admin account...")
try:
    result = supabase.table('admins').select('*').eq('email', 'admin@communityvoice.com').execute()
    
    if len(result.data) == 0:
        print("❌ Default admin doesn't exist!")
        print("   Creating it now...")
        
        password = "Admin@123"
        password_hash = hash_password(password)
        
        admin_data = {
            'email': 'admin@communityvoice.com',
            'password_hash': password_hash,
            'full_name': 'System Administrator',
            'is_super_admin': True,
            'is_active': True
        }
        
        insert_result = supabase.table('admins').insert(admin_data).execute()
        
        if insert_result.data:
            print("✅ Default admin created successfully!")
            print()
        else:
            print("❌ Failed to create admin")
            exit(1)
    else:
        print("✅ Default admin exists!")
        admin = result.data[0]
        print(f"   Email: {admin['email']}")
        print(f"   Name: {admin['full_name']}")
        print(f"   Active: {admin['is_active']}")
        print(f"   Super Admin: {admin['is_super_admin']}")
        print()
        
except Exception as e:
    print(f"❌ Error: {str(e)}")
    exit(1)

# Step 3: Test password verification
print("📋 Step 3: Testing password verification...")
try:
    result = supabase.table('admins').select('*').eq('email', 'admin@communityvoice.com').execute()
    admin = result.data[0]
    
    test_password = "Admin@123"
    is_valid = verify_password(test_password, admin['password_hash'])
    
    if is_valid:
        print("✅ Password verification works!")
        print(f"   Test password '{test_password}' matches the hash")
    else:
        print("❌ Password verification FAILED!")
        print(f"   Test password '{test_password}' does NOT match the hash")
        print()
        print("   Fixing: Creating new password hash...")
        
        new_hash = hash_password(test_password)
        supabase.table('admins').update({
            'password_hash': new_hash
        }).eq('email', 'admin@communityvoice.com').execute()
        
        print("✅ Password hash updated! Try logging in again.")
    
    print()
    
except Exception as e:
    print(f"❌ Error: {str(e)}")
    exit(1)

# Step 4: Summary
print("=" * 60)
print("SUMMARY")
print("=" * 60)
print()
print("Login Credentials:")
print("  Email: admin@communityvoice.com")
print("  Password: Admin@123")
print()
print("API Endpoint:")
print("  http://localhost:5000/api/admin/auth/login")
print()
print("If you still can't login, check:")
print("  1. Backend server is running: python app.py")
print("  2. No errors in terminal when starting server")
print("  3. Browser console for any errors")
print()
