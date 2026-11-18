-- 014: Workout exercises (exercises within a session)
CREATE TABLE IF NOT EXISTS workout_exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL UNIQUE,
  workout_session_id UUID NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT,
  variant_id UUID REFERENCES exercise_variants(id) ON DELETE SET NULL,
  sort_order INT NOT NULL DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workout_exercises_session ON workout_exercises(workout_session_id);
CREATE INDEX IF NOT EXISTS idx_workout_exercises_exercise ON workout_exercises(exercise_id);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON workout_exercises
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
