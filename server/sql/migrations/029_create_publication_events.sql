-- 029: Publication events (state machine tracking)
DO $$ BEGIN
  CREATE TYPE publication_action AS ENUM ('created', 'scheduled', 'published', 'updated', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS publication_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_program_id UUID NOT NULL REFERENCES class_programs(id) ON DELETE CASCADE,
  version_id UUID REFERENCES class_program_versions(id) ON DELETE SET NULL,
  action publication_action NOT NULL,
  performed_by UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  scheduled_for TIMESTAMPTZ,
  processed_at TIMESTAMPTZ,
  lock_token UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pub_events_program ON publication_events(class_program_id);
CREATE INDEX IF NOT EXISTS idx_pub_events_scheduled ON publication_events(scheduled_for)
  WHERE action = 'scheduled' AND processed_at IS NULL;

CREATE TRIGGER set_updated_at BEFORE UPDATE ON publication_events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
