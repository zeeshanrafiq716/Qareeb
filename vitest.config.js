import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "node",
    fileParallelism: false,
    sequence: { concurrent: false },
    setupFiles: ["./tests/setup.js"],
    testTimeout: 30000,
    hookTimeout: 60000,
    reporters: ["verbose"],
  },
});
