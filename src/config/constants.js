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

export const DOCUMENT_TYPES = ["cnic", "passport", "license", "other"];
