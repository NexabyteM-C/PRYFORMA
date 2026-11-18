-- 013: Workout sessions (athlete-owned, organization_id nullable)
DO $$ BEGIN
  CREATE TYPE workout_type AS ENUM ('free', 'class', 'programmed', 'test');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS workout_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL UNIQUE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  organization_id UUID REFERENCES organizations(id) ON DELETE SET NULL,
  type workout_type NOT NULL DEFAULT 'free',
  title TEXT,
  notes TEXT,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at TIMESTAMPTZ,
  duration_ms INT,
  is_synced BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workout_sessions_user ON workout_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_org ON workout_sessions(organization_id) WHERE organization_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_workout_sessions_started ON workout_sessions(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_client ON workout_sessions(client_id);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON workout_sessions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
