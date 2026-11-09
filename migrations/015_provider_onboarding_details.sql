-- Migration 015: Provider Onboarding Details & Vehicle Information
ALTER TABLE providers ADD COLUMN IF NOT EXISTS whatsapp_number VARCHAR(30);
ALTER TABLE providers ADD COLUMN IF NOT EXISTS iqama_number VARCHAR(50);
ALTER TABLE providers ADD COLUMN IF NOT EXISTS iqama_expiry VARCHAR(50);
ALTER TABLE providers ADD COLUMN IF NOT EXISTS vehicle_type_id UUID REFERENCES vehicle_types(id) ON DELETE SET NULL;
ALTER TABLE providers ADD COLUMN IF NOT EXISTS vehicle_type_name VARCHAR(120);
ALTER TABLE providers ADD COLUMN IF NOT EXISTS vehicle_model VARCHAR(120);
ALTER TABLE providers ADD COLUMN IF NOT EXISTS plate_number VARCHAR(50);
ALTER TABLE providers ADD COLUMN IF NOT EXISTS vehicle_color VARCHAR(50);

