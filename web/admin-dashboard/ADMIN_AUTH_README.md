# Admin Dashboard Authentication Setup

This document describes the admin authentication system implementation for the Community Voice Admin Dashboard.

## Overview

The admin authentication system provides secure login functionality for administrators to access the admin dashboard. It uses Supabase for database storage and bcrypt for password hashing.

## Architecture

### Database (Supabase)
- **Table**: `admins`
- **Migration File**: `supabase/migrations/003_create_admin_table.sql`

### Backend API
- **File**: `backend/admin_app.py`
- **Port**: 5002
- **Framework**: Flask with Flask-CORS

### Frontend
- **Framework**: React (Vite)
- **Components**: 
  - `Login.jsx` - Login form
  - `Login.css` - Login styling
- **Main App**: `App.jsx` - Updated with authentication flow

## Database Schema

### `admins` Table

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| email | TEXT | Unique email address |
| password_hash | TEXT | Bcrypt hashed password |
| full_name | TEXT | Admin's full name |
| is_super_admin | BOOLEAN | Super admin privileges |
| is_active | BOOLEAN | Account active status |
| created_at | TIMESTAMP | Account creation timestamp |
| last_login | TIMESTAMP | Last login timestamp |
| created_by | UUID | Reference to creating admin |

## Default Admin Credentials

**Email**: `admin@communityvoice.com`  
**Password**: `Admin@123`

⚠️ **IMPORTANT**: Change these credentials after first login!

## Setup Instructions

### 1. Database Setup

Run the migration to create the admins table:

```sql
-- Execute the migration file in Supabase SQL Editor
-- File: supabase/migrations/003_create_admin_table.sql
```

Or if using Supabase CLI:
```bash
cd supabase
supabase db push
```

### 2. Backend Setup

#### Install Dependencies

```bash
cd backend
pip install -r admin_requirements.txt
```

**Dependencies**:
- Flask==3.0.0
- Flask-CORS==4.0.0
- supabase==2.3.0
- bcrypt==4.1.2
- python-dotenv==1.0.0

#### Configure Environment Variables

Create a `.env` file in the `backend/` directory:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_anon_key
```

#### Run the Admin API Server

```bash
python admin_app.py
```

The API will run on `http://localhost:5002`

### 3. Frontend Setup

The frontend is already configured and ready to use. Just ensure the React app is running:

```bash
cd web/admin-dashboard
npm install  # if not already installed
npm run dev
```

The dashboard will be available at `http://localhost:5173` (or the port shown in terminal)

## API Endpoints

### Authentication

#### POST `/api/admin/auth/login`
Login with email and password.

**Request Body**:
```json
{
  "email": "admin@communityvoice.com",
  "password": "Admin@123"
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "admin@communityvoice.com",
    "full_name": "System Administrator",
    "is_super_admin": true,
    "is_active": true
  },
  "message": "Login successful"
}
```

#### POST `/api/admin/auth/change-password`
Change admin password.

**Request Body**:
```json
{
  "admin_id": "uuid",
  "current_password": "Admin@123",
  "new_password": "NewSecurePassword@456"
}
```

### Admin Management (Super Admin Only)

#### GET `/api/admin/admins`
Get all admins.

#### POST `/api/admin/admins/create`
Create a new admin.

**Request Body**:
```json
{
  "email": "newadmin@communityvoice.com",
  "password": "SecurePassword@123",
  "full_name": "New Admin Name",
  "is_super_admin": false,
  "created_by": "creator_admin_uuid"
}
```

#### POST `/api/admin/admins/:admin_id/toggle-status`
Activate or deactivate an admin.

#### DELETE `/api/admin/admins/:admin_id`
Delete an admin account.

## Security Features

1. **Password Hashing**: All passwords are hashed using bcrypt with auto-generated salt
2. **Session Management**: Admin data stored in localStorage (consider JWT for production)
3. **Active Status Check**: Inactive admins cannot log in
4. **Row Level Security**: Enabled on the admins table in Supabase
5. **CORS Protection**: Configured in Flask-CORS

## Frontend Features

1. **Persistent Login**: Admin session persists across page refreshes
2. **Logout Functionality**: Clear logout with session cleanup
3. **User Info Display**: Shows logged-in admin's name
4. **Protected Routes**: Dashboard only accessible after authentication
5. **Error Handling**: User-friendly error messages
6. **Loading States**: Visual feedback during login process

## File Structure

```
community-voice/
├── backend/
│   ├── admin_app.py                    # Admin API server
│   ├── admin_requirements.txt          # Python dependencies
│   └── .env                            # Environment variables
├── supabase/
│   └── migrations/
│       └── 003_create_admin_table.sql  # Database migration
└── web/
    └── admin-dashboard/
        └── src/
            ├── App.jsx                  # Main app with auth logic
            ├── components/
            │   ├── Login.jsx            # Login component
            │   └── Login.css            # Login styles
            └── index.css                # Updated with header styles
```

## Running All Services

To run the complete system:

1. **Supabase**: Ensure Supabase project is running
2. **Admin API** (Terminal 1):
   ```bash
   cd backend
   python admin_app.py
   ```
3. **Schemes API** (Terminal 2):
   ```bash
   cd backend
   python app.py
   ```
4. **Paralegal API** (Terminal 3):
   ```bash
   cd backend
   python paralegal_app.py
   ```
5. **Admin Dashboard** (Terminal 4):
   ```bash
   cd web/admin-dashboard
   npm run dev
   ```

## Production Considerations

Before deploying to production:

1. **Change Default Credentials**: Update the default admin password
2. **Implement JWT**: Replace localStorage with JWT tokens
3. **Add Refresh Tokens**: Implement token refresh mechanism
4. **HTTPS Only**: Ensure all API calls use HTTPS
5. **Rate Limiting**: Add rate limiting to prevent brute force attacks
6. **Password Policies**: Enforce strong password requirements
7. **Email Verification**: Add email verification for new admins
8. **Audit Logging**: Log all admin actions
9. **Session Timeout**: Implement automatic session expiration
10. **Environment Variables**: Never commit `.env` files to version control

## Troubleshooting

### Login Not Working
- Check that `admin_app.py` is running on port 5002
- Verify Supabase credentials are correct in `.env`
- Check browser console for CORS errors
- Ensure the migration has been run in Supabase

### "Admin not found" Error
- Run the migration to create the default admin
- Check Supabase dashboard to verify the admins table exists
- Verify the email is correct: `admin@communityvoice.com`

### Password Not Working
- Default password is `Admin@123` (case-sensitive)
- If changed, use the new password
- Check if the password hash in database is correct

### CORS Errors
- Ensure Flask-CORS is installed: `pip install Flask-CORS`
- Check that CORS is enabled in `admin_app.py`
- Verify the frontend is making requests to the correct port (5002)

## Future Enhancements

- [ ] Two-factor authentication (2FA)
- [ ] Password reset via email
- [ ] Role-based access control (RBAC)
- [ ] Activity logs and audit trail
- [ ] Session management dashboard
- [ ] IP whitelisting
- [ ] Biometric authentication
- [ ] SSO integration

## Support

For issues or questions, please refer to the main project documentation or contact the development team.
