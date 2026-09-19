import { beforeEach, describe, expect, it } from "vitest";
import { adminAuth, api, completeRegistration } from "./helpers.js";
import { resetDb } from "./setup.js";

describe("category management", () => {
  beforeEach(async () => {
    await resetDb();
  });

  it("lists only enabled categories publicly", async () => {
    const res = await api().get("/api/v1/categories");
    expect(res.status).toBe(200);
    expect(res.body.data.length).toBeGreaterThan(0);
    expect(res.body.data.every((item) => item.isEnabled)).toBe(true);
  });

  it("lets admin add, disable, enable, and remove a category", async () => {
    const token = await adminAuth();
    const created = await api()
      .post("/api/v1/admin/categories")
      .set("Authorization", `Bearer ${token}`)
      .send({ name: "Welder" });
    expect(created.status).toBe(201);
    expect(created.body.data.slug).toBe("welder");

    const disabled = await api()
      .patch(`/api/v1/admin/categories/${created.body.data.id}`)
      .set("Authorization", `Bearer ${token}`)
      .send({ isEnabled: false });
    expect(disabled.body.data.isEnabled).toBe(false);

    const publicList = await api().get("/api/v1/categories");
    expect(publicList.body.data.find((item) => item.slug === "welder")).toBeUndefined();

    const enabled = await api()
      .patch(`/api/v1/admin/categories/${created.body.data.id}`)
      .set("Authorization", `Bearer ${token}`)
      .send({ isEnabled: true });
    expect(enabled.body.data.isEnabled).toBe(true);

    const removed = await api()
      .delete(`/api/v1/admin/categories/${created.body.data.id}`)
      .set("Authorization", `Bearer ${token}`);
    expect(removed.status).toBe(200);
  });

  it("does not delete a category assigned to a provider", async () => {
    const created = await completeRegistration("03040000001");
    const token = await adminAuth();
    const categoryId = created.profile.body.data.category.id;
    const res = await api()
      .delete(`/api/v1/admin/categories/${categoryId}`)
      .set("Authorization", `Bearer ${token}`);
    expect(res.status).toBe(409);
    expect(res.body.error.code).toBe("CATEGORY_IN_USE");
  });
});
