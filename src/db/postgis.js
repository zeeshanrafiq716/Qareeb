import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { logger } from "../logger.js";

let postgisAvailable = false;

export function isPostgisEnabled() {
  return postgisAvailable;
}

export async function tryEnablePostgis(pool) {
  try {
    await pool.query("CREATE EXTENSION IF NOT EXISTS postgis");
    const dir = path.dirname(fileURLToPath(import.meta.url));
    const sql = await fs.readFile(path.join(dir, "../../migrations/optional_004_postgis.sql"), "utf8");
    await pool.query(sql);
    postgisAvailable = true;
    logger.info("PostGIS enabled for geospatial queries");
  } catch (error) {
    postgisAvailable = false;
    logger.warn({ err: error.message }, "PostGIS not available — using haversine queries");
  }
  return postgisAvailable;
}
