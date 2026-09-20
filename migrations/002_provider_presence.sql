-- Phase 2: real-time provider presence (online / last-seen)

ALTER TABLE providers
  ADD COLUMN IF NOT EXISTS is_online BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS last_seen_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_providers_online ON providers (is_online) WHERE is_online = true;
CREATE INDEX IF NOT EXISTS idx_providers_last_seen ON providers (last_seen_at DESC);
