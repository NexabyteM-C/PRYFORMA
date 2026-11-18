-- =============================================================================
-- Fitness Platform — Full Schema for Supabase
-- Run in the SQL Editor (Supabase Dashboard > SQL Editor > New Query)
-- Compatible with migration to self-hosted PostgreSQL
-- =============================================================================

-- ─── 0. Helper function ─────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ─── 1. Enums ───────────────────────────────────────────────────────────────
DO $$ BEGIN CREATE TYPE experience_level AS ENUM ('beginner','intermediate','advanced','elite'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE weight_unit AS ENUM ('kg','lb'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE member_role AS ENUM ('visitor','athlete','coach','box_admin','box_owner','superadmin'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE membership_status AS ENUM ('pending','active','suspended','cancelled'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE invitation_status AS ENUM ('pending','accepted','declined','expired','revoked'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE exercise_type AS ENUM ('strength','gymnastic','monostructural','weightlifting','powerlifting','accessory','mobility'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE metric_type AS ENUM ('weight','reps','duration','distance','calories','rounds','height'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE workout_type AS ENUM ('free','class','programmed','test'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE set_type AS ENUM ('warmup','working','drop','failure','amrap','emom'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE attempt_result AS ENUM ('success','failure','no_lift'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE record_type AS ENUM ('1rm','3rm','5rm','max_reps','max_duration','min_time','max_distance','max_weight'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE mark_source AS ENUM ('real','estimated','weighted','assisted'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE goal_status AS ENUM ('active','achieved','abandoned','paused'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE goal_type AS ENUM ('weight','reps','duration','distance','frequency','custom'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE block_type AS ENUM ('warmup','strength','skill','wod','cooldown','accessory','custom'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE scoring_type AS ENUM ('time','reps','weight','rounds_reps','pass_fail','none'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE publication_status AS ENUM ('draft','scheduled','published','updated','cancelled'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE publication_action AS ENUM ('created','scheduled','published','updated','cancelled'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE audience_type AS ENUM ('all_members','athletes_only','coaches_only','specific_roles','custom'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE notification_channel AS ENUM ('push','in_app','email'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE delivery_status AS ENUM ('pending','sent','delivered','failed','read'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE subscription_status AS ENUM ('trial','active','past_due','cancelled','expired'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE subscription_event_type AS ENUM ('created','activated','renewed','upgraded','downgraded','cancelled','expired','payment_failed','payment_succeeded'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN CREATE TYPE billing_status AS ENUM ('pending','paid','failed','refunded','voided'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ─── 2. Profiles (linked to auth.users) ────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  avatar_url TEXT,
  email_verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE TRIGGER set_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ─── 3. Athlete Profiles ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.athlete_profiles (
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

CREATE TRIGGER set_athlete_profiles_updated_at BEFORE UPDATE ON athlete_profiles
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 4. Organizations ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  description TEXT,
  logo_url TEXT,
  owner_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_organizations_owner ON organizations(owner_id);
CREATE INDEX IF NOT EXISTS idx_organizations_slug ON organizations(slug);
CREATE TRIGGER set_organizations_updated_at BEFORE UPDATE ON organizations
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 5. Organization Locations ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.organization_locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  address TEXT,
  city TEXT,
  state TEXT,
  country TEXT NOT NULL DEFAULT 'CO',
  timezone TEXT NOT NULL DEFAULT 'America/Bogota',
  latitude NUMERIC(10,7),
  longitude NUMERIC(10,7),
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_org_locations_org ON organization_locations(organization_id);
CREATE TRIGGER set_org_locations_updated_at BEFORE UPDATE ON organization_locations
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 6. Organization Members ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.organization_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role member_role NOT NULL DEFAULT 'athlete',
  status membership_status NOT NULL DEFAULT 'active',
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(organization_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_org_members_user ON organization_members(user_id);
CREATE INDEX IF NOT EXISTS idx_org_members_org ON organization_members(organization_id);
CREATE TRIGGER set_org_members_updated_at BEFORE UPDATE ON organization_members
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 7. Organization Invitations ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.organization_invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  invited_by UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  role member_role NOT NULL DEFAULT 'athlete',
  status invitation_status NOT NULL DEFAULT 'pending',
  token TEXT NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  accepted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_org_invitations_org ON organization_invitations(organization_id);
CREATE INDEX IF NOT EXISTS idx_org_invitations_email ON organization_invitations(email);
CREATE INDEX IF NOT EXISTS idx_org_invitations_token ON organization_invitations(token);
CREATE TRIGGER set_org_invitations_updated_at BEFORE UPDATE ON organization_invitations
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 8. Organization Permissions ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.organization_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  role member_role NOT NULL,
  permission_key TEXT NOT NULL,
  is_allowed BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(organization_id, role, permission_key)
);

CREATE INDEX IF NOT EXISTS idx_org_permissions_org ON organization_permissions(organization_id);
CREATE TRIGGER set_org_permissions_updated_at BEFORE UPDATE ON organization_permissions
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 9. Organization Announcements ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.organization_announcements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  is_pinned BOOLEAN NOT NULL DEFAULT FALSE,
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_org_announcements_org ON organization_announcements(organization_id);
CREATE INDEX IF NOT EXISTS idx_org_announcements_published ON organization_announcements(published_at DESC NULLS LAST);
CREATE TRIGGER set_org_announcements_updated_at BEFORE UPDATE ON organization_announcements
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 10. Exercises ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.exercises (
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
CREATE TRIGGER set_exercises_updated_at BEFORE UPDATE ON exercises
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 11. Exercise Variants ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.exercise_variants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  scaling_type TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_exercise_variants_exercise ON exercise_variants(exercise_id);
CREATE TRIGGER set_exercise_variants_updated_at BEFORE UPDATE ON exercise_variants
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 12. Exercise Metric Definitions ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.exercise_metric_definitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  metric metric_type NOT NULL,
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  unit TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(exercise_id, metric)
);

CREATE INDEX IF NOT EXISTS idx_metric_defs_exercise ON exercise_metric_definitions(exercise_id);
CREATE TRIGGER set_metric_defs_updated_at BEFORE UPDATE ON exercise_metric_definitions
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 13. Workout Sessions ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.workout_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL UNIQUE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  organization_id UUID REFERENCES organizations(id) ON DELETE SET NULL,
  type workout_type NOT NULL DEFAULT 'free',
  title TEXT,
  notes TEXT,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at TIMESTAMPTZ,
  duration_ms INT,
  is_synced BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workout_sessions_user ON workout_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_org ON workout_sessions(organization_id) WHERE organization_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_workout_sessions_started ON workout_sessions(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_client ON workout_sessions(client_id);
CREATE TRIGGER set_workout_sessions_updated_at BEFORE UPDATE ON workout_sessions
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 14. Workout Exercises ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.workout_exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL UNIQUE,
  workout_session_id UUID NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT,
  variant_id UUID REFERENCES exercise_variants(id) ON DELETE SET NULL,
  sort_order INT NOT NULL DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workout_exercises_session ON workout_exercises(workout_session_id);
CREATE INDEX IF NOT EXISTS idx_workout_exercises_exercise ON workout_exercises(exercise_id);
CREATE TRIGGER set_workout_exercises_updated_at BEFORE UPDATE ON workout_exercises
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 15. Performance Sets ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.performance_sets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL UNIQUE,
  workout_exercise_id UUID NOT NULL REFERENCES workout_exercises(id) ON DELETE CASCADE,
  set_number INT NOT NULL,
  set_type set_type NOT NULL DEFAULT 'working',
  weight_kg NUMERIC(7,2),
  reps INT,
  duration_ms INT,
  distance_m NUMERIC(10,2),
  calories INT,
  is_pr BOOLEAN NOT NULL DEFAULT FALSE,
  rpe NUMERIC(3,1),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_performance_sets_exercise ON performance_sets(workout_exercise_id);
CREATE TRIGGER set_performance_sets_updated_at BEFORE UPDATE ON performance_sets
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 16. Performance Attempts ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.performance_attempts (
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
CREATE TRIGGER set_attempts_updated_at BEFORE UPDATE ON performance_attempts
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 17. Personal Records ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.personal_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
  record_type record_type NOT NULL,
  value_kg NUMERIC(7,2),
  value_reps INT,
  value_ms INT,
  value_distance_m NUMERIC(10,2),
  source mark_source NOT NULL DEFAULT 'real',
  achieved_at TIMESTAMPTZ NOT NULL,
  performance_set_id UUID REFERENCES performance_sets(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, exercise_id, record_type)
);

CREATE INDEX IF NOT EXISTS idx_pr_user ON personal_records(user_id);
CREATE INDEX IF NOT EXISTS idx_pr_exercise ON personal_records(exercise_id);
CREATE INDEX IF NOT EXISTS idx_pr_user_exercise ON personal_records(user_id, exercise_id);
CREATE TRIGGER set_pr_updated_at BEFORE UPDATE ON personal_records
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 18. Goals ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  exercise_id UUID REFERENCES exercises(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  type goal_type NOT NULL DEFAULT 'custom',
  status goal_status NOT NULL DEFAULT 'active',
  target_value NUMERIC(10,2),
  current_value NUMERIC(10,2) NOT NULL DEFAULT 0,
  unit TEXT,
  deadline TIMESTAMPTZ,
  achieved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_goals_user ON goals(user_id);
CREATE INDEX IF NOT EXISTS idx_goals_status ON goals(status);
CREATE TRIGGER set_goals_updated_at BEFORE UPDATE ON goals
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 19. Goal Milestones ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.goal_milestones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  target_value NUMERIC(10,2) NOT NULL,
  achieved_at TIMESTAMPTZ,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_milestones_goal ON goal_milestones(goal_id);
CREATE TRIGGER set_milestones_updated_at BEFORE UPDATE ON goal_milestones
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 20. Program Templates ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.program_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  created_by UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  is_archived BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_program_templates_org ON program_templates(organization_id);
CREATE TRIGGER set_program_templates_updated_at BEFORE UPDATE ON program_templates
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 21. Program Template Blocks ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.program_template_blocks (
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
CREATE TRIGGER set_template_blocks_updated_at BEFORE UPDATE ON program_template_blocks
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 22. Class Programs ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.class_programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  template_id UUID REFERENCES program_templates(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  program_date DATE NOT NULL,
  status publication_status NOT NULL DEFAULT 'draft',
  created_by UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(organization_id, program_date, title)
);

CREATE INDEX IF NOT EXISTS idx_class_programs_org ON class_programs(organization_id);
CREATE INDEX IF NOT EXISTS idx_class_programs_date ON class_programs(program_date);
CREATE INDEX IF NOT EXISTS idx_class_programs_status ON class_programs(status);
CREATE TRIGGER set_class_programs_updated_at BEFORE UPDATE ON class_programs
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 23. Class Program Versions ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.class_program_versions (
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

-- ─── 24. Class Program Blocks ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.class_program_blocks (
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
CREATE TRIGGER set_program_blocks_updated_at BEFORE UPDATE ON class_program_blocks
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 25. Class Block Exercises ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.class_block_exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  block_id UUID NOT NULL REFERENCES class_program_blocks(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT,
  variant_id UUID REFERENCES exercise_variants(id) ON DELETE SET NULL,
  sets INT,
  reps TEXT,
  weight_prescription TEXT,
  duration_ms INT,
  rest_ms INT,
  tempo TEXT,
  notes TEXT,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_block_exercises_block ON class_block_exercises(block_id);
CREATE INDEX IF NOT EXISTS idx_block_exercises_exercise ON class_block_exercises(exercise_id);
CREATE TRIGGER set_block_exercises_updated_at BEFORE UPDATE ON class_block_exercises
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 26. Class Sessions ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.class_sessions (
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
CREATE TRIGGER set_class_sessions_updated_at BEFORE UPDATE ON class_sessions
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 27. Class Session Coaches ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.class_session_coaches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_session_id UUID NOT NULL REFERENCES class_sessions(id) ON DELETE CASCADE,
  coach_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  is_lead BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(class_session_id, coach_id)
);

CREATE INDEX IF NOT EXISTS idx_session_coaches_session ON class_session_coaches(class_session_id);
CREATE INDEX IF NOT EXISTS idx_session_coaches_coach ON class_session_coaches(coach_id);

-- ─── 28. Class Program Audiences ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.class_program_audiences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_program_id UUID NOT NULL REFERENCES class_programs(id) ON DELETE CASCADE,
  type audience_type NOT NULL DEFAULT 'all_members',
  roles member_role[] DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audiences_program ON class_program_audiences(class_program_id);
CREATE TRIGGER set_audiences_updated_at BEFORE UPDATE ON class_program_audiences
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 29. Publication Events ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.publication_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_program_id UUID NOT NULL REFERENCES class_programs(id) ON DELETE CASCADE,
  version_id UUID REFERENCES class_program_versions(id) ON DELETE SET NULL,
  action publication_action NOT NULL,
  performed_by UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  scheduled_for TIMESTAMPTZ,
  processed_at TIMESTAMPTZ,
  lock_token UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pub_events_program ON publication_events(class_program_id);
CREATE INDEX IF NOT EXISTS idx_pub_events_scheduled ON publication_events(scheduled_for)
  WHERE action = 'scheduled' AND processed_at IS NULL;

-- ─── 30. Athlete Class Results ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.athlete_class_results (
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
CREATE TRIGGER set_class_results_updated_at BEFORE UPDATE ON athlete_class_results
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 31. Notification Deliveries ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.notification_deliveries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES publication_events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  channel notification_channel NOT NULL,
  status delivery_status NOT NULL DEFAULT 'pending',
  title TEXT NOT NULL,
  body TEXT,
  payload JSONB,
  sent_at TIMESTAMPTZ,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(event_id, user_id, channel)
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notification_deliveries(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_status ON notification_deliveries(status) WHERE status = 'pending';
CREATE INDEX IF NOT EXISTS idx_notifications_event ON notification_deliveries(event_id);
CREATE TRIGGER set_notifications_updated_at BEFORE UPDATE ON notification_deliveries
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 32. Subscription Plans ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.subscription_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  price_cop NUMERIC(12,2) NOT NULL,
  interval_months INT NOT NULL DEFAULT 1,
  max_members INT,
  max_locations INT DEFAULT 1,
  features JSONB NOT NULL DEFAULT '{}',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_sub_plans_updated_at BEFORE UPDATE ON subscription_plans
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 33. Plan Features ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.plan_features (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID NOT NULL REFERENCES subscription_plans(id) ON DELETE CASCADE,
  feature_key TEXT NOT NULL,
  feature_label TEXT NOT NULL,
  limit_value INT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(plan_id, feature_key)
);

CREATE INDEX IF NOT EXISTS idx_plan_features_plan ON plan_features(plan_id);

-- ─── 34. Organization Subscriptions ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.organization_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  plan_id UUID NOT NULL REFERENCES subscription_plans(id) ON DELETE RESTRICT,
  status subscription_status NOT NULL DEFAULT 'trial',
  starts_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ends_at TIMESTAMPTZ,
  trial_ends_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_org_subs_org ON organization_subscriptions(organization_id);
CREATE INDEX IF NOT EXISTS idx_org_subs_status ON organization_subscriptions(status);
CREATE TRIGGER set_org_subs_updated_at BEFORE UPDATE ON organization_subscriptions
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 35. Subscription Events ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.subscription_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id UUID NOT NULL REFERENCES organization_subscriptions(id) ON DELETE CASCADE,
  event_type subscription_event_type NOT NULL,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sub_events_sub ON subscription_events(subscription_id);

-- ─── 36. Billing Records ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.billing_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  subscription_id UUID REFERENCES organization_subscriptions(id) ON DELETE SET NULL,
  amount_cop NUMERIC(12,2) NOT NULL,
  status billing_status NOT NULL DEFAULT 'pending',
  description TEXT,
  invoice_number TEXT,
  payment_method TEXT,
  paid_at TIMESTAMPTZ,
  due_date TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_billing_org ON billing_records(organization_id);
CREATE INDEX IF NOT EXISTS idx_billing_status ON billing_records(status);
CREATE TRIGGER set_billing_updated_at BEFORE UPDATE ON billing_records
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- ─── 37. Link Workout Sessions → Class Sessions ────────────────────────────
ALTER TABLE workout_sessions
  ADD COLUMN IF NOT EXISTS class_session_id UUID REFERENCES class_sessions(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_workout_sessions_class ON workout_sessions(class_session_id)
  WHERE class_session_id IS NOT NULL;

-- ─── 38. Row Level Security (RLS) ───────────────────────────────────────────
-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE athlete_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_metric_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE performance_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE performance_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE personal_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE goal_milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE program_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE program_template_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_program_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_program_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_block_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_session_coaches ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_program_audiences ENABLE ROW LEVEL SECURITY;
ALTER TABLE publication_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE athlete_class_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE plan_features ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE billing_records ENABLE ROW LEVEL SECURITY;

-- ── Profiles: users see and edit their own ──
CREATE POLICY profiles_select ON profiles FOR SELECT USING (true);
CREATE POLICY profiles_update ON profiles FOR UPDATE USING (auth.uid() = id);

-- ── Athlete profiles: own data ──
CREATE POLICY athlete_profiles_select ON athlete_profiles FOR SELECT USING (true);
CREATE POLICY athlete_profiles_insert ON athlete_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY athlete_profiles_update ON athlete_profiles FOR UPDATE USING (auth.uid() = user_id);

-- ── Organizations: public read, owner writes ──
CREATE POLICY orgs_select ON organizations FOR SELECT USING (true);
CREATE POLICY orgs_insert ON organizations FOR INSERT WITH CHECK (auth.uid() = owner_id);
CREATE POLICY orgs_update ON organizations FOR UPDATE USING (auth.uid() = owner_id);

-- ── Org locations: visible to members ──
CREATE POLICY org_locations_select ON organization_locations FOR SELECT USING (true);
CREATE POLICY org_locations_manage ON organization_locations FOR ALL USING (
  EXISTS (SELECT 1 FROM organization_members WHERE organization_id = organization_locations.organization_id AND user_id = auth.uid() AND role IN ('box_admin','box_owner','superadmin') AND status = 'active')
);

-- ── Org members: read if member, write if admin ──
CREATE POLICY org_members_select ON organization_members FOR SELECT USING (
  user_id = auth.uid() OR EXISTS (SELECT 1 FROM organization_members om WHERE om.organization_id = organization_members.organization_id AND om.user_id = auth.uid() AND om.status = 'active')
);
CREATE POLICY org_members_insert ON organization_members FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM organization_members om WHERE om.organization_id = organization_members.organization_id AND om.user_id = auth.uid() AND om.role IN ('box_admin','box_owner','superadmin') AND om.status = 'active')
  OR auth.uid() = user_id
);
CREATE POLICY org_members_update ON organization_members FOR UPDATE USING (
  EXISTS (SELECT 1 FROM organization_members om WHERE om.organization_id = organization_members.organization_id AND om.user_id = auth.uid() AND om.role IN ('box_admin','box_owner','superadmin') AND om.status = 'active')
);

-- ── Invitations: org admins manage ──
CREATE POLICY invitations_select ON organization_invitations FOR SELECT USING (
  email = (SELECT email FROM profiles WHERE id = auth.uid()) OR
  EXISTS (SELECT 1 FROM organization_members om WHERE om.organization_id = organization_invitations.organization_id AND om.user_id = auth.uid() AND om.role IN ('coach','box_admin','box_owner','superadmin') AND om.status = 'active')
);
CREATE POLICY invitations_manage ON organization_invitations FOR ALL USING (
  EXISTS (SELECT 1 FROM organization_members om WHERE om.organization_id = organization_invitations.organization_id AND om.user_id = auth.uid() AND om.role IN ('box_admin','box_owner','superadmin') AND om.status = 'active')
);

-- ── Org permissions: admin only ──
CREATE POLICY org_perms_select ON organization_permissions FOR SELECT USING (
  EXISTS (SELECT 1 FROM organization_members om WHERE om.organization_id = organization_permissions.organization_id AND om.user_id = auth.uid() AND om.status = 'active')
);
CREATE POLICY org_perms_manage ON organization_permissions FOR ALL USING (
  EXISTS (SELECT 1 FROM organization_members om WHERE om.organization_id = organization_permissions.organization_id AND om.user_id = auth.uid() AND om.role IN ('box_admin','box_owner','superadmin') AND om.status = 'active')
);

-- ── Announcements: members read, admins/coaches write ──
CREATE POLICY announcements_select ON organization_announcements FOR SELECT USING (
  EXISTS (SELECT 1 FROM organization_members om WHERE om.organization_id = organization_announcements.organization_id AND om.user_id = auth.uid() AND om.status = 'active')
);
CREATE POLICY announcements_manage ON organization_announcements FOR ALL USING (
  EXISTS (SELECT 1 FROM organization_members om WHERE om.organization_id = organization_announcements.organization_id AND om.user_id = auth.uid() AND om.role IN ('coach','box_admin','box_owner','superadmin') AND om.status = 'active')
);

-- ── Exercises: global read, org-scoped write ──
CREATE POLICY exercises_select ON exercises FOR SELECT USING (true);
CREATE POLICY exercise_variants_select ON exercise_variants FOR SELECT USING (true);
CREATE POLICY metric_defs_select ON exercise_metric_definitions FOR SELECT USING (true);

-- ── Workouts: athlete owns their data ──
CREATE POLICY workouts_select ON workout_sessions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY workouts_insert ON workout_sessions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY workouts_update ON workout_sessions FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY workouts_delete ON workout_sessions FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY workout_ex_select ON workout_exercises FOR SELECT USING (
  EXISTS (SELECT 1 FROM workout_sessions ws WHERE ws.id = workout_exercises.workout_session_id AND ws.user_id = auth.uid())
);
CREATE POLICY workout_ex_insert ON workout_exercises FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM workout_sessions ws WHERE ws.id = workout_exercises.workout_session_id AND ws.user_id = auth.uid())
);

CREATE POLICY sets_select ON performance_sets FOR SELECT USING (
  EXISTS (SELECT 1 FROM workout_exercises we JOIN workout_sessions ws ON ws.id = we.workout_session_id WHERE we.id = performance_sets.workout_exercise_id AND ws.user_id = auth.uid())
);
CREATE POLICY sets_insert ON performance_sets FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM workout_exercises we JOIN workout_sessions ws ON ws.id = we.workout_session_id WHERE we.id = performance_sets.workout_exercise_id AND ws.user_id = auth.uid())
);

CREATE POLICY attempts_select ON performance_attempts FOR SELECT USING (
  EXISTS (SELECT 1 FROM performance_sets ps JOIN workout_exercises we ON we.id = ps.workout_exercise_id JOIN workout_sessions ws ON ws.id = we.workout_session_id WHERE ps.id = performance_attempts.performance_set_id AND ws.user_id = auth.uid())
);
CREATE POLICY attempts_insert ON performance_attempts FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM performance_sets ps JOIN workout_exercises we ON we.id = ps.workout_exercise_id JOIN workout_sessions ws ON ws.id = we.workout_session_id WHERE ps.id = performance_attempts.performance_set_id AND ws.user_id = auth.uid())
);

-- ── Personal records: own data ──
CREATE POLICY pr_select ON personal_records FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY pr_insert ON personal_records FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY pr_update ON personal_records FOR UPDATE USING (auth.uid() = user_id);

-- ── Goals: own data ──
CREATE POLICY goals_select ON goals FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY goals_insert ON goals FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY goals_update ON goals FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY goals_delete ON goals FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY milestones_select ON goal_milestones FOR SELECT USING (
  EXISTS (SELECT 1 FROM goals g WHERE g.id = goal_milestones.goal_id AND g.user_id = auth.uid())
);
CREATE POLICY milestones_manage ON goal_milestones FOR ALL USING (
  EXISTS (SELECT 1 FROM goals g WHERE g.id = goal_milestones.goal_id AND g.user_id = auth.uid())
);

-- ── Class programming: members read, coaches/admins write ──
CREATE POLICY programs_select ON class_programs FOR SELECT USING (
  EXISTS (SELECT 1 FROM organization_members om WHERE om.organization_id = class_programs.organization_id AND om.user_id = auth.uid() AND om.status = 'active')
);
CREATE POLICY programs_manage ON class_programs FOR ALL USING (
  EXISTS (SELECT 1 FROM organization_members om WHERE om.organization_id = class_programs.organization_id AND om.user_id = auth.uid() AND om.role IN ('coach','box_admin','box_owner','superadmin') AND om.status = 'active')
);

CREATE POLICY program_templates_select ON program_templates FOR SELECT USING (
  EXISTS (SELECT 1 FROM organization_members om WHERE om.organization_id = program_templates.organization_id AND om.user_id = auth.uid() AND om.status = 'active')
);
CREATE POLICY program_templates_manage ON program_templates FOR ALL USING (
  EXISTS (SELECT 1 FROM organization_members om WHERE om.organization_id = program_templates.organization_id AND om.user_id = auth.uid() AND om.role IN ('coach','box_admin','box_owner','superadmin') AND om.status = 'active')
);

CREATE POLICY template_blocks_select ON program_template_blocks FOR SELECT USING (true);
CREATE POLICY program_versions_select ON class_program_versions FOR SELECT USING (true);
CREATE POLICY program_blocks_select ON class_program_blocks FOR SELECT USING (true);
CREATE POLICY block_exercises_select ON class_block_exercises FOR SELECT USING (true);
CREATE POLICY sessions_select ON class_sessions FOR SELECT USING (true);
CREATE POLICY session_coaches_select ON class_session_coaches FOR SELECT USING (true);
CREATE POLICY audiences_select ON class_program_audiences FOR SELECT USING (true);
CREATE POLICY pub_events_select ON publication_events FOR SELECT USING (true);

-- ── Results: own data + org admins can view ──
CREATE POLICY results_select ON athlete_class_results FOR SELECT USING (
  auth.uid() = user_id OR
  EXISTS (SELECT 1 FROM class_sessions cs JOIN class_programs cp ON cp.id = cs.class_program_id JOIN organization_members om ON om.organization_id = cp.organization_id WHERE cs.id = athlete_class_results.class_session_id AND om.user_id = auth.uid() AND om.role IN ('coach','box_admin','box_owner','superadmin') AND om.status = 'active')
);
CREATE POLICY results_insert ON athlete_class_results FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY results_update ON athlete_class_results FOR UPDATE USING (auth.uid() = user_id);

-- ── Notifications: own data ──
CREATE POLICY notifications_select ON notification_deliveries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY notifications_update ON notification_deliveries FOR UPDATE USING (auth.uid() = user_id);

-- ── Subscriptions/billing: read-only for public plans, org admin for the rest ──
CREATE POLICY plans_select ON subscription_plans FOR SELECT USING (true);
CREATE POLICY plan_features_select ON plan_features FOR SELECT USING (true);

CREATE POLICY org_subs_select ON organization_subscriptions FOR SELECT USING (
  EXISTS (SELECT 1 FROM organization_members om WHERE om.organization_id = organization_subscriptions.organization_id AND om.user_id = auth.uid() AND om.role IN ('box_admin','box_owner','superadmin') AND om.status = 'active')
);
CREATE POLICY sub_events_select ON subscription_events FOR SELECT USING (
  EXISTS (SELECT 1 FROM organization_subscriptions os JOIN organization_members om ON om.organization_id = os.organization_id WHERE os.id = subscription_events.subscription_id AND om.user_id = auth.uid() AND om.role IN ('box_admin','box_owner','superadmin') AND om.status = 'active')
);
CREATE POLICY billing_select ON billing_records FOR SELECT USING (
  EXISTS (SELECT 1 FROM organization_members om WHERE om.organization_id = billing_records.organization_id AND om.user_id = auth.uid() AND om.role IN ('box_admin','box_owner','superadmin') AND om.status = 'active')
);
