/** In-memory map: provider UUID → active socket ids (supports reconnect + multiple tabs). */
const byProvider = new Map();

export function addProviderSocket(providerId, socketId) {
  if (!byProvider.has(providerId)) {
    byProvider.set(providerId, new Set());
  }
  byProvider.get(providerId).add(socketId);
}

export function removeProviderSocket(providerId, socketId) {
  const set = byProvider.get(providerId);
  if (!set) return 0;
  set.delete(socketId);
  if (set.size === 0) {
    byProvider.delete(providerId);
    return 0;
  }
  return set.size;
}

export function providerConnectionCount(providerId) {
  return byProvider.get(providerId)?.size ?? 0;
}

export function hasLiveConnection(providerId) {
  return providerConnectionCount(providerId) > 0;
}

export function resetConnectionsForTests() {
  byProvider.clear();
}
