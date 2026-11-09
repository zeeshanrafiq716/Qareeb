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

  it("allows admin to reorder categories and returns them in custom sort order publicly", async () => {
    const token = await adminAuth();

    // 1. Fetch current categories
    const initial = await api().get("/api/v1/categories");
    expect(initial.status).toBe(200);
    const cats = initial.body.data;
    expect(cats.length).toBeGreaterThanOrEqual(2);

    const firstCat = cats[0];
    const secondCat = cats[1];

    // 2. Reorder them (swap 1st and 2nd)
    const reorderRes = await api()
      .patch("/api/v1/admin/categories/reorder")
      .set("Authorization", `Bearer ${token}`)
      .send({
        items: [
          { id: firstCat.id, sortOrder: 2 },
          { id: secondCat.id, sortOrder: 1 },
        ],
      });
    expect(reorderRes.status).toBe(200);

    // 3. Verify public endpoint now serves secondCat first
    const reorderedPublic = await api().get("/api/v1/categories");
    expect(reorderedPublic.status).toBe(200);
    expect(reorderedPublic.body.data[0].id).toBe(secondCat.id);
    expect(reorderedPublic.body.data[0].sortOrder).toBe(1);
    expect(reorderedPublic.body.data[1].id).toBe(firstCat.id);
    expect(reorderedPublic.body.data[1].sortOrder).toBe(2);

    // 4. Create category with custom sortOrder
    const customCreated = await api()
      .post("/api/v1/admin/categories")
      .set("Authorization", `Bearer ${token}`)
      .send({
        name: "VIP Helicopter",
        sortOrder: 0,
      });
    expect(customCreated.status).toBe(201);
    expect(customCreated.body.data.sortOrder).toBe(0);

    // Verify it is served at the very top (index 0) because sortOrder 0 < 1
    const finalPublic = await api().get("/api/v1/categories");
    expect(finalPublic.body.data[0].name).toBe("VIP Helicopter");
  });
});
