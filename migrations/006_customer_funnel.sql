-- Phase 3: customer funnel + direct contact accountability (no hosted call/chat)

CREATE TABLE IF NOT EXISTS customer_funnel_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID NOT NULL REFERENCES providers(id) ON DELETE CASCADE,
  event_type VARCHAR(40) NOT NULL,
  customer_session_id VARCHAR(64),
  customer_latitude DOUBLE PRECISION,
  customer_longitude DOUBLE PRECISION,
  metadata JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT customer_funnel_event_type_check CHECK (
    event_type IN (
      'list_impression',
      'profile_click',
      'profile_view',
      'call_click',
      'whatsapp_click',
      'share_location_click'
    )
  )
);

CREATE INDEX IF NOT EXISTS idx_customer_funnel_provider_created
  ON customer_funnel_events (provider_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_customer_funnel_provider_type
  ON customer_funnel_events (provider_id, event_type, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_customer_funnel_session
  ON customer_funnel_events (customer_session_id, created_at DESC)
  WHERE customer_session_id IS NOT NULL;
