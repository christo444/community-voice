# Paralegal Dashboard Setup Guide

## 🎯 Overview
Complete paralegal management system with React frontend and Python Flask backend, integrated with Supabase for database and authentication.

---

## 📋 Prerequisites
- Node.js (v16 or higher)
- Python 3.8+
- Supabase account

---

## 🗄️ Database Setup

### 1. Run Migration in Supabase
Go to your Supabase project → SQL Editor and run:

```sql
-- File: supabase/migrations/001_paralegal_system.sql
-- (Copy the entire migration file content)
```

This will create:
- `paralegal_requests` table (for applications)
- `paralegals` table (for approved paralegals)
- `paralegal_cases` table (for case assignments)

---

## 🖥️ Backend Setup (Python Flask)

### 1. Navigate to backend folder
```powershell
cd c:\community_voice\community-voice\backend
```

### 2. Install Python dependencies
```powershell
pip install -r paralegal_requirements.txt
```

This installs:
- Flask 3.0.0
- Flask-CORS 4.0.0
- supabase 2.1.0
- bcrypt 4.1.1
- python-dotenv 1.0.0

### 3. Run the Paralegal Backend (Port 5001)
```powershell
python paralegal_app.py
```

Backend runs on: **http://localhost:5001**

---

## 🌐 Frontend Setup - Paralegal Dashboard

### 1. Navigate to paralegal dashboard folder
```powershell
cd c:\community_voice\community-voice\web\paralegal-dashboard
```

### 2. Install npm dependencies
```powershell
npm install
```

This installs:
- React 18.2.0
- React Router DOM 6.20.0
- Supabase JS Client 2.39.0
- Axios 1.6.0
- Vite 5.0.0

### 3. Run the Paralegal Dashboard (Port 3001)
```powershell
npm run dev
```

Frontend runs on: **http://localhost:3001**

---

## 🎨 Admin Dashboard Update

The admin dashboard now includes a **Paralegals** tab for:
- Viewing and approving paralegal applications
- Managing approved paralegals
- Assigning cases to paralegals

### Run Admin Dashboard
```powershell
cd c:\community_voice\community-voice\web\admin-dashboard
npm run dev
```

Admin Dashboard runs on: **http://localhost:3000**

---

## 🚀 Complete Startup Commands

### Terminal 1: Admin Backend (Port 5000)
```powershell
cd c:\community_voice\community-voice\backend
python app.py
```

### Terminal 2: Paralegal Backend (Port 5001)
```powershell
cd c:\community_voice\community-voice\backend
python paralegal_app.py
```

### Terminal 3: Admin Dashboard (Port 3000)
```powershell
cd c:\community_voice\community-voice\web\admin-dashboard
npm run dev
```

### Terminal 4: Paralegal Dashboard (Port 3001)
```powershell
cd c:\community_voice\community-voice\web\paralegal-dashboard
npm run dev
```

---

## 📱 Application URLs

| Application | URL | Purpose |
|------------|-----|---------|
| Admin Dashboard | http://localhost:3000 | Manage schemes & paralegals |
| Paralegal Dashboard | http://localhost:3001 | Paralegal case management |
| Paralegal Application | http://localhost:3001/apply | Public application form |
| Paralegal Login | http://localhost:3001/login | Paralegal login portal |

---

## 🔄 Complete Workflow

### 1. Paralegal Application
1. Visit: http://localhost:3001/apply
2. Fill application form (name, email, qualification)
3. Submit → Record created in `paralegal_requests` table

### 2. Admin Reviews Application
1. Login to Admin Dashboard: http://localhost:3000
2. Click **Paralegals** tab
3. View pending applications
4. Click **Approve** → Generates temporary password
5. Click **Reject** → Optionally provide reason

### 3. Paralegal Login
1. Admin shares credentials with paralegal
2. Paralegal visits: http://localhost:3001/login
3. Login with email + temporary password
4. View assigned cases

### 4. Admin Assigns Cases
1. In Admin Dashboard → **Paralegals** tab
2. Click **Assign Cases**
3. Select user and paralegal
4. Click **Assign**

### 5. Paralegal Manages Cases
1. View cases in dashboard
2. Click **View Details** on any case
3. Update status (Open → In Progress → Completed)
4. Add notes
5. View user profile information

---

## 🎯 Features

### Paralegal Dashboard
- ✅ Public application form
- ✅ Login with email/password (via Supabase Auth)
- ✅ Dashboard with case statistics
- ✅ View assigned cases
- ✅ Case details with full user profile
- ✅ Update case status
- ✅ Add case notes

### Admin Dashboard
- ✅ Schemes management (existing)
- ✅ **NEW:** View paralegal applications
- ✅ **NEW:** Approve/Reject applications
- ✅ **NEW:** Generate temporary passwords
- ✅ **NEW:** Manage approved paralegals
- ✅ **NEW:** Activate/Deactivate paralegals
- ✅ **NEW:** Assign users to paralegals

---

## 🔧 API Endpoints (Port 5001)

### Paralegal Requests
- `GET /api/paralegal/requests?status=pending` - Get applications
- `POST /api/paralegal/requests/{id}/approve` - Approve application
- `POST /api/paralegal/requests/{id}/reject` - Reject application

### Paralegals
- `GET /api/paralegals` - Get all paralegals
- `POST /api/paralegals/{id}/toggle-status` - Activate/Deactivate

### Cases
- `POST /api/cases` - Assign case to paralegal
- `GET /api/cases/{id}` - Get case details

### Users
- `GET /api/users` - Get all users for assignment

---

## 📊 Database Tables

### paralegal_requests
- Application submissions
- Status: pending, approved, rejected

### paralegals
- Approved paralegals
- Login credentials (hashed)
- Active/Inactive status

### paralegal_cases
- User-Paralegal assignments
- Case status and notes

---

## 🔐 Authentication

**Paralegal Login uses Supabase Auth:**
- Email + Password authentication
- Session management
- Protected routes

---

## 🐛 Troubleshooting

### "Cannot connect to backend"
- Ensure backend is running on correct port
- Check CORS settings in Flask

### "Supabase error"
- Verify Supabase URL and API key
- Check RLS policies are set to allow all (for development)

### "npm install fails"
- Delete `node_modules` and `package-lock.json`
- Run `npm install` again

---

## 🎨 Tech Stack

**Frontend:**
- React 18 with Vite
- React Router for navigation
- Supabase JS Client
- Axios for API calls

**Backend:**
- Python Flask
- Supabase Python SDK
- bcrypt for password hashing

**Database:**
- Supabase (PostgreSQL)
- Row Level Security enabled

---

## 📝 Next Steps

1. ✅ All features implemented
2. 🔜 Email notifications (using Resend/SendGrid)
3. 🔜 Password reset functionality
4. 🔜 Advanced case filtering
5. 🔜 Real-time notifications

---

## 📞 Support

If you encounter issues:
1. Check all services are running (4 terminals)
2. Verify database migration has run
3. Check console for error messages
4. Ensure ports 3000, 3001, 5000, 5001 are available

---

**Created: February 2026**
**Version: 1.0.0**
