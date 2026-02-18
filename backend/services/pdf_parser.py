from PyPDF2 import PdfReader
import pdfplumber
from pdf2image import convert_from_path
from PIL import Image
from google import genai
from google.genai import types
import requests
import re
import json
from datetime import datetime
import os
import io
import time

def extract_with_gemini_vision(image_path, api_key):
    """
    Extract structured scheme data using Google Gemini Vision API
    Much more accurate than OCR + regex parsing
    """
    try:
        # Initialize Gemini client
        client = genai.Client(api_key=api_key)
        
        # Load image and convert to bytes
        with open(image_path, 'rb') as f:
            image_bytes = f.read()
        
        # Create detailed prompt for extraction
        prompt = """
You are analyzing a government scheme document page. CRITICAL: This is OFFICIAL GOVERNMENT DATA.

STRICT INSTRUCTIONS:
- Extract ONLY information that is CLEARLY VISIBLE in this image
- DO NOT make up, guess, or infer any information
- DO NOT use your training data or general knowledge
- Copy text EXACTLY as it appears - do not paraphrase
- If a section is not visible on this page, return empty array [] or empty string ""
- Preserve exact numbering, amounts, and wording

Return ONLY valid JSON with this exact structure:
{
  "schemeName": "EXACT scheme title if visible on this page",
  "description": "COMPLETE description text from 'Details' section on this page. Include full sentences explaining what the scheme is, who it's for, and its purpose.",
  "benefits": "ALL benefits text EXACTLY as written, including monetary amounts with ₹ symbol, allowances, and categories",
  "eligibility": ["criterion 1 EXACTLY as written", "criterion 2 EXACTLY as written", ...],
  "exclusions": ["exclusion 1 EXACTLY as written", "exclusion 2 EXACTLY as written", ...],
  "applicationProcess": ["Step 1 with COMPLETE details EXACTLY as written", "Step 2 EXACTLY as written", ...],
  "documentsRequired": ["document 1 EXACTLY as written", "document 2 EXACTLY as written", ...],
  "faqs": ["question 1 EXACTLY as written?", "question 2 EXACTLY as written?", ...],
  "sourceUrl": "ANY https:// URL visible on this page"
}

EXTRACTION RULES:
1. Scheme Name: Extract EXACT official name from page header (don't abbreviate)
2. Description: Extract FULL text from Details/About section - complete sentences and paragraphs
3. Benefits: All amounts EXACTLY as shown (₹1600, ₹4000, etc.), include Group 1/2/3/4 categories
4. Eligibility: Each numbered criterion as separate item with EXACT wording
5. Exclusions: Each numbered exclusion with EXACT wording  
6. Application Process: Complete steps with full instructions, URLs, OTP details
7. Documents Required: EXACT document names from numbered list
8. FAQs: EXACT questions with question marks
9. Source URL: Any https:// link visible

VALIDATION: If unsure, leave empty. Only include what you can READ on THIS page.

Return ONLY the JSON, no other text.
"""
        
        # Generate content with image using Gemini 2.5 Flash (best for document analysis)
        response = client.models.generate_content(
            model='models/gemini-2.5-flash',
            contents=[
                types.Content(
                    role='user',
                    parts=[
                        types.Part.from_bytes(data=image_bytes, mime_type='image/jpeg'),
                        types.Part.from_text(text=prompt)
                    ]
                )
            ]
        )
        
        # Parse JSON from response
        response_text = response.text.strip()
        
        # Remove markdown code blocks if present
        if response_text.startswith('```'):
            response_text = re.sub(r'^```json?\s*', '', response_text)
            response_text = re.sub(r'\s*```$', '', response_text)
        
        data = json.loads(response_text)
        return data
        
    except Exception as e:
        print(f"Gemini Vision failed: {e}")
        return None


def extract_scheme_from_url(url):
    """
    Extract scheme details from a website URL using Gemini
    """
    try:
        # Get Gemini API key from environment
        api_key = os.getenv('GEMINI_API_KEY')
        
        if not api_key:
            raise Exception("GEMINI_API_KEY not found in .env file. Please add your Gemini API key.")
        
        print(f"Extracting scheme data from URL: {url}")
        
        # Initialize Gemini client
        client = genai.Client(api_key=api_key)
        
        # Create detailed prompt for extraction from webpage
        prompt = f"""
You are analyzing a government scheme webpage at this URL: {url}

CRITICAL INSTRUCTIONS:
- Extract ONLY the information that is ACTUALLY PRESENT on the webpage
- DO NOT make up, guess, or infer any information
- DO NOT add information from your training data or general knowledge
- If a section is not visible on the page, return empty array [] or empty string ""
- Copy text EXACTLY as it appears - do not paraphrase or reword
- For lists, preserve the EXACT numbering and wording from the original
- This is official government data - accuracy is critical

Extract ALL visible information in the following structured JSON format:

{{
  "schemeName": "EXACT full scheme name as written on the page",
  "description": "Complete description of the scheme from the 'Details' or 'Description' section. Include the full text explaining what the scheme is, who it's for, its purpose, and any background information.",
  "benefits": "ALL benefits text exactly as written, including monetary amounts, allowances, and calculations",
  "eligibility": ["criterion 1 EXACTLY as written", "criterion 2 EXACTLY as written", ...],
  "exclusions": ["exclusion 1 EXACTLY as written", "exclusion 2 EXACTLY as written", ...],
  "applicationProcess": ["Step 1 EXACTLY as written with full details", "Step 2 EXACTLY as written with full details", ...],
  "documentsRequired": ["document 1 EXACTLY as written", "document 2 EXACTLY as written", ...],
  "faqs": ["question 1 EXACTLY as written?", "question 2 EXACTLY as written?", ...],
  "sourceUrl": "{url}"
}}

DETAILED EXTRACTION INSTRUCTIONS:

1. Scheme Name: 
   - Extract the EXACT official name from the page header
   - Do not abbreviate or modify

2. Description: 
   - Extract the COMPLETE text from the "Details" or "About" section
   - Include the full scheme description - WHO it's for, WHAT it provides, WHY it exists
   - Preserve all sentences and paragraphs
   - This should be comprehensive (200-500 words typically)

3. Benefits:
   - Extract ALL monetary amounts EXACTLY as shown
   - Include maintenance allowances, category breakdowns, disability allowances
   - Preserve all calculations and amounts with ₹ symbol
   - Include hosteller/day scholar distinctions if present

4. Eligibility:
   - Extract EVERY numbered criterion as a separate array item
   - Copy the EXACT wording - don't summarize
   - Include age limits, income limits, educational qualifications as written

5. Exclusions:
   - Extract EVERY numbered exclusion as a separate array item
   - Copy EXACTLY as written

6. Application Process:
   - Extract EVERY step with COMPLETE instructions
   - Include URLs, OTP details, form filling guidance
   - Preserve step numbers and full details

7. Documents Required:
   - Extract EVERY document from the numbered list
   - Use EXACT names (e.g., "Certificate of Disability (Rights of Persons with Disabilities Act 2016)")

8. FAQs:
   - Extract EVERY question EXACTLY as written
   - Include the question mark at the end

VALIDATION:
- If you're unsure about any information, leave it empty
- Only include information you can see on the page
- Double-check all numbers and amounts for accuracy

Return ONLY the JSON with extracted data, no additional text.
"""
        
        # Generate content from URL
        print("Sending request to Gemini Vision API...")
        response = client.models.generate_content(
            model='models/gemini-2.5-flash',
            contents=prompt
        )
        
        # Parse JSON from response
        response_text = response.text.strip()
        print(f"Received response: {len(response_text)} characters")
        
        # Remove markdown code blocks if present
        if response_text.startswith('```'):
            response_text = re.sub(r'^```json?\s*', '', response_text)
            response_text = re.sub(r'\s*```$', '', response_text)
        
        data = json.loads(response_text)
        
        # Add metadata
        data['uploadedAt'] = datetime.now().isoformat()
        data['rawText'] = data.get('description', '')[:500]
        
        # Validate extracted data
        validation_warnings = validate_scheme_data(data, source="URL")
        
        print(f"\n✓ Gemini extracted scheme data from URL!")
        print(f"  Scheme Name: {data.get('schemeName', 'N/A')}")
        print(f"  Description: {len(data.get('description', ''))} chars")
        print(f"  Benefits: {len(data.get('benefits', ''))} chars")
        print(f"  Eligibility: {len(data.get('eligibility', []))} items")
        print(f"  Exclusions: {len(data.get('exclusions', []))} items")
        print(f"  Application Steps: {len(data.get('applicationProcess', []))} steps")
        print(f"  Documents: {len(data.get('documentsRequired', []))} items")
        print(f"  FAQs: {len(data.get('faqs', []))} questions")
        
        if validation_warnings:
            print(f"\n⚠️ VALIDATION WARNINGS:")
            for warning in validation_warnings:
                print(f"  - {warning}")
        
        return data
        
    except json.JSONDecodeError as e:
        print(f"JSON parsing error: {e}")
        print(f"Response text: {response_text}")
        raise Exception(f"Failed to parse response as JSON: {str(e)}")
    except Exception as e:
        raise Exception(f"Error extracting from URL: {str(e)}")


def extract_scheme_from_pdf(pdf_path):
    """
    Extract scheme details from PDF file using Gemini Vision API
    Converts PDF to images and uses AI to extract structured data
    """
    try:
        # Initialize combined data structure
        combined_data = {
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
            'rawText': ''
        }
        
        # Get Gemini API key from environment
        api_key = os.getenv('GEMINI_API_KEY')
        
        if not api_key:
            raise Exception("GEMINI_API_KEY not found in .env file. Please add your Gemini API key.")
        
        print("Converting PDF to images for Gemini Vision analysis...")
        
        # Get poppler path (for Windows)
        poppler_path = None
        if os.name == 'nt':  # Windows
            backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
            poppler_path = os.path.join(backend_dir, 'poppler-24.08.0', 'Library', 'bin')
            if not os.path.exists(poppler_path):
                print(f"Warning: Poppler not found at {poppler_path}")
                poppler_path = None
        
        # Convert with poppler path if available
        if poppler_path:
            images = convert_from_path(pdf_path, dpi=200, poppler_path=poppler_path)
        else:
            images = convert_from_path(pdf_path, dpi=200)
        
        print(f"✓ Converted PDF to {len(images)} images")
        
        # Create temp directory for images
        temp_dir = "temp_images"
        os.makedirs(temp_dir, exist_ok=True)
        
        # Process each page with Gemini Vision
        for i, image in enumerate(images):
            print(f"Processing page {i+1}/{len(images)} with Gemini Vision API...")
            
            # Save image as JPEG
            img_path = os.path.join(temp_dir, f"page_{i}.jpg")
            image.save(img_path, 'JPEG', quality=85, optimize=True)
            
            # Extract data with Gemini
            page_data = extract_with_gemini_vision(img_path, api_key)
            
            if page_data:
                print(f"  ✓ Extracted structured data from page {i+1}")
                
                # Merge data intelligently
                # Scheme name: use first non-empty
                if page_data.get('schemeName') and not combined_data['schemeName']:
                    combined_data['schemeName'] = page_data['schemeName']
                
                # Description: concatenate
                if page_data.get('description'):
                    if combined_data['description']:
                        combined_data['description'] += " " + page_data['description']
                    else:
                        combined_data['description'] = page_data['description']
                
                # Benefits: concatenate
                if page_data.get('benefits'):
                    if combined_data['benefits']:
                        combined_data['benefits'] += "\n\n" + page_data['benefits']
                    else:
                        combined_data['benefits'] = page_data['benefits']
                
                # Lists: extend (avoiding duplicates)
                for list_field in ['eligibility', 'exclusions', 'applicationProcess', 'documentsRequired', 'faqs']:
                    if page_data.get(list_field):
                        for item in page_data[list_field]:
                            if item and item not in combined_data[list_field]:
                                combined_data[list_field].append(item)
                
                # Source URL: use first non-empty
                if page_data.get('sourceUrl') and not combined_data['sourceUrl']:
                    combined_data['sourceUrl'] = page_data['sourceUrl']
            else:
                print(f"  ⚠ No data extracted from page {i+1}")
            
            # Clean up image file
            try:
                os.remove(img_path)
            except:
                pass
            
            # Small delay to avoid rate limiting (Gemini free tier)
            if i < len(images) - 1:
                time.sleep(1)
        
        # Remove temp directory
        try:
            os.rmdir(temp_dir)
        except:
            pass
        
        # Trim description and benefits to reasonable length
        if combined_data['description']:
            combined_data['description'] = combined_data['description'][:1000].strip()
        if combined_data['benefits']:
            combined_data['benefits'] = combined_data['benefits'][:2000].strip()
        
        # Store raw text preview
        combined_data['rawText'] = combined_data['description'][:500] if combined_data['description'] else ''
        
        # Validate extracted data
        validation_warnings = validate_scheme_data(combined_data, source="PDF")
        
        print(f"\n✓ Gemini Vision extraction complete!")
        print(f"  Scheme Name: {combined_data['schemeName']}")
        print(f"  Description: {len(combined_data['description'])} chars")
        print(f"  Benefits: {len(combined_data['benefits'])} chars")
        print(f"  Eligibility: {len(combined_data['eligibility'])} items")
        print(f"  Exclusions: {len(combined_data['exclusions'])} items")
        print(f"  Application Steps: {len(combined_data['applicationProcess'])} steps")
        print(f"  Documents: {len(combined_data['documentsRequired'])} items")
        print(f"  FAQs: {len(combined_data['faqs'])} questions")
        
        if validation_warnings:
            print(f"\n⚠️ VALIDATION WARNINGS:")
            for warning in validation_warnings:
                print(f"  - {warning}")
        
        return combined_data
        
    except Exception as e:
        raise Exception(f"Error extracting PDF: {str(e)}")


def parse_scheme_text(text):
    """
    Parse extracted text to identify scheme components
    Specifically designed for government scheme documents from OCR
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
    
    # Extract scheme name - look for title pattern
    lines = text.split('\n')
    for i, line in enumerate(lines[:30]):
        line = line.strip()
        if len(line) > 15 and len(line) < 150:
            if any(keyword in line.lower() for keyword in ['scholarship', 'scheme', 'yojana', 'programme', 'students', 'disability']):
                if 'myScheme' not in line and 'Digital' not in line and 'Ministry' not in line:
                    scheme_data['schemeName'] = line
                    print(f"Found scheme name: {line}")
                    break
    
    # Extract Details/Description section
    # Look for text between "Details" header and "Benefits" header
    details_match = re.search(
        r'Details\s*\n+(.*?)(?=\n\s*Benefits|\n\s*Eligibility)', 
        text, 
        re.IGNORECASE | re.DOTALL
    )
    if details_match:
        desc_text = details_match.group(1).strip()
        # Clean up - remove URLs and extra whitespace
        desc_text = re.sub(r'https?://\S+', '', desc_text)
        desc_text = re.sub(r'\s+', ' ', desc_text)
        scheme_data['description'] = desc_text[:1000]
        print(f"Found details section: {len(scheme_data['description'])} chars")
    
    # Extract Benefits section
    benefits_match = re.search(
        r'Benefits\s*\n+(.*?)(?=\n\s*Eligibility|\n\s*https?://)', 
        text, 
        re.IGNORECASE | re.DOTALL
    )
    if benefits_match:
        benefits_text = benefits_match.group(1).strip()
        # Clean up
        benefits_text = re.sub(r'https?://\S+', '', benefits_text)
        benefits_text = re.sub(r'\d+/\d+', '', benefits_text)  # Remove page numbers
        scheme_data['benefits'] = benefits_text[:2000]
        print(f"Found benefits section: {len(scheme_data['benefits'])} chars")
    
    # Extract Eligibility criteria - numbered list
    eligibility_match = re.search(
        r'Eligibility\s*\n+(.*?)(?=\n\s*Exclusions|\n\s*https?://)', 
        text, 
        re.IGNORECASE | re.DOTALL
    )
    if eligibility_match:
        eligibility_text = eligibility_match.group(1).strip()
        # Find all numbered items: "1. text", "2. text", etc.
        items = re.findall(r'\d+\.\s+([^\n]+(?:\n(?!\d+\.)[^\n]+)*)', eligibility_text)
        scheme_data['eligibility'] = [item.strip() for item in items if len(item.strip()) > 10]
        print(f"Found {len(scheme_data['eligibility'])} eligibility criteria")
    
    # Extract Exclusions - numbered list
    exclusion_match = re.search(
        r'Exclusions?\s*\n+(.*?)(?=\n\s*Application Process|\n\s*https?://)', 
        text, 
        re.IGNORECASE | re.DOTALL
    )
    if exclusion_match:
        exclusion_text = exclusion_match.group(1).strip()
        # Find all numbered items
        items = re.findall(r'\d+\.\s+([^\n]+(?:\n(?!\d+\.)[^\n]+)*)', exclusion_text)
        scheme_data['exclusions'] = [item.strip() for item in items if len(item.strip()) > 10]
        print(f"Found {len(scheme_data['exclusions'])} exclusions")
    
    # Extract Application Process - "Step 1:", "Step 2:", etc.
    process_match = re.search(
        r'Application Process\s*\n+(.*?)(?=\n\s*Documents Required|\n\s*https?://)', 
        text, 
        re.IGNORECASE | re.DOTALL
    )
    if process_match:
        process_text = process_match.group(1).strip()
        # Find all steps
        steps = re.findall(r'Step\s+\d+:\s*([^\n]+(?:\n(?!Step\s+\d)[^\n]+)*)', process_text, re.IGNORECASE)
        scheme_data['applicationProcess'] = [step.strip() for step in steps if len(step.strip()) > 20]
        print(f"Found {len(scheme_data['applicationProcess'])} application steps")
    
    # Extract Documents Required - numbered list
    docs_match = re.search(
        r'Documents Required\s*\n+(.*?)(?=\n\s*Frequently Asked|\n\s*https?://|\n\s*Sources)', 
        text, 
        re.IGNORECASE | re.DOTALL
    )
    if docs_match:
        docs_text = docs_match.group(1).strip()
        # Find all numbered items
        items = re.findall(r'\d+\.\s+([^\n]+(?:\n(?!\d+\.)[^\n]+)*)', docs_text)
        scheme_data['documentsRequired'] = [item.strip() for item in items if len(item.strip()) > 5]
        print(f"Found {len(scheme_data['documentsRequired'])} required documents")
    
    # Extract FAQs - just the questions
    faq_match = re.search(
        r'Frequently Asked Questions\s*\n+(.*?)(?=\n\s*https?://|\n\s*Sources|\n\s*Was this helpful)', 
        text, 
        re.IGNORECASE | re.DOTALL
    )
    if faq_match:
        faq_text = faq_match.group(1).strip()
        # Split by question marks to get individual questions
        questions = [q.strip() + '?' for q in faq_text.split('?') if len(q.strip()) > 10]
        scheme_data['faqs'] = questions[:20]
        print(f"Found {len(scheme_data['faqs'])} FAQs")
    
    # Extract source URL
    url_match = re.search(r'(https?://[^\s]+)', text)
    if url_match:
        scheme_data['sourceUrl'] = url_match.group(1)
        print(f"Found URL: {scheme_data['sourceUrl']}")
    
    print(f"Parsing complete. Found: Name={bool(scheme_data['schemeName'])}, "
          f"Benefits={bool(scheme_data['benefits'])}, Eligibility={len(scheme_data['eligibility'])}, "
          f"Documents={len(scheme_data['documentsRequired'])}")
    
    return scheme_data


def validate_scheme_data(data, source="PDF"):
    """
    Validate extracted scheme data to detect potential hallucinations or errors
    Returns list of warning messages
    """
    warnings = []
    
    # Check if scheme name is present
    if not data.get('schemeName') or len(data.get('schemeName', '')) < 10:
        warnings.append("Scheme name is missing or too short")
    
    # Check if description is present (critical field)
    if not data.get('description') or len(data.get('description', '')) < 50:
        warnings.append("Description is missing or too short (should be 200+ characters)")
    
    # Check for suspiciously generic descriptions
    generic_phrases = [
        "this scheme provides",
        "the government of india",
        "this program aims to"
    ]
    desc_lower = data.get('description', '').lower()
    if any(phrase in desc_lower for phrase in generic_phrases) and len(desc_lower) < 100:
        warnings.append("Description appears generic - may be hallucinated")
    
    # Check if benefits contain actual amounts
    benefits = data.get('benefits', '')
    if benefits and len(benefits) > 20:
        # Should contain rupee symbols or numbers for government schemes
        has_amounts = '₹' in benefits or 'Rs' in benefits or any(char.isdigit() for char in benefits)
        if not has_amounts:
            warnings.append("Benefits section missing monetary amounts")
    
    # Check eligibility criteria
    eligibility = data.get('eligibility', [])
    if len(eligibility) == 0:
        warnings.append("No eligibility criteria extracted")
    elif len(eligibility) > 20:
        warnings.append("Unusually high number of eligibility criteria (may be parsing error)")
    
    # Check for duplicate items in lists (can indicate hallucination)
    for field_name, field_data in [
        ('eligibility', data.get('eligibility', [])),
        ('exclusions', data.get('exclusions', [])),
        ('documentsRequired', data.get('documentsRequired', []))
    ]:
        if len(field_data) != len(set(field_data)):
            warnings.append(f"Duplicate items found in {field_name}")
    
    # Check if application process has reasonable number of steps
    app_process = data.get('applicationProcess', [])
    if len(app_process) > 15:
        warnings.append("Unusually high number of application steps (may be parsing error)")
    
    # Check for suspiciously short items in lists
    for field_name, field_data in [
        ('eligibility', data.get('eligibility', [])),
        ('documentsRequired', data.get('documentsRequired', []))
    ]:
        short_items = [item for item in field_data if len(item) < 10]
        if len(short_items) > 0:
            warnings.append(f"{len(short_items)} items in {field_name} are very short (< 10 chars)")
    
    # Check if FAQs actually end with question marks
    faqs = data.get('faqs', [])
    if faqs:
        non_questions = [faq for faq in faqs if not faq.strip().endswith('?')]
        if len(non_questions) > 0:
            warnings.append(f"{len(non_questions)} FAQs don't end with question marks")
    
    # Data completeness check
    required_fields = ['schemeName', 'description', 'benefits', 'eligibility']
    missing_required = [field for field in required_fields if not data.get(field)]
    if missing_required:
        warnings.append(f"Missing required fields: {', '.join(missing_required)}")
    
    return warnings
