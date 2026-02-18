# OCR Setup Guide for Image-based PDFs

Your PDF contains images (not selectable text), so we need **Tesseract OCR** to extract text.

## 🔧 Install Tesseract OCR on Windows

### Step 1: Download Tesseract

Download the Windows installer from:
**https://github.com/UB-Mannheim/tesseract/wiki**

Or direct link:
**https://digi.bib.uni-mannheim.de/tesseract/tesseract-ocr-w64-setup-5.3.3.20231005.exe**

### Step 2: Install Tesseract

1. Run the downloaded `.exe` file
2. During installation, note the installation path (usually `C:\Program Files\Tesseract-OCR`)
3. **Important**: Check the box to add Tesseract to PATH
4. Complete the installation

### Step 3: Add Tesseract to PATH (if not already added)

If you didn't add to PATH during installation:

1. Press `Win + X` and select "System"
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "System variables", find "Path" and click "Edit"
5. Click "New" and add: `C:\Program Files\Tesseract-OCR`
6. Click "OK" on all dialogs
7. **Restart your terminal**

### Step 4: Verify Installation

Open a **new** Git Bash terminal and run:
```bash
tesseract --version
```

You should see output like:
```
tesseract 5.3.3
```

### Step 5: Install Python Dependencies

```bash
cd /c/Users/chris/OneDrive/Desktop/mini/community-voice/backend
source venv/Scripts/activate
pip install -r requirements.txt
```

This will install:
- `pdf2image` - Convert PDF pages to images
- `pytesseract` - Python wrapper for Tesseract
- `Pillow` - Image processing

### Step 6: Install Poppler (for pdf2image)

`pdf2image` also needs **Poppler**:

1. Download Poppler for Windows:
   **https://github.com/oschwartz10612/poppler-windows/releases/**

2. Extract the ZIP file (e.g., to `C:\poppler`)

3. Add to PATH: `C:\poppler\Library\bin`

4. Restart terminal and verify:
   ```bash
   pdftoppm -v
   ```

## 🚀 Quick Start Commands

After installing Tesseract and Poppler:

```bash
# Navigate to backend
cd /c/Users/chris/OneDrive/Desktop/mini/community-voice/backend

# Activate virtual environment
source venv/Scripts/activate

# Install updated dependencies
pip install -r requirements.txt

# Run Flask server
python app.py
```

## 🧪 Test OCR

1. Start the Flask backend
2. Upload your PDF through the React frontend
3. Check the Flask console for OCR progress messages:
   ```
   ✓ Converted PDF to 9 images
   Processing page 1/9...
   Processing page 2/9...
   ...
   ✓ OCR extracted 12450 characters
   ```

## ⚠️ Troubleshooting

**Error: "tesseract is not recognized"**
- Solution: Restart terminal after adding to PATH
- Or manually set in Python: `pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'`

**Error: "Unable to get page count"**
- Solution: Install Poppler and add to PATH

**OCR is slow**
- Normal: OCR takes 2-5 seconds per page
- For 9-page PDF: expect 20-45 seconds total

**OCR text quality is poor**
- Solution: Use higher DPI in code (already set to 300)
- Or use better quality PDF source

## 📝 What Changed

The parser now:
1. ✅ Tries text extraction first (fast)
2. ✅ If no text, uses OCR (slower but works on images)
3. ✅ Extracts all sections specifically for government schemes:
   - Scheme Name
   - Details/Description
   - Benefits (comprehensive)
   - Eligibility (numbered list)
   - Exclusions (numbered list)
   - Application Process (steps)
   - Documents Required (numbered list)
   - FAQs
   - Source URL

---

**Ready to test!** Upload your PDF again after setting up Tesseract OCR.
