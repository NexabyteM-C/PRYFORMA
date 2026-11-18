-- 022: Class programs (a specific day's programming)
DO $$ BEGIN
  CREATE TYPE publication_status AS ENUM ('draft', 'scheduled', 'published', 'updated', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS class_programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  template_id UUID REFERENCES program_templates(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  program_date DATE NOT NULL,
  status publication_status NOT NULL DEFAULT 'draft',
  created_by UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(organization_id, program_date, title)
);

CREATE INDEX IF NOT EXISTS idx_class_programs_org ON class_programs(organization_id);
CREATE INDEX IF NOT EXISTS idx_class_programs_date ON class_programs(program_date);
CREATE INDEX IF NOT EXISTS idx_class_programs_status ON class_programs(status);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON class_programs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
