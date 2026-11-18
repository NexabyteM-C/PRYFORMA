-- 010: Exercises catalog
DO $$ BEGIN
  CREATE TYPE exercise_type AS ENUM ('strength', 'gymnastic', 'monostructural', 'weightlifting', 'powerlifting', 'accessory', 'mobility');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  type exercise_type NOT NULL,
  description TEXT,
  muscle_groups TEXT[] NOT NULL DEFAULT '{}',
  equipment TEXT[] NOT NULL DEFAULT '{}',
  is_compound BOOLEAN NOT NULL DEFAULT FALSE,
  is_global BOOLEAN NOT NULL DEFAULT TRUE,
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_exercises_type ON exercises(type);
CREATE INDEX IF NOT EXISTS idx_exercises_slug ON exercises(slug);
CREATE INDEX IF NOT EXISTS idx_exercises_org ON exercises(organization_id) WHERE organization_id IS NOT NULL;

CREATE TRIGGER set_updated_at BEFORE UPDATE ON exercises
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
