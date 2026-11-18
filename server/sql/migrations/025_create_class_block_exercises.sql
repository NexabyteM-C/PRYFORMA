-- 025: Class block exercises (exercises within a program block)
CREATE TABLE IF NOT EXISTS class_block_exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  block_id UUID NOT NULL REFERENCES class_program_blocks(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT,
  variant_id UUID REFERENCES exercise_variants(id) ON DELETE SET NULL,
  sets INT,
  reps TEXT,
  weight_prescription TEXT,
  duration_ms INT,
  rest_ms INT,
  tempo TEXT,
  notes TEXT,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_block_exercises_block ON class_block_exercises(block_id);
CREATE INDEX IF NOT EXISTS idx_block_exercises_exercise ON class_block_exercises(exercise_id);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON class_block_exercises
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
