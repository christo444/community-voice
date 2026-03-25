-- Migration to add case rejections tracking
-- Created: 2026-03-25

-- Create table specifically for tracking which paralegal rejected which case
CREATE TABLE IF NOT EXISTS case_rejections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_id UUID REFERENCES paralegal_cases(id) ON DELETE CASCADE,
    paralegal_id UUID REFERENCES paralegals(id) ON DELETE CASCADE,
    rejected_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    rejection_reason TEXT,
    UNIQUE(case_id, paralegal_id)
);

-- Ensure paralegal_cases has necessary columns for unregistered users or ad-hoc requests
-- Assuming paralegal_cases might link to users table, but we might want to store snapshot details
-- as users might not even be fully registered or we just want the request details.
-- The user request says: 1.name 2.phonenumber 3.Place 4.name of the scheme.

ALTER TABLE paralegal_cases ADD COLUMN IF NOT EXISTS user_name TEXT;
ALTER TABLE paralegal_cases ADD COLUMN IF NOT EXISTS user_phone_number TEXT; -- Likely already exists or linked
ALTER TABLE paralegal_cases ADD COLUMN IF NOT EXISTS location TEXT; -- For "Place"
ALTER TABLE paralegal_cases ADD COLUMN IF NOT EXISTS scheme_name TEXT;
