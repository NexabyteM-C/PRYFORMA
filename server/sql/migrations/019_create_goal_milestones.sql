-- 019: Goal milestones
CREATE TABLE IF NOT EXISTS goal_milestones (
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

CREATE TRIGGER set_updated_at BEFORE UPDATE ON goal_milestones
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
