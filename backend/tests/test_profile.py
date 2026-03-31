from services.scheme_matcher import get_supabase_client

client = get_supabase_client()

# Check if profile exists
profile = client.table('profile_details').select('*').eq('phone_number', '7012528994').execute()

if profile.data:
    user = profile.data[0]
    print("Profile found!")
    print(f"Name: {user.get('name')}")
    print(f"Age: {user.get('age')}")
    print(f"Education: {user.get('education')}")
    print(f"Special Category: {user.get('special_category')}")
    print(f"Caste Certificate: {user.get('caste_certificate')}")
    print(f"Income: {user.get('income_below')}")
    print(f"\nFull profile fields:")
    for key, value in user.items():
        if value and key not in ['created_at', 'updated_at', 'id']:
            print(f"  {key}: {value}")
else:
    print("No profile found for phone 7012528994")
