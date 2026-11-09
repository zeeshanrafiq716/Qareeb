import { beforeEach, describe, expect, it } from "vitest";
import { env } from "../src/config/env.js";
import { adminAuth, api, loginAdmin } from "./helpers.js";
import { resetDb } from "./setup.js";

describe("admin settings & vehicle types management", () => {
  beforeEach(async () => {
    await resetDb();
  });

  it("fetches admin profile", async () => {
    const token = await adminAuth();
    const res = await api()
      .get("/api/v1/admin/profile")
      .set("Authorization", `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.data.email).toBe(env.ADMIN_EMAIL);
    expect(res.body.data.role).toBe("admin");
  });

  it("allows admin to update email and password", async () => {
    const token = await adminAuth();
    const newEmail = "superadmin@qareeb.com";

    // 1. Update email
    const emailRes = await api()
      .patch("/api/v1/admin/profile")
      .set("Authorization", `Bearer ${token}`)
      .send({ email: newEmail });
    expect(emailRes.status).toBe(200);
    expect(emailRes.body.data.admin.email).toBe(newEmail);

    const updatedToken = emailRes.body.data.token;

    // 2. Update password
    const passRes = await api()
      .patch("/api/v1/admin/profile")
      .set("Authorization", `Bearer ${updatedToken}`)
      .send({
        currentPassword: env.ADMIN_PASSWORD,
        newPassword: "NewSecretPassword123!",
      });
    expect(passRes.status).toBe(200);

    // 3. Login with new credentials
    const loginRes = await api()
      .post("/api/v1/admin/auth/login")
      .send({
        email: newEmail,
        password: "NewSecretPassword123!",
      });
    expect(loginRes.status).toBe(200);
    expect(loginRes.body.data.admin.email).toBe(newEmail);
  });

  it("manages vehicle types and serves them to onboarding dropdowns", async () => {
    const token = await adminAuth();

    // 1. Create a vehicle type
    const createRes = await api()
      .post("/api/v1/admin/vehicle-types")
      .set("Authorization", `Bearer ${token}`)
      .send({
        name: "Custom Winch Truck",
        sortOrder: 1,
      });
    expect(createRes.status).toBe(201);
    expect(createRes.body.data.name).toBe("Custom Winch Truck");
    expect(createRes.body.data.slug).toBe("custom-winch-truck");
    const vehicleTypeId = createRes.body.data.id;

    // 2. List vehicle types
    const listRes = await api()
      .get("/api/v1/admin/vehicle-types")
      .set("Authorization", `Bearer ${token}`);
    expect(listRes.status).toBe(200);
    expect(listRes.body.data.some((v) => v.name === "Custom Winch Truck")).toBe(true);

    // 3. Public onboarding endpoint serves vehicle type names
    const publicTypes = await api().get("/api/v1/categories/vehicle-types");
    expect(publicTypes.status).toBe(200);
    expect(publicTypes.body.data).toContain("Custom Winch Truck");

    // 4. Patch vehicle type (disable)
    const patchRes = await api()
      .patch(`/api/v1/admin/vehicle-types/${vehicleTypeId}`)
      .set("Authorization", `Bearer ${token}`)
      .send({ isEnabled: false });
    expect(patchRes.status).toBe(200);
    expect(patchRes.body.data.isEnabled).toBe(false);

    // 5. Delete vehicle type
    const deleteRes = await api()
      .delete(`/api/v1/admin/vehicle-types/${vehicleTypeId}`)
      .set("Authorization", `Bearer ${token}`);
    expect(deleteRes.status).toBe(200);
    expect(deleteRes.body.data.deleted).toBe(true);
  });

  it("auto-translates added category and vehicle type into Arabic", async () => {
    const token = await adminAuth();

    // 1. Add "Workhouse" category without Arabic - verify server auto-translates to "ورشة عمل"
    const catRes = await api()
      .post("/api/v1/admin/categories")
      .set("Authorization", `Bearer ${token}`)
      .send({ name: "Workhouse Special" });
    expect(catRes.status).toBe(201);
    expect(catRes.body.data.nameAr).toContain("ورشة عمل");

    // 2. Add vehicle type with explicit Arabic name
    const typeRes = await api()
      .post("/api/v1/admin/vehicle-types")
      .set("Authorization", `Bearer ${token}`)
      .send({
        name: "Electric Tow Truck",
        nameAr: "سطحة كهربائية",
      });
    expect(typeRes.status).toBe(201);
    expect(typeRes.body.data.name).toBe("Electric Tow Truck");
    expect(typeRes.body.data.nameAr).toBe("سطحة كهربائية");

    // 3. Verify public endpoint returns Arabic when requested
    const arTypes = await api()
      .get("/api/v1/categories/vehicle-types?lang=ar");
    expect(arTypes.status).toBe(200);
    expect(arTypes.body.data).toContain("سطحة كهربائية");

    // 4. Verify public endpoint returns details with bilingual fields
    const detailedTypes = await api()
      .get("/api/v1/categories/vehicle-types?details=1");
    expect(detailedTypes.status).toBe(200);
    const found = detailedTypes.body.data.find((v) => v.name === "Electric Tow Truck");
    expect(found).toBeDefined();
    expect(found.nameAr).toBe("سطحة كهربائية");

    // 5. Test auto-translation for "Loader" and "Water Tank" (never leaks "خدمة Loader" or English)
    const loaderRes = await api()
      .post("/api/v1/admin/vehicle-types")
      .set("Authorization", `Bearer ${token}`)
      .send({ name: "Loader" });
    expect(loaderRes.status).toBe(201);
    expect(loaderRes.body.data.nameAr).toContain("لودر");
    expect(loaderRes.body.data.nameAr).not.toContain("خدمة Loader");

    const waterTankRes = await api()
      .post("/api/v1/admin/categories")
      .set("Authorization", `Bearer ${token}`)
      .send({ name: "Water Tank" });
    expect(waterTankRes.status).toBe(201);
    expect(waterTankRes.body.data.nameAr).not.toContain("خدمة Water Tank");
    expect(/[\u0600-\u06FF]/.test(waterTankRes.body.data.nameAr)).toBe(true);

    // 6. Test dedicated translation API
    const transApi = await api()
      .post("/api/v1/admin/translate")
      .set("Authorization", `Bearer ${token}`)
      .send({ text: "Heavy Bulldozer" });
    expect(transApi.status).toBe(200);
    expect(/[\u0600-\u06FF]/.test(transApi.body.data.translated)).toBe(true);
  });

  it("manages operational cities and serves them to admin map & discovery", async () => {
    const token = await adminAuth();

    // 1. List seeded cities
    const listRes = await api()
      .get("/api/v1/admin/cities")
      .set("Authorization", `Bearer ${token}`);
    expect(listRes.status).toBe(200);
    expect(Array.isArray(listRes.body.data)).toBe(true);
    expect(listRes.body.data.length).toBeGreaterThanOrEqual(1);

    // 2. Create a new city
    const createRes = await api()
      .post("/api/v1/admin/cities")
      .set("Authorization", `Bearer ${token}`)
      .send({
        name: "Al Ahsa",
        latitude: 25.3835,
        longitude: 49.5862,
        zoom: 12,
      });
    expect(createRes.status).toBe(201);
    expect(createRes.body.data.name).toBe("Al Ahsa");
    expect(createRes.body.data.nameAr).toBe("الأحساء");
    expect(createRes.body.data.latitude).toBe(25.3835);

    const cityId = createRes.body.data.id;

    // 3. Update city (toggle or edit coordinates)
    const patchRes = await api()
      .patch(`/api/v1/admin/cities/${cityId}`)
      .set("Authorization", `Bearer ${token}`)
      .send({
        zoom: 14,
        isEnabled: false,
      });
    expect(patchRes.status).toBe(200);
    expect(patchRes.body.data.zoom).toBe(14);
    expect(patchRes.body.data.isEnabled).toBe(false);

    // 4. Verify public cities endpoint returns only enabled cities
    const publicRes = await api().get("/api/v1/cities");
    expect(publicRes.status).toBe(200);
    const foundDisabled = publicRes.body.data.find((c) => c.id === cityId);
    expect(foundDisabled).toBeUndefined();

    // Re-enable city
    await api()
      .patch(`/api/v1/admin/cities/${cityId}`)
      .set("Authorization", `Bearer ${token}`)
      .send({ isEnabled: true });

    const publicRes2 = await api().get("/api/v1/cities");
    const foundEnabled = publicRes2.body.data.find((c) => c.id === cityId);
    expect(foundEnabled).toBeDefined();
    expect(foundEnabled.name).toBe("Al Ahsa");

    // 5. Delete city
    const delRes = await api()
      .delete(`/api/v1/admin/cities/${cityId}`)
      .set("Authorization", `Bearer ${token}`);
    expect(delRes.status).toBe(200);
  });
});

