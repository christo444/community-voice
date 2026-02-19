# Google Cloud Vision Setup (Alternative to Tesseract)

Google Cloud Vision API is the **backend equivalent** of the Google ML Kit used in your mobile app. It provides better accuracy for government documents.

## 🎯 Why Use Cloud Vision?

✅ **Same technology** as mobile app's ML Kit  
✅ **Better accuracy** for Indian government documents  
✅ **Handles Hindi + English** mixed text  
✅ **Better formatting** preservation  
✅ **No local installation** (Tesseract/Poppler) needed  

## 🚀 Quick Setup (5 minutes)

### Step 1: Enable Google Cloud Vision API

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable **Cloud Vision API**:
   - Search for "Vision API" in the search bar
   - Click "Enable"

### Step 2: Create Service Account

1. Go to **IAM & Admin** → **Service Accounts**
2. Click **Create Service Account**
3. Name: `community-voice-ocr`
4. Role: **Cloud Vision API User**
5. Click **Done**

### Step 3: Create API Key

1. Click on the service account you just created
2. Go to **Keys** tab
3. Click **Add Key** → **Create new key**
4. Choose **JSON** format
5. Download the JSON file

### Step 4: Configure Backend

1. Save the downloaded JSON file as `google-credentials.json` in your backend folder:
   ```
   backend/google-credentials.json
   ```

2. Create a `.env` file in the backend folder:
   ```bash
   cd /c/Users/chris/OneDrive/Desktop/mini/community-voice/backend
   touch .env
   ```

3. Add this line to `.env`:
   ```
   GOOGLE_APPLICATION_CREDENTIALS=google-credentials.json
   ```

4. Update `.gitignore` to exclude credentials:
   ```
   google-credentials.json
   .env
   ```

### Step 5: Install Dependencies

```bash
cd /c/Users/chris/OneDrive/Desktop/mini/community-voice/backend
source venv/Scripts/activate
pip install -r requirements.txt
```

### Step 6: Test

```bash
python app.py
```

Upload your PDF - the system will automatically use Cloud Vision!

## 🆚 Cloud Vision vs Tesseract

| Feature | Cloud Vision | Tesseract |
|---------|-------------|-----------|
| Accuracy | ⭐⭐⭐⭐⭐ Excellent | ⭐⭐⭐ Good |
| Setup | API key only | Install binaries |
| Speed | 2-3 sec/page | 3-5 sec/page |
| Hindi Support | Excellent | Basic |
| Cost | Free tier: 1000/month | Free forever |
| Same as Mobile | ✅ Yes (ML Kit) | ❌ No |

## 💰 Pricing

**Free Tier:** 1,000 pages/month  
**After that:** $1.50 per 1,000 pages  

For typical usage (10-50 PDFs/month), you'll stay in free tier.

## 🔄 Fallback Strategy

The code now uses this priority:

```
1. Try text extraction (pdfplumber) → Fast for text PDFs
   ↓ [If fails]
2. Try Google Cloud Vision → Best accuracy
   ↓ [If not configured]
3. Try Tesseract OCR → Fallback option
   ↓ [If fails]
4. Try PyPDF2 → Last resort
```

## 🐛 Troubleshooting

**Error: "Could not automatically determine credentials"**
- Make sure `.env` file exists with `GOOGLE_APPLICATION_CREDENTIALS` path
- Check that JSON file path is correct
- Restart Flask server after creating `.env`

**Error: "Cloud Vision API has not been used"**
- Go to Cloud Console and enable Cloud Vision API
- Wait 1-2 minutes for activation

**Cloud Vision not being used**
- Check Flask console for "Using Google Cloud Vision"
- If you see "Using Tesseract OCR (fallback)", Cloud Vision isn't configured
- Verify `.env` file and credentials

## ✅ Verify Setup

After starting Flask, you should see:
```
Using Google Cloud Vision API (same as mobile ML Kit)
Processing page 1/9 with Cloud Vision...
Processing page 2/9 with Cloud Vision...
✓ Cloud Vision extracted 12450 characters
```

## 🎯 Recommended: Use Cloud Vision

Since your mobile app uses Google ML Kit, I recommend using Cloud Vision for consistency across platforms. Both use the same underlying Google technology.

---

**Note:** If you don't want to set up Cloud Vision, the system will automatically fall back to Tesseract (requires separate installation - see OCR_SETUP.md).
