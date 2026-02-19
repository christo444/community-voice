from flask import Flask, request, jsonify
from flask_cors import CORS
from supabase import create_client, Client
import bcrypt
import os
from datetime import datetime
from dotenv import load_dotenv
import secrets
import string

load_dotenv()

app = Flask(__name__)
CORS(app)

# Initialize Supabase
SUPABASE_URL = os.getenv('SUPABASE_URL', 'https://wzpfhmngcfwrbgzcdymv.supabase.co')
SUPABASE_KEY = os.getenv('SUPABASE_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6cGZobW5nY2Z3cmJnemNkeW12Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyNjA5NjgsImV4cCI6MjA4NTgzNjk2OH0.x_ivRdyK1HPT43vJq8B0p0D2jcZXO0dunnipMAPcP7E')

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def generate_password(length=12):
    """Generate a secure random password"""
    characters = string.ascii_letters + string.digits + "!@#$%"
    return ''.join(secrets.choice(characters) for _ in range(length))

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
        'status': 'Paralegal Dashboard API is running',
        'version': '1.0.0'
    })

# ==================== AUTHENTICATION ====================
@app.route('/api/auth/login', methods=['POST'])
def login():
    """Login endpoint for paralegals"""
    try:
        data = request.json
        email = data.get('email')
        password = data.get('password')
        
        if not email or not password:
            return jsonify({
                'success': False,
                'error': 'Email and password are required'
            }), 400
        
        # Get paralegal by email
        response = supabase.table('paralegals').select('*').eq('email', email).execute()
        
        if not response.data or len(response.data) == 0:
            return jsonify({
                'success': False,
                'error': 'Invalid email or password'
            }), 401
        
        paralegal = response.data[0]
        
        # Check if account is active
        if not paralegal.get('is_active', False):
            return jsonify({
                'success': False,
                'error': 'Your account has been deactivated. Please contact admin.'
            }), 403
        
        # Verify password
        if not verify_password(password, paralegal['password_hash']):
            return jsonify({
                'success': False,
                'error': 'Invalid email or password'
            }), 401
        
        # Update last login
        supabase.table('paralegals').update({
            'last_login': datetime.now().isoformat()
        }).eq('id', paralegal['id']).execute()
        
        # Return paralegal data (exclude password)
        paralegal_data = {
            'id': paralegal['id'],
            'email': paralegal['email'],
            'name': paralegal['name'],
            'qualification': paralegal['qualification'],
            'phone_number': paralegal.get('phone_number'),
            'must_reset_password': paralegal.get('must_reset_password', False)
        }
        
        return jsonify({
            'success': True,
            'data': paralegal_data
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/auth/reset-password', methods=['POST'])
def reset_password():
    """Reset password for paralegal (first-time login)"""
    try:
        data = request.json
        paralegal_id = data.get('paralegal_id')
        current_password = data.get('current_password')
        new_password = data.get('new_password')
        
        if not paralegal_id or not current_password or not new_password:
            return jsonify({
                'success': False,
                'error': 'All fields are required'
            }), 400
        
        # Validate new password strength
        if len(new_password) < 8:
            return jsonify({
                'success': False,
                'error': 'Password must be at least 8 characters long'
            }), 400
        
        # Get paralegal
        response = supabase.table('paralegals').select('*').eq('id', paralegal_id).execute()
        
        if not response.data or len(response.data) == 0:
            return jsonify({
                'success': False,
                'error': 'Paralegal not found'
            }), 404
        
        paralegal = response.data[0]
        
        # Verify current password
        if not verify_password(current_password, paralegal['password_hash']):
            return jsonify({
                'success': False,
                'error': 'Current password is incorrect'
            }), 401
        
        # Hash new password
        new_password_hash = hash_password(new_password)
        
        # Update password and reset flag
        supabase.table('paralegals').update({
            'password_hash': new_password_hash,
            'must_reset_password': False
        }).eq('id', paralegal_id).execute()
        
        return jsonify({
            'success': True,
            'message': 'Password updated successfully'
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

# ==================== PARALEGAL REQUESTS ====================
@app.route('/api/paralegal/requests', methods=['GET'])
def get_paralegal_requests():
    """Get all paralegal requests (for admin)"""
    try:
        status = request.args.get('status', 'pending')
        
        response = supabase.table('paralegal_requests').select('*').eq('status', status).order('created_at', desc=True).execute()
        
        return jsonify({
            'success': True,
            'data': response.data
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/paralegal/requests/<request_id>/approve', methods=['POST'])
def approve_paralegal_request(request_id):
    """Approve a paralegal request and create login credentials"""
    try:
        data = request.json
        admin_email = data.get('admin_email')
        
        # Get the request details
        req_response = supabase.table('paralegal_requests').select('*').eq('id', request_id).single().execute()
        
        if not req_response.data:
            return jsonify({'success': False, 'error': 'Request not found'}), 404
        
        request_data = req_response.data
        
        # Generate temporary password
        temp_password = generate_password()
        hashed_password = hash_password(temp_password)
        
        # Create paralegal account
        paralegal_data = {
            'email': request_data['email'],
            'password_hash': hashed_password,
            'name': request_data['name'],
            'qualification': request_data['qualification'],
            'phone_number': request_data.get('phone_number'),
            'is_active': True,
            'must_reset_password': True
        }
        
        paralegal_response = supabase.table('paralegals').insert(paralegal_data).execute()
        
        # Update request status
        supabase.table('paralegal_requests').update({
            'status': 'approved',
            'reviewed_at': datetime.now().isoformat(),
            'reviewed_by': admin_email
        }).eq('id', request_id).execute()
        
        # TODO: Send email with credentials
        # For now, return the temp password to admin
        
        return jsonify({
            'success': True,
            'message': 'Paralegal approved successfully',
            'email': request_data['email'],
            'temporary_password': temp_password
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/paralegal/requests/<request_id>/reject', methods=['POST'])
def reject_paralegal_request(request_id):
    """Reject a paralegal request"""
    try:
        data = request.json
        rejection_reason = data.get('rejection_reason', '')
        admin_email = data.get('admin_email')
        
        supabase.table('paralegal_requests').update({
            'status': 'rejected',
            'rejection_reason': rejection_reason,
            'reviewed_at': datetime.now().isoformat(),
            'reviewed_by': admin_email
        }).eq('id', request_id).execute()
        
        # TODO: Send rejection email
        
        return jsonify({
            'success': True,
            'message': 'Request rejected'
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

# ==================== PARALEGALS MANAGEMENT ====================
@app.route('/api/paralegals', methods=['GET'])
def get_paralegals():
    """Get all approved paralegals"""
    try:
        response = supabase.table('paralegals').select('id, email, name, qualification, phone_number, is_active, created_at').order('created_at', desc=True).execute()
        
        return jsonify({
            'success': True,
            'data': response.data
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/paralegals/<paralegal_id>/toggle-status', methods=['POST'])
def toggle_paralegal_status(paralegal_id):
    """Activate or deactivate a paralegal"""
    try:
        data = request.json
        is_active = data.get('is_active', True)
        
        supabase.table('paralegals').update({
            'is_active': is_active
        }).eq('id', paralegal_id).execute()
        
        return jsonify({
            'success': True,
            'message': 'Status updated successfully'
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

# ==================== CASE MANAGEMENT ====================
@app.route('/api/cases', methods=['POST'])
def assign_case():
    """Assign a user to a paralegal"""
    try:
        data = request.json
        paralegal_id = data.get('paralegal_id')
        user_phone_number = data.get('user_phone_number')
        
        case_data = {
            'paralegal_id': paralegal_id,
            'user_phone_number': user_phone_number,
            'status': 'open'
        }
        
        response = supabase.table('paralegal_cases').insert(case_data).execute()
        
        return jsonify({
            'success': True,
            'message': 'Case assigned successfully',
            'data': response.data
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/cases/<case_id>', methods=['GET'])
def get_case(case_id):
    """Get case details"""
    try:
        response = supabase.table('paralegal_cases').select('*, profile:profile_details!paralegal_cases_user_phone_number_fkey(*)').eq('id', case_id).single().execute()
        
        return jsonify({
            'success': True,
            'data': response.data
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/users', methods=['GET'])
def get_users():
    """Get all users from profile_details for assignment"""
    try:
        response = supabase.table('profile_details').select('phone_number, name, age, gender').order('created_at', desc=True).execute()
        
        return jsonify({
            'success': True,
            'data': response.data
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

if __name__ == '__main__':
    app.run(debug=True, port=5001)
