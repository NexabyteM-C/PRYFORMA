-- 015: Performance sets
DO $$ BEGIN
  CREATE TYPE set_type AS ENUM ('warmup', 'working', 'drop', 'failure', 'amrap', 'emom');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS performance_sets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL UNIQUE,
  workout_exercise_id UUID NOT NULL REFERENCES workout_exercises(id) ON DELETE CASCADE,
  set_number INT NOT NULL,
  set_type set_type NOT NULL DEFAULT 'working',
  weight_kg NUMERIC(7,2),
  reps INT,
  duration_ms INT,
  distance_m NUMERIC(10,2),
  calories INT,
  is_pr BOOLEAN NOT NULL DEFAULT FALSE,
  rpe NUMERIC(3,1),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_performance_sets_exercise ON performance_sets(workout_exercise_id);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON performance_sets
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
