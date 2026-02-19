# Technologies Used in Community Voice

## Backend (Python Flask API)
- **Flask 3.0.0** - web framework for API
- **Flask-CORS 4.0.0** - to allow React frontend to call API
- **google-genai 1.63.0** - Gemini AI for extracting scheme data
- **PyPDF2 3.0.1** - reading PDF files
- **pdf2image 1.16.3** - converting PDF pages to images
- **Pillow 10.1.0** - image processing
- **python-dotenv 1.0.0** - managing environment variables

## Admin Dashboard (React)
- **React 18.2** - for building UI
- **Vite 5.0** - fast build tool
- **Axios 1.6** - for API calls to backend

## Mobile App (Flutter)
- **Flutter SDK** - cross-platform mobile development
- **Dart** - programming language
- **supabase_flutter 2.8.0** - database connection
- **camera 0.11.3** - accessing phone camera
- **google_mlkit_text_recognition 0.15.0** - OCR for Aadhaar scanning
- **flutter_tts 4.2.0** - text-to-speech in Malayalam
- **image_picker 1.2.1** - selecting images from gallery
- **google_fonts 6.2.0** - custom fonts

## Database
- **Supabase** - PostgreSQL database hosting
- Uses 2 tables: `users` and `profile_details`

## AI Services
- **Google Gemini API** (model: gemini-2.5-flash)
  - Reading PDF documents
  - Extracting scheme details from webpages
  - Vision AI for document analysis

## Development Tools
- Python 3.12
- Node.js & npm
- Git for version control
