-- 016: Performance attempts (individual attempts within a set)
DO $$ BEGIN
  CREATE TYPE attempt_result AS ENUM ('success', 'failure', 'no_lift');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS performance_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL UNIQUE,
  performance_set_id UUID NOT NULL REFERENCES performance_sets(id) ON DELETE CASCADE,
  attempt_number INT NOT NULL,
  weight_kg NUMERIC(7,2),
  result attempt_result NOT NULL DEFAULT 'success',
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_attempts_set ON performance_attempts(performance_set_id);

CREATE TRIGGER set_updated_at BEFORE UPDATE ON performance_attempts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
