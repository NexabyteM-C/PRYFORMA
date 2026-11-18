-- 037: Link workout sessions to class sessions
ALTER TABLE workout_sessions
  ADD COLUMN IF NOT EXISTS class_session_id UUID REFERENCES class_sessions(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_workout_sessions_class ON workout_sessions(class_session_id)
  WHERE class_session_id IS NOT NULL;
