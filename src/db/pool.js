import pg from "pg";
import { env } from "../config/env.js";
import { logger } from "../logger.js";

const { Pool } = pg;

let pool;

export function getPool(connectionString = env.DATABASE_URL) {
  if (!pool) {
    pool = new Pool({
      connectionString,
      max: env.isTest ? 5 : 10,
      idleTimeoutMillis: 10_000,
    });
    pool.on("error", (err) => {
      logger.error({ err }, "Unexpected PostgreSQL pool error");
    });
  }
  return pool;
}

export function setPool(nextPool) {
  pool = nextPool;
}

export async function query(text, params) {
  return getPool().query(text, params);
}

export async function withTransaction(fn) {
  const client = await getPool().connect();
  try {
    await client.query("BEGIN");
    const result = await fn(client);
    await client.query("COMMIT");
    return result;
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

export async function closePool() {
  if (pool) {
    await pool.end();
    pool = null;
  }
}
