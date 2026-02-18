from flask import Blueprint, request, jsonify
from services.pdf_parser import extract_scheme_from_pdf
from services.storage import save_scheme, get_all_schemes, get_scheme_by_id, delete_scheme
import os
import uuid

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
