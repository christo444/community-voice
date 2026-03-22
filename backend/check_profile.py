from supabase import create_client
import os
from dotenv import load_dotenv
import json

load_dotenv()
supabase_url = os.getenv('SUPABASE_URL')
supabase_key = os.getenv('SUPABASE_KEY')
client = create_client(supabase_url, supabase_key)

try:
    response = client.table('profile_details').select('*').limit(1).execute()
    print("Columns:", list(response.data[0].keys()) if response.data else "No data, but table exists.")
    
    # Let's also check the columns by getting a single object via postgrest if empty
except Exception as e:
    print("Error:", e)
