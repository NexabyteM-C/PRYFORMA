-- 027: Class session coaches
CREATE TABLE IF NOT EXISTS class_session_coaches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_session_id UUID NOT NULL REFERENCES class_sessions(id) ON DELETE CASCADE,
  coach_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  is_lead BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(class_session_id, coach_id)
);

CREATE INDEX IF NOT EXISTS idx_session_coaches_session ON class_session_coaches(class_session_id);
CREATE INDEX IF NOT EXISTS idx_session_coaches_coach ON class_session_coaches(coach_id);
