-- Migration 013: Add sort_order to categories for home screen display ordering

ALTER TABLE categories ADD COLUMN IF NOT EXISTS sort_order INTEGER NOT NULL DEFAULT 0;

-- Assign initial sort order to existing categories based on standard hierarchy
WITH ranked AS (
  SELECT id, ROW_NUMBER() OVER (
    ORDER BY 
      CASE slug
        WHEN 'flatbed-truck' THEN 1
        WHEN 'towing-truck' THEN 2
        WHEN 'ride-sedan' THEN 3
        WHEN 'pickup-truck' THEN 4
        WHEN 'family-van' THEN 5
        WHEN 'emergency-beacon' THEN 6
        ELSE 100
      END,
      created_at ASC
  ) AS rnk
  FROM categories
)
UPDATE categories c
SET sort_order = ranked.rnk
FROM ranked
WHERE c.id = ranked.id AND (c.sort_order = 0 OR c.sort_order IS NULL);

