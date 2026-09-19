-- Qareeb Phase 1 schema: providers, categories, verification, status, location, call logs, admin

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS schema_migrations (
  id SERIAL PRIMARY KEY,
  filename TEXT UNIQUE NOT NULL,
  applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS statuses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type VARCHAR(32) NOT NULL,
  code VARCHAR(64) NOT NULL,
  label VARCHAR(120) NOT NULL,
  is_terminal BOOLEAN NOT NULL DEFAULT false,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT statuses_entity_code_unique UNIQUE (entity_type, code),
  CONSTRAINT statuses_entity_type_check CHECK (entity_type IN ('provider', 'verification', 'call'))
);

CREATE TABLE IF NOT EXISTS admins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL,
  password_hash TEXT NOT NULL,
  name VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL DEFAULT 'admin',
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT admins_email_unique UNIQUE (email),
  CONSTRAINT admins_email_format CHECK (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$')
);

CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(120) NOT NULL,
  slug VARCHAR(140) NOT NULL,
  is_enabled BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT categories_slug_unique UNIQUE (slug),
  CONSTRAINT categories_name_not_blank CHECK (length(trim(name)) > 1)
);

CREATE UNIQUE INDEX IF NOT EXISTS categories_name_lower_idx ON categories (LOWER(name));

CREATE SEQUENCE IF NOT EXISTS provider_public_id_seq START WITH 100001 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS providers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  public_id VARCHAR(24) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  phone_verified_at TIMESTAMPTZ,
  name VARCHAR(255),
  category_id UUID REFERENCES categories(id) ON DELETE RESTRICT,
  photo_url TEXT,
  status_id UUID NOT NULL REFERENCES statuses(id) ON DELETE RESTRICT,
  status_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT providers_public_id_unique UNIQUE (public_id),
  CONSTRAINT providers_phone_unique UNIQUE (phone),
  CONSTRAINT providers_public_id_format CHECK (public_id ~ '^QRB-[0-9]+$')
);

CREATE TABLE IF NOT EXISTS locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID NOT NULL REFERENCES providers(id) ON DELETE CASCADE,
  latitude NUMERIC(10, 7),
  longitude NUMERIC(10, 7),
  address TEXT,
  city VARCHAR(120),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT locations_provider_unique UNIQUE (provider_id),
  CONSTRAINT locations_latitude_range CHECK (latitude IS NULL OR (latitude >= -90 AND latitude <= 90)),
  CONSTRAINT locations_longitude_range CHECK (longitude IS NULL OR (longitude >= -180 AND longitude <= 180))
);

CREATE TABLE IF NOT EXISTS verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID NOT NULL REFERENCES providers(id) ON DELETE CASCADE,
  document_type VARCHAR(50) NOT NULL,
  document_url TEXT NOT NULL,
  status_id UUID NOT NULL REFERENCES statuses(id) ON DELETE RESTRICT,
  reviewed_by UUID REFERENCES admins(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT verifications_document_type_check CHECK (document_type IN ('cnic', 'passport', 'license', 'other'))
);

CREATE TABLE IF NOT EXISTS provider_status_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID NOT NULL REFERENCES providers(id) ON DELETE CASCADE,
  from_status_id UUID REFERENCES statuses(id) ON DELETE SET NULL,
  to_status_id UUID NOT NULL REFERENCES statuses(id) ON DELETE RESTRICT,
  changed_by_admin_id UUID REFERENCES admins(id) ON DELETE SET NULL,
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS call_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID NOT NULL REFERENCES providers(id) ON DELETE CASCADE,
  caller_phone VARCHAR(20),
  started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  ended_at TIMESTAMPTZ,
  duration_seconds INTEGER,
  status_id UUID NOT NULL REFERENCES statuses(id) ON DELETE RESTRICT,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT call_logs_duration_check CHECK (duration_seconds IS NULL OR duration_seconds >= 0),
  CONSTRAINT call_logs_ended_after_start CHECK (ended_at IS NULL OR ended_at >= started_at)
);

CREATE TABLE IF NOT EXISTS otp_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone VARCHAR(20) NOT NULL,
  code_hash TEXT NOT NULL,
  purpose VARCHAR(40) NOT NULL DEFAULT 'provider_register',
  expires_at TIMESTAMPTZ NOT NULL,
  verified_at TIMESTAMPTZ,
  attempts INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_providers_status_id ON providers (status_id);
CREATE INDEX IF NOT EXISTS idx_providers_category_id ON providers (category_id);
CREATE INDEX IF NOT EXISTS idx_providers_created_at ON providers (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_providers_name ON providers (LOWER(name));
CREATE INDEX IF NOT EXISTS idx_locations_city ON locations (LOWER(city));
CREATE INDEX IF NOT EXISTS idx_verifications_provider_id ON verifications (provider_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_verifications_status_id ON verifications (status_id);
CREATE INDEX IF NOT EXISTS idx_status_history_provider ON provider_status_history (provider_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_call_logs_provider_id ON call_logs (provider_id, started_at DESC);
CREATE INDEX IF NOT EXISTS idx_otp_phone_created ON otp_codes (phone, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_otp_unverified ON otp_codes (phone) WHERE verified_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_admins_email ON admins (email);
CREATE INDEX IF NOT EXISTS idx_categories_enabled ON categories (is_enabled);

DROP TRIGGER IF EXISTS trg_admins_updated_at ON admins;
CREATE TRIGGER trg_admins_updated_at BEFORE UPDATE ON admins
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_categories_updated_at ON categories;
CREATE TRIGGER trg_categories_updated_at BEFORE UPDATE ON categories
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_providers_updated_at ON providers;
CREATE TRIGGER trg_providers_updated_at BEFORE UPDATE ON providers
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_locations_updated_at ON locations;
CREATE TRIGGER trg_locations_updated_at BEFORE UPDATE ON locations
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_verifications_updated_at ON verifications;
CREATE TRIGGER trg_verifications_updated_at BEFORE UPDATE ON verifications
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
