"""
Admin Password Hash Generator
Use this script to generate bcrypt password hashes for admin accounts.
"""

import bcrypt

def generate_password_hash(password):
    """Generate a bcrypt hash for the given password"""
    salt = bcrypt.gensalt()
    password_hash = bcrypt.hashpw(password.encode('utf-8'), salt)
    return password_hash.decode('utf-8')

def verify_password(password, hash_string):
    """Verify a password against a hash"""
    return bcrypt.checkpw(password.encode('utf-8'), hash_string.encode('utf-8'))

if __name__ == '__main__':
    print("=== Admin Password Hash Generator ===\n")
    
    # Generate hash for default password
    default_password = "Admin@123"
    default_hash = generate_password_hash(default_password)
    
    print(f"Default Password: {default_password}")
    print(f"Generated Hash: {default_hash}")
    print()
    
    # Verify it works
    is_valid = verify_password(default_password, default_hash)
    print(f"Verification Test: {'✓ PASSED' if is_valid else '✗ FAILED'}")
    print()
    
    # Interactive mode
    print("=" * 50)
    print("Generate custom password hash:")
    print("=" * 50)
    
    try:
        custom_password = input("Enter password (or press Enter to skip): ").strip()
        
        if custom_password:
            custom_hash = generate_password_hash(custom_password)
            print(f"\nPassword: {custom_password}")
            print(f"Hash: {custom_hash}")
            print("\nCopy this hash to your SQL migration or use it in your admin creation API call.")
    except KeyboardInterrupt:
        print("\n\nExiting...")

print("\n=== Usage Instructions ===")
print("1. Install bcrypt: pip install bcrypt")
print("2. Run this script: python generate_admin_password.py")
print("3. Copy the generated hash to your migration file or API call")
