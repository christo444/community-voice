from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()
SUPABASE_URL = os.getenv('SUPABASE_URL', 'https://wzpfhmngcfwrbgzcdymv.supabase.co')
SUPABASE_KEY = os.getenv('SUPABASE_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6cGZobW5nY2Z3cmJnemNkeW12Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyNjA5NjgsImV4cCI6MjA4NTgzNjk2OH0.x_ivRdyK1HPT43vJq8B0p0D2jcZXO0dunnipMAPcP7E')

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
try:
    res = supabase.table('paralegal_cases').select('*, profile_details(*)').execute()
    print("Success with profile_details(*):", res.data)
except Exception as e:
    print("Error 1:", e)

try:
    res = supabase.table('paralegal_cases').select('*').execute()
    print("Just table:", res.data)
except Exception as e:
    print("Error 2:", e)
