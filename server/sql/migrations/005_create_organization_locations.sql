-- 005: Organization locations
CREATE TABLE IF NOT EXISTS organization_locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  address TEXT,
  city TEXT,
  state TEXT,
  country TEXT NOT NULL DEFAULT 'CO',
  timezone TEXT NOT NULL DEFAULT 'America/Bogota',
  latitude NUMERIC(10,7),
  longitude NUMERIC(10,7),
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_org_locations_org ON organization_locations(organization_id);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organization_locations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
