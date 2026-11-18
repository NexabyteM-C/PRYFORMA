-- 035: Subscription events (lifecycle tracking)
DO $$ BEGIN
  CREATE TYPE subscription_event_type AS ENUM ('created', 'activated', 'renewed', 'upgraded', 'downgraded', 'cancelled', 'expired', 'payment_failed', 'payment_succeeded');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS subscription_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id UUID NOT NULL REFERENCES organization_subscriptions(id) ON DELETE CASCADE,
  event_type subscription_event_type NOT NULL,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sub_events_sub ON subscription_events(subscription_id);
