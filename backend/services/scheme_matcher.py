"""
Scheme Matching Service - Matches users with eligible government schemes
Currently simplified to return ALL schemes to ALL users for testing
"""

from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()

# Initialize Supabase client
supabase_client = create_client(
    os.getenv('SUPABASE_URL'),
    os.getenv('SUPABASE_KEY')
)

def match_user_with_schemes(phone_number):
    """
    Match user with eligible schemes based on their profile
    
    Currently returns ALL schemes with 100% match for testing purposes.
    After basic flow is verified, this will be updated to use AI-based eligibility matching.
    
    Args:
        phone_number (str): User's phone number
        
    Returns:
        list: List of matched schemes with match percentage
    """
    try:
        # Fetch ALL schemes from database
        response = supabase_client.table('schemes').select('*').execute()
        
        schemes = response.data if response.data else []
        
        # For now, return ALL schemes with 100% match
        # This allows testing the complete flow before implementing AI matching
        matched_schemes = []
        for scheme in schemes:
            matched_schemes.append({
                'scheme_id': scheme['id'],
                'scheme_name': scheme['scheme_name'],
                'description': scheme.get('description'),
                'benefits': scheme.get('benefits'),
                'match_percentage': 100,  # Everyone gets 100% match for testing
                'matched_criteria': ['All users eligible for testing'],
                'unmatched_criteria': [],
                'reasoning': 'Showing all schemes to all users for testing purposes'
            })
        
        return matched_schemes
        
    except Exception as e:
        print(f"Error matching schemes: {e}")
        raise


def get_scheme_details(scheme_id):
    """
    Get complete details for a specific scheme
    
    Args:
        scheme_id (str): Scheme ID
        
    Returns:
        dict: Complete scheme details
    """
    try:
        response = supabase_client.table('schemes').select('*').eq('id', scheme_id).single().execute()
        return response.data
    except Exception as e:
        print(f"Error fetching scheme details: {e}")
        raise
