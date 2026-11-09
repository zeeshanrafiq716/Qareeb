CREATE TABLE IF NOT EXISTS cities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(120) NOT NULL,
  name_ar VARCHAR(120),
  latitude NUMERIC(10, 7) NOT NULL,
  longitude NUMERIC(10, 7) NOT NULL,
  zoom INT NOT NULL DEFAULT 13,
  is_enabled BOOLEAN NOT NULL DEFAULT true,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT cities_name_unique UNIQUE (name)
);

-- Seed default major Saudi cities
INSERT INTO cities (name, name_ar, latitude, longitude, zoom, sort_order)
VALUES
  ('Riyadh', 'الرياض', 24.7136, 46.6753, 13, 1),
  ('Jeddah', 'جدة', 21.5433, 39.1728, 13, 2),
  ('Makkah', 'مكة المكرمة', 21.3891, 39.8579, 13, 3),
  ('Madinah', 'المدينة المنورة', 24.5247, 39.5692, 13, 4),
  ('Dammam', 'الدمام', 26.4207, 50.0888, 13, 5),
  ('Khobar', 'الخبر', 26.2818, 50.2084, 13, 6),
  ('Tabuk', 'تبوك', 28.3835, 36.5662, 13, 7),
  ('Taif', 'الطائف', 21.4373, 40.5127, 13, 8),
  ('Abha', 'أبها', 18.2164, 42.5053, 13, 9),
  ('Buraidah', 'بريدة', 26.3592, 43.9818, 13, 10),
  ('Jubail', 'الجبيل', 27.0046, 49.6601, 13, 11),
  ('Hail', 'حائل', 27.5216, 41.6907, 13, 12),
  ('Najran', 'نجران', 17.4924, 44.1277, 13, 13),
  ('Yanbu', 'ينبع', 24.0895, 38.0637, 13, 14)
ON CONFLICT (name) DO NOTHING;

