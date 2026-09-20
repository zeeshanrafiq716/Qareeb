-- Phase 3: provider ratings for customer discovery

ALTER TABLE providers
  ADD COLUMN IF NOT EXISTS rating_avg NUMERIC(3, 2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS rating_count INTEGER NOT NULL DEFAULT 0;

ALTER TABLE providers DROP CONSTRAINT IF EXISTS providers_rating_avg_range;
ALTER TABLE providers ADD CONSTRAINT providers_rating_avg_range
  CHECK (rating_avg >= 0 AND rating_avg <= 5);

ALTER TABLE providers DROP CONSTRAINT IF EXISTS providers_rating_count_nonneg;
ALTER TABLE providers ADD CONSTRAINT providers_rating_count_nonneg
  CHECK (rating_count >= 0);
