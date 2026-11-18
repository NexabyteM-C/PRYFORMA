-- 021: Program template blocks
DO $$ BEGIN
  CREATE TYPE block_type AS ENUM ('warmup', 'strength', 'skill', 'wod', 'cooldown', 'accessory', 'custom');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE scoring_type AS ENUM ('time', 'reps', 'weight', 'rounds_reps', 'pass_fail', 'none');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS program_template_blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id UUID NOT NULL REFERENCES program_templates(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type block_type NOT NULL DEFAULT 'custom',
  scoring scoring_type NOT NULL DEFAULT 'none',
  description TEXT,
  time_cap_ms INT,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_template_blocks_template ON program_template_blocks(template_id);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON program_template_blocks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
