-- Provider login phone change requests (Reports & Complaints)
ALTER TABLE support_tickets
  ADD COLUMN IF NOT EXISTS provider_id UUID REFERENCES providers(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS requested_phone VARCHAR(32),
  ADD COLUMN IF NOT EXISTS ticket_type VARCHAR(64) NOT NULL DEFAULT 'general';

CREATE INDEX IF NOT EXISTS idx_support_tickets_provider ON support_tickets (provider_id);
CREATE INDEX IF NOT EXISTS idx_support_tickets_ticket_type ON support_tickets (ticket_type);