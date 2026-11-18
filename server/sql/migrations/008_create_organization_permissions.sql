-- 008: Organization permissions (configurable coach permissions per org)
CREATE TABLE IF NOT EXISTS organization_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  role member_role NOT NULL,
  permission_key TEXT NOT NULL,
  is_allowed BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(organization_id, role, permission_key)
);

CREATE INDEX IF NOT EXISTS idx_org_permissions_org ON organization_permissions(organization_id);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organization_permissions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
