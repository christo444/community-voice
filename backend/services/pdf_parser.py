from PyPDF2 import PdfReader
import pdfplumber
import requests
import re
from datetime import datetime
import os

def extract_text_with_ocr_space(pdf_path, api_key):
    """
    Extract text using OCR Space API (Free, no credit card needed)
    https://ocr.space/ocrapi
    """
    try:
        url = 'https://api.ocr.space/parse/image'
        
        with open(pdf_path, 'rb') as f:
            payload = {
                'apikey': api_key,
                'language': 'eng',
                'isOverlayRequired': False,
                'detectOrientation': True,
                'scale': True,
                'OCREngine': 2,  # Engine 2 is better for documents
            }
            
            files = {
                'file': f
            }
            
            print(f"Sending PDF to OCR Space API...")
            response = requests.post(url, files=files, data=payload)
            result = response.json()
            
            if result.get('IsErroredOnProcessing'):
                error_msg = result.get('ErrorMessage', ['Unknown error'])[0]
                print(f"OCR Space API error: {error_msg}")
                return None
            
            # Extract text from all pages
            parsed_results = result.get('ParsedResults', [])
            full_text = ""
            
            for page_result in parsed_results:
                page_text = page_result.get('ParsedText', '')
                if page_text:
                    full_text += page_text + "\n"
            
            if full_text.strip():
                print(f"✓ OCR Space extracted {len(full_text)} characters")
                return full_text
            
            return None
            
    except Exception as e:
        print(f"OCR Space API failed: {e}")
        return None


def extract_scheme_from_pdf(pdf_path):
    """
    Extract scheme details from PDF file
    Uses OCR Space API for image-based PDFs (free, no credit card needed)
    """
    try:
        full_text = ""
        
        # Method 1: Try pdfplumber first (for text-based PDFs)
        print("Attempting text extraction with pdfplumber...")
        try:
            with pdfplumber.open(pdf_path) as pdf:
                for page in pdf.pages:
                    page_text = page.extract_text()
                    if page_text:
                        full_text += page_text + "\n"
            
            if full_text.strip():
                print(f"✓ pdfplumber extracted {len(full_text)} characters")
        except Exception as e:
            print(f"pdfplumber failed: {e}")
        
        # Method 2: If no text, use OCR Space API (for image-based PDFs)
        if not full_text.strip() or len(full_text.strip()) < 100:
            print("Text extraction minimal or failed. Using OCR Space API...")
            
            # Get API key from environment
            api_key = os.getenv('OCR_SPACE_API_KEY')
            
            if not api_key:
                raise Exception("OCR_SPACE_API_KEY not found in .env file. Please add your API key.")
            
            # Use OCR Space API
            ocr_text = extract_text_with_ocr_space(pdf_path, api_key)
            
            if ocr_text:
                full_text = ocr_text
            else:
                # Fallback to PyPDF2
                print("OCR Space failed, trying PyPDF2...")
                try:
                    reader = PdfReader(pdf_path)
                    for page in reader.pages:
                        page_text = page.extract_text()
                        if page_text:
                            full_text += page_text + "\n"
                    
                    if full_text.strip():
                        print(f"✓ PyPDF2 extracted {len(full_text)} characters")
                except Exception as e:
                    print(f"PyPDF2 failed: {e}")
        
        # Check if we got any text
        if not full_text.strip():
            raise Exception("No text could be extracted from PDF. Please check your OCR_SPACE_API_KEY in .env file.")
        
        print(f"Total extracted text length: {len(full_text)}")
        print(f"First 300 chars: {full_text[:300]}")
        
        # Parse the text to extract scheme details
        scheme_data = parse_scheme_text(full_text)
        
        return scheme_data
        
    except Exception as e:
        raise Exception(f"Error extracting PDF: {str(e)}")


def parse_scheme_text(text):
    """
    Parse extracted text to identify scheme components
    Specifically designed for government scheme documents
    """
    
    # Initialize data structure
    scheme_data = {
        'schemeName': '',
        'description': '',
        'benefits': '',
        'eligibility': [],
        'exclusions': [],
        'applicationProcess': [],
        'documentsRequired': [],
        'faqs': [],
        'sourceUrl': '',
        'uploadedAt': datetime.now().isoformat(),
        'rawText': text[:1500]  # Store first 1500 chars for reference
    }
    
    print(f"Parsing text of length: {len(text)}")
    
    # Extract scheme name - look for common patterns
    lines = text.split('\n')
    
    # Try to find scheme name (usually contains "Scholarship", "Scheme", "Yojana", etc.)
    for i, line in enumerate(lines[:30]):  # Check first 30 lines
        line = line.strip()
        if len(line) > 15 and len(line) < 150:
            # Check for scheme-related keywords
            if any(keyword in line.lower() for keyword in ['scholarship', 'scheme', 'yojana', 'programme', 'students', 'disability']):
                if line.isupper() or line.istitle() or 'Scholarship' in line:
                    scheme_data['schemeName'] = line
                    print(f"Found scheme name: {line}")
                    break
    
    # If still no name, get first substantial line
    if not scheme_data['schemeName']:
        for line in lines[:20]:
            line = line.strip()
            if 20 < len(line) < 100:
                scheme_data['schemeName'] = line
                break
    
    # Extract Details/Description section
    details_match = re.search(r'Details?\s*\n(.*?)(?=Benefits|Eligibility|Application|Documents|$)', 
                              text, re.IGNORECASE | re.DOTALL)
    if details_match:
        scheme_data['description'] = details_match.group(1).strip()[:500]
        print(f"Found details section: {len(scheme_data['description'])} chars")
    
    # Extract Benefits section - more comprehensive
    benefits_match = re.search(r'Benefits?\s*\n(.*?)(?=Eligibility|Exclusion|Application|Documents|$)', 
                               text, re.IGNORECASE | re.DOTALL)
    if benefits_match:
        scheme_data['benefits'] = benefits_match.group(1).strip()[:1000]
        print(f"Found benefits section: {len(scheme_data['benefits'])} chars")
    
    # Extract Eligibility section - capture numbered list
    eligibility_match = re.search(r'Eligibility\s*\n(.*?)(?=Exclusion|Application|Documents|Benefits|$)', 
                                 text, re.IGNORECASE | re.DOTALL)
    if eligibility_match:
        eligibility_text = eligibility_match.group(1).strip()
        # Split by numbers (1. 2. 3. etc.) or bullets
        eligibility_items = re.split(r'\n\s*\d+[\.\)]\s+|\n\s*[•\-]\s+', eligibility_text)
        scheme_data['eligibility'] = [item.strip() for item in eligibility_items if len(item.strip()) > 15][:15]
        print(f"Found {len(scheme_data['eligibility'])} eligibility criteria")
    
    # Extract Exclusions section - capture numbered list
    exclusion_match = re.search(r'Exclusions?\s*\n(.*?)(?=Application|Documents|FAQ|Eligibility|$)', 
                               text, re.IGNORECASE | re.DOTALL)
    if exclusion_match:
        exclusion_text = exclusion_match.group(1).strip()
        # Split by numbers or bullets
        exclusion_items = re.split(r'\n\s*\d+[\.\)]\s+|\n\s*[•\-]\s+', exclusion_text)
        scheme_data['exclusions'] = [item.strip() for item in exclusion_items if len(item.strip()) > 15][:15]
        print(f"Found {len(scheme_data['exclusions'])} exclusions")
    
    # Extract Application Process section
    process_match = re.search(r'Application Process\s*\n(.*?)(?=Documents|FAQ|Eligibility|Exclusion|$)', 
                             text, re.IGNORECASE | re.DOTALL)
    if process_match:
        process_text = process_match.group(1).strip()
        # Split by "Step" or numbers
        process_items = re.split(r'Step\s+\d+[:.]?|Stage\s+\d+[:.]?|\n\s*\d+[\.\)]\s+', process_text, flags=re.IGNORECASE)
        scheme_data['applicationProcess'] = [item.strip() for item in process_items if len(item.strip()) > 20][:15]
        print(f"Found {len(scheme_data['applicationProcess'])} application steps")
    
    # Extract Documents Required section - capture numbered list
    docs_match = re.search(r'Documents?\s+Required\s*\n(.*?)(?=FAQ|Application|Eligibility|Exclusion|References|$)', 
                          text, re.IGNORECASE | re.DOTALL)
    if docs_match:
        docs_text = docs_match.group(1).strip()
        # Split by numbers or bullets
        doc_items = re.split(r'\n\s*\d+[\.\)]\s+|\n\s*[•\-]\s+', docs_text)
        scheme_data['documentsRequired'] = [item.strip() for item in doc_items if len(item.strip()) > 5][:20]
        print(f"Found {len(scheme_data['documentsRequired'])} required documents")
    
    # Extract FAQs section
    faq_match = re.search(r'Frequently Asked Questions?\s*\n(.*?)(?=Sources|References|$)', 
                         text, re.IGNORECASE | re.DOTALL)
    if faq_match:
        faq_text = faq_match.group(1).strip()[:500]
        # Split by question patterns
        faq_items = re.split(r'\n\s*Q[\.\):]|\n\s*\d+[\.\)]\s+', faq_text, flags=re.IGNORECASE)
        scheme_data['faqs'] = [item.strip() for item in faq_items if len(item.strip()) > 10][:10]
        print(f"Found {len(scheme_data['faqs'])} FAQs")
    
    # Extract URL if present
    url_match = re.search(r'https?://[^\s\)]+', text)
    if url_match:
        scheme_data['sourceUrl'] = url_match.group(0)
        print(f"Found URL: {scheme_data['sourceUrl']}")
    
    print(f"Parsing complete. Found: Name={bool(scheme_data['schemeName'])}, "
          f"Benefits={bool(scheme_data['benefits'])}, "
          f"Eligibility={len(scheme_data['eligibility'])}, "
          f"Documents={len(scheme_data['documentsRequired'])}")
    
    return scheme_data
