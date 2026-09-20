-- Phase 2: battery-efficient location tracking metadata

ALTER TABLE locations
  ADD COLUMN IF NOT EXISTS location_updated_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_locations_coords ON locations (latitude, longitude)
  WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_locations_updated ON locations (location_updated_at DESC)
  WHERE location_updated_at IS NOT NULL;
