-- 007: Organization invitations
DO $$ BEGIN
  CREATE TYPE invitation_status AS ENUM ('pending', 'accepted', 'declined', 'expired', 'revoked');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS organization_invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  invited_by UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  role member_role NOT NULL DEFAULT 'athlete',
  status invitation_status NOT NULL DEFAULT 'pending',
  token TEXT NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  accepted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_org_invitations_org ON organization_invitations(organization_id);
CREATE INDEX IF NOT EXISTS idx_org_invitations_email ON organization_invitations(email);
CREATE INDEX IF NOT EXISTS idx_org_invitations_token ON organization_invitations(token);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organization_invitations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
