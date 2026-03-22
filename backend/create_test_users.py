import os
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()

supabase_url = os.getenv('SUPABASE_URL')
supabase_key = os.getenv('SUPABASE_KEY')
client = create_client(supabase_url, supabase_key)

profiles = [
    {
        "phone_number": "1111111111",
        "name": "User One",
        "age": 22,
        "gender": "Male",
        "state_district": "Delhi",
        "address": "Permanent resident of India",
        "income_below": "100000",
        "education": "Undergraduate student in recognized university, passed previous exam with 60%, not receiving any other scholarship/stipend",
        "special_category": "General",
        "disability": "Yes, holds differently-abled certificate, 45% visual impairment",
        "kutcha_house": False,
        "pension": "No"
    }
]

# Upsert profiles
for p in profiles:
    try:
        client.table('profile_details').upsert(p).execute()
        print(f"Upserted profile for {p['phone_number']}")
    except Exception as e:
        print(f"Error upserting {p['phone_number']}: {e}")

print("Successfully updated test users and profiles!")
