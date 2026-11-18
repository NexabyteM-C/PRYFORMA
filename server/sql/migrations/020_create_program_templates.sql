-- 020: Program templates (reusable workout blueprints)
CREATE TABLE IF NOT EXISTS program_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  created_by UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  is_archived BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_program_templates_org ON program_templates(organization_id);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON program_templates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
