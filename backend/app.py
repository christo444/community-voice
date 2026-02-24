from flask import Flask, request, jsonify
from flask_cors import CORS
from routes.schemes import schemes_bp
import os
from datetime import datetime
from dotenv import load_dotenv

# Import admin authentication functions if available
try:
    from supabase import create_client, Client
    import bcrypt
    SUPABASE_AVAILABLE = True
except ImportError:
    SUPABASE_AVAILABLE = False
    print("Warning: supabase or bcrypt not installed. Admin auth will not work.")
    print("Install with: pip install supabase bcrypt")

load_dotenv()

app = Flask(__name__)
CORS(app)  # Enable CORS for React frontend

# Initialize Supabase for admin auth
if SUPABASE_AVAILABLE:
    SUPABASE_URL = os.getenv('SUPABASE_URL', 'https://wzpfhmngcfwrbgzcdymv.supabase.co')
    SUPABASE_KEY = os.getenv('SUPABASE_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6cGZobW5nY2Z3cmJnemNkeW12Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyNjA5NjgsImV4cCI6MjA4NTgzNjk2OH0.x_ivRdyK1HPT43vJq8B0p0D2jcZXO0dunnipMAPcP7E')
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    def hash_password(password):
        """Hash a password using bcrypt"""
        return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    
    def verify_password(password, hashed):
        """Verify a password against its hash"""
        return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))

# Register blueprints
app.register_blueprint(schemes_bp, url_prefix='/api/schemes')

# Create necessary directories
os.makedirs('data', exist_ok=True)
os.makedirs('uploads', exist_ok=True)

@app.route('/')
def health_check():
    return {'status': 'Admin Dashboard API is running', 'version': '1.0.0'}

# ==================== ADMIN AUTHENTICATION ====================
@app.route('/api/admin/auth/login', methods=['POST'])
def admin_login():
    """Login endpoint for admins"""
    if not SUPABASE_AVAILABLE:
        return jsonify({'success': False, 'error': 'Admin auth not configured'}), 500
    
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

@app.route('/api/admin/auth/change-password', methods=['POST'])
def change_password():
    """Change password for an admin"""
    if not SUPABASE_AVAILABLE:
        return jsonify({'success': False, 'error': 'Admin auth not configured'}), 500
    
    try:
        data = request.json
        admin_id = data.get('admin_id')
        current_password = data.get('current_password')
        new_password = data.get('new_password')
        
        if not admin_id or not current_password or not new_password:
            return jsonify({
                'success': False,
                'error': 'All fields are required'
            }), 400
        
        if len(new_password) < 8:
            return jsonify({
                'success': False,
                'error': 'New password must be at least 8 characters long'
            }), 400
        
        # Get admin
        response = supabase.table('admins').select('*').eq('id', admin_id).execute()
        
        if not response.data or len(response.data) == 0:
            return jsonify({
                'success': False,
                'error': 'Admin not found'
            }), 404
        
        admin = response.data[0]
        
        # Verify current password
        if not verify_password(current_password, admin['password_hash']):
            return jsonify({
                'success': False,
                'error': 'Current password is incorrect'
            }), 401
        
        # Hash new password and update
        new_hash = hash_password(new_password)
        supabase.table('admins').update({
            'password_hash': new_hash
        }).eq('id', admin_id).execute()
        
        return jsonify({
            'success': True,
            'message': 'Password changed successfully'
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)
