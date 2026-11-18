-- 028: Class program audiences (who gets notified)
DO $$ BEGIN
  CREATE TYPE audience_type AS ENUM ('all_members', 'athletes_only', 'coaches_only', 'specific_roles', 'custom');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS class_program_audiences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_program_id UUID NOT NULL REFERENCES class_programs(id) ON DELETE CASCADE,
  type audience_type NOT NULL DEFAULT 'all_members',
  roles member_role[] DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audiences_program ON class_program_audiences(class_program_id);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON class_program_audiences
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
