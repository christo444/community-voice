"""
Script to create the default admin account directly in Supabase.
Run this if the SQL migration didn't work or to create additional admins.
"""

from supabase import create_client, Client
import bcrypt
import os
from dotenv import load_dotenv

load_dotenv()

# Initialize Supabase
SUPABASE_URL = os.getenv('SUPABASE_URL', 'https://wzpfhmngcfwrbgzcdymv.supabase.co')
SUPABASE_KEY = os.getenv('SUPABASE_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6cGZobW5nY2Z3cmJnemNkeW12Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyNjA5NjgsImV4cCI6MjA4NTgzNjk2OH0.x_ivRdyK1HPT43vJq8B0p0D2jcZXO0dunnipMAPcP7E')

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def hash_password(password):
    """Hash a password using bcrypt"""
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def create_default_admin():
    """Create the default super admin account"""
    try:
        # Check if admin already exists
        existing = supabase.table('admins').select('id').eq('email', 'admin@communityvoice.com').execute()
        
        if existing.data and len(existing.data) > 0:
            print("❌ Default admin already exists!")
            print("   Email: admin@communityvoice.com")
            print("   If you forgot the password, you can update it directly in Supabase.")
            return False
        
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
            print("=" * 50)
            print("DEFAULT ADMIN CREDENTIALS")
            print("=" * 50)
            print(f"Email: admin@communityvoice.com")
            print(f"Password: {password}")
            print("=" * 50)
            print()
            print("⚠️  IMPORTANT: Change this password after first login!")
            return True
        else:
            print("❌ Failed to create admin account")
            return False
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return False

def create_custom_admin():
    """Create a custom admin account"""
    try:
        print("\n=== Create Custom Admin Account ===\n")
        
        email = input("Email: ").strip()
        password = input("Password: ").strip()
        full_name = input("Full Name: ").strip()
        is_super_admin_input = input("Is Super Admin? (y/n): ").strip().lower()
        
        if not email or not password or not full_name:
            print("❌ All fields are required!")
            return False
        
        is_super_admin = is_super_admin_input == 'y'
        
        # Check if admin already exists
        existing = supabase.table('admins').select('id').eq('email', email).execute()
        
        if existing.data and len(existing.data) > 0:
            print(f"❌ Admin with email {email} already exists!")
            return False
        
        # Create admin
        password_hash = hash_password(password)
        
        admin_data = {
            'email': email,
            'password_hash': password_hash,
            'full_name': full_name,
            'is_super_admin': is_super_admin,
            'is_active': True
        }
        
        result = supabase.table('admins').insert(admin_data).execute()
        
        if result.data:
            print(f"\n✅ Admin account created successfully!")
            print(f"   Email: {email}")
            print(f"   Name: {full_name}")
            print(f"   Super Admin: {is_super_admin}")
            return True
        else:
            print("❌ Failed to create admin account")
            return False
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return False

def list_admins():
    """List all admin accounts"""
    try:
        result = supabase.table('admins').select('email, full_name, is_super_admin, is_active, created_at').execute()
        
        if result.data:
            print("\n=== Admin Accounts ===\n")
            for idx, admin in enumerate(result.data, 1):
                print(f"{idx}. {admin['full_name']} ({admin['email']})")
                print(f"   Super Admin: {admin['is_super_admin']}")
                print(f"   Active: {admin['is_active']}")
                print(f"   Created: {admin['created_at']}")
                print()
        else:
            print("\n❌ No admin accounts found")
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")

def main():
    print("╔═══════════════════════════════════════════╗")
    print("║   Admin Account Management Script        ║")
    print("╚═══════════════════════════════════════════╝")
    print()
    
    while True:
        print("\nOptions:")
        print("1. Create default admin (admin@communityvoice.com)")
        print("2. Create custom admin")
        print("3. List all admins")
        print("4. Exit")
        print()
        
        choice = input("Select option (1-4): ").strip()
        
        if choice == '1':
            create_default_admin()
        elif choice == '2':
            create_custom_admin()
        elif choice == '3':
            list_admins()
        elif choice == '4':
            print("\nGoodbye!")
            break
        else:
            print("❌ Invalid option. Please try again.")

if __name__ == '__main__':
    print("\n📋 Checking Supabase connection...")
    try:
        # Test connection
        test = supabase.table('admins').select('count').execute()
        print("✅ Connected to Supabase successfully!\n")
    except Exception as e:
        print(f"❌ Failed to connect to Supabase: {str(e)}")
        print("\nPlease check your SUPABASE_URL and SUPABASE_KEY in .env file")
        exit(1)
    
    main()
