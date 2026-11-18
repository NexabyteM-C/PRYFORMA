-- 009: Organization announcements
CREATE TABLE IF NOT EXISTS organization_announcements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  is_pinned BOOLEAN NOT NULL DEFAULT FALSE,
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_org_announcements_org ON organization_announcements(organization_id);
CREATE INDEX IF NOT EXISTS idx_org_announcements_published ON organization_announcements(published_at DESC NULLS LAST);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organization_announcements
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
