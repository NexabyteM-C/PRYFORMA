-- 030: Athlete class results
CREATE TABLE IF NOT EXISTS athlete_class_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_session_id UUID NOT NULL REFERENCES class_sessions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  block_id UUID REFERENCES class_program_blocks(id) ON DELETE SET NULL,
  workout_session_id UUID REFERENCES workout_sessions(id) ON DELETE SET NULL,
  score_value NUMERIC(10,2),
  score_unit TEXT,
  rx BOOLEAN NOT NULL DEFAULT FALSE,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(class_session_id, user_id, block_id)
);

CREATE INDEX IF NOT EXISTS idx_class_results_session ON athlete_class_results(class_session_id);
CREATE INDEX IF NOT EXISTS idx_class_results_user ON athlete_class_results(user_id);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON athlete_class_results
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
