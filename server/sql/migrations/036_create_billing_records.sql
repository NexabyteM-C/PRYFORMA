-- 036: Billing records
DO $$ BEGIN
  CREATE TYPE billing_status AS ENUM ('pending', 'paid', 'failed', 'refunded', 'voided');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS billing_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  subscription_id UUID REFERENCES organization_subscriptions(id) ON DELETE SET NULL,
  amount_cop NUMERIC(12,2) NOT NULL,
  status billing_status NOT NULL DEFAULT 'pending',
  description TEXT,
  invoice_number TEXT,
  payment_method TEXT,
  paid_at TIMESTAMPTZ,
  due_date TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_billing_org ON billing_records(organization_id);
CREATE INDEX IF NOT EXISTS idx_billing_status ON billing_records(status);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON billing_records
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
