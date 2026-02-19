-- Add password reset requirement for paralegals
-- Created: 2026-02-19

-- Add must_reset_password column to paralegals table
ALTER TABLE paralegals 
ADD COLUMN IF NOT EXISTS must_reset_password BOOLEAN DEFAULT false;

-- Set existing paralegals to require password reset (if any)
UPDATE paralegals 
SET must_reset_password = true 
WHERE must_reset_password IS NULL OR must_reset_password = false;

COMMENT ON COLUMN paralegals.must_reset_password IS 'Forces paralegal to reset password on next login';
