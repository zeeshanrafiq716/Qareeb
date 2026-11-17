-- Migration 020: In-app notifications for providers (call, WhatsApp, location, requests)
CREATE TABLE IF NOT EXISTS provider_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID NOT NULL REFERENCES providers(id) ON DELETE CASCADE,
  event_type VARCHAR(64) NOT NULL,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  customer_session_id VARCHAR(64),
  customer_latitude NUMERIC(10, 7),
  customer_longitude NUMERIC(10, 7),
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  is_read BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_provider_notifications_provider_created
  ON provider_notifications (provider_id, created_at DESC);