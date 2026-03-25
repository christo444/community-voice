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

    # Unique Identifier
    if profile.get('user_id'):
        summary_parts.append(f"User ID: {profile['user_id']}")

    # Basic Information (Removed Name and Address for privacy)
    if profile.get('age'):
        summary_parts.append(f"Age: {profile['age']} years")
    if profile.get('gender'):
        summary_parts.append(f"Gender: {profile['gender']}")
    if profile.get('date_of_birth'):
        summary_parts.append(f"Date of Birth: {profile['date_of_birth']}")

    # Location (Removed specific address for privacy)
    if profile.get('state_district'):
        summary_parts.append(f"Location: {profile['state_district']}")

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
                    print(f"Hit Gemini rate limit (429). Retrying in 25 seconds... (Attempt {attempt+1}/{max_retries - 1})")
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

import threading

def process_batch_and_save(profile_summary, schemes_batch, phone_number, client):
    """
    Process a batch of schemes with Gemini and save results to DB.
    Run in background thread or foreground.
    """
    try:
        print(f"Processing batch of {len(schemes_batch)} schemes for {phone_number}")
        batch_results = match_with_gemini_batch(profile_summary, schemes_batch)
        
        if not batch_results:
            print("Gemini batch matching failed or returned empty.")
            return []

        saved_matches = []
        
        # Map batch results back to schemes using the index
        for match_result in batch_results:
            scheme_idx = match_result.get('scheme_index')
            
            if scheme_idx is None or scheme_idx >= len(schemes_batch) or scheme_idx < 0:
                print(f"Invalid scheme index {scheme_idx} returned by Gemini")
                continue
                
            scheme = schemes_batch[scheme_idx]
            
            # Safe conversion to integer for database
            raw_percentage = match_result.get('match_percentage', 0)
            try:
                match_percentage = int(float(raw_percentage))
            except (ValueError, TypeError):
                match_percentage = 0
                
            is_eligible = match_percentage >= 75
            
            # Save to user_schemes table
            try:
                db_record = {
                    'user_phone': phone_number,
                    'scheme_id': scheme['id'],
                    'is_eligible': is_eligible,
                    'match_percentage': match_percentage,
                    'matched_criteria': match_result.get('matched_criteria', []),
                    'unmatched_criteria': match_result.get('unmatched_criteria', []),
                    'reasoning': match_result.get('reasoning', '')
                }
                
                # Check if record exists before upserting (if using insert) or just use upsert
                # Since we want to update if logic improved
                client.table('user_schemes').upsert(db_record, on_conflict='user_phone, scheme_id').execute()
                
                if is_eligible:
                    # Construct return object
                    matched_scheme = scheme.copy()
                    matched_scheme['match_percentage'] = match_percentage
                    matched_scheme['matched_criteria'] = match_result.get('matched_criteria', [])
                    matched_scheme['unmatched_criteria'] = match_result.get('unmatched_criteria', [])
                    matched_scheme['reasoning'] = match_result.get('reasoning', '')
                    saved_matches.append(matched_scheme)
                    print(f"✅ Matched: {scheme.get('scheme_name')} ({match_percentage}%)")
                else:
                    print(f"❌ Not eligible: {scheme.get('scheme_name')} ({match_percentage}%)")
                    
            except Exception as e:
                print(f"Error saving match result to DB: {e}")
        
        return saved_matches
    except Exception as e:
        print(f"Error in process_batch_and_save: {e}")
        return []

def match_user_with_schemes(phone_number):
    """
    Match user with eligible schemes based on their profile using AI
    
    Uses Google Gemini to intelligently compare user profile with scheme eligibility criteria.
    - First checks 'user_schemes' table for cached matches.
    - If user has matches, returns them immediately.
    - Checks for NEW schemes not in cache.
    - If new schemes exist, spawns BACKGROUND thread to process them.
    - If user has NO matches (first time), runs synchronously.

    Args:
        phone_number (str): User's phone number

    Returns:
        list: List of matched schemes with match percentage >= 75%
    """
    try:
        client = get_supabase_client()

        # 1. Fetch user profile
        print(f"Fetching profile for phone: {phone_number}")
        profile_response = client.table('profile_details').select('*').eq('phone_number', phone_number).execute()

        if not profile_response.data or len(profile_response.data) == 0:
            print(f"No profile found for phone: {phone_number}")
            return []

        user_profile = profile_response.data[0]
        
        # Ensure user_id exists for privacy anonymity 
        if not user_profile.get('user_id'):
            import uuid
            new_id = str(uuid.uuid4())
            try:
                # Try to persist it to the database if the column exists
                client.table('profile_details').update({'user_id': new_id}).eq('phone_number', phone_number).execute()
            except Exception:
                pass # Column might not exist yet, but we will still use it for this session
            user_profile['user_id'] = new_id

        # 2. Fetch ALL schemes
        print("Fetching all schemes from database...")
        schemes_response = client.table('schemes').select('*').execute()
        all_schemes = schemes_response.data if schemes_response.data else []
        
        if not all_schemes:
            print("No schemes in database")
            return []

        # 3. Fetch CACHED matches from user_schemes
        print("Checking for cached matches...")
        try:
            cached_response = client.table('user_schemes').select('*').eq('user_phone', phone_number).execute()
            cached_records = cached_response.data if cached_response.data else []
        except Exception as e:
            print(f"Error fetching cached matches (table might not exist): {e}")
            cached_records = []

        # Map cached records by scheme_id for quick lookup
        cached_map = {record['scheme_id']: record for record in cached_records}
        
        # Identify NEW schemes (not in cache)
        new_schemes = [s for s in all_schemes if s['id'] not in cached_map]
        
        # Prepare list of eligible schemes from cache
        eligible_schemes = []
        for s in all_schemes:
            if s['id'] in cached_map:
                record = cached_map[s['id']]
                if record.get('is_eligible', False):
                    # Combine scheme data with match data
                    matched_s = s.copy()
                    matched_s['match_percentage'] = record.get('match_percentage')
                    matched_s['matched_criteria'] = record.get('matched_criteria')
                    matched_s['unmatched_criteria'] = record.get('unmatched_criteria')
                    matched_s['reasoning'] = record.get('reasoning')
                    eligible_schemes.append(matched_s)

        matched_schemes = eligible_schemes
        
        profile_summary = build_profile_summary(user_profile)

        # LOGIC BRANCHING
        if not cached_records:
            # SCENARIO 1: First time user (No cache) -> Run SYNCHRONOUSLY
            print("🆕 First time matching for user. Running full sync match...")
            BATCH_SIZE = 10
            for i in range(0, len(all_schemes), BATCH_SIZE):
                batch = all_schemes[i:i+BATCH_SIZE]
                results = process_batch_and_save(profile_summary, batch, phone_number, client)
                matched_schemes.extend(results)
                
        elif new_schemes:
            # SCENARIO 2: Returning user with NEW schemes -> Return cached, process new in BACKGROUND
            print(f"🔄 User has {len(eligible_schemes)} cached matches. Found {len(new_schemes)} new schemes.")
            print("🚀 Launching background thread for new schemes...")
            
            def background_worker():
                print("🧵 Background thread started...")
                BATCH_SIZE = 10
                for i in range(0, len(new_schemes), BATCH_SIZE):
                    batch = new_schemes[i:i+BATCH_SIZE]
                    process_batch_and_save(profile_summary, batch, phone_number, client)
                print("🧵 Background thread finished.")

            thread = threading.Thread(target=background_worker)
            thread.daemon = True # Ensure thread doesn't block app shutdown
            thread.start()
            
        else:
            # SCENARIO 3: Returning user, everything up to date -> Return cached immediately
            print("✅ All schemes already processed. Returning cached results.")

        return matched_schemes

    except Exception as e:
        print(f"Error in match_user_with_schemes: {e}")
        import traceback
        traceback.print_exc()
        return []


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
