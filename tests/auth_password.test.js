import { beforeEach, describe, expect, it } from "vitest";
import { app, api, requestOtp, verifyOtp } from "./helpers.js";
import { resetDb } from "./setup.js";

describe("Phone + Password Authentication (Customer & Provider)", () => {
  beforeEach(async () => {
    await resetDb();
  });

  it("allows setting a password for a provider and logging in with phone + password", async () => {
    // 1. Register provider via OTP
    await requestOtp("03001234567");
    const verifyRes = await verifyOtp("03001234567", "123456");
    expect(verifyRes.status).toBe(200);

    // 2. Set password for provider
    const setRes = await api()
      .post("/api/v1/auth/password/set")
      .send({
        phone: "+923001234567",
        password: "secretpassword123",
        userType: "provider",
      });
    expect(setRes.status).toBe(200);
    expect(setRes.body.data.success).toBe(true);

    // 3. Log in with phone + password
    const loginRes = await api()
      .post("/api/v1/auth/login")
      .send({
        phone: "+923001234567",
        password: "secretpassword123",
        userType: "provider",
      });

    expect(loginRes.status).toBe(200);
    expect(loginRes.body.data.token).toBeTruthy();
    expect(loginRes.body.data.userType).toBe("provider");
    expect(loginRes.body.data.provider.phone).toBe("+923001234567");
  });

  it("rejects invalid password on provider login", async () => {
    await requestOtp("03001234567");
    await verifyOtp("03001234567", "123456");

    await api()
      .post("/api/v1/auth/password/set")
      .send({
        phone: "+923001234567",
        password: "secretpassword123",
        userType: "provider",
      });

    const badLogin = await api()
      .post("/api/v1/auth/login")
      .send({
        phone: "+923001234567",
        password: "wrongpassword",
        userType: "provider",
      });

    expect(badLogin.status).toBe(401);
    expect(badLogin.body.error.code).toBe("INVALID_CREDENTIALS");
  });

  it("supports customer account registration, password setting and phone + password login", async () => {
    // 1. Customer sets password or registers
    const setCustRes = await api()
      .post("/api/v1/auth/password/set")
      .send({
        phone: "+966501234567",
        password: "customerpass123",
        userType: "customer",
        name: "Ahmad Al-Harbi",
      });

    expect(setCustRes.status).toBe(200);
    expect(setCustRes.body.data.customer.name).toBe("Ahmad Al-Harbi");

    // 2. Customer logs in directly with phone + password
    const loginCustRes = await api()
      .post("/api/v1/auth/login")
      .send({
        phone: "+966501234567",
        password: "customerpass123",
        userType: "customer",
      });

    expect(loginCustRes.status).toBe(200);
    expect(loginCustRes.body.data.token).toBeTruthy();
    expect(loginCustRes.body.data.userType).toBe("customer");
    expect(loginCustRes.body.data.customer.name).toBe("Ahmad Al-Harbi");
    expect(loginCustRes.body.data.customer.phone).toBe("+966501234567");
  });

  it("rejects non-existent phone number on login", async () => {
    const res = await api()
      .post("/api/v1/auth/login")
      .send({
        phone: "+966509999999",
        password: "somepassword",
        userType: "customer",
      });

    expect(res.status).toBe(404);
    expect(res.body.error.code).toBe("ACCOUNT_NOT_FOUND");
  });

  it("prevents duplicate customer signup with same phone number", async () => {
    const phone = "+966501112233";

    // 1. Initial customer signup via OTP
    await api()
      .post("/api/v1/auth/otp/request")
      .send({ phone, channel: "sms", userType: "customer", purpose: "signup" });

    const verifyRes = await api()
      .post("/api/v1/auth/otp/verify")
      .send({
        phone,
        otp: "123456",
        name: "First Customer",
        password: "securepassword123",
        userType: "customer",
        purpose: "signup",
      });
    expect(verifyRes.status).toBe(200);
    expect(verifyRes.body.data.token).toBeTruthy();

    // 2. Second signup attempt with same phone in requestOtp must fail with 409
    const dupRequestRes = await api()
      .post("/api/v1/auth/otp/request")
      .send({ phone, channel: "sms", userType: "customer", purpose: "signup" });

    expect(dupRequestRes.status).toBe(409);
    expect(dupRequestRes.body.error.code).toBe("ACCOUNT_ALREADY_EXISTS");

    // 3. User can log in with password
    const loginRes = await api()
      .post("/api/v1/auth/login")
      .send({
        phone,
        password: "securepassword123",
        userType: "customer",
      });
    expect(loginRes.status).toBe(200);
    expect(loginRes.body.data.customer.phone).toBe(phone);
  });

  it("allows setting a password during provider OTP verification and logging in", async () => {
    const phone = "+966555123456";

    // 1. Initial provider signup via OTP
    await api()
      .post("/api/v1/auth/otp/request")
      .send({ phone, channel: "sms", userType: "provider", purpose: "signup" });

    const verifyRes = await api()
      .post("/api/v1/auth/otp/verify")
      .send({
        phone,
        otp: "123456",
        password: "providerpass123",
        userType: "provider",
        purpose: "signup",
      });
    expect(verifyRes.status).toBe(200);
    expect(verifyRes.body.data.token).toBeTruthy();

    // 2. Duplicate signup attempt with same phone in requestOtp must fail with 409
    const dupRequestRes = await api()
      .post("/api/v1/auth/otp/request")
      .send({ phone, channel: "sms", userType: "provider", purpose: "signup" });

    expect(dupRequestRes.status).toBe(409);
    expect(dupRequestRes.body.error.code).toBe("ACCOUNT_ALREADY_EXISTS");

    // 3. Provider can log in with password
    const loginRes = await api()
      .post("/api/v1/auth/login")
      .send({
        phone,
        password: "providerpass123",
        userType: "provider",
      });
    expect(loginRes.status).toBe(200);
    expect(loginRes.body.data.token).toBeTruthy();
    expect(loginRes.body.data.userType).toBe("provider");
  });

  it("blocks registering as a customer when phone is already a registered provider", async () => {
    const phone = "+966555987654";

    // 1. Register as provider
    await api()
      .post("/api/v1/auth/otp/request")
      .send({ phone, channel: "sms", userType: "provider", purpose: "signup" });

    await api()
      .post("/api/v1/auth/otp/verify")
      .send({
        phone,
        otp: "123456",
        password: "providerpass123",
        userType: "provider",
        purpose: "signup",
      });

    // 2. Attempting customer signup with same phone must be rejected with 409
    const custOtpRes = await api()
      .post("/api/v1/auth/otp/request")
      .send({ phone, channel: "sms", userType: "customer", purpose: "signup" });

    expect(custOtpRes.status).toBe(409);
    expect(custOtpRes.body.error.code).toBe("ACCOUNT_ALREADY_EXISTS");

    // 3. Attempting customer login with provider phone must reject with ROLE_MISMATCH
    const custLoginRes = await api()
      .post("/api/v1/auth/login")
      .send({
        phone,
        password: "providerpass123",
        userType: "customer",
      });

    expect(custLoginRes.status).toBe(400);
    expect(custLoginRes.body.error.code).toBe("ROLE_MISMATCH");
  });

  it("blocks registering as a provider when phone is already a registered customer", async () => {
    const phone = "+966555112233";

    // 1. Register as customer
    await api()
      .post("/api/v1/auth/otp/request")
      .send({ phone, channel: "sms", userType: "customer", purpose: "signup" });

    await api()
      .post("/api/v1/auth/otp/verify")
      .send({
        phone,
        otp: "123456",
        name: "Test Customer",
        password: "customerpass123",
        userType: "customer",
        purpose: "signup",
      });

    // 2. Attempting provider signup with same phone must be rejected with 409
    const provOtpRes = await api()
      .post("/api/v1/auth/otp/request")
      .send({ phone, channel: "sms", userType: "provider", purpose: "signup" });

    expect(provOtpRes.status).toBe(409);
    expect(provOtpRes.body.error.code).toBe("ACCOUNT_ALREADY_EXISTS");

    // 3. Attempting provider login with customer phone must reject with ROLE_MISMATCH
    const provLoginRes = await api()
      .post("/api/v1/auth/login")
      .send({
        phone,
        password: "customerpass123",
        userType: "provider",
      });

    expect(provLoginRes.status).toBe(400);
    expect(provLoginRes.body.error.code).toBe("ROLE_MISMATCH");
  });
});
