-- 018: Goals
DO $$ BEGIN
  CREATE TYPE goal_status AS ENUM ('active', 'achieved', 'abandoned', 'paused');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE goal_type AS ENUM ('weight', 'reps', 'duration', 'distance', 'frequency', 'custom');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  exercise_id UUID REFERENCES exercises(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  type goal_type NOT NULL DEFAULT 'custom',
  status goal_status NOT NULL DEFAULT 'active',
  target_value NUMERIC(10,2),
  current_value NUMERIC(10,2) NOT NULL DEFAULT 0,
  unit TEXT,
  deadline TIMESTAMPTZ,
  achieved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_goals_user ON goals(user_id);
CREATE INDEX IF NOT EXISTS idx_goals_status ON goals(status);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON goals
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
