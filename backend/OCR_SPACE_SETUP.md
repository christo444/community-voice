# OCR Space API Setup Guide

**FREE OCR service - No credit card needed!**

OCR Space API is a completely free OCR service with 25,000 requests per month. Perfect for government scheme PDF extraction.

## 🚀 Quick Setup (2 minutes)

### Step 1: Get Free API Key

1. Go to **https://ocr.space/ocrapi**
2. Scroll down to "Register for Free API Key"
3. Fill in:
   - Email address
   - First name
   - Last name
4. Click **Register**
5. Check your email for the API key
6. Copy the API key

### Step 2: Configure Backend

1. Navigate to backend folder:
   ```powershell
   cd C:\Users\chris\OneDrive\Desktop\mini\community-voice\backend
   ```

2. Create `.env` file:
   ```powershell
   echo "OCR_SPACE_API_KEY=your_actual_api_key_here" > .env
   ```
   
   **Replace `your_actual_api_key_here` with your actual API key from the email!**

3. Install dependencies:
   ```powershell
   # Activate virtual environment
   .\venv\Scripts\Activate.ps1
   
   # Install updated requirements
   pip install -r requirements.txt
   ```

### Step 3: Start Flask Server

```powershell
python app.py
```

### Step 4: Test

1. Go to React admin dashboard (http://localhost:3000)
2. Upload your scheme PDF
3. Check Flask console for:
   ```
   Sending PDF to OCR Space API...
   ✓ OCR Space extracted 12450 characters
   ```

## ✅ What You Get

**Free Tier:**
- ✅ **25,000 requests/month**
- ✅ **No credit card required**
- ✅ **No time limit**
- ✅ **PDF support** (up to 5MB per file)
- ✅ **Multiple languages** (English, Hindi, etc.)
- ✅ **High accuracy** OCR Engine 2

For typical usage (10-100 scheme PDFs/month), you'll never exceed the free tier!

## 📊 How It Works

```
User uploads PDF
      ↓
pdfplumber tries text extraction (fast)
      ↓
If no text found → Send PDF to OCR Space API
      ↓
API processes and returns text
      ↓
Parser extracts scheme sections
      ↓
Data saved to JSON
```

## 🔧 Troubleshooting

**Error: "OCR_SPACE_API_KEY not found"**
- Make sure `.env` file exists in backend folder
- Check that API key is on a line like: `OCR_SPACE_API_KEY=K12345678`
- No quotes needed around the key
- Restart Flask server after creating `.env`

**Error: "API key invalid"**
- Check your email for the correct API key
- Make sure you copied the entire key (no spaces)
- Try generating a new key at https://ocr.space/ocrapi

**OCR taking long time**
- Normal: OCR takes 5-10 seconds for multi-page PDFs
- OCR Space processes on their servers
- Be patient, it will complete

**Error: "IsErroredOnProcessing"**
- PDF might be too large (max 5MB)
- Try compressing the PDF first
- Or split into smaller PDFs

## 📝 .env File Example

Your `.env` file should look like this:

```
OCR_SPACE_API_KEY=K87654321988957
```

**No quotes, no spaces, just the key!**

## 🆚 Comparison

| Feature | OCR Space API | Google Cloud Vision | Tesseract |
|---------|--------------|---------------------|-----------|
| Credit Card | ❌ No | ✅ Yes | ❌ No |
| Setup Time | 2 min | 15 min | 10 min |
| Free Tier | 25K/month | 1K/month | Unlimited |
| Accuracy | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Installation | None | None | Binary install |
| PDF Support | ✅ Direct | ❌ Images only | ❌ Images only |

## 🎯 Perfect For Your Use Case

OCR Space API is ideal for your scheme management system:
- No payment setup needed
- 25,000 PDFs/month free (more than enough)
- Direct PDF upload (no conversion needed)
- Good accuracy for government documents
- Simple REST API

## 📞 Support

If you have issues:
1. Check OCR Space documentation: https://ocr.space/ocrapi
2. Test your API key: https://ocr.space/ocrapi#testing
3. Contact OCR Space support if key issues

## ✅ Ready to Use!

Once you've added your API key to `.env`, the system is ready to extract text from image-based PDFs automatically!

---

**Note:** The code automatically tries text extraction first (fast), and only uses OCR if the PDF contains images. This saves API calls and speeds up processing.
