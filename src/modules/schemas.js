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
    categoryId: z.string().trim().min(1),
    categoryName: z.string().trim().optional(),
    whatsappNumber: z.string().trim().max(30).optional().or(z.literal("")),
    whatsapp: z.string().trim().max(30).optional().or(z.literal("")),
    iqamaNumber: z.string().trim().max(50).optional().or(z.literal("")),
    nationalId: z.string().trim().max(50).optional().or(z.literal("")),
    iqamaExpiry: z.string().trim().max(50).optional().or(z.literal("")),
    vehicleType: z.string().trim().max(120).optional().or(z.literal("")),
    vehicleTypeId: z.string().trim().optional().or(z.literal("")),
    vehicleModel: z.string().trim().max(120).optional().or(z.literal("")),
    plateNumber: z.string().trim().max(50).optional().or(z.literal("")),
    vehicleColor: z.string().trim().max(50).optional().or(z.literal("")),
    address: z.string().trim().max(500).optional().or(z.literal("")),
    city: z.string().trim().max(120).optional().or(z.literal("")),
    latitude: z.coerce.number().min(-90).max(90).optional(),
    longitude: z.coerce.number().min(-180).max(180).optional(),
  }),
});

export const verificationSchema = z.object({
  body: z.object({
    documentType: z.enum([
      "iqama",
      "registration",
      "license",
      "driving_licence",
      "vehicle_front",
      "vehicle_rear",
      "vehicle_left_side",
      "vehicle_right_side",
      "vehicle_photo",
      "cnic",
      "passport",
      "other",
    ]),
    expiryDate: z.string().trim().optional(),
    documentNumber: z.string().trim().optional(),
  }),
});

export const kycTokenSchema = z.object({
  body: z
    .object({
      levelName: z.string().trim().default("provider-verification"),
    })
    .default({}),
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

export const adminLookupSchema = z.object({
  query: z.object({
    q: z.string().trim().min(3).max(40),
  }),
});

export const adminMapSchema = z.object({
  query: z.object({
    status: z.string().optional(),
    categoryId: z.string().uuid().optional(),
  }),
});

export const adminAnalyticsSchema = z.object({
  query: z.object({
    days: z.coerce.number().int().positive().max(365).optional(),
  }),
});

export const adminCallLogsSchema = z.object({
  query: z.object({
    page: z.coerce.number().int().positive().optional(),
    limit: z.coerce.number().int().positive().max(100).optional(),
    providerId: z.string().uuid().optional(),
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
    nameAr: z.string().trim().max(120).optional(),
    name_ar: z.string().trim().max(120).optional(),
    subtitle: z.string().trim().max(255).optional(),
    subtitleAr: z.string().trim().max(255).optional(),
    subtitle_ar: z.string().trim().max(255).optional(),
    sortOrder: z.coerce.number().int().optional(),
    sort_order: z.coerce.number().int().optional(),
    iconUrl: z.string().optional(),
    image: z.string().optional(),
    icon_url: z.string().optional(),
  }),
});

export const categoryPatchSchema = z.object({
  params: z.object({ id: z.string().uuid() }),
  body: z.object({
    name: z.string().trim().min(2).max(120).optional(),
    nameAr: z.string().trim().max(120).optional(),
    name_ar: z.string().trim().max(120).optional(),
    isEnabled: z.boolean().optional(),
    sortOrder: z.coerce.number().int().optional(),
    sort_order: z.coerce.number().int().optional(),
    subtitle: z.string().trim().max(255).optional(),
    subtitleAr: z.string().trim().max(255).optional(),
    subtitle_ar: z.string().trim().max(255).optional(),
    iconUrl: z.string().optional(),
    image: z.string().optional(),
    icon_url: z.string().optional(),
  }),
});

export const categoryReorderSchema = z.object({
  body: z.object({
    items: z
      .array(
        z.object({
          id: z.string().uuid(),
          sortOrder: z.coerce.number().int(),
        }),
      )
      .optional(),
    orders: z
      .array(
        z.object({
          id: z.string().uuid(),
          sortOrder: z.coerce.number().int(),
        }),
      )
      .optional(),
    categoryIds: z.array(z.string().uuid()).optional(),
  }),
});

export const adminProfileUpdateSchema = z.object({
  body: z.object({
    email: z.string().trim().email().optional(),
    name: z.string().trim().min(2).max(255).optional(),
    currentPassword: z.string().optional(),
    newPassword: z.string().min(6).max(128).optional(),
  }),
});

export const vehicleTypeCreateSchema = z.object({
  body: z.object({
    name: z.string().trim().min(2).max(120),
    nameAr: z.string().trim().max(120).optional(),
    name_ar: z.string().trim().max(120).optional(),
    categoryId: z.string().uuid().nullable().optional(),
    icon: z.string().max(60).optional(),
    isEnabled: z.boolean().optional(),
    sortOrder: z.number().int().optional(),
  }),
});

export const vehicleTypePatchSchema = z.object({
  params: z.object({ id: z.string().uuid() }),
  body: z.object({
    name: z.string().trim().min(2).max(120).optional(),
    nameAr: z.string().trim().max(120).optional(),
    name_ar: z.string().trim().max(120).optional(),
    categoryId: z.string().uuid().nullable().optional(),
    icon: z.string().max(60).optional(),
    isEnabled: z.boolean().optional(),
    sortOrder: z.number().int().optional(),
  }),
});

export const cityCreateSchema = z.object({
  body: z.object({
    name: z.string().trim().min(2).max(120),
    nameAr: z.string().trim().max(120).optional(),
    name_ar: z.string().trim().max(120).optional(),
    latitude: z.coerce.number().min(-90).max(90).optional(),
    longitude: z.coerce.number().min(-180).max(180).optional(),
    lat: z.coerce.number().min(-90).max(90).optional(),
    lng: z.coerce.number().min(-180).max(180).optional(),
    zoom: z.coerce.number().int().min(1).max(22).optional(),
    isEnabled: z.boolean().optional(),
    is_enabled: z.boolean().optional(),
    sortOrder: z.coerce.number().int().optional(),
    sort_order: z.coerce.number().int().optional(),
  }),
});

export const cityPatchSchema = z.object({
  params: z.object({ id: z.string().uuid() }),
  body: z.object({
    name: z.string().trim().min(2).max(120).optional(),
    nameAr: z.string().trim().max(120).optional(),
    name_ar: z.string().trim().max(120).optional(),
    latitude: z.coerce.number().min(-90).max(90).optional(),
    longitude: z.coerce.number().min(-180).max(180).optional(),
    lat: z.coerce.number().min(-90).max(90).optional(),
    lng: z.coerce.number().min(-180).max(180).optional(),
    zoom: z.coerce.number().int().min(1).max(22).optional(),
    isEnabled: z.boolean().optional(),
    is_enabled: z.boolean().optional(),
    sortOrder: z.coerce.number().int().optional(),
    sort_order: z.coerce.number().int().optional(),
  }),
});

export const locationUpdateSchema = z.object({
  body: z.object({
    latitude: z.coerce.number().min(-90).max(90),
    longitude: z.coerce.number().min(-180).max(180),
    address: z.string().optional(),
    city: z.string().optional(),
  }),
});

export const nearbyDiscoverySchema = z.object({
  query: z.object({
    latitude: z.coerce.number().min(-90).max(90),
    longitude: z.coerce.number().min(-180).max(180),
    radiusKm: z.coerce.number().positive().max(50).optional(),
    categoryId: z.string().uuid().optional(),
    categorySlug: z.string().trim().min(1).max(140).optional(),
    limit: z.coerce.number().int().positive().max(50).optional(),
    sessionId: z.string().trim().min(8).max(64).optional(),
  }),
});

export const discoverySearchSchema = nearbyDiscoverySchema;

export const publicProviderParamSchema = z.object({
  params: z.object({
    publicId: z.string().regex(/^QRB-[0-9]+$/, "Invalid provider public id"),
  }),
  query: z.object({
    latitude: z.coerce.number().min(-90).max(90).optional(),
    longitude: z.coerce.number().min(-180).max(180).optional(),
    sessionId: z.string().trim().min(8).max(64).optional(),
  }),
});

export const deviceTokenSchema = z.object({
  body: z.object({
    token: z.string().trim().min(20).max(4096),
    platform: z.enum(["android", "ios", "web"]).optional(),
    appVersion: z.string().trim().max(40).optional(),
  }),
});

export const adminPushSchema = z.object({
  body: z.object({
    providerId: z.string().uuid(),
    title: z.string().trim().min(1).max(120),
    body: z.string().trim().min(1).max(500),
    data: z.record(z.string()).optional(),
  }),
});

export const customerFunnelEventSchema = z.object({
  body: z.object({
    sessionId: z.string().trim().min(4).max(64).optional(),
    event: z.enum([
      "profile_view",
      "profile_click",
      "call_click",
      "whatsapp_click",
      "share_location_click",
    ]),
    providerPublicId: z.string().min(1).max(64),
    latitude: z.coerce.number().min(-90).max(90).optional(),
    longitude: z.coerce.number().min(-180).max(180).optional(),
    metadata: z.record(z.unknown()).optional(),
  }),
});
