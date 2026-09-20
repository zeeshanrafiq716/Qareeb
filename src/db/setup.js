import pg from "pg";
import { env, databaseUrlFor } from "../config/env.js";
import { logger } from "../logger.js";
import { getPool, setPool, closePool } from "./pool.js";
import { migrate } from "./migrate.js";
import { seed } from "./seed.js";
import { ensureEmbeddedPostgres } from "./embedded.js";
import { tryEnablePostgis } from "./postgis.js";

function parseUrl(connectionString) {
  const url = new URL(connectionString);
  return {
    dbName: decodeURIComponent(url.pathname.replace(/^\//, "")),
    adminUrl: (() => {
      const next = new URL(connectionString);
      next.pathname = "/postgres";
      return next.toString();
    })(),
  };
}

async function createDatabaseIfNeeded(connectionString) {
  const { dbName, adminUrl } = parseUrl(connectionString);
  const admin = new pg.Client({ connectionString: adminUrl });
  await admin.connect();
  try {
    const exists = await admin.query("SELECT 1 FROM pg_database WHERE datname = $1", [dbName]);
    if (!exists.rowCount) {
      await admin.query(`CREATE DATABASE "${dbName.replaceAll('"', "")}"`);
      logger.info({ dbName }, "Created database");
    }
  } finally {
    await admin.end();
  }
}

export async function setupDatabase(connectionString = env.DATABASE_URL) {
  await ensureEmbeddedPostgres();
  await createDatabaseIfNeeded(connectionString);
  await closePool();
  setPool(
    new pg.Pool({
      connectionString,
      max: env.isTest ? 5 : 10,
    }),
  );
  await migrate(getPool());
  await tryEnablePostgis(getPool());
  if (env.AUTO_SEED || env.isTest) {
    await seed(getPool());
  }
  return getPool();
}

export async function setupTestDatabase() {
  return setupDatabase(env.DATABASE_URL_TEST || databaseUrlFor("qareeb_test"));
}

if (process.argv[1]?.endsWith("setup.js")) {
  setupDatabase()
    .then(async () => {
      logger.info("Database setup complete");
      await closePool();
      process.exit(0);
    })
    .catch((error) => {
      logger.error({ err: error }, "Database setup failed");
      process.exit(1);
    });
}
