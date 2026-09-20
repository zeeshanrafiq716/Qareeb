const online = new Map();
const sessions = new Map();
const locations = new Map();
const locationGate = new Map();

export function resetMemoryPresenceStore() {
  online.clear();
  sessions.clear();
  locations.clear();
  locationGate.clear();
}

export const memoryPresenceStore = {
  async setOnline(providerId) {
    online.set(providerId, { at: Date.now() });
  },
  async setOffline(providerId) {
    online.delete(providerId);
  },
  async touch(providerId) {
    online.set(providerId, { at: Date.now() });
  },
  async isOnline(providerId) {
    return online.has(providerId);
  },
  async addSession(providerId, socketId) {
    if (!sessions.has(providerId)) sessions.set(providerId, new Set());
    sessions.get(providerId).add(socketId);
  },
  async removeSession(providerId, socketId) {
    const set = sessions.get(providerId);
    if (!set) return 0;
    set.delete(socketId);
    if (set.size === 0) {
      sessions.delete(providerId);
      return 0;
    }
    return set.size;
  },
  async sessionCount(providerId) {
    return sessions.get(providerId)?.size ?? 0;
  },
  async setLocation(providerId, payload) {
    locations.set(providerId, payload);
  },
  async getLocation(providerId) {
    return locations.get(providerId) ?? null;
  },
  async getLocationGate(providerId) {
    return locationGate.get(providerId) ?? null;
  },
  async setLocationGate(providerId, ms) {
    locationGate.set(providerId, ms);
  },
};
