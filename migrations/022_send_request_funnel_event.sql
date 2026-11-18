-- Allow send_request_click and request_cancelled in customer_funnel_events
ALTER TABLE customer_funnel_events
  DROP CONSTRAINT IF EXISTS customer_funnel_event_type_check;

ALTER TABLE customer_funnel_events
  ADD CONSTRAINT customer_funnel_event_type_check CHECK (
    event_type IN (
      'list_impression',
      'profile_click',
      'profile_view',
      'call_click',
      'whatsapp_click',
      'share_location_click',
      'send_request_click',
      'request_cancelled'
    )
  );

