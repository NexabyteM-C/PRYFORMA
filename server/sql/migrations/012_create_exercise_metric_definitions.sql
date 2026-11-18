-- 012: Exercise metric definitions
DO $$ BEGIN
  CREATE TYPE metric_type AS ENUM ('weight', 'reps', 'duration', 'distance', 'calories', 'rounds', 'height');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS exercise_metric_definitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  metric metric_type NOT NULL,
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  unit TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(exercise_id, metric)
);

CREATE INDEX IF NOT EXISTS idx_metric_defs_exercise ON exercise_metric_definitions(exercise_id);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON exercise_metric_definitions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
