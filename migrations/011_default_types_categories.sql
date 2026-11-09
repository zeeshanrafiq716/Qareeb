-- Migration 011: Seed initial default categories and vehicle types
INSERT INTO categories (name, slug, subtitle, is_enabled) VALUES
('Flatbed Truck (سطحة)', 'flatbed-truck', 'Standard breakdown & tow transport', true),
('Towing Truck (ونش)', 'towing-truck', 'Heavy wheel-lift and winch recovery', true),
('Ride Sedan (توصيل)', 'ride-sedan', 'City car and passenger support', true),
('Pickup Truck (وانيت)', 'pickup-truck', 'Light cargo and open bed transport', true),
('Family Van (فان)', 'family-van', 'Spacious passenger and equipment transport', true),
('Emergency Beacon (طوارئ)', 'emergency-beacon', 'Emergency road and battery assistance', true)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO vehicle_types (name, slug, sort_order, is_enabled) VALUES
('Flatbed Tow Truck (سطحة عادية)', 'flatbed-tow-truck', 1, true),
('Hydraulic Low Flatbed (سطحة هيدروليك)', 'hydraulic-low-flatbed', 2, true),
('Wheel Lift Tow Truck (ونش رفع)', 'wheel-lift-tow-truck', 3, true),
('Heavy Duty Recovery Truck (سطحة ثقيل)', 'heavy-duty-recovery-truck', 4, true),
('Covered Carrier (سطحة مغلقة VIP)', 'covered-carrier-vip', 5, true),
('Motorbike Carrier (سطحة دبابات)', 'motorbike-carrier', 6, true)
ON CONFLICT (slug) DO NOTHING;

