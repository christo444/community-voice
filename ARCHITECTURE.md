# System Architecture

## Overview
Community Voice is a 3-part system:
1. **Mobile App** (Flutter) - For users
2. **Admin Dashboard** (React) - For managing schemes
3. **Backend API** (Flask) - Connects everything

```
┌──────────────┐
│  Mobile App  │ (Flutter)
│  (Users)     │
└──────┬───────┘
       │
       │ HTTP requests
       ▼
┌──────────────────────┐
│   Supabase           │
│   (Database)         │
│                      │
│  - users table       │
│  - profile_details   │
└──────────────────────┘


┌─────────────────┐
│ Admin Dashboard │ (React)
│ (PDF upload)    │
└────────┬────────┘
         │
         │ HTTP requests
         ▼
┌─────────────────────┐        ┌──────────────┐
│  Backend API        │───────>│  Gemini AI   │
│  (Flask)            │        │  (Google)    │
│                     │        └──────────────┘
│  - Upload PDF       │
│  - Extract from URL │        ┌──────────────┐
│  - Store schemes    │───────>│ JSON Files   │
│  - Get schemes      │        │ (Storage)    │
└─────────────────────┘        └──────────────┘
```

## Components

### 1. Mobile App (Flutter)
**What it does:**
- User registration with phone number
- PIN-based login
- Profile creation (name, DOB, age, gender, address)
- Aadhaar card scanning with OCR
- View government schemes list
- Text-to-speech for schemes in Malayalam

**Files location:** `mobile/`

**Key technologies:**
- Supabase for database
- Google ML Kit for OCR
- Flutter TTS for voice
- Camera for scanning

### 2. Admin Dashboard (React)
**What it does:**
- Upload government scheme PDFs
- Extract scheme details from URLs
- View all uploaded schemes
- Delete schemes

**Files location:** `web/admin-dashboard/`

**Key files:**
- `src/App.jsx` - main component with upload forms
- `src/index.css` - styling

**Runs on:** http://localhost:3000

### 3. Backend API (Flask)
**What it does:**
- Receives PDF files from admin dashboard
- Converts PDF to images using pdf2image
- Sends images to Gemini Vision AI
- Extracts scheme details (name, description, benefits, eligibility, etc.)
- Saves schemes to JSON file
- Can also extract from URLs

**Files location:** `backend/`

**API Endpoints:**
- `POST /api/schemes/upload` - Upload PDF
- `POST /api/schemes/extract-url` - Extract from URL
- `GET /api/schemes` - Get all schemes
- `GET /api/schemes/:id` - Get one scheme
- `DELETE /api/schemes/:id` - Delete scheme

**Runs on:** http://localhost:5000

**Key files:**
- `app.py` - main Flask app
- `routes/schemes.py` - API route handlers
- `services/pdf_parser.py` - PDF processing + Gemini AI
- `services/storage.py` - JSON file read/write
- `data/schemes.json` - where schemes are stored

### 4. Database (Supabase)
**What it stores:**
- User accounts (phone + PIN)
- User profiles (name, age, address, etc.)

**Tables:** 
- `users` - login credentials
- `profile_details` - personal information

## Data Flow

### Scheme Upload Flow
1. Admin selects PDF in React dashboard
2. PDF sent to Flask API (`/api/schemes/upload`)
3. Backend converts PDF to images
4. Each image sent to Gemini Vision AI
5. AI extracts scheme details (JSON format)
6. Data saved to `data/schemes.json`
7. Success message sent back to React
8. React refreshes scheme list

### Mobile App Login Flow
1. User enters phone number
2. App checks Supabase `users` table
3. If exists → ask for PIN
4. If PIN correct → login successful
5. App loads profile from `profile_details` table
6. Show home screen

## How AI Extraction Works
Instead of manual OCR + regex patterns, we use Gemini AI:
- Send PDF page image to Gemini
- Give it detailed instructions on what to extract
- Gemini reads the image and returns structured JSON
- We validate the data (check for missing fields, weird values)
- Save to database

This is much more accurate than traditional OCR!

## Storage Strategy
- **Mobile data** → Supabase PostgreSQL (cloud database)
- **Scheme data** → JSON files (simple, no database setup needed)
- **PDF files** → `backend/uploads/` folder
- **API keys** → `.env` file (GEMINI_API_KEY)

## Why This Architecture?
- **Mobile app separate** - users don't need admin access
- **JSON storage** - simple for college project, no complex database setup
- **Gemini AI** - very accurate extraction without manual coding
- **REST API** - easy to add more features later
- **Supabase** - free database hosting, no server setup needed
