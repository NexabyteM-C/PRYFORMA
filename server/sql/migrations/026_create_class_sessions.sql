-- 026: Class sessions (specific timeslots sharing the same program)
CREATE TABLE IF NOT EXISTS class_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_program_id UUID NOT NULL REFERENCES class_programs(id) ON DELETE CASCADE,
  location_id UUID NOT NULL REFERENCES organization_locations(id) ON DELETE CASCADE,
  starts_at TIMESTAMPTZ NOT NULL,
  ends_at TIMESTAMPTZ NOT NULL,
  capacity INT,
  enrolled_count INT NOT NULL DEFAULT 0,
  is_cancelled BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_class_sessions_program ON class_sessions(class_program_id);
CREATE INDEX IF NOT EXISTS idx_class_sessions_location ON class_sessions(location_id);
CREATE INDEX IF NOT EXISTS idx_class_sessions_starts ON class_sessions(starts_at);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON class_sessions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
