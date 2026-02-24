# Quick Start Guide - Admin Login System

## 🚀 Quick Setup (5 Minutes)

### Step 1: Run Database Migration
```bash
# Option A: Using Supabase Dashboard
1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy contents from: supabase/migrations/003_create_admin_table.sql
4. Paste and execute

# Option B: Using Supabase CLI (if installed)
cd supabase
supabase db push
```

### Step 2: Start Backend Server
```bash
# Open new terminal in backend directory
cd backend

# Install dependencies (first time only)
pip install Flask Flask-CORS supabase bcrypt python-dotenv

# Run admin API server
python admin_app.py
```

You should see:
```
* Running on http://127.0.0.1:5002
```

### Step 3: Start Frontend
```bash
# Open new terminal in admin-dashboard directory
cd web/admin-dashboard

# Install dependencies (first time only, if not done yet)
npm install

# Start frontend
npm run dev
```

You should see something like:
```
Local: http://localhost:5173/
```

### Step 4: Login!
1. Open browser to `http://localhost:5173`
2. You'll see the login page
3. Use default credentials:
   - **Email**: `admin@communityvoice.com`
   - **Password**: `Admin@123`
4. Click "Login"
5. You should now see the admin dashboard! 🎉

## ✅ Verification Checklist

- [ ] Database migration completed successfully
- [ ] Admin API running on port 5002
- [ ] Frontend running on port 5173 (or similar)
- [ ] Login page displays correctly
- [ ] Can login with default credentials
- [ ] Dashboard shows admin name and logout button
- [ ] Can access both "Schemes" and "Paralegals" tabs

## 🔧 Running Multiple Backend Services

Since you have multiple backend services, run each in a separate terminal:

**Terminal 1 - Admin API** (Port 5002):
```bash
cd backend
python admin_app.py
```

**Terminal 2 - Schemes API** (Port 5000):
```bash
cd backend
python app.py
```

**Terminal 3 - Paralegal API** (Port 5001):
```bash
cd backend
python paralegal_app.py
```

**Terminal 4 - Frontend**:
```bash
cd web/admin-dashboard
npm run dev
```

## 📋 What Was Implemented

### Database
✅ Created `admins` table in Supabase  
✅ Added default super admin account  
✅ Implemented password hashing with bcrypt  
✅ Added Row Level Security policies  

### Backend API
✅ Admin login endpoint (`/api/admin/auth/login`)  
✅ Password change endpoint (`/api/admin/auth/change-password`)  
✅ Admin management endpoints (CRUD operations)  
✅ Supabase integration  
✅ CORS enabled for frontend  

### Frontend
✅ Login page component with form validation  
✅ Authentication state management  
✅ Session persistence (localStorage)  
✅ Logout functionality  
✅ Admin info display in header  
✅ Protected dashboard routes  
✅ Beautiful gradient design  

## 🎨 New Features

### Login Page
- Clean, modern design with gradient background
- Email and password fields
- Loading states during authentication
- Error message display
- Default credentials shown for convenience

### Dashboard Header
- Shows logged-in admin's full name
- Logout button with one-click logout
- Persistent across page refreshes

### Security
- Passwords hashed with bcrypt
- Protected routes (must login to access dashboard)
- Session management
- Active status checking

## 🐛 Troubleshooting

**Problem**: Can't see login page, dashboard shows directly
- **Solution**: Clear browser localStorage and refresh

**Problem**: Login button doesn't work
- **Solution**: Check browser console, ensure admin_app.py is running on port 5002

**Problem**: "Invalid email or password" error with correct credentials
- **Solution**: Verify database migration ran successfully, check Supabase dashboard

**Problem**: CORS error in console
- **Solution**: Ensure Flask-CORS is installed: `pip install Flask-CORS`

**Problem**: Admin API won't start
- **Solution**: Check if port 5002 is already in use, or change port in admin_app.py

## 📝 Files Created/Modified

### New Files
1. `supabase/migrations/003_create_admin_table.sql` - Database schema
2. `backend/admin_app.py` - Admin authentication API
3. `backend/admin_requirements.txt` - Python dependencies
4. `web/admin-dashboard/src/components/Login.jsx` - Login component
5. `web/admin-dashboard/src/components/Login.css` - Login styles
6. `web/admin-dashboard/ADMIN_AUTH_README.md` - Full documentation

### Modified Files
1. `web/admin-dashboard/src/App.jsx` - Added authentication logic
2. `web/admin-dashboard/src/index.css` - Added header styles

## 🔐 Default Admin Account

**Important**: This account is created automatically by the migration:

```
Email: admin@communityvoice.com
Password: Admin@123
Role: Super Admin
```

**Security Note**: Change this password after first login in production!

## 🎯 Next Steps

1. ✅ Test the login functionality
2. ⬜ Change default admin password
3. ⬜ Create additional admin accounts (if needed)
4. ⬜ Implement password reset functionality
5. ⬜ Add JWT tokens for better security
6. ⬜ Deploy to production

## 💡 Pro Tips

- Keep all terminal windows open while developing
- Use browser DevTools Network tab to debug API calls
- Check Supabase dashboard to verify data is being stored
- Use the correct port for each service (5000, 5001, 5002)

## 📞 Need Help?

Check the detailed documentation in `ADMIN_AUTH_README.md` for:
- Complete API reference
- Security best practices
- Production deployment checklist
- Advanced configuration options

---

**Made with ❤️ for Community Voice Platform**
