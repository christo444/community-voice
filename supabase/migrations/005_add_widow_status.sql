-- Add new column for widow/single parent/dependent status
ALTER TABLE profile_details 
ADD COLUMN IF NOT EXISTS widow_singleparent_dependentfamilymember BOOLEAN;

-- Update the comment/documentation for the profile details
COMMENT ON COLUMN profile_details.widow_singleparent_dependentfamilymember IS 'Whether the user is a widow, single parent, or dependent family member';
