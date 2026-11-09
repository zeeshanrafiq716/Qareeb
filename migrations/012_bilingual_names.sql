-- Migration 012: Add bilingual support for categories and vehicle types

ALTER TABLE categories ADD COLUMN IF NOT EXISTS name_ar VARCHAR(120);
ALTER TABLE categories ADD COLUMN IF NOT EXISTS subtitle_ar VARCHAR(255);

ALTER TABLE vehicle_types ADD COLUMN IF NOT EXISTS name_ar VARCHAR(120);

-- Update existing categories with Arabic translations
UPDATE categories
SET name = 'Flatbed Truck', name_ar = 'سطحة'
WHERE slug = 'flatbed-truck' OR LOWER(name) LIKE '%flatbed%';

UPDATE categories
SET name = 'Towing Truck', name_ar = 'ونش'
WHERE slug = 'towing-truck' OR LOWER(name) LIKE '%towing%';

UPDATE categories
SET name = 'Ride Sedan', name_ar = 'توصيل'
WHERE slug = 'ride-sedan' OR LOWER(name) LIKE '%ride sedan%';

UPDATE categories
SET name = 'Pickup Truck', name_ar = 'وانيت'
WHERE slug = 'pickup-truck' OR LOWER(name) LIKE '%pickup%';

UPDATE categories
SET name = 'Family Van', name_ar = 'فان'
WHERE slug = 'family-van' OR LOWER(name) LIKE '%family van%';

UPDATE categories
SET name = 'Emergency Beacon', name_ar = 'طوارئ'
WHERE slug = 'emergency-beacon' OR LOWER(name) LIKE '%emergency%';

-- Specifically translate "workhouse" or workshop
UPDATE categories
SET name_ar = 'ورشة عمل'
WHERE LOWER(name) = 'workhouse' OR LOWER(slug) = 'workhouse' OR LOWER(name) LIKE '%workhouse%';

UPDATE categories
SET name_ar = 'ورشة عمل'
WHERE (LOWER(name) = 'workshop' OR LOWER(slug) = 'workshop') AND (name_ar IS NULL OR name_ar = '');

-- Update existing vehicle types with Arabic translations
UPDATE vehicle_types
SET name = 'Flatbed Tow Truck', name_ar = 'سطحة عادية'
WHERE slug = 'flatbed-tow-truck' OR LOWER(name) LIKE '%flatbed tow%';

UPDATE vehicle_types
SET name = 'Hydraulic Low Flatbed', name_ar = 'سطحة هيدروليك'
WHERE slug = 'hydraulic-low-flatbed' OR LOWER(name) LIKE '%hydraulic%';

UPDATE vehicle_types
SET name = 'Wheel Lift Tow Truck', name_ar = 'ونش رفع'
WHERE slug = 'wheel-lift-tow-truck' OR LOWER(name) LIKE '%wheel lift%';

UPDATE vehicle_types
SET name = 'Heavy Duty Recovery Truck', name_ar = 'سطحة ثقيل'
WHERE slug = 'heavy-duty-recovery-truck' OR LOWER(name) LIKE '%heavy duty%';

UPDATE vehicle_types
SET name = 'Covered Carrier', name_ar = 'سطحة مغلقة VIP'
WHERE slug = 'covered-carrier-vip' OR LOWER(name) LIKE '%covered%';

UPDATE vehicle_types
SET name = 'Motorbike Carrier', name_ar = 'سطحة دبابات'
WHERE slug = 'motorbike-carrier' OR LOWER(name) LIKE '%motorbike%';

-- For any remaining rows where name has (عربي), extract it into name_ar
UPDATE categories
SET name_ar = substring(name from '\(([\u0600-\u06FF\s]+)\)')
WHERE (name_ar IS NULL OR name_ar = '') AND name ~ '\(([\u0600-\u06FF\s]+)\)';

UPDATE vehicle_types
SET name_ar = substring(name from '\(([\u0600-\u06FF\s]+)\)')
WHERE (name_ar IS NULL OR name_ar = '') AND name ~ '\(([\u0600-\u06FF\s]+)\)';

