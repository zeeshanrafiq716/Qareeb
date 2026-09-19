import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { getPool } from "./pool.js";
import { logger } from "../logger.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const migrationsDir = path.resolve(__dirname, "../../migrations");

export async function migrate(pool = getPool()) {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      id SERIAL PRIMARY KEY,
      filename TEXT UNIQUE NOT NULL,
      applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
    )
  `);

  const files = (await fs.readdir(migrationsDir))
    .filter((file) => file.endsWith(".sql"))
    .sort();

  const applied = await pool.query("SELECT filename FROM schema_migrations");
  const done = new Set(applied.rows.map((row) => row.filename));

  for (const file of files) {
    if (done.has(file)) continue;
    const sql = await fs.readFile(path.join(migrationsDir, file), "utf8");
    const client = await pool.connect();
    try {
      await client.query("BEGIN");
      await client.query(sql);
      await client.query("INSERT INTO schema_migrations (filename) VALUES ($1)", [file]);
      await client.query("COMMIT");
      logger.info({ file }, "Applied migration");
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  }
}

if (import.meta.url === `file://${process.argv[1]}`.replaceAll("\\", "/") || process.argv[1]?.endsWith("migrate.js")) {
  migrate()
    .then(() => {
      logger.info("Migrations complete");
      process.exit(0);
    })
    .catch((error) => {
      logger.error({ err: error }, "Migration failed");
      process.exit(1);
    });
}
