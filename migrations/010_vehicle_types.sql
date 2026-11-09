-- Migration 010: Vehicle Types Table
CREATE TABLE IF NOT EXISTS vehicle_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(120) NOT NULL,
  slug VARCHAR(140) NOT NULL,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  icon VARCHAR(60),
  is_enabled BOOLEAN NOT NULL DEFAULT true,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT vehicle_types_slug_unique UNIQUE (slug),
  CONSTRAINT vehicle_types_name_not_blank CHECK (length(trim(name)) > 1)
);

CREATE UNIQUE INDEX IF NOT EXISTS vehicle_types_name_lower_idx ON vehicle_types (LOWER(name));

