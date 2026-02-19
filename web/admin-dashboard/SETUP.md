# Admin Dashboard - Setup Guide

## Overview
Simple admin dashboard to upload government scheme PDFs, extract details, and save them locally.

## Backend Setup (Flask)

### 1. Navigate to backend folder
```bash
cd backend
```

### 2. Create virtual environment (recommended)
```bash
python -m venv venv
```

### 3. Activate virtual environment
**Windows:**
```bash
venv\Scripts\activate
```

**Mac/Linux:**
```bash
source venv/bin/activate
```

### 4. Install dependencies
```bash
pip install -r requirements.txt
```

### 5. Run the Flask server
```bash
python app.py
```

The backend will run on: `http://localhost:5000`

## Frontend Setup (React)

### 1. Navigate to admin dashboard folder
```bash
cd web/admin-dashboard
```

### 2. Install dependencies
```bash
npm install
```

### 3. Run the development server
```bash
npm run dev
```

The frontend will run on: `http://localhost:3000`

## How to Use

1. **Start Backend**: Make sure Flask server is running on port 5000
2. **Start Frontend**: Open React app on port 3000
3. **Upload PDF**: Click the file input, select a PDF containing scheme details
4. **Submit**: Click "Upload PDF" button
5. **View Results**: The extracted scheme details will appear in the list below
6. **Delete**: Use the delete button to remove schemes

## API Endpoints

- `GET /api/schemes` - Get all schemes
- `POST /api/schemes/upload` - Upload PDF and extract data
- `GET /api/schemes/:id` - Get single scheme
- `DELETE /api/schemes/:id` - Delete scheme

## Data Storage

All schemes are saved in `backend/data/schemes.json` file.
Uploaded PDFs are stored in `backend/uploads/` folder.

## Features

- Upload PDF files
- Automatic text extraction from PDF
- Parse scheme details (name, eligibility, benefits, etc.)
- Save to local JSON file
- View all saved schemes
- Delete schemes
- Simple, clean UI
