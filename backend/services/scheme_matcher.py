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


def match_with_gemini_batch(profile_summary, schemes_batch):
    """Use Gemini AI to intelligently match user profile with a batch of schemes"""
    try:
        api_key = os.getenv('GEMINI_API_KEY')
        if not api_key:
            print("Warning: GEMINI_API_KEY not set, using fallback matching")
            return []

        # Initialize Gemini client
        client = genai.Client(api_key=api_key)

        schemes_text_parts = []
        for i, s in enumerate(schemes_batch):
            eligibility_text = "\n".join([f"{j+1}. {criterion}" for j, criterion in enumerate(s.get('eligibility', []))])
            if not eligibility_text.strip():
                eligibility_text = "No specific eligibility criteria - open to all"
            
            p = f"--- SCHEME INDEX: {i} ---\nScheme Name: {s.get('scheme_name', 'Unknown')}\nDescription: {s.get('description', 'No description')}\nELIGIBILITY CRITERIA:\n{eligibility_text}"
            schemes_text_parts.append(p)

        schemes_context = "\n\n".join(schemes_text_parts)

        # Create detailed matching prompt
        prompt = f"""You are an expert government scheme eligibility analyzer for India. Your task is to determine if a user is eligible for MULTIPLE government schemes based on their profile.

USER PROFILE:
{profile_summary}

SCHEMES TO ANALYZE:
{schemes_context}

TASK:
Analyze the user profile against the eligibility criteria for EACH scheme provided above. Consider:
1. Different wordings for the same concept (e.g., "SC/ST" = "Scheduled Caste/Scheduled Tribe", "below poverty line" = "low income", "farmer" = "agriculture", etc.)
2. Logical implications (e.g., if income is below 5 lakh and criteria says below 8 lakh, that matches)
3. Partial matches (e.g., if user is a student and criteria mentions "students or unemployed youth", that's a match)
4. Missing information (if user profile doesn't have a field, assume it's UNKNOWN and don't count as matched OR unmatched)
5. COMMON SENSE REALISM: Apply strict real-world age limits implicitly implied by the scheme. For instance, a 62-year old CANNOT logically qualify for a "Pre-Matric" (primary/middle school) scheme. Old Age schemes are for 60+ only. Drop the match score aggressively if physical real-world logic contradicts the criteria.

IMPORTANT RULES:
- Evaluate EVERY scheme provided.
- Only count criteria where you can CONFIRM a match or mismatch from the user profile.
- If information is missing/unknown for a criterion, DO NOT include it in matched or unmatched lists.
- Be lenient with similar wordings.
- Calculate match percentage as: (matched criteria count / total criteria count) × 100. If no specific criteria, match is 100.

OUTPUT FORMAT:
You MUST return ONLY a valid JSON ARRAY of objects with this exact structure (no other text or markdown):
[
  {{
    "scheme_index": <exact SCHEME INDEX integer from the prompt>,
    "match_percentage": <number 0-100>,
    "matched_criteria": ["criterion 1 that user meets", "criterion 2 that user meets"],
    "unmatched_criteria": ["criterion 1 that user does NOT meet"],
    "reasoning": "Brief explanation of why the user matches or doesn't match this scheme"
  }}
]
"""

        # Call Gemini API with retry logic for rate limits
        max_retries = 3
        for attempt in range(max_retries):
            try:
                response = client.models.generate_content(
                    model='gemini-2.5-flash',
                    contents=prompt
                )
                break # Success!
            except Exception as e:
                import time
                error_str = str(e)
                if '429' in error_str and attempt < max_retries - 1:
                    print(f"⚠️ Hit Gemini rate limit (429). Retrying in 25 seconds... (Attempt {attempt+1}/{max_retries - 1})")
                    time.sleep(25)
                else:
                    raise e # Re-raise if not a rate limit or out of retries

        # Parse JSON response
        response_text = response.text.strip()

        # Remove markdown code blocks using regular expressions for robustness
        import re
        if response_text.startswith('```'):
            response_text = re.sub(r'^```json?\s*', '', response_text)
            response_text = re.sub(r'\s*```$', '', response_text)
        
        # Fallback to extract JSON array if there's text before/after
        match = re.search(r'(\[.*\])', response_text, re.DOTALL)
        if match:
            response_text = match.group(1)

        result = json.loads(response_text)

        # Ensure it's a list
        if not isinstance(result, list):
            print("Error: Gemini response is not a JSON array.")
            return []

        return result

    except json.JSONDecodeError as e:
        print(f"Error parsing Gemini batch JSON response: {e}")
        return []
    except Exception as e:
        print(f"Error in Gemini batch matching: {e}")
        return []

def match_user_with_schemes(phone_number):
    """
    Match user with eligible schemes based on their profile using AI
    
    Uses Google Gemini to intelligently compare user profile with scheme eligibility criteria in batches.
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

        # 4. Match schemes using Gemini AI in batches
        matched_schemes = []
        BATCH_SIZE = 10
        
        for i in range(0, len(schemes), BATCH_SIZE):
            batch = schemes[i:i+BATCH_SIZE]
            print(f"\n{'='*60}")
            print(f"🔄 Processing Batch {i//BATCH_SIZE + 1} ({len(batch)} schemes)")
            print(f"{'='*60}")

            batch_results = match_with_gemini_batch(profile_summary, batch)
            
            if not batch_results:
                print("❌ Gemini batch matching failed or returned empty.")
                continue
                
            # Map batch results back to schemes using the index
            for match_result in batch_results:
                scheme_idx = match_result.get('scheme_index')
                
                if scheme_idx is None or scheme_idx >= len(batch) or scheme_idx < 0:
                    print(f"⚠️ Invalid scheme index {scheme_idx} returned by Gemini")
                    continue
                    
                scheme = batch[scheme_idx]
                
                match_percentage = match_result.get('match_percentage', 0)
                print(f"📊 {scheme.get('scheme_name')}: Match Score {match_percentage}%")

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
