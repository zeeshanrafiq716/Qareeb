export const ENTITY = {
  PROVIDER: "provider",
  VERIFICATION: "verification",
  CALL: "call",
};

export const PROVIDER_STATUS = {
  PENDING_OTP: "pending_otp",
  PENDING_PROFILE: "pending_profile",
  PENDING_VERIFICATION: "pending_verification",
  APPROVED: "approved",
  REJECTED: "rejected",
  SUSPENDED: "suspended",
  BLOCKED: "blocked",
};

export const VERIFICATION_STATUS = {
  PENDING: "pending",
  APPROVED: "approved",
  REJECTED: "rejected",
};

export const CALL_STATUS = {
  INITIATED: "initiated",
  COMPLETED: "completed",
  MISSED: "missed",
  FAILED: "failed",
};

export const ROLES = {
  PROVIDER: "provider",
  ADMIN: "admin",
};

export const DOCUMENT_TYPES = [
  "iqama",
  "registration",
  "license",
  "driving_licence",
  "vehicle_photos",
  "vehicle_front",
  "vehicle_rear",
  "vehicle_left_side",
  "vehicle_right_side",
  "cnic",
  "passport",
  "other",
];

export const COMPULSORY_DOCUMENT_TYPES = [
  "iqama",
  "registration",
  "license",
  "vehicle_front",
  "vehicle_rear",
  "vehicle_left_side",
  "vehicle_right_side",
];
