from services.scheme_matcher import get_supabase_client

client = get_supabase_client()

# Update profile with correct values
response = client.table('profile_details').update({
    'education': 'Pursuing B.Tech',
    'special_category': 'SC',
    'caste_certificate': 'Yes',
    'income_below': 'Below 5 lakh',
    'age': 22
}).eq('phone_number', '7012528994').execute()

print("✅ Profile updated successfully!")
print("Now try refreshing the app homepage")
