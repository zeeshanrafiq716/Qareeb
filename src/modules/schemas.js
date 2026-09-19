import { z } from "zod";

export const otpRequestSchema = z.object({
  body: z.object({
    phone: z.string().min(10).max(20),
  }),
});

export const otpVerifySchema = z.object({
  body: z.object({
    phone: z.string().min(10).max(20),
    otp: z.string().regex(/^\d{6}$/, "OTP must be 6 digits"),
  }),
});

export const profileSchema = z.object({
  body: z.object({
    name: z.string().trim().min(2).max(255),
    categoryId: z.string().uuid(),
    address: z.string().trim().max(500).optional().or(z.literal("")),
    city: z.string().trim().max(120).optional().or(z.literal("")),
    latitude: z.coerce.number().min(-90).max(90).optional(),
    longitude: z.coerce.number().min(-180).max(180).optional(),
  }),
});

export const verificationSchema = z.object({
  body: z.object({
    documentType: z.enum(["cnic", "passport", "license", "other"]),
  }),
});

export const adminLoginSchema = z.object({
  body: z.object({
    email: z.string().email(),
    password: z.string().min(6),
  }),
});
                                         
export const providerListSchema = z.object({
  query: z.object({
    status: z.string().optional(),
    search: z.string().optional(),
    page: z.coerce.number().int().positive().optional(),
    limit: z.coerce.number().int().positive().max(100).optional(),
  }),
});

export const idParamSchema = z.object({
  params: z.object({
    id: z.string().uuid(),
  }),
});

export const reasonSchema = z.object({
  params: z.object({ id: z.string().uuid() }),
  body: z.object({
    reason: z.string().trim().min(3).max(500),
  }),
});

export const optionalReasonSchema = z.object({
  params: z.object({ id: z.string().uuid() }),
  body: z
    .object({
      reason: z.string().trim().max(500).optional(),
    })
    .default({}),
});

export const categoryCreateSchema = z.object({
  body: z.object({
    name: z.string().trim().min(2).max(120),
  }),
});

export const categoryPatchSchema = z.object({
  params: z.object({ id: z.string().uuid() }),
  body: z.object({
    name: z.string().trim().min(2).max(120).optional(),
    isEnabled: z.boolean().optional(),
  }),
});
