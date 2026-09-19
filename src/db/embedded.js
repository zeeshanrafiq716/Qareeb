import os from "node:os";
import path from "node:path";
import EmbeddedPostgres from "embedded-postgres";
import { env } from "../config/env.js";
import { logger } from "../logger.js";

let instance;
let started = false;

export async function ensureEmbeddedPostgres() {
  if (!env.EMBEDDED_POSTGRES || started) return;

  const databaseDir = path.join(os.homedir(), "AppData", "Local", "qareeb-postgres");
  instance = new EmbeddedPostgres({
    databaseDir,
    user: "postgres",
    password: "postgres",
    port: env.EMBEDDED_POSTGRES_PORT,
    persistent: true,
    authMethod: "scram-sha-256",
    onLog: (message) => logger.debug({ msg: String(message).trim() }, "embedded-postgres"),
    onError: (error) => logger.error({ err: error }, "embedded-postgres error"),
  });

  try {
    await instance.initialise();
  } catch (error) {
    logger.debug({ err: error }, "Embedded Postgres already initialised");
  }

  try {
    await instance.start();
  } catch (error) {
    const text = String(error?.message || error);
    if (!/already|in use|running/i.test(text)) {
      throw error;
    }
  }

  for (const name of ["qareeb", "qareeb_test", "qareeb_staging"]) {
    try {
      await instance.createDatabase(name);
    } catch (error) {
      const text = String(error?.message || error);
      if (!/already exists/i.test(text)) {
        throw error;
      }
    }
  }

  started = true;
  logger.info(
    { port: env.EMBEDDED_POSTGRES_PORT, databaseDir },
    "Embedded PostgreSQL is ready",
  );
}

export async function stopEmbeddedPostgres() {
  if (instance && started) {
    await instance.stop();
    started = false;
  }
}
