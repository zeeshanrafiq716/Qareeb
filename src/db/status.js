import {
  CALL_STATUS,
  ENTITY,
  PROVIDER_STATUS,
  VERIFICATION_STATUS,
} from "../config/constants.js";
import { NotFoundError } from "../utils/AppError.js";
import { query } from "./pool.js";

let cache = null;

export function clearStatusCache() {
  cache = null;
}

export async function loadStatuses() {
  if (cache) return cache;
  const { rows } = await query(
    `SELECT id, entity_type, code, label, is_terminal, sort_order
     FROM statuses
     ORDER BY entity_type, sort_order`,
  );
  cache = rows;
  return cache;
}

export async function getStatus(entityType, code) {
  const statuses = await loadStatuses();
  const status = statuses.find((row) => row.entity_type === entityType && row.code === code);
  if (!status) {
    throw new NotFoundError(`Status not configured: ${entityType}:${code}`);
  }
  return status;
}

export const providerStatus = (code) => getStatus(ENTITY.PROVIDER, code);
export const verificationStatus = (code) => getStatus(ENTITY.VERIFICATION, code);
export const callStatus = (code) => getStatus(ENTITY.CALL, code);

export { PROVIDER_STATUS, VERIFICATION_STATUS, CALL_STATUS, ENTITY };
