import { describe, expect, it, beforeEach } from "vitest";
import { api } from "./helpers.js";
import { resetDb } from "./setup.js";

describe("health and root", () => {
  beforeEach(async () => {
    await resetDb();
  });

  it("GET /health returns healthy", async () => {
    const res = await api().get("/health");
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.status).toBe("healthy");
  });

  it("GET / returns app metadata", async () => {
    const res = await api().get("/");
    expect(res.status).toBe(200);
    expect(res.body.data.phase).toBe(2);
    expect(res.body.data.name).toBe("Qareeb App");
  });

  it("GET /api/v1/health returns phase 2", async () => {
    const res = await api().get("/api/v1/health");
    expect(res.status).toBe(200);
    expect(res.body.data.phase).toBe(2);
  });

  it("unknown route returns 404", async () => {
    const res = await api().get("/api/v1/does-not-exist");
    expect(res.status).toBe(404);
    expect(res.body.error.code).toBe("NOT_FOUND");
  });
});
