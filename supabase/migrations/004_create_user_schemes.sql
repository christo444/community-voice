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
