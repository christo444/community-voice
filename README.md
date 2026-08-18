# 🎤 Community Voice Platform

> **Bridging the Digital Divide: Voice-Driven Legal Aid for Marginalized Communities**

Community Voice is an **AI-powered, voice-first legal aid platform** that connects millions of Indians from marginalized and backward communities to:
- ✅ **40+ Government Welfare Schemes** they're eligible for (identified via AI)
- ✅ **Trained Paralegals** for legal guidance and case management  
- ✅ **Trusted Administrators** overseeing the entire ecosystem

Built with **privacy-first design**, **multi-language support**, and **accessibility for low-literacy users** at its core.

---

## 🌟 Key Innovations

| Feature | Impact | Technology |
|---------|--------|-----------|
| 🎤 **Voice-First Interface** | Users interact via speech, not typing | Flutter TTS/STT (8+ Indian languages) |
| 🤖 **AI Eligibility Matching** | Analyzes user profile against 40+ schemes | Google Gemini 2.5 Flash + batch processing |
| 📸 **Privacy-Preserving OCR** | Aadhaar extraction happens on-device | Google ML Kit (no server processing) |
| 🌐 **Multi-Language** | Support for 8+ Indian languages | Translation + Language-aware speech |
| 🔐 **Role-Based Access** | Different portals for users/paralegals/admins | Supabase RLS + JWT authentication |
| ⚡ **AI Scheme Extraction** | Auto-extract scheme data from PDFs | Gemini Vision API |
| 📊 **Intelligent Matching** | Contextual, lenient eligibility logic | Advanced prompt engineering |

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    MOBILE APP (Flutter)                         │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Voice Input → Profile → Aadhaar OCR → Scheme Matching   │   │
│  │ Auto-Login • Multi-Language • TTS/STT • On-Device OCR   │   │
│  └──────────────────────────────────────────────────────────┘   │
└────────────────────────────┬─────────────────────────────────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
            ▼                ▼                ▼
     ┌────────────┐  ┌──────────────┐  ┌──────────────┐
     │  Backend   │  │     Admin    │  │  Paralegal   │
     │   API      │  │  Dashboard   │  │  Dashboard   │
     │  (Flask)   │  │   (React)    │  │   (React)    │
     │  :5000     │  │   :5173      │  │   :5173      │
     └─────┬──────┘  └──────┬───────┘  └──────┬───────┘
           │                │                │
           └────────────────┼────────────────┘
                            │
              ┌─────────────▼──────────────┐
              │   Supabase (PostgreSQL)    │
              │   - Profiles              │
              │   - Schemes               │
              │   - Matches               │
              │   - Paralegals            │
              │   - Cases                 │
              └────────────────────────────┘
```

### Component Overview

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Mobile** | Flutter 3.35 + Dart | Cross-platform user app (Android/iOS/Web) |
| **Admin Dashboard** | React 18 + Vite | Scheme upload, admin management |
| **Paralegal Dashboard** | React 18 + Vite | Case management for paralegals |
| **Backend API** | Flask 3.0 + Gunicorn | REST API, PDF processing, AI matching |
| **Database** | Supabase + PostgreSQL | Centralized data, RLS policies |
| **AI/ML** | Google Gemini API | Vision OCR, text analysis, eligibility matching |
| **OCR (Mobile)** | Google ML Kit | On-device Aadhaar extraction |

---

## 🚀 Quick Start

### Prerequisites
- Node.js 16+ (for web dashboards)
- Python 3.9+ (for backend)
- Flutter 3.35+ (for mobile)
- Supabase account + PostgreSQL database
- Google Gemini API key
- Git

### 1️⃣ Backend Setup (5 minutes)

```bash
cd backend

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with:
# - SUPABASE_URL
# - SUPABASE_KEY
# - GEMINI_API_KEY
# - Flask settings

# Run migrations (if needed)
# psql -U postgres -h localhost -d community_voice -a -f ../supabase/migrations/*.sql

# Start API
python app.py           # Main API (port 5000)
# In another terminal:
python admin_app.py     # Admin API (port 5002)
```

**Default Admin Credentials:**
- Email: `admin@communityvoice.com`
- Password: `Admin@123`

### 2️⃣ Mobile Setup (10 minutes)

```bash
cd mobile

# Install dependencies
flutter pub get

# Configure Supabase
# Edit lib/core/constants/constants.dart with your Supabase URL/key

# Run on device/emulator
flutter run -d android    # Android
flutter run -d ios        # iOS
flutter run -d chrome     # Web

# Or build
flutter build apk
flutter build ios
```

### 3️⃣ Admin Dashboard Setup (5 minutes)

```bash
cd web/admin-dashboard

# Install dependencies
npm install

# Configure API endpoint
# Edit src/config.js with backend URL (http://localhost:5002)

# Development server
npm run dev            # Runs on port 5173

# Production build
npm build
npm preview
```

### 4️⃣ Paralegal Dashboard Setup (5 minutes)

```bash
cd web/paralegal-dashboard

# Install dependencies
npm install

# Configure API endpoint
# Edit src/config.js with backend URL

# Development server
npm run dev

# Production build
npm build
```

---

## 📊 Database Schema

### Core Tables

#### 1. **profile_details** — User Information
Stores 40+ fields capturing comprehensive user data:
- Demographics: age, gender, DOB, location
- Income & Employment: occupation, income level, sector
- Education & Social Status: education level, caste category (SC/ST/OBC/EWS)
- Special Categories: disability, widow/single parent, pregnant/lactating

```sql
SELECT 
  user_id, phone_number, age, gender,
  income_below, occupation, education,
  special_category, disability
FROM profile_details;
```

#### 2. **schemes** — Government Schemes
Auto-extracted from PDF uploads via Gemini Vision API:
- schemeName, description, benefits
- eligibility[] (array of criteria)
- documentsRequired[], applicationProcess[]
- sourceUrl, uploadedAt, rawText (full text preview)

```sql
SELECT 
  id, schemeName, benefits, 
  eligibility, documentsRequired
FROM schemes
ORDER BY uploadedAt DESC;
```

#### 3. **user_schemes** — AI Match Results
Stores intelligent eligibility matching results:
- is_eligible (boolean)
- match_percentage (0-100)
- matched_criteria[], unmatched_criteria[]
- reasoning (why scheme matched/didn't match)
- UNIQUE constraint: (user_phone, scheme_id)

```sql
SELECT 
  user_phone, scheme_id, is_eligible, match_percentage,
  matched_criteria, reasoning
FROM user_schemes
WHERE match_percentage > 75
ORDER BY match_percentage DESC;
```

#### 4. **paralegals** — Approved Legal Representatives
Paralegals approved by admins to handle user cases:
- email, password_hash (bcrypt)
- name, qualification, phone_number
- is_active, must_reset_password (first login)
- created_at, last_login

#### 5. **paralegal_requests** — Applications
Public form for paralegals to apply:
- name, qualification, email, phone_number
- status: pending → approved → active
- reviewed_by, rejection_reason, reviewed_at

#### 6. **paralegal_cases** — Case Management
Track user cases and paralegal assignments:
- case_id, user_phone_number, paralegal_id (nullable)
- scheme_name, location, user_name
- status: open → in_progress → completed
- notes, assigned_at, updated_at

#### 7. **case_rejections** — Rejection Tracking
Audit trail: which paralegal rejected which case:
- case_id, paralegal_id, rejected_at
- rejection_reason
- UNIQUE(case_id, paralegal_id)

#### 8. **admins** — Platform Administrators
Super-admins and delegated admins:
- email, password_hash (bcrypt)
- full_name, is_super_admin, is_active
- created_by (hierarchical), created_at, last_login

---

## 🔐 Authentication & Security

### Mobile Users
- **Method**: PIN-based (4-6 digits)
- **Storage**: Encrypted in SharedPreferences  
- **Auto-Login**: Persists session on app restart
- **Verification**: DOB confirmation for added security

### Admins & Paralegals
- **Method**: Email + Password with bcrypt hashing (12 rounds)
- **First Login**: Paralegals must reset password (forced)
- **Session**: JWT tokens + localStorage persistence
- **Active Status**: Toggleable by super admins

### Database Security
- ✅ **Row-Level Security (RLS)** enabled on all tables
- ✅ **CORS** configured for cross-origin access
- ✅ **Environment variables** for sensitive data
- ✅ **Bcrypt hashing** (12 rounds) for passwords
- ✅ **Unique constraints** on critical fields

---

## 🤖 AI Services

### 1. **PDF Scheme Extraction** (`backend/services/pdf_parser.py`)

**Flow:**
1. Admin uploads PDF scheme document
2. Extract text via PyPDF2/pdfplumber
3. Render PDF pages to images
4. Send to Gemini Vision API with extraction prompt
5. Parse JSON response
6. Store structured data in `schemes` table

**Gemini Prompt** includes anti-hallucination rules:
- Extract ONLY information from the document
- Identify: scheme name, description, benefits, eligibility criteria, documents needed, application process, FAQs
- Return structured JSON
- Mark uncertain fields with "UNKNOWN"

**Output Example:**
```json
{
  "schemeName": "Pradhan Mantri Awas Yojana",
  "description": "Housing scheme for economically weaker sections...",
  "benefits": "Subsidy up to 2.5-6.5 lakhs; loan up to 20 lakhs...",
  "eligibility": [
    "Annual income below ₹3 lakhs (Urban)",
    "Belongs to SC/ST/OBC/EWS category",
    "Not beneficiary of any previous housing scheme"
  ],
  "documentsRequired": [
    "Aadhaar card",
    "Income certificate",
    "House ownership documents"
  ],
  "applicationProcess": [
    "Register on official portal",
    "Fill application form",
    "Submit required documents"
  ],
  "sourceUrl": "https://pmaymis.gov.in/"
}
```

### 2. **AI Eligibility Matching** (`backend/services/scheme_matcher.py`)

**Algorithm:**
1. Build user profile summary (30+ fields)
2. Batch schemes for efficient processing (multiple at once)
3. Use Gemini 2.5 Flash for intelligent analysis
4. Apply contextual logic:
   - Lenient matching ("farmer" ≈ "agriculture")
   - Logical implications ("income < 5L" matches "below 8L")
   - Age-appropriate schemes only
   - Real-world constraints

**Matching Features:**
- ✅ Calculates match_percentage (0-100)
- ✅ Lists matched_criteria (what the user qualifies for)
- ✅ Lists unmatched_criteria (what they don't qualify for)
- ✅ Provides reasoning (why matched/not matched)
- ✅ Handles missing info (assumes UNKNOWN intelligently)
- ✅ Rate-limit retry with 25-second backoff

**Batch Processing Example:**
```python
# Match user against multiple schemes efficiently
user_profile = "45-year-old widow, farmer, income ₹2.5L, SC category..."
schemes = [scheme1, scheme2, scheme3, ...]

matches = match_schemes_batch(user_profile, schemes)
# Returns: [
#   {scheme_id: 1, match_percentage: 92, matched_criteria: [...], ...},
#   {scheme_id: 2, match_percentage: 45, matched_criteria: [...], ...},
#   ...
# ]
```

**Matching Output:**
```json
{
  "scheme_id": 1,
  "match_percentage": 85,
  "is_eligible": true,
  "matched_criteria": [
    "Annual income below ₹6 lakhs",
    "SC category",
    "Female headed household"
  ],
  "unmatched_criteria": [
    "Must own agricultural land (unconfirmed)"
  ],
  "reasoning": "User matches 85% of eligibility criteria. Strong match due to income and caste category alignment. Recommend applying."
}
```

### 3. **Aadhaar OCR** (On-Device via ML Kit)
- Extracts: Name, DOB, Gender, Aadhaar number
- Front & Back: Merges data from both sides
- Privacy: Completely on-device, no server transmission
- Verification: DOB cross-check with profile

---

## 🎨 Mobile App Features

### Clean Architecture
```
lib/
├── main.dart                 # Entry point + splash logic
├── core/
│   ├── constants/           # App constants & config
│   ├── theme/               # UI theme (gradient maroon)
│   ├── localization/        # Multi-language support
│   └── di/                  # Dependency injection
├── data/
│   ├── datasources/         # Supabase, API calls
│   ├── models/              # Data models
│   └── repositories/        # Repository pattern
├── domain/
│   ├── entities/            # Business entities
│   └── usecases/            # Business logic
└── features/
    └── app_features/
        ├── presentation/    # UI screens & widgets
        ├── domain/          # Feature-specific logic
        └── data/            # Feature-specific data
```

### User Flows

**🔵 Authentication Flow**
```
Splash Screen → Check PIN in storage → 
  IF exists: Auto-login → Home
  ELSE: Phone Input → Profile Creation → PIN Setup → Home
```

**🎯 Scheme Discovery Flow**
```
Home → Voice/Text Input → Profile → 
Aadhaar OCR (optional) → AI Eligibility Matching → 
Matched Schemes List → Scheme Details (with TTS) → 
User Request → Paralegal Assignment
```

**📞 Paralegal Interaction Flow**
```
User Request → Assigned Paralegal → Chat/Notes →
Case Status Updates → Closure → Feedback
```

---

## 💻 Admin Dashboard Features

### Scheme Management
- 📤 **Upload PDF**: Drag & drop PDF scheme documents
- 🤖 **Auto-Extraction**: Gemini Vision API extracts structured data
- 📋 **Review & Store**: Validate extracted data, save to database
- 📊 **View All Schemes**: Browse uploaded schemes
- 🗑️ **Delete**: Remove schemes from system

### Admin Management
- 👤 **Create Admins**: Add new admin accounts (bcrypt passwords)
- 🔑 **Login**: Secure email + password authentication
- ⚙️ **Account Settings**: Toggle admin status, delete accounts
- 📝 **Session Persistence**: Remember login in localStorage

### Paralegal Oversight
- ✅ **Review Applications**: See paralegal requests
- 🎯 **Approve/Reject**: Decision workflow
- 📊 **Track Performance**: Monitor cases, rejections
- 🔄 **Force Password Reset**: On first paralegal login

---

## 🌐 API Endpoints

### Main API (Flask - Port 5000)

```bash
# Health Check
GET /health

# Schemes
GET /api/schemes                     # List all schemes
POST /api/schemes                    # Create scheme (admin)
GET /api/schemes/<id>                # Get scheme details
DELETE /api/schemes/<id>             # Delete scheme (admin)

# Eligibility Matching
POST /api/match-schemes              # Match user to schemes
GET /api/user-schemes/<phone>        # Get matches for user

# User Requests
POST /api/user-requests              # Submit user request
GET /api/user-requests               # Get requests (paralegal)
PUT /api/user-requests/<id>          # Update request status
```

### Admin API (Flask - Port 5002)

```bash
# Authentication
POST /auth/login                     # Admin login
POST /auth/logout                    # Admin logout
POST /auth/change-password           # Change password

# Admin Management
POST /api/admins                     # Create admin
GET /api/admins                      # List admins
DELETE /api/admins/<id>              # Delete admin
PATCH /api/admins/<id>/status        # Toggle active status

# Scheme Management (same as main API)

# Paralegal Management
GET /api/paralegal-requests          # List applications
POST /api/paralegal-requests/<id>/approve
POST /api/paralegal-requests/<id>/reject

# Case Management
GET /api/cases                       # List all cases
PUT /api/cases/<id>/assign           # Assign to paralegal
```

---

## 📈 Project Status

### ✅ **Completed**

**Core Infrastructure**
- ✅ Full-stack monorepo setup
- ✅ Supabase database + 8 migration files
- ✅ Bcrypt password hashing for admins/paralegals
- ✅ Row-Level Security (RLS) policies
- ✅ Default admin account configured

**Backend**
- ✅ Flask API with health checks
- ✅ Admin authentication (login, password change)
- ✅ Supabase integration
- ✅ Gemini Vision API integration (PDF parsing)
- ✅ AI scheme matching with batch processing
- ✅ Rate-limit handling + retries
- ✅ CORS configuration
- ✅ Error handling & validation

**Mobile**
- ✅ Clean architecture setup
- ✅ Supabase integration
- ✅ PIN-based authentication with auto-login
- ✅ Aadhaar OCR (ML Kit)
- ✅ Multi-language provider
- ✅ Premium gradient UI theme
- ✅ Core widgets & components

**Admin Dashboard**
- ✅ Beautiful gradient login UI
- ✅ PDF scheme upload & Gemini extraction
- ✅ Schemes list/delete functionality
- ✅ Admin management (create, delete, toggle status)
- ✅ Session persistence
- ✅ Responsive design

**Paralegal System**
- ✅ Application form & database schema
- ✅ Admin approval/rejection workflow
- ✅ Paralegal authentication (bcrypt)
- ✅ Password reset on first login
- ✅ Case management tables
- ✅ Case rejection tracking

### ⏳ **In Progress**

**Mobile**
- ⏳ Interview questions & voice input
- ⏳ Real-time scheme matching integration
- ⏳ Scheme detail pages with TTS
- ⏳ User request submission flow
- ⏳ Voice-based navigation
- ⏳ Paralegal assignment notifications

**Web Dashboards**
- ⏳ Paralegal dashboard full implementation
- ⏳ Case management UI & workflows
- ⏳ Admin analytics & reporting
- ⏳ Real-time case status updates

**Backend**
- ⏳ Advanced analytics endpoints
- ⏳ Email notifications (scheme matches, case updates)
- ⏳ SMS notifications for paralegals
- ⏳ Bulk scheme import
- ⏳ Performance optimizations

---

## 📚 Documentation

- [🏃 Quick Start Guide](./QUICK_START_ADMIN_LOGIN.md) — Get admin access in 2 minutes
- [📖 Full Documentation](./DOCUMENTATION.md) — Comprehensive platform guide
- [🔧 Implementation Summary](./IMPLEMENTATION_SUMMARY.md) — What's been built
- [⚙️ Tech Stack](./TECHNOLOGY_STACK.tex) — Detailed tech decisions
- [🗂️ System Requirements](./SYSTEM_REQUIREMENTS.tex) — Hardware & software needs
- [👮 Admin/Paralegal Commands](./PARALEGAL_COMMANDS.md) — Admin operations

### Component READMEs
- [Backend Setup](./backend/README.md)
- [Mobile Setup](./mobile/IMPLEMENTATION.md)
- [Admin Dashboard Setup](./web/admin-dashboard/SETUP.md)
- [Paralegal Dashboard Setup](./web/paralegal-dashboard/SETUP.md)

---

## 🤝 Contributing

Community Voice is built for and by communities. We welcome contributions!

### Development Setup
```bash
# Clone repository
git clone https://github.com/christo444/community-voice.git
cd community-voice

# Create feature branch
git checkout -b feature/your-feature-name

# Make changes, commit, push
git push origin feature/your-feature-name

# Create Pull Request
```

### Coding Standards
- **Mobile**: Follow [Flutter style guide](https://flutter.dev/docs/guides/style-guide)
- **Web**: ES6+ JavaScript, functional React components
- **Backend**: PEP 8 Python style
- **Database**: Migrations for schema changes (see `supabase/migrations/`)

---

## 🚢 Deployment

### Docker Support
```bash
cd infrastructure/docker
docker-compose up -d
```

### Environment Configuration
Create `.env` files in each component:

**Backend (.env)**
```
FLASK_ENV=production
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_key
GEMINI_API_KEY=your_gemini_key
FLASK_SECRET_KEY=random_secret_key
```

**Mobile (lib/core/constants/constants.dart)**
```dart
const String SUPABASE_URL = 'your_supabase_url';
const String SUPABASE_KEY = 'your_supabase_key';
```

**Web Dashboards (.env.local)**
```
VITE_API_URL=http://localhost:5002
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_KEY=your_supabase_key
```


---

**Last Updated**: August 2024 | **Repository**: [GitHub](https://github.com/christo444/community-voice) | **Status**: Active Development ✨
