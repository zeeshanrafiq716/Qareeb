CREATE TABLE IF NOT EXISTS category_asset_library (
  id VARCHAR(100) PRIMARY KEY,
  label VARCHAR(255) NOT NULL,
  path TEXT NOT NULL,
  is_custom BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed official realistic vehicle fleet presets if table is empty
INSERT INTO category_asset_library (id, label, path, is_custom)
VALUES
  ('car_ride', 'Ride (Sedan Car)', '/assets/categories/car_ride.png', false),
  ('pickup', 'Pickup (Hilux Truck)', '/assets/categories/pickup.png', false),
  ('rider', 'Rider (Motorbike)', '/assets/categories/rider_bike.png', false),
  ('van', 'Van (Toyota HiAce)', '/assets/categories/van.png', false),
  ('flatbed_truck', 'Flatbed Tow Truck (سطحة)', '/assets/categories/flatbed_truck.png', false),
  ('towing', 'Towing Truck (سطحة ونش)', '/assets/categories/towing.png', false),
  ('heavy_truk', 'Heavy Truck (شاحنة نقل)', '/assets/categories/truk.png', false),
  ('ambulance', 'Ambulance (إسعاف)', '/assets/categories/ambulance.png', false),
  ('police', 'Police Car (شرطة)', '/assets/categories/police.png', false),
  ('fire_brigade', 'Fire Brigade (دفاع مدني)', '/assets/categories/fire_brigade.png', false),
  ('emergency', 'Emergency Beacon', '/assets/categories/emergency_beacon.png', false)
ON CONFLICT (id) DO UPDATE SET
  label = EXCLUDED.label,
  path = EXCLUDED.path;

