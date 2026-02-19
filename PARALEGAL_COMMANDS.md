# 🚀 Quick Start Commands - Community Voice Paralegal System

## 📦 Installation (One-time setup)

### Backend Dependencies
```powershell
cd c:\community_voice\community-voice\backend
pip install -r paralegal_requirements.txt
```

### Paralegal Dashboard Dependencies
```powershell
cd c:\community_voice\community-voice\web\paralegal-dashboard
npm install
```

### Admin Dashboard Dependencies (if not already installed)
```powershell
cd c:\community_voice\community-voice\web\admin-dashboard
npm install
```

---

## ▶️ Run All Services (4 Terminals Required)

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

## 🌐 Access URLs

- **Admin Dashboard:** http://localhost:3000
- **Paralegal Dashboard:** http://localhost:3001
- **Paralegal Application Form:** http://localhost:3001/apply
- **Paralegal Login:** http://localhost:3001/login

---

## 🗄️ Database Migration

Run this SQL in Supabase SQL Editor:
```
File: c:\community_voice\community-voice\supabase\migrations\001_paralegal_system.sql
```

---

## ✅ Verification Checklist

- [ ] Backend (5000) running - Visit http://localhost:5000
- [ ] Backend (5001) running - Visit http://localhost:5001
- [ ] Admin Dashboard running - Visit http://localhost:3000
- [ ] Paralegal Dashboard running - Visit http://localhost:3001
- [ ] Database migration executed
- [ ] Supabase credentials correct

---

## 🔧 Troubleshooting

**Port already in use?**
```powershell
# Find and kill process on port 5000
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# Or change port in app.py (last line)
app.run(debug=True, port=5002)
```

**Module not found?**
```powershell
pip install -r requirements.txt
pip install -r paralegal_requirements.txt
```

**Cannot connect to backend?**
- Check if all 4 terminals are running
- Verify no firewall blocking ports

---

## 📱 Test Workflow

1. **Apply as Paralegal:** http://localhost:3001/apply
2. **Admin Approves:** http://localhost:3000 → Paralegals tab
3. **Paralegal Logs In:** http://localhost:3001/login
4. **Admin Assigns Case:** Admin Dashboard → Assign Cases
5. **Paralegal Views Case:** Paralegal Dashboard

---

**Quick Reference:** See SETUP.md for detailed documentation
