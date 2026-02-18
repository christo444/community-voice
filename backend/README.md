# Backend API - Community Voice

Flask-based backend for government scheme management with OCR capabilities.

## ✅ OCR Space API Implementation

This backend uses **OCR Space API** - a free OCR service that requires **no credit card**.

### Quick Setup (2 Minutes)

1. **Get Free API Key**: https://ocr.space/ocrapi
2. **Create `.env` file** in backend folder:
   ```
   OCR_SPACE_API_KEY=your_api_key_here
   ```
3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```
4. **Run server**:
   ```bash
   python app.py
   ```

### What It Does

- 📄 Extracts text from PDF files (text-based and image-based)
- 🔍 Parses government scheme details automatically
- 💾 Saves scheme data to local JSON storage
- 🚀 Provides REST API for admin dashboard

### API Endpoints

- `POST /api/schemes/upload` - Upload and extract scheme PDF
- `GET /api/schemes` - Get all schemes
- `GET /api/schemes/:id` - Get single scheme
- `DELETE /api/schemes/:id` - Delete scheme

### Features

✅ **Free OCR** (25,000 requests/month)  
✅ **No credit card required**  
✅ **Direct PDF support**  
✅ **Automatic section extraction**  
✅ **Hindi + English support**  

## 📖 Full Documentation

- **OCR Setup**: See `OCR_SPACE_SETUP.md`
- **API Details**: Check route files in `routes/`
- **PDF Parsing**: See `services/pdf_parser.py`

## Technology Stack

- **Framework**: Flask 3.0
- **PDF Processing**: PyPDF2, pdfplumber
- **OCR**: OCR Space API
- **Storage**: JSON (local), will migrate to Supabase

## Purpose

Serves as the API layer for:
- Admin dashboard (scheme management)
- Future: Mobile app integration
- Future: Paralegal dashboard
