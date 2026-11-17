-- Migration 019: Customer account status for admin block/unblock
ALTER TABLE customers
  ADD COLUMN IF NOT EXISTS status VARCHAR(32) NOT NULL DEFAULT 'active';

ALTER TABLE customers
  DROP CONSTRAINT IF EXISTS customers_status_check;

ALTER TABLE customers
  ADD CONSTRAINT customers_status_check CHECK (status IN ('active', 'blocked'));

CREATE INDEX IF NOT EXISTS idx_customers_status ON customers(status);