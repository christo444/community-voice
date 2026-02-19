-- Paralegal System Database Migration
-- Created: 2026-02-18

-- 1. Paralegal Requests Table (for applications)
CREATE TABLE IF NOT EXISTS paralegal_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  qualification TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone_number TEXT,
  message TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  rejection_reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  reviewed_at TIMESTAMP WITH TIME ZONE,
  reviewed_by TEXT
);

-- 2. Approved Paralegals Table (for login)
CREATE TABLE IF NOT EXISTS paralegals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name TEXT NOT NULL,
  qualification TEXT NOT NULL,
  phone_number TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login TIMESTAMP WITH TIME ZONE
);

-- 3. Paralegal Cases (assignments)
CREATE TABLE IF NOT EXISTS paralegal_cases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  paralegal_id UUID REFERENCES paralegals(id) ON DELETE CASCADE,
  user_phone_number TEXT REFERENCES users(phone_number) ON DELETE CASCADE,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'completed')),
  notes TEXT,
  assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_paralegal_requests_status ON paralegal_requests(status);
CREATE INDEX IF NOT EXISTS idx_paralegal_requests_email ON paralegal_requests(email);
CREATE INDEX IF NOT EXISTS idx_paralegals_email ON paralegals(email);
CREATE INDEX IF NOT EXISTS idx_paralegal_cases_paralegal ON paralegal_cases(paralegal_id);
CREATE INDEX IF NOT EXISTS idx_paralegal_cases_user ON paralegal_cases(user_phone_number);

-- Enable Row Level Security
ALTER TABLE paralegal_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE paralegals ENABLE ROW LEVEL SECURITY;
ALTER TABLE paralegal_cases ENABLE ROW LEVEL SECURITY;

-- Create policies (allow all for development - refine in production)
DROP POLICY IF EXISTS "Allow all for paralegal_requests" ON paralegal_requests;
CREATE POLICY "Allow all for paralegal_requests" ON paralegal_requests FOR ALL USING (true);

DROP POLICY IF EXISTS "Allow all for paralegals" ON paralegals;
CREATE POLICY "Allow all for paralegals" ON paralegals FOR ALL USING (true);

DROP POLICY IF EXISTS "Allow all for paralegal_cases" ON paralegal_cases;
CREATE POLICY "Allow all for paralegal_cases" ON paralegal_cases FOR ALL USING (true);

-- Add comments for documentation
COMMENT ON TABLE paralegal_requests IS 'Stores paralegal application requests from the public form';
COMMENT ON TABLE paralegals IS 'Stores approved paralegals who can login to the dashboard';
COMMENT ON TABLE paralegal_cases IS 'Links paralegals to users for case management';
