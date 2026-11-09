export function slugify(value) {
  const ascii = String(value)
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 140);
  if (ascii.length > 0) return ascii;
  return `item-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 6)}`;
}

export function pagination({ page = 1, limit = 20 }) {
  const safePage = Math.max(1, Number(page) || 1);
  const safeLimit = Math.min(100, Math.max(1, Number(limit) || 20));
  return {
    page: safePage,
    limit: safeLimit,
    offset: (safePage - 1) * safeLimit,
  };
}
