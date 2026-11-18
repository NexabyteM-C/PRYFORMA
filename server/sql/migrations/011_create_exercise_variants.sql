-- 011: Exercise variants
CREATE TABLE IF NOT EXISTS exercise_variants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  scaling_type TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_exercise_variants_exercise ON exercise_variants(exercise_id);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON exercise_variants
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
