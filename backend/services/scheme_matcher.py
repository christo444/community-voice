"""
Scheme Matching Service - AI-powered matching of users with eligible government schemes
Uses Google Gemini to intelligently compare user profiles with scheme eligibility
"""

from supabase import create_client
import os
import json
from dotenv import load_dotenv
from google import genai

# Load environment variables
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


def build_profile_summary(profile):
    """Build a comprehensive text summary of user profile for AI matching"""
    summary_parts = []

    # Basic Information
    if profile.get('name'):
        summary_parts.append(f"Name: {profile['name']}")
    if profile.get('age'):
        summary_parts.append(f"Age: {profile['age']} years")
    if profile.get('gender'):
        summary_parts.append(f"Gender: {profile['gender']}")
    if profile.get('date_of_birth'):
        summary_parts.append(f"Date of Birth: {profile['date_of_birth']}")

    # Location
    if profile.get('state_district'):
        summary_parts.append(f"Location: {profile['state_district']}")
    if profile.get('address'):
        summary_parts.append(f"Address: {profile['address']}")

    # Economic Status
    if profile.get('income_below'):
        summary_parts.append(f"Annual Family Income: Below {profile['income_below']}")
    if profile.get('income_certificate'):
        summary_parts.append(f"Has Income Certificate: {'Yes' if profile['income_certificate'] else 'No'}")

    # Occupation & Employment
    if profile.get('occupation'):
        summary_parts.append(f"Occupation: {profile['occupation']}")
    if profile.get('organised_unorganised_sector'):
        summary_parts.append(f"Employment Sector: {profile['organised_unorganised_sector']}")

    # Agriculture
    if profile.get('agriculture_involved'):
        summary_parts.append(f"Involved in Agriculture: {'Yes' if profile['agriculture_involved'] else 'No'}")
    if profile.get('land_ownership'):
        summary_parts.append(f"Land Ownership: {profile['land_ownership']}")

    # Business
    if profile.get('msme_status'):
        summary_parts.append(f"MSME Status: {profile['msme_status']}")

    # Education
    if profile.get('education'):
        summary_parts.append(f"Education Level: {profile['education']}")

    # Social Category
    if profile.get('special_category'):
        summary_parts.append(f"Social Category: {profile['special_category']}")
    if profile.get('caste_certificate'):
        summary_parts.append(f"Has Caste Certificate: {'Yes' if profile['caste_certificate'] else 'No'}")
    if profile.get('minority_community'):
        summary_parts.append(f"Belongs to Minority Community: {'Yes' if profile['minority_community'] else 'No'}")
    if profile.get('ews_certificate'):
        summary_parts.append(f"Has EWS Certificate: {'Yes' if profile['ews_certificate'] else 'No'}")

    # Special Conditions
    if profile.get('disability'):
        summary_parts.append(f"Person with Disability: {'Yes' if profile['disability'] else 'No'}")
    if profile.get('pregnant_or_lactating'):
        summary_parts.append(f"Pregnant or Lactating Mother: {'Yes' if profile['pregnant_or_lactating'] else 'No'}")

    # Housing
    if profile.get('kutcha_house'):
        summary_parts.append(f"Lives in Kutcha House: {'Yes' if profile['kutcha_house'] else 'No'}")

    # Financial Inclusion
    if profile.get('aadhaar_linked_account'):
        summary_parts.append(f"Has Aadhaar Linked Bank Account: {'Yes' if profile['aadhaar_linked_account'] else 'No'}")
    if profile.get('ration_card'):
        summary_parts.append(f"Has Ration Card: {'Yes' if profile['ration_card'] else 'No'}")

    # Pension
    if profile.get('pension'):
        summary_parts.append(f"Receives Pension: {profile['pension']}")

    return "\n".join(summary_parts)


def match_with_gemini(profile_summary, scheme):
    """Use Gemini AI to intelligently match user profile with scheme eligibility"""
    try:
        api_key = os.getenv('GEMINI_API_KEY')
        if not api_key:
            print("Warning: GEMINI_API_KEY not set, using fallback matching")
            return None

        # Initialize Gemini client
        client = genai.Client(api_key=api_key)

        # Build eligibility criteria text
        eligibility_text = "\n".join([f"{i+1}. {criterion}" for i, criterion in enumerate(scheme.get('eligibility', []))])

        # If no eligibility criteria, assume everyone is eligible
        if not eligibility_text.strip():
            return {
                'match_percentage': 100,
                'matched_criteria': ['No specific eligibility criteria - open to all'],
                'unmatched_criteria': [],
                'reasoning': 'This scheme has no specific eligibility restrictions'
            }

        # Create detailed matching prompt
        prompt = f"""You are an expert government scheme eligibility analyzer for India. Your task is to determine if a user is eligible for a government scheme based on their profile.

USER PROFILE:
{profile_summary}

SCHEME DETAILS:
Scheme Name: {scheme.get('scheme_name', 'Unknown')}
Description: {scheme.get('description', 'No description')}

ELIGIBILITY CRITERIA:
{eligibility_text}

TASK:
Analyze the user profile against the eligibility criteria. Consider:
1. Different wordings for the same concept (e.g., "SC/ST" = "Scheduled Caste/Scheduled Tribe", "below poverty line" = "low income", "farmer" = "agriculture", etc.)
2. Logical implications (e.g., if income is below 5 lakh and criteria says below 8 lakh, that matches)
3. Partial matches (e.g., if user is a student and criteria mentions "students or unemployed youth", that's a match)
4. Missing information (if user profile doesn't have a field, assume it's UNKNOWN and don't count as matched OR unmatched)

IMPORTANT RULES:
- Only count criteria where you can CONFIRM a match or mismatch from the user profile
- If information is missing/unknown for a criterion, DO NOT include it in matched or unmatched lists
- Be lenient with similar wordings (farmer=agriculturist, SC=Scheduled Caste, etc.)
- Calculate match percentage as: (matched criteria count / total criteria count) × 100

OUTPUT FORMAT (JSON ONLY):
{{
  "match_percentage": <number 0-100>,
  "matched_criteria": ["criterion 1 that user meets", "criterion 2 that user meets", ...],
  "unmatched_criteria": ["criterion 1 that user does NOT meet", "criterion 2 that user does NOT meet", ...],
  "reasoning": "Brief explanation of why the user matches or doesn't match this scheme"
}}

Return ONLY valid JSON, no other text."""

        # Call Gemini API
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt
        )

        # Parse JSON response
        response_text = response.text.strip()

        # Remove markdown code blocks if present
        if response_text.startswith('```'):
            response_text = response_text.split('```')[1]
            if response_text.startswith('json'):
                response_text = response_text[4:]
            response_text = response_text.strip()

        result = json.loads(response_text)

        # Validate result structure
        if not all(key in result for key in ['match_percentage', 'matched_criteria', 'unmatched_criteria', 'reasoning']):
            print(f"Invalid Gemini response structure for scheme {scheme.get('scheme_name')}")
            return None

        return result

    except json.JSONDecodeError as e:
        print(f"Error parsing Gemini JSON response: {e}")
        print(f"Response text: {response_text[:200]}")
        return None
    except Exception as e:
        print(f"Error in Gemini matching: {e}")
        return None

def match_user_with_schemes(phone_number):
    """
    Match user with eligible schemes based on their profile using AI

    Uses Google Gemini to intelligently compare user profile with scheme eligibility criteria.
    Only returns schemes with 75% or higher match.

    Args:
        phone_number (str): User's phone number

    Returns:
        list: List of matched schemes with match percentage >= 75%
    """
    try:
        client = get_supabase_client()

        # 1. Fetch user profile
        print(f"🔍 Fetching profile for phone: {phone_number}")
        profile_response = client.table('profile_details').select('*').eq('phone_number', phone_number).execute()

        if not profile_response.data or len(profile_response.data) == 0:
            print(f"⚠️ No profile found for phone: {phone_number}")
            # Return empty list if no profile exists
            return []

        user_profile = profile_response.data[0]
        print(f"✅ Profile found: {user_profile.get('name', 'Unknown')}")

        # 2. Build profile summary for AI
        profile_summary = build_profile_summary(user_profile)
        print(f"📝 Profile summary created ({len(profile_summary)} chars)")

        # 3. Fetch all schemes from database
        print("📚 Fetching all schemes from database...")
        schemes_response = client.table('schemes').select('*').execute()
        schemes = schemes_response.data if schemes_response.data else []
        print(f"📚 Found {len(schemes)} total schemes")

        if not schemes:
            print("⚠️ No schemes in database")
            return []

        # 4. Match each scheme using Gemini AI
        matched_schemes = []

        for idx, scheme in enumerate(schemes, 1):
            scheme_name = scheme.get('scheme_name', 'Unknown')
            print(f"\n{'='*60}")
            print(f"🔄 [{idx}/{len(schemes)}] Matching: {scheme_name}")
            print(f"{'='*60}")

            # Use Gemini to analyze match
            match_result = match_with_gemini(profile_summary, scheme)

            if match_result is None:
                # If Gemini fails, skip this scheme
                print(f"❌ Gemini matching failed for: {scheme_name}")
                continue

            match_percentage = match_result.get('match_percentage', 0)
            print(f"📊 Match Score: {match_percentage}%")

            # 5. Only include schemes with >= 75% match
            if match_percentage >= 75:
                print(f"✅ MATCHED! Adding to results")
                matched_schemes.append({
                    'scheme_id': scheme['id'],
                    'scheme_name': scheme['scheme_name'],
                    'description': scheme.get('description'),
                    'benefits': scheme.get('benefits'),
                    'match_percentage': match_percentage,
                    'matched_criteria': match_result.get('matched_criteria', []),
                    'unmatched_criteria': match_result.get('unmatched_criteria', []),
                    'reasoning': match_result.get('reasoning', '')
                })
            else:
                print(f"❌ Match too low ({match_percentage}% < 75%), skipping")

        print(f"\n{'='*60}")
        print(f"🎯 FINAL RESULTS: {len(matched_schemes)} schemes matched (>= 75%)")
        print(f"{'='*60}")

        # Sort by match percentage (highest first)
        matched_schemes.sort(key=lambda x: x['match_percentage'], reverse=True)

        return matched_schemes

    except Exception as e:
        print(f"❌ Error matching schemes: {e}")
        import traceback
        traceback.print_exc()
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
        client = get_supabase_client()
        response = client.table('schemes').select('*').eq('id', scheme_id).single().execute()
        return response.data
    except Exception as e:
        print(f"Error fetching scheme details: {e}")
        raise
