const base = "http://127.0.0.1:3000";

async function call(method, path, { token, json, form } = {}) {
  const headers = {};
  if (token) headers.Authorization = `Bearer ${token}`;
  let body;
  if (json) {
    headers["content-type"] = "application/json";
    body = JSON.stringify(json);
  } else if (form) {
    body = form;
  }
  const res = await fetch(base + path, { method, headers, body });
  const data = await res.json();
  if (!res.ok) {
    throw new Error(`${method} ${path} ${res.status} ${JSON.stringify(data)}`);
  }
  return data;
}

const png = Buffer.from(
  "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==",
  "base64",
);

const health = await call("GET", "/health");
const categories = await call("GET", "/api/v1/categories");
const otp = await call("POST", "/api/v1/auth/otp/request", { json: { phone: "03211234567" } });
const verified = await call("POST", "/api/v1/auth/otp/verify", {
  json: { phone: "03211234567", otp: otp.data.otp },
});

const profileForm = new FormData();
profileForm.set("name", "Staging Plumber");
profileForm.set("categoryId", categories.data[0].id);
profileForm.set("city", "Karachi");
profileForm.set("photo", new Blob([png], { type: "image/png" }), "photo.png");
const profile = await call("PUT", "/api/v1/providers/me/profile", {
  token: verified.data.token,
  form: profileForm,
});

const docForm = new FormData();
docForm.set("documentType", "cnic");
docForm.set("document", new Blob([png], { type: "image/png" }), "cnic.png");
const document = await call("POST", "/api/v1/providers/me/verification", {
  token: verified.data.token,
  form: docForm,
});

const admin = await call("POST", "/api/v1/admin/auth/login", {
  json: { email: "admin@qareeb.app", password: "QareebAdmin@123" },
});
const approved = await call("POST", `/api/v1/admin/providers/${verified.data.provider.id}/approve`, {
  token: admin.data.token,
  json: { reason: "Staging smoke test" },
});

console.log(JSON.stringify({
  health: health.data.status,
  categories: categories.data.length,
  otpPhone: otp.data.phone,
  afterOtp: verified.data.provider.status,
  afterProfile: profile.data.status,
  afterDocument: document.data.status,
  afterApprove: approved.data.status,
  providerId: verified.data.provider.providerId,
}, null, 2));
