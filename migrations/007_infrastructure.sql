-- Phase 5: push tokens, OTP audit, performance indexes

CREATE TABLE IF NOT EXISTS provider_device_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID NOT NULL REFERENCES providers(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL,
  platform VARCHAR(20) NOT NULL DEFAULT 'android',
  app_version VARCHAR(40),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT provider_device_tokens_platform_check CHECK (platform IN ('android', 'ios', 'web')),
  CONSTRAINT provider_device_tokens_unique UNIQUE (provider_id, fcm_token)
);

CREATE INDEX IF NOT EXISTS idx_provider_device_tokens_provider
  ON provider_device_tokens (provider_id, updated_at DESC);

CREATE TABLE IF NOT EXISTS otp_request_audit (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone VARCHAR(20) NOT NULL,
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_otp_audit_phone_created
  ON otp_request_audit (phone, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_otp_audit_ip_created
  ON otp_request_audit (ip_address, created_at DESC)
  WHERE ip_address IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_providers_online_approved
  ON providers (status_id, is_online, last_seen_at DESC)
  WHERE is_online = true;

CREATE INDEX IF NOT EXISTS idx_locations_fresh
  ON locations (provider_id, location_updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_customer_funnel_created
  ON customer_funnel_events (created_at DESC);
