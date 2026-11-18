-- 017: Personal records (derived index — recalculated from history)
DO $$ BEGIN
  CREATE TYPE record_type AS ENUM ('1rm', '3rm', '5rm', 'max_reps', 'max_duration', 'min_time', 'max_distance', 'max_weight');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE mark_source AS ENUM ('real', 'estimated', 'weighted', 'assisted');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS personal_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  record_type record_type NOT NULL,
  value_kg NUMERIC(7,2),
  value_reps INT,
  value_ms INT,
  value_distance_m NUMERIC(10,2),
  source mark_source NOT NULL DEFAULT 'real',
  achieved_at TIMESTAMPTZ NOT NULL,
  performance_set_id UUID REFERENCES performance_sets(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, exercise_id, record_type)
);

CREATE INDEX IF NOT EXISTS idx_pr_user ON personal_records(user_id);
CREATE INDEX IF NOT EXISTS idx_pr_exercise ON personal_records(exercise_id);
CREATE INDEX IF NOT EXISTS idx_pr_user_exercise ON personal_records(user_id, exercise_id);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON personal_records
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
