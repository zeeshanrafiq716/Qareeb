import { normalizePhone } from "../utils/phone.js";

/** Build WHERE fragment for provider search (exact QRB id or E.164 phone when possible). */
export function buildProviderSearchFilter(search, values) {
  if (!search?.trim()) return null;
  const term = search.trim();
  if (/^QRB-\d+$/i.test(term)) {
    values.push(term.toUpperCase());
    return `p.public_id = $${values.length}`;
  }
  try {
    const phone = normalizePhone(term);
    values.push(phone);
    return `p.phone = $${values.length}`;
  } catch {
    values.push(`%${term}%`);
    const idx = values.length;
    return `(p.phone ILIKE $${idx} OR p.name ILIKE $${idx} OR p.public_id ILIKE $${idx})`;
  }
}

export function resolveLookupKeys(identifier) {
  const term = String(identifier).trim();
  if (/^QRB-\d+$/i.test(term)) {
    return { publicId: term.toUpperCase(), phone: null };
  }
  try {
    return { publicId: null, phone: normalizePhone(term) };
  } catch {
    return { publicId: null, phone: null, invalid: true };
  }
}
