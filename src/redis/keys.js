export const RedisKeys = {
  online: (providerId) => `qareeb:presence:online:${providerId}`,
  sessions: (providerId) => `qareeb:presence:sessions:${providerId}`,
  location: (providerId) => `qareeb:presence:location:${providerId}`,
  locationGate: (providerId) => `qareeb:presence:location:gate:${providerId}`,
  onlineIndex: "qareeb:presence:online:index",
};
