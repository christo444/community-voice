"""
Setup Matched Schemes Table in Supabase
This script creates the user_schemes table for caching scheme matches.
"""

from supabase import create_client, Client
import os
from dotenv import load_dotenv

load_dotenv()

# Initialize Supabase
SUPABASE_URL = os.getenv('SUPABASE_URL', 'https://wzpfhmngcfwrbgzcdymv.supabase.co')
SUPABASE_KEY = os.getenv('SUPABASE_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6cGZobW5nY2Z3cmJnemNkeW12Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyNjA5NjgsImV4cCI6MjA4NTgzNjk2OH0.x_ivRdyK1HPT43vJq8B0p0D2jcZXO0dunnipMAPcP7E')

# SQL to create the table
CREATE_TABLE_SQL = """
-- Create a table to store matched schemes for users
CREATE TABLE IF NOT EXISTS user_schemes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_phone TEXT NOT NULL,
    scheme_id UUID NOT NULL REFERENCES schemes(id) ON DELETE CASCADE,
    is_eligible BOOLEAN DEFAULT FALSE,
    match_percentage INTEGER DEFAULT 0,
    matched_criteria JSONB DEFAULT '[]'::jsonb,
    unmatched_criteria JSONB DEFAULT '[]'::jsonb,
    reasoning TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Prevent duplicate matches for same user and scheme
    UNIQUE(user_phone, scheme_id)
);

-- Add indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_schemes_phone ON user_schemes(user_phone);
CREATE INDEX IF NOT EXISTS idx_user_schemes_eligible ON user_schemes(user_phone, is_eligible);
"""

def setup_matched_schemes_table():
    """Create matched schemes table"""
    print("=" * 60)
    print("SUPABASE MATCHED SCHEMES TABLE SETUP")
    print("=" * 60)
    print()
    
    print("📋 Step 1: Connecting to Supabase...")
    try:
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("✅ Connected successfully!")
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        return

    print()
    print("📋 Step 2: Instructions")
    print("   Please run the following SQL in your Supabase SQL Editor:")
    print("   https://supabase.com/dashboard/project/wzpfhmngcfwrbgzcdymv/sql")
    print()
    print("-" * 60)
    print(CREATE_TABLE_SQL)
    print("-" * 60)
    print()

if __name__ == "__main__":
    setup_matched_schemes_table()
