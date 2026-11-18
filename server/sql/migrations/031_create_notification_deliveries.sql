-- 031: Notification deliveries (dedup via unique constraint)
DO $$ BEGIN
  CREATE TYPE notification_channel AS ENUM ('push', 'in_app', 'email');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE delivery_status AS ENUM ('pending', 'sent', 'delivered', 'failed', 'read');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS notification_deliveries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES publication_events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  channel notification_channel NOT NULL,
  status delivery_status NOT NULL DEFAULT 'pending',
  title TEXT NOT NULL,
  body TEXT,
  payload JSONB,
  sent_at TIMESTAMPTZ,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(event_id, user_id, channel)
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notification_deliveries(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_status ON notification_deliveries(status)
  WHERE status = 'pending';
CREATE INDEX IF NOT EXISTS idx_notifications_event ON notification_deliveries(event_id);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON notification_deliveries
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
