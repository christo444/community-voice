"""
Scheme Storage Service - Save schemes to Supabase database
"""
from supabase import create_client
import os
from dotenv import load_dotenv
from datetime import datetime

load_dotenv()

# Initialize Supabase client lazily
_supabase_client = None

def get_supabase_client():
    """Get or create Supabase client"""
    global _supabase_client
    if _supabase_client is None:
        supabase_url = os.getenv('SUPABASE_URL')
        supabase_key = os.getenv('SUPABASE_KEY')

        if not supabase_url or not supabase_key:
            raise ValueError("SUPABASE_URL and SUPABASE_KEY must be set in environment variables")

        _supabase_client = create_client(supabase_url, supabase_key)
    return _supabase_client


def save_scheme(scheme_data):
    """Save a new scheme to Supabase"""
    try:
        client = get_supabase_client()

        # Prepare data for Supabase (convert field names to snake_case)
        db_data = {
            'id': scheme_data.get('id'),
            'scheme_name': scheme_data.get('schemeName', ''),
            'description': scheme_data.get('description'),
            'benefits': scheme_data.get('benefits'),
            'eligibility': scheme_data.get('eligibility', []),
            'exclusions': scheme_data.get('exclusions', []),
            'application_process': scheme_data.get('applicationProcess', []),
            'documents_required': scheme_data.get('documentsRequired', []),
            'faqs': scheme_data.get('faqs', []),
            'pdf_file_name': scheme_data.get('pdfFileName'),
            'source_url': scheme_data.get('sourceUrl'),
            'raw_text': scheme_data.get('rawText'),
            'uploaded_at': datetime.now().isoformat(),
            'created_at': datetime.now().isoformat()
        }

        # Insert into Supabase
        response = client.table('schemes').insert(db_data).execute()

        if response.data:
            # Convert back to camelCase for consistent API response
            saved = response.data[0]
            return {
                'id': saved.get('id'),
                'schemeName': saved.get('scheme_name'),
                'description': saved.get('description'),
                'benefits': saved.get('benefits'),
                'eligibility': saved.get('eligibility', []),
                'exclusions': saved.get('exclusions', []),
                'applicationProcess': saved.get('application_process', []),
                'documentsRequired': saved.get('documents_required', []),
                'faqs': saved.get('faqs', []),
                'pdfFileName': saved.get('pdf_file_name'),
                'sourceUrl': saved.get('source_url'),
                'rawText': saved.get('raw_text'),
                'uploadedAt': saved.get('uploaded_at'),
                'createdAt': saved.get('created_at')
            }

        return scheme_data

    except Exception as e:
        print(f"Error saving to Supabase: {e}")
        raise


def get_all_schemes():
    """Get all schemes from Supabase"""
    try:
        client = get_supabase_client()
        response = client.table('schemes').select('*').execute()

        # Convert snake_case to camelCase for frontend compatibility
        schemes = []
        for scheme in (response.data or []):
            schemes.append({
                'id': scheme.get('id'),
                'schemeName': scheme.get('scheme_name'),
                'description': scheme.get('description'),
                'benefits': scheme.get('benefits'),
                'eligibility': scheme.get('eligibility', []),
                'exclusions': scheme.get('exclusions', []),
                'applicationProcess': scheme.get('application_process', []),
                'documentsRequired': scheme.get('documents_required', []),
                'faqs': scheme.get('faqs', []),
                'pdfFileName': scheme.get('pdf_file_name'),
                'sourceUrl': scheme.get('source_url'),
                'rawText': scheme.get('raw_text'),
                'uploadedAt': scheme.get('uploaded_at'),
                'createdAt': scheme.get('created_at')
            })

        return schemes
    except Exception as e:
        print(f"Error fetching schemes: {e}")
        return []


def get_scheme_by_id(scheme_id):
    """Get a single scheme by ID from Supabase"""
    try:
        client = get_supabase_client()
        response = client.table('schemes').select('*').eq('id', scheme_id).single().execute()

        if not response.data:
            return None

        # Convert snake_case to camelCase for frontend compatibility
        scheme = response.data
        return {
            'id': scheme.get('id'),
            'schemeName': scheme.get('scheme_name'),
            'description': scheme.get('description'),
            'benefits': scheme.get('benefits'),
            'eligibility': scheme.get('eligibility', []),
            'exclusions': scheme.get('exclusions', []),
            'applicationProcess': scheme.get('application_process', []),
            'documentsRequired': scheme.get('documents_required', []),
            'faqs': scheme.get('faqs', []),
            'pdfFileName': scheme.get('pdf_file_name'),
            'sourceUrl': scheme.get('source_url'),
            'rawText': scheme.get('raw_text'),
            'uploadedAt': scheme.get('uploaded_at'),
            'createdAt': scheme.get('created_at')
        }
    except Exception as e:
        print(f"Error fetching scheme by ID: {e}")
        return None


def delete_scheme(scheme_id):
    """Delete a scheme by ID from Supabase"""
    try:
        client = get_supabase_client()
        response = client.table('schemes').delete().eq('id', scheme_id).execute()
        return True if response.data else False
    except Exception as e:
        print(f"Error deleting scheme: {e}")
        return False
