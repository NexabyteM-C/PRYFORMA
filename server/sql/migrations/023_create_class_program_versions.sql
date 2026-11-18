-- 023: Class program versions (immutable snapshots of published content)
CREATE TABLE IF NOT EXISTS class_program_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_program_id UUID NOT NULL REFERENCES class_programs(id) ON DELETE CASCADE,
  version_number INT NOT NULL,
  published_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  published_by UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  change_summary TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(class_program_id, version_number)
);

CREATE INDEX IF NOT EXISTS idx_program_versions_program ON class_program_versions(class_program_id);
