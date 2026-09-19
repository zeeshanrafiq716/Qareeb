# Qareeb Phase 1 — Manual API Testing

Base URL: `http://localhost:3000`

Har response format:

```json
{ "success": true, "data": { ... }, "meta": { ... } }
```

Error:

```json
{ "success": false, "error": { "code": "...", "message": "..." } }
```

---

## 1. Health check

```http
GET /health
GET /api/v1/health
```

---

## 2. Provider flow (step by step)

### 2.1 Categories (public)

Pehle category ka `id` copy karein (profile ke liye chahiye).

```http
GET /api/v1/categories
```

### 2.2 OTP request

Dev mode mein OTP response ke andar `data.otp` aata hai.

```http
POST /api/v1/auth/otp/request
Content-Type: application/json

{ "phone": "03001234567" }
```

### 2.3 OTP verify

Response se `data.token` (provider JWT) aur `data.provider.id` save karein.

```http
POST /api/v1/auth/otp/verify
Content-Type: application/json

{ "phone": "03001234567", "otp": "<otp from step 2.2>" }
```

Expected status: `pending_profile`

### 2.4 Profile (multipart)

Header: `Authorization: Bearer <provider token>`

Fields (form-data):

| Key | Example |
|-----|---------|
| name | Ali Plumber |
| categoryId | uuid from categories |
| city | Lahore |
| address | Shop 12 |
| latitude | 31.5204 |
| longitude | 74.3587 |
| photo | file (jpg/png) |

```http
PUT /api/v1/providers/me/profile
Authorization: Bearer {{providerToken}}
```

### 2.5 Verification document (multipart)

| Key | Value |
|-----|--------|
| documentType | cnic \| passport \| license \| other |
| document | file (jpg/png/pdf) |

```http
POST /api/v1/providers/me/verification
Authorization: Bearer {{providerToken}}
```

Expected status: `pending_verification`

### 2.6 My profile

```http
GET /api/v1/providers/me
Authorization: Bearer {{providerToken}}
```

---

## 3. Admin flow

### 3.1 Login

```http
POST /api/v1/admin/auth/login
Content-Type: application/json

{
  "email": "admin@qareeb.app",
  "password": "QareebAdmin@123"
}
```

Save `data.token` as admin token.

### 3.2 List providers

Optional query: `?status=pending_verification&search=Ali&page=1&limit=20`

```http
GET /api/v1/admin/providers
Authorization: Bearer {{adminToken}}
```

### 3.3 Provider details

```http
GET /api/v1/admin/providers/{{providerId}}
Authorization: Bearer {{adminToken}}
```

### 3.4 Approve / Reject / Suspend / Reinstate

```http
POST /api/v1/admin/providers/{{providerId}}/approve
Authorization: Bearer {{adminToken}}
Content-Type: application/json

{ "reason": "Documents OK" }
```

```http
POST /api/v1/admin/providers/{{providerId}}/reject
Content-Type: application/json

{ "reason": "Invalid CNIC" }
```

```http
POST /api/v1/admin/providers/{{providerId}}/suspend
Content-Type: application/json

{ "reason": "Policy violation" }
```

```http
POST /api/v1/admin/providers/{{providerId}}/reinstate
Content-Type: application/json

{ "reason": "Issue resolved" }
```

---

## 4. Categories (admin)

```http
GET    /api/v1/admin/categories
POST   /api/v1/admin/categories          body: { "name": "Welder" }
PATCH  /api/v1/admin/categories/{{id}}   body: { "isEnabled": false }
DELETE /api/v1/admin/categories/{{id}}
```

---

## Tools

| Tool | File |
|------|------|
| VS Code REST Client | `docs/api.http` |
| Postman | Import `docs/Qareeb-Phase1.postman_collection.json` |

---

## Full happy path checklist

1. OTP request → verify → `pending_profile`
2. Profile + photo → still `pending_profile`
3. Document upload → `pending_verification`
4. Admin approve → `approved`
5. `GET /providers/me` shows `approved`
