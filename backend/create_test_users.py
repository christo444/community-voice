import os
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()

supabase_url = os.getenv('SUPABASE_URL')
supabase_key = os.getenv('SUPABASE_KEY')
client = create_client(supabase_url, supabase_key)

profiles = [
    {
        "phone_number": "3333333333",
        "name": "User Three",
        "age": 65,
        "gender": "Male",
        "state_district": "Puducherry",
        "address": "Native of Puducherry, Union Territory",
        "income_below": "50000",
        "education": "Illiterate",
        "special_category": "Scheduled Caste",
        "caste_certificate": True,
        "disability": "No",
        "kutcha_house": True,
        "pension": "No"
    }
]

# Upsert profiles
for p in profiles:
    try:
        client.table('profile_details').upsert(p).execute()
        print(f"Upserted highly realistic profile for {p['phone_number']}")
    except Exception as e:
        print(f"Error upserting {p['phone_number']}: {e}")

print("Successfully updated User 3 to match Scheme 2 and Scheme 4 realistically!")
