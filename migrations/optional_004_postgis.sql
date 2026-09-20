-- Optional: requires PostGIS extension (see src/db/postgis.js)

ALTER TABLE locations
  ADD COLUMN IF NOT EXISTS geom geography(POINT, 4326);

CREATE INDEX IF NOT EXISTS idx_locations_geom ON locations USING GIST (geom)
  WHERE geom IS NOT NULL;

CREATE OR REPLACE FUNCTION sync_location_geom()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
    NEW.geom := ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326)::geography;
  ELSE
    NEW.geom := NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_locations_geom ON locations;
CREATE TRIGGER trg_locations_geom
  BEFORE INSERT OR UPDATE OF latitude, longitude ON locations
  FOR EACH ROW EXECUTE FUNCTION sync_location_geom();

UPDATE locations
SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography
WHERE latitude IS NOT NULL AND longitude IS NOT NULL AND geom IS NULL;
