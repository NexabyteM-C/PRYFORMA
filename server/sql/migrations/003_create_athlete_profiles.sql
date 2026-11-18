CREATE TYPE experience_level AS ENUM ('beginner', 'intermediate', 'advanced', 'elite');
CREATE TYPE weight_unit AS ENUM ('kg', 'lb');

CREATE TABLE IF NOT EXISTS athlete_profiles (
  user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  experience_level experience_level DEFAULT 'beginner',
  preferred_unit weight_unit DEFAULT 'kg',
  primary_sport TEXT,
  date_of_birth DATE,
  height_cm NUMERIC(5,1),
  weight_kg NUMERIC(5,1),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_athlete_profiles_updated_at
  BEFORE UPDATE ON athlete_profiles
  FOR EACH ROW
  EXECUTE FUNCTION trigger_set_updated_at();
