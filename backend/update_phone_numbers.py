from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()
supabase_url = os.getenv('SUPABASE_URL')
supabase_key = os.getenv('SUPABASE_KEY')
client = create_client(supabase_url, supabase_key)

old_phones = ['+911111111111', '+912222222222']

# Delete old profiles and users to prevent duplicate clutter
for phone in old_phones:
    try:
        client.table('profile_details').delete().eq('phone_number', phone).execute()
        client.table('users').delete().eq('phone_number', phone).execute()
        print(f"Deleted old data for {phone}")
    except Exception as e:
        print(f"Error deleting old {phone}: {e}")

profile1 = {
    'phone_number': '1111111111',
    'name': 'Ravi Kumar',
    'age': 22,
    'gender': 'Male',
    'address': '123 University Road, New Delhi, India',
    'state_district': 'Delhi',
    'occupation': 'Student',
    'education': 'Undergraduate',
    'income_below': '2.0 lakh',
    'disability': True,
    'special_category': 'General',
    'kutcha_house': False,
    'land_ownership': 'Owns land',
}

profile2 = {
    'phone_number': '2222222222',
    'name': 'Sundar Rajan',
    'age': 40,
    'gender': 'Male',
    'address': '45 Beach Road, Puducherry',
    'state_district': 'Puducherry',
    'occupation': 'Daily Wager',
    'education': '8th Pass',
    'income_below': '80,000',
    'disability': False,
    'special_category': 'SC',
    'kutcha_house': True,
    'caste_certificate': True,
    'land_ownership': 'No land',
}

new_phones = ['1111111111', '2222222222']

for phone in new_phones:
    try:
        client.table('users').upsert({'phone_number': phone, 'pin': '1234'}).execute()
        print(f"Upserted user {phone}")
    except Exception as e:
        print(f"Error {phone}: {e}")

for p in [profile1, profile2]:
    try:
        client.table('profile_details').upsert(p).execute()
        print(f"Upserted profile {p['name']} with {p['phone_number']}")
    except Exception as e:
        print(f"Error {p['name']}: {e}")
