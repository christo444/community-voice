from flask import Flask, request, jsonify
from flask_cors import CORS
from supabase import create_client, Client
import bcrypt
import os
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)

# Initialize Supabase
SUPABASE_URL = os.getenv('SUPABASE_URL', 'https://wzpfhmngcfwrbgzcdymv.supabase.co')
SUPABASE_KEY = os.getenv('SUPABASE_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6cGZobW5nY2Z3cmJnemNkeW12Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyNjA5NjgsImV4cCI6MjA4NTgzNjk2OH0.x_ivRdyK1HPT43vJq8B0p0D2jcZXO0dunnipMAPcP7E')

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def hash_password(password):
    """Hash a password using bcrypt"""
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def verify_password(password, hashed):
    """Verify a password against its hash"""
    return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))

# ==================== HEALTH CHECK ====================
@app.route('/')
def health_check():
    return jsonify({
        'status': 'Admin Dashboard API is running',
        'version': '1.0.0'
    })

# ==================== AUTHENTICATION ====================
@app.route('/api/admin/auth/login', methods=['POST'])
def admin_login():
    """Login endpoint for admins"""
    try:
        data = request.json
        email = data.get('email')
        password = data.get('password')
        
        if not email or not password:
            return jsonify({
                'success': False,
                'error': 'Email and password are required'
            }), 400
        
        # Get admin by email
        response = supabase.table('admins').select('*').eq('email', email).execute()
        
        if not response.data or len(response.data) == 0:
            return jsonify({
                'success': False,
                'error': 'Invalid email or password'
            }), 401
        
        admin = response.data[0]
        
        # Check if account is active
        if not admin.get('is_active', False):
            return jsonify({
                'success': False,
                'error': 'Your account has been deactivated. Please contact super admin.'
            }), 403
        
        # Verify password
        if not verify_password(password, admin['password_hash']):
            return jsonify({
                'success': False,
                'error': 'Invalid email or password'
            }), 401
        
        # Update last login
        supabase.table('admins').update({
            'last_login': datetime.now().isoformat()
        }).eq('id', admin['id']).execute()
        
        # Return admin data (exclude password)
        admin_data = {
            'id': admin['id'],
            'email': admin['email'],
            'full_name': admin['full_name'],
            'is_super_admin': admin.get('is_super_admin', False),
            'is_active': admin.get('is_active', True)
        }
        
        return jsonify({
            'success': True,
            'data': admin_data,
            'message': 'Login successful'
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

if __name__ == '__main__':
    app.run(debug=True, port=5002)
