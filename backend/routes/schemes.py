from flask import Blueprint, request, jsonify
from services.pdf_parser import extract_scheme_from_pdf, extract_scheme_from_url
from services.storage import save_scheme, get_all_schemes, get_scheme_by_id, delete_scheme
from services.scheme_matcher import match_user_with_schemes, get_scheme_details
import os
import uuid
from google import genai
from dotenv import load_dotenv

load_dotenv()

schemes_bp = Blueprint('schemes', __name__)

@schemes_bp.route('/upload', methods=['POST'])
def upload_scheme():
    """Upload a PDF and extract scheme details"""
    try:
        # Check if file is present
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['file']
        
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        if not file.filename.endswith('.pdf'):
            return jsonify({'error': 'Only PDF files are allowed'}), 400
        
        # Save uploaded file temporarily
        upload_folder = 'uploads'
        os.makedirs(upload_folder, exist_ok=True)
        
        file_path = os.path.join(upload_folder, file.filename)
        file.save(file_path)
        
        # Extract data from PDF
        scheme_data = extract_scheme_from_pdf(file_path)
        
        # Add metadata
        scheme_data['id'] = str(uuid.uuid4())
        scheme_data['pdfFileName'] = file.filename
        
        # Save to JSON storage
        saved_scheme = save_scheme(scheme_data)
        
        return jsonify({
            'success': True,
            'message': 'Scheme uploaded and processed successfully',
            'data': saved_scheme
        }), 201
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@schemes_bp.route('/extract-url', methods=['POST'])
def extract_from_url():
    """Extract scheme details from a website URL"""
    try:
        # Get URL from request body
        data = request.get_json()
        
        if not data or 'url' not in data:
            return jsonify({'error': 'No URL provided'}), 400
        
        url = data['url'].strip()
        
        if not url.startswith('http'):
            return jsonify({'error': 'Invalid URL format. Must start with http:// or https://'}), 400
        
        # Extract data from URL using Gemini
        scheme_data = extract_scheme_from_url(url)
        
        # Add metadata
        scheme_data['id'] = str(uuid.uuid4())
        scheme_data['sourceUrl'] = url
        
        # Save to JSON storage
        saved_scheme = save_scheme(scheme_data)
        
        return jsonify({
            'success': True,
            'message': 'Scheme extracted from URL successfully',
            'data': saved_scheme
        }), 201
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@schemes_bp.route('', methods=['GET'])
def get_schemes():
    """Get all saved schemes"""
    try:
        schemes = get_all_schemes()
        return jsonify({
            'success': True,
            'count': len(schemes),
            'data': schemes
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@schemes_bp.route('/<scheme_id>', methods=['GET'])
def get_scheme(scheme_id):
    """Get a single scheme by ID"""
    try:
        scheme = get_scheme_by_id(scheme_id)
        if scheme:
            return jsonify({
                'success': True,
                'data': scheme
            }), 200
        else:
            return jsonify({'error': 'Scheme not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@schemes_bp.route('/<scheme_id>', methods=['DELETE'])
def remove_scheme(scheme_id):
    """Delete a scheme by ID"""
    try:
        success = delete_scheme(scheme_id)
        if success:
            return jsonify({
                'success': True,
                'message': 'Scheme deleted successfully'
            }), 200
        else:
            return jsonify({'error': 'Scheme not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@schemes_bp.route('/match/<phone_number>', methods=['GET'])
def get_matched_schemes(phone_number):
    """Get schemes matched for a specific user"""
    try:
        matched_schemes = match_user_with_schemes(phone_number)
        return jsonify({
            'success': True,
            'data': {
                'phone_number': phone_number,
                'matched_schemes': matched_schemes,
                'total_matches': len(matched_schemes)
            }
        }), 200
    except Exception as e:
        print(f"Error in get_matched_schemes: {e}")
        return jsonify({'error': str(e)}), 500


@schemes_bp.route('/details/<scheme_id>', methods=['GET'])
def get_scheme_full_details(scheme_id):
    """Get complete details for a specific scheme"""
    try:
        scheme = get_scheme_details(scheme_id)
        if scheme:
            return jsonify({
                'success': True,
                'data': scheme
            }), 200
        else:
            return jsonify({'error': 'Scheme not found'}), 404
    except Exception as e:
        print(f"Error in get_scheme_full_details: {e}")
        return jsonify({'error': str(e)}), 500


@schemes_bp.route('/summarize', methods=['POST'])
def summarize_text():
    """Summarize text to 1-2 sentences using Gemini"""
    try:
        data = request.get_json()
        text = data.get('text', '')
        
        if not text or len(text.strip()) == 0:
            return jsonify({'error': 'No text provided'}), 400
        
        # Get Gemini API key
        api_key = os.getenv('GEMINI_API_KEY')
        if not api_key:
            return jsonify({'error': 'Gemini API not configured'}), 500
        
        # Initialize Gemini client
        client = genai.Client(api_key=api_key)
        
        # Create prompt for summarization (max 1-2 sentences)
        prompt = f"""Summarize the following text in ONLY 1-2 very short, simple sentences. 
Make it extremely easy to understand for people with low literacy. Use the simplest words possible.
Keep it very brief and clear.

Text to summarize:
{text}

Provide ONLY the summary, no additional text or explanations."""
        
        # Call Gemini API
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt
        )
        
        summary = response.text.strip()
        
        return jsonify({
            'success': True,
            'summary': summary
        }), 200
        
    except Exception as e:
        print(f"Error in summarize_text: {e}")
        return jsonify({'error': str(e)}), 500
