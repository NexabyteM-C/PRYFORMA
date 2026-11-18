-- 033: Plan features
CREATE TABLE IF NOT EXISTS plan_features (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID NOT NULL REFERENCES subscription_plans(id) ON DELETE CASCADE,
  feature_key TEXT NOT NULL,
  feature_label TEXT NOT NULL,
  limit_value INT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(plan_id, feature_key)
);

CREATE INDEX IF NOT EXISTS idx_plan_features_plan ON plan_features(plan_id);
