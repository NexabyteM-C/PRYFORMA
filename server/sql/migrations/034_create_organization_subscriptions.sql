-- 034: Organization subscriptions
DO $$ BEGIN
  CREATE TYPE subscription_status AS ENUM ('trial', 'active', 'past_due', 'cancelled', 'expired');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS organization_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  plan_id UUID NOT NULL REFERENCES subscription_plans(id) ON DELETE RESTRICT,
  status subscription_status NOT NULL DEFAULT 'trial',
  starts_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ends_at TIMESTAMPTZ,
  trial_ends_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_org_subs_org ON organization_subscriptions(organization_id);
CREATE INDEX IF NOT EXISTS idx_org_subs_status ON organization_subscriptions(status);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON organization_subscriptions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
