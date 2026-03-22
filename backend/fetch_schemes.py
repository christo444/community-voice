from supabase import create_client
import os
from dotenv import load_dotenv
import json

load_dotenv()
supabase_url = os.getenv('SUPABASE_URL')
supabase_key = os.getenv('SUPABASE_KEY')
client = create_client(supabase_url, supabase_key)

response = client.table('schemes').select('id, scheme_name, eligibility').execute()
for scheme in response.data:
    print(f"ID: {scheme['id']}")
    print(f"Name: {scheme['scheme_name']}")
    print(f"Eligibility: {json.dumps(scheme['eligibility'], indent=2)}")
    print("---")
