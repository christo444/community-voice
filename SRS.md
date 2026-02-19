# Software Requirements Specification

## 1. Introduction

### 1.1 Project Name
Community Voice - Legal Aid Platform

### 1.2 Purpose
To help underprivileged people in Kerala access government schemes and legal assistance through:
- Mobile app for users to browse schemes and scan documents
- Admin dashboard to upload and manage scheme information
- Database to store user profiles and scheme data

### 1.3 Scope
This system has 3 main parts:
1. **Mobile App** - Phone-based app where users can register, view schemes, scan Aadhaar cards
2. **Admin Dashboard** - Web page where admins upload government scheme PDFs
3. **Backend** - Server that processes PDFs and stores data

---

## 2. System Requirements

### 2.1 Functional Requirements

#### Mobile App Features
**FR-1: User Registration**
- Users enter 10-digit phone number
- New users create 4-digit PIN
- System checks if user already exists in database

**FR-2: User Login**
- Users enter phone number + PIN
- System verifies credentials against database
- Successful login shows home screen

**FR-3: Profile Creation**
- Users fill form with: Name, Date of Birth, Age, Gender, Address
- System saves to profile_details table in database
- Phone number links profile to user account

**FR-4: Aadhaar Scanning**
- User opens camera to scan Aadhaar card
- App uses OCR to extract text from image
- User can scan multiple cards (front/back)
- Can also select image from gallery

**FR-5: View Schemes**
- Home screen shows list of government schemes
- Each scheme shows: name and brief description
- User can tap to see full details
- Currently shows dummy data (not yet connected to backend)

**FR-6: Text-to-Speech**
- User can tap voice button on any scheme
- App reads scheme name and description aloud in Malayalam
- User can stop speech by tapping button again

**FR-7: Scheme Details**
- Tap on scheme card opens detail page
- Shows: scheme name, full description, how to apply
- Has back button to return to list

#### Admin Dashboard Features
**FR-8: PDF Upload**
- Admin selects PDF file from computer
- File must be PDF format only
- System uploads to backend server
- Shows loading indicator during upload

**FR-9: URL Extraction**
- Admin enters government scheme website URL
- URL must start with http:// or https://
- System sends URL to backend for processing
- Extracts scheme details from webpage

**FR-10: View Schemes**
- Dashboard shows all uploaded schemes as cards
- Each card shows: scheme name, description excerpt, source type (PDF/URL)
- List auto-refreshes after upload

**FR-11: Delete Scheme**
- Each scheme card has delete button
- Removes scheme from system
- No confirmation dialog (direct delete)

#### Backend API Features
**FR-12: PDF Processing**
- Receives PDF file from admin dashboard
- Converts PDF pages to images
- Sends each image to Google Gemini AI
- Gemini extracts: scheme name, description, benefits, eligibility, application process, documents required, FAQs
- Returns structured JSON data

**FR-13: URL Processing**
- Receives URL from admin dashboard
- Sends URL to Gemini AI
- Gemini reads webpage and extracts scheme details
- Returns structured JSON data

**FR-14: Data Storage**
- Saves extracted scheme data to JSON file
- Assigns unique ID to each scheme
- Stores PDF filename and source URL

**FR-15: Scheme Retrieval**
- GET all schemes - returns array of all saved schemes
- GET single scheme by ID - returns one scheme
- Handles errors if scheme not found

**FR-16: Scheme Deletion**
- Receives scheme ID
- Removes scheme from JSON file
- Returns success confirmation

**FR-17: Data Validation**
- Checks if scheme name is present
- Checks if description is meaningful (not too short)
- Looks for duplicate entries
- Warns if data looks suspicious
- Prints warnings to console

#### Database Features
**FR-18: User Storage**
- users table stores: phone_number, pin, created_at, last_login_at
- phone_number is unique (no duplicates)
- Timestamps auto-generated

**FR-19: Profile Storage**
- profile_details table stores: phone_number, name, date_of_birth, age, gender, address
- Links to users table via phone_number
- Updates updated_at timestamp on edit

### 2.2 Non-Functional Requirements

**NFR-1: Performance**
- Mobile app should load home screen within 3 seconds
- PDF upload should show progress indicator
- OCR should complete within 5 seconds for normal Aadhaar card

**NFR-2: Usability**
- Malayalam language support in mobile app
- Large buttons for elderly users
- Voice assistance for illiterate users
- Simple forms with clear labels

**NFR-3: Security**
- PINs stored as plain text (for now - not production ready!)
- Admin dashboard has no authentication (needs to be added)
- API allows anyone to access (no authorization checks)

**NFR-4: Reliability**
- System should handle PDF processing failures gracefully
- Show error messages if Gemini AI fails
- Don't lose data if upload fails

**NFR-5: Compatibility**
- Mobile app works on Android 6.0+ and iOS 12.0+
- Admin dashboard works on Chrome, Firefox, Edge browsers
- Backend runs on Windows (uses PowerShell commands)

**NFR-6: Maintainability**
- Code organized in separate files (routes, services, pages)
- Uses JSON for easy data inspection
- Comments in code explain what each part does

---

## 3. System Interfaces

### 3.1 Mobile App → Database
- **Protocol:** HTTPS
- **Library:** supabase_flutter
- **Operations:** Insert user, check login, save profile, get profile
- **Format:** SQL queries executed via Supabase client

### 3.2 Admin Dashboard → Backend API
- **Protocol:** HTTP
- **Port:** Backend runs on localhost:5000
- **Format:** JSON for data, multipart/form-data for file upload
- **Endpoints:**
  - POST /api/schemes/upload (file upload)
  - POST /api/schemes/extract-url (JSON body with URL)
  - GET /api/schemes (returns all schemes)
  - DELETE /api/schemes/:id (deletes one scheme)

### 3.3 Backend → Gemini AI
- **Protocol:** HTTPS
- **Library:** google-genai Python package
- **Model:** gemini-2.5-flash
- **Input:** Image bytes + text prompt (for PDF), or URL + prompt (for websites)
- **Output:** JSON string with scheme details
- **API Key:** Stored in .env file

### 3.4 Backend → File System
- **Uploads folder:** backend/uploads/ (stores uploaded PDFs)
- **Data folder:** backend/data/schemes.json (stores extracted schemes)
- **Operations:** Read JSON, write JSON, save uploaded files

---

## 4. Data Requirements

### 4.1 User Data
```
{
  phone_number: "1234567890",
  pin: "1234",
  created_at: "2026-02-05T...",
  last_login_at: "2026-02-18T..."
}
```

### 4.2 Profile Data
```
{
  phone_number: "1234567890",
  name: "Hima Baljuraj",
  date_of_birth: "04/06/2005",
  age: 21,
  gender: "Female",
  address: "Kuppakkattukozhiyil, Ezhiakaranad, Manjaly",
  created_at: "2026-02-18T...",
  updated_at: "2026-02-18T..."
}
```

### 4.3 Scheme Data
```json
{
  "id": "uuid-string",
  "schemeName": "Pradhan Mantri Kisan Samman Nidhi",
  "description": "This scheme provides direct income support...",
  "benefits": "₹6000 per year in 3 installments",
  "eligibility": ["Small farmers", "Landholding up to 2 hectares"],
  "exclusions": ["Government employees"],
  "applicationProcess": ["Visit CSC", "Fill form", "Upload documents"],
  "documentsRequired": ["Aadhaar card", "Land records"],
  "faqs": ["Who is eligible?", "How to apply online?"],
  "sourceType": "pdf",
  "sourceUrl": "https://pmkisan.gov.in/...",
  "pdfFileName": "scheme_document.pdf"
}
```

---

## 5. Use Cases

### Use Case 1: New User Registration
1. User opens mobile app
2. Enters 10-digit phone number
3. App checks database - user not found
4. App shows "Create PIN" screen
5. User enters 4-digit PIN twice
6. App saves to users table
7. App shows profile form
8. User fills name, DOB, age, gender, address
9. App saves to profile_details table
10. User goes to home screen

### Use Case 2: Admin Uploads Scheme PDF
1. Admin opens React dashboard
2. Clicks "Choose PDF File" button
3. Selects government scheme PDF from computer
4. Clicks "Upload and Extract" button
5. Dashboard sends file to backend API
6. Backend converts PDF to images
7. Backend sends images to Gemini AI
8. Gemini extracts scheme details
9. Backend saves to schemes.json
10. Dashboard shows success message
11. New scheme appears in list

### Use Case 3: User Scans Aadhaar Card
1. User taps scan icon in app
2. Camera view opens
3. User points camera at Aadhaar card
4. User taps capture button
5. App processes image with Google ML Kit OCR
6. App extracts text from Aadhaar
7. App shows extracted details screen
8. User can scan more cards or finish

### Use Case 4: User Views Scheme with Voice
1. User sees scheme list on home screen
2. User taps speaker icon on a scheme card
3. App starts speaking scheme name and description in Malayalam
4. User listens to full description
5. User can tap icon again to stop

---

## 6. Constraints and Assumptions

### Constraints
- Must use phone number (no email) because target users may not have email
- Must work offline partially (Supabase needs internet)
- Admin dashboard has no auth (security issue for later)
- Using JSON files instead of database for schemes (temporary solution)
- Gemini API has rate limits (can't process too many PDFs too fast)

### Assumptions
- Users have smartphones with camera
- Internet connection available for login and scheme viewing
- Government PDFs are relatively clean (not too blurry)
- Scheme format is somewhat consistent
- Admins are trusted (no malicious uploads)

---

## 7. Future Enhancements

Things we plan to add later:
- [ ] Connect mobile app to backend for real scheme data
- [ ] Admin login system
- [ ] Edit scheme functionality
- [ ] Search and filter schemes by category
- [ ] Apply for schemes through app
- [ ] Track application status
- [ ] Paralegal dashboard for case management
- [ ] Document upload and storage
- [ ] Push notifications
- [ ] Multi-language support (more than just Malayalam)
- [ ] Better security (encrypt PINs, add auth tokens)
- [ ] Move from JSON to proper database for schemes
- [ ] Offline mode for mobile

---

**Project Status:** Currently about 40% complete. Core features of mobile registration, PDF extraction, and basic admin functionality are working. Many features like case management, document tracking, and paralegal dashboard are not started yet.

**Made by:** College students as mini project

**Date:** February 2026
