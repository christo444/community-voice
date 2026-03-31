from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_mail import Mail, Message
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

# Configure Flask-Mail
app.config['MAIL_SERVER'] = os.getenv('MAIL_SERVER', 'smtp.gmail.com')
app.config['MAIL_PORT'] = int(os.getenv('MAIL_PORT', 587))
app.config['MAIL_USE_TLS'] = os.getenv('MAIL_USE_TLS', 'True').lower() == 'true'
app.config['MAIL_USERNAME'] = os.getenv('MAIL_USERNAME', 'admincommunityvoice@gmail.com')
app.config['MAIL_PASSWORD'] = os.getenv('MAIL_PASSWORD', '')
app.config['MAIL_DEFAULT_SENDER'] = os.getenv('MAIL_DEFAULT_SENDER', 'admincommunityvoice@gmail.com')

mail = Mail(app)

# Initialize Supabase
SUPABASE_URL = os.getenv('SUPABASE_URL', 'https://wzpfhmngcfwrbgzcdymv.supabase.co')
SUPABASE_KEY = os.getenv('SUPABASE_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6cGZobW5nY2Z3cmJnemNkeW12Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyNjA5NjgsImV4cCI6MjA4NTgzNjk2OH0.x_ivRdyK1HPT43vJq8B0p0D2jcZXO0dunnipMAPcP7E')

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def send_paralegal_credentials_email(paralegal_email, paralegal_name, temp_password):
    """Send email with temporary password to paralegal"""
    try:
        subject = "Your Community Voice Account - Login Credentials"
        html_body = f"""
        <html>
            <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
                <div style="max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 5px;">
                    <h2 style="color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px;">Welcome to Community Voice</h2>

                    <p>Hi <strong>{paralegal_name}</strong>,</p>

                    <p>Your account has been approved by the admin. You can now login to the Community Voice paralegal dashboard using your email and the temporary password below.</p>

                    <div style="background-color: #ecf0f1; padding: 15px; margin: 20px 0; border-left: 4px solid #3498db; border-radius: 3px;">
                        <p style="margin: 5px 0;"><strong>Email:</strong> {paralegal_email}</p>
                        <p style="margin: 5px 0;"><strong>Temporary Password:</strong> <code style="background: #fff; padding: 5px 10px; border-radius: 3px; font-family: monospace; font-weight: bold;">{temp_password}</code></p>
                    </div>

                    <p style="background-color: #fff3cd; padding: 12px; border-radius: 3px; border-left: 4px solid #ffc107;">
                        <strong>Important:</strong> You will be required to change your password on your first login for security purposes.
                    </p>

                    <p>If you did not request this account or have any questions, please contact the admin immediately.</p>

                    <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;">
                    <p style="color: #7f8c8d; font-size: 12px;">This is an automated message. Please do not reply to this email.</p>
                </div>
            </body>
        </html>
        """

        msg = Message(
            subject=subject,
            recipients=[paralegal_email],
            html=html_body
        )

        mail.send(msg)
        print(f"Email sent successfully to {paralegal_email}")
        return True
    except Exception as e:
        print(f"Error sending email to {paralegal_email}: {str(e)}")
        return False

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

        # Send email with credentials to paralegal
        email_sent = send_paralegal_credentials_email(
            request_data['email'],
            request_data['name'],
            temp_password
        )

        return jsonify({
            'success': True,
            'message': 'Paralegal approved successfully',
            'email': request_data['email'],
            'temporary_password': temp_password,
            'email_sent': email_sent
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

@app.route('/api/user/request-help', methods=['POST'])
def request_paralegal_help():
    """User initiates a request for paralegal help"""
    try:
        data = request.json
        user_id = data.get('user_id') # Optional, if we have it
        scheme_name = data.get('scheme_name')
        name = data.get('name')
        phone_number = data.get('phone_number')
        location = data.get('location') # Place
        
        if not scheme_name or not name or not phone_number:
            return jsonify({
                'success': False,
                'error': 'Name, phone number, and scheme name are required'
            }), 400
            
        # Create a new case with status 'open' and paralegal_id NULL
        case_data = {
            'user_name': name,
            'user_phone_number': phone_number,
            'location': location,
            'scheme_name': scheme_name,
            'status': 'open',
            'paralegal_id': None, # explicitly explicit
            'assigned_at': datetime.now().isoformat(),
            # 'priority': 'medium' # removed as column not in schema by default
        }
        
        # If we have a user_id, link it? currently paralegal_cases might not link user_id directly
        # but relies on phone number. We'll just insert the data.
        
        response = supabase.table('paralegal_cases').insert(case_data).execute()
        
        return jsonify({
            'success': True,
            'message': 'Request sent for paralegal',
            'data': response.data
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/cases/<case_id>/reject', methods=['POST'])
def reject_case_assignment(case_id):
    """Paralegal rejects a specific case (hides it from their view)"""
    try:
        data = request.json
        paralegal_id = data.get('paralegal_id')
        reason = data.get('reason', '')
        
        if not paralegal_id:
            return jsonify({'success': False, 'error': 'Paralegal ID required'}), 400
            
        # Insert into case_rejections
        rejection_data = {
            'case_id': case_id,
            'paralegal_id': paralegal_id,
            'rejection_reason': reason,
            'rejected_at': datetime.now().isoformat()
        }
        
        try:
            supabase.table('case_rejections').insert(rejection_data).execute()
        except Exception as insert_error:
            # duplicate key error is fine, just ignore
            pass
            
        return jsonify({
            'success': True,
            'message': 'Case rejected'
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

# [REMOVED] get_users endpoint (was for assignment dropdown)

# ==================== CASE STATUS MANAGEMENT ====================
@app.route('/api/cases', methods=['GET'])
def get_all_cases():
    """Get all assigned cases (for admin dashboard) OR available cases (for paralegal)"""
    try:
        status = request.args.get('status', None)
        paralegal_id = request.args.get('paralegal_id', None)
        unassigned = request.args.get('unassigned', 'false').lower() == 'true'
        
        query = supabase.table('paralegal_cases').select('*').order('assigned_at', desc=True)
        # Note: removed profile join for simplicity as we store user details directly now
        # query = supabase.table('paralegal_cases').select('*, profile:profile_details!paralegal_cases_user_phone_number_fkey(*)').order('assigned_at', desc=True)
        
        if status:
            query = query.eq('status', status)
            
        if unassigned:
            # Fetch cases where paralegal_id is NULL
            query = query.is_('paralegal_id', 'null')
            
            # If a paralegal_id is provided, we must exclude cases they rejected.
            # Supabase-py doesn't support sophisticated subqueries in one go easily via the JS-like builder without stored procs or Views.
            # Best approach: Fetch all unassigned, then filter in Python (not efficient for scale, effective for MVP).
            
        elif paralegal_id:
            query = query.eq('paralegal_id', paralegal_id)
        
        response = query.execute()
        cases = response.data
        
        # Post-processing for unassigned cases (exclude rejections)
        if unassigned and paralegal_id:
            # Fetch rejections for this paralegal
            rejections_res = supabase.table('case_rejections').select('case_id').eq('paralegal_id', paralegal_id).execute()
            rejected_ids = {r['case_id'] for r in rejections_res.data} if rejections_res.data else set()
            
            # Filter
            cases = [c for c in cases if c['id'] not in rejected_ids]

        return jsonify({
            'success': True,
            'data': cases
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/cases/<case_id>', methods=['PUT'])
def update_case(case_id):
    """Update case status (accept/reject/complete)"""
    try:
        data = request.json
        paralegal_id = data.get('paralegal_id')
        new_status = data.get('status')
        notes = data.get('notes', '')
        
        if not new_status:
            return jsonify({
                'success': False,
                'error': 'Status is required'
            }), 400
        
        # Verify paralegal ownership
        case_response = supabase.table('paralegal_cases').select('paralegal_id').eq('id', case_id).single().execute()
        
        if not case_response.data:
            return jsonify({
                'success': False,
                'error': 'Case not found'
            }), 404
        
        existing_paralegal_id = case_response.data.get('paralegal_id')
        print(f"DEBUG: Update Case {case_id} | Requesting Paralegal: {paralegal_id} | Existing Paralegal: {existing_paralegal_id}")

        # Only allow paralegal to update their own cases OR claim unassigned cases
        if existing_paralegal_id and existing_paralegal_id != paralegal_id:
            print(f"DEBUG: Unauthorized access attempt. Existing: {existing_paralegal_id}, Requesting: {paralegal_id}")
            return jsonify({
                'success': False,
                'error': 'Unauthorized: Case does not belong to this paralegal'
            }), 403
        
        update_data = {
            'status': new_status,
            'updated_at': datetime.now().isoformat()
        }
        
        # If claiming an unassigned case, set the paralegal_id
        if not existing_paralegal_id:
            update_data['paralegal_id'] = paralegal_id
            # Also update assigned_at if picking up for first time
            update_data['assigned_at'] = datetime.now().isoformat()
        
        if notes:
            update_data['notes'] = notes
        
        response = supabase.table('paralegal_cases').update(update_data).eq('id', case_id).execute()
        
        return jsonify({
            'success': True,
            'message': f'Case status updated to {new_status}',
            'data': response.data
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


if __name__ == '__main__':
    # Run heavily accessible for mobile testing
    app.run(debug=True, host='0.0.0.0', port=5001)
