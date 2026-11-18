-- 024: Class program blocks (blocks within a specific version)
CREATE TABLE IF NOT EXISTS class_program_blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  version_id UUID NOT NULL REFERENCES class_program_versions(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type block_type NOT NULL DEFAULT 'custom',
  scoring scoring_type NOT NULL DEFAULT 'none',
  description TEXT,
  coach_notes TEXT,
  time_cap_ms INT,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_program_blocks_version ON class_program_blocks(version_id);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON class_program_blocks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
