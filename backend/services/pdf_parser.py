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
You are analyzing a government scheme document page. Extract ALL visible information in the following structured JSON format. If a section is not visible on this page, return empty values.

Return ONLY valid JSON with this exact structure:
{
  "schemeName": "scheme title if visible",
  "description": "detailed description text",
  "benefits": "all benefits text including allowances and amounts",
  "eligibility": ["criterion 1", "criterion 2", ...],
  "exclusions": ["exclusion 1", "exclusion 2", ...],
  "applicationProcess": ["step 1", "step 2", ...],
  "documentsRequired": ["doc 1", "doc 2", ...],
  "faqs": ["question 1?", "question 2?", ...],
  "sourceUrl": "https://... if visible"
}

Extract:
- Scheme Name: The title/name of the scheme
- Description/Details: Full descriptive text about the scheme
- Benefits: Maintenance allowances, disability allowances, book allowances with amounts
- Eligibility: All numbered eligibility criteria
- Exclusions: All numbered exclusion rules  
- Application Process: All steps to apply (Step 1, Step 2, etc.)
- Documents Required: All required documents (numbered list)
- FAQs: All FAQ questions visible
- Source URL: Any https:// links visible

Be thorough and include ALL text from each section. Return only the JSON, no other text.
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
        
        print(f"\n✓ Gemini Vision extraction complete!")
        print(f"  Scheme Name: {combined_data['schemeName']}")
        print(f"  Description: {len(combined_data['description'])} chars")
        print(f"  Benefits: {len(combined_data['benefits'])} chars")
        print(f"  Eligibility: {len(combined_data['eligibility'])} items")
        print(f"  Exclusions: {len(combined_data['exclusions'])} items")
        print(f"  Application Steps: {len(combined_data['applicationProcess'])} steps")
        print(f"  Documents: {len(combined_data['documentsRequired'])} items")
        print(f"  FAQs: {len(combined_data['faqs'])} questions")
        
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

