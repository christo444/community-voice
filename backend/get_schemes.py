import os
import json
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()

supabase_url = os.getenv('SUPABASE_URL')
supabase_key = os.getenv('SUPABASE_KEY')
client = create_client(supabase_url, supabase_key)

schemes = client.table('schemes').select('id, scheme_name, eligibility').execute()

with open('schemes_out.json', 'w', encoding='utf-8') as f:
    json.dump(schemes.data, f, indent=2)
