-- Migration to allow unassigned cases (User Requests)
-- Created: 2026-03-25

-- Ensure paralegal_id can be NULL for initial User Requests (before acceptance)
ALTER TABLE paralegal_cases ALTER COLUMN paralegal_id DROP NOT NULL;

-- Rename status 'open' to 'pending' if desired? No, 'open' is fine for requests.
-- 'open' = User Request
-- 'in_progress' = Accepted/Approved by Paralegal
-- 'completed' = Done

-- Add comment
COMMENT ON COLUMN paralegal_cases.paralegal_id IS 'can be NULL for unassigned user requests';
