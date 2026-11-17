import { beforeEach, describe, expect, it } from "vitest";
import { query } from "../src/db/pool.js";
import { PROVIDER_STATUS } from "../src/config/constants.js";
import { completeRegistration, api } from "./helpers.js";
import { resetDb } from "./setup.js";
import {
  getProviderQuickStats,
  getProviderDashboardAnalytics,
} from "../src/modules/funnel.service.js";

describe("Customer interaction deduplication for provider dashboard & stats cards", () => {
  beforeEach(async () => {
    await resetDb();
  });

  it("1 customer contacting 1 provider multiple times only counts once on dashboard & stats", async () => {
    // 1. Create approved provider
    const { provider } = await completeRegistration("03099990001");
    await query(
      `UPDATE providers SET status_id = (SELECT id FROM statuses WHERE code = $2 LIMIT 1)
       WHERE id = $1`,
      [provider.id, PROVIDER_STATUS.APPROVED],
    );

    const customerSession1 = "customer_session_device_1";
    const customerSession2 = "customer_session_device_2";

    // 2. Customer 1 clicks multiple times on Call, WhatsApp, Location, and View
    // 5 Call clicks from Customer 1
    for (let i = 0; i < 5; i++) {
      await api().post("/api/v1/discovery/events").send({
        sessionId: customerSession1,
        event: "call_click",
        providerPublicId: provider.providerId,
      });
    }

    // 10 WhatsApp clicks from Customer 1
    for (let i = 0; i < 10; i++) {
      await api().post("/api/v1/discovery/events").send({
        sessionId: customerSession1,
        event: "whatsapp_click",
        providerPublicId: provider.providerId,
      });
    }

    // 4 Share location clicks from Customer 1
    for (let i = 0; i < 4; i++) {
      await api().post("/api/v1/discovery/events").send({
        sessionId: customerSession1,
        event: "share_location_click",
        providerPublicId: provider.providerId,
      });
    }

    // 3 Profile views from Customer 1
    for (let i = 0; i < 3; i++) {
      await api().post("/api/v1/discovery/events").send({
        sessionId: customerSession1,
        event: "profile_view",
        providerPublicId: provider.providerId,
      });
    }

    // 3. Check Quick Stats before Customer 2:
    // Even though Customer 1 clicked 19 contact actions, contactsToday MUST BE EXACTLY 1!
    let quickStats = await getProviderQuickStats(provider.id);
    expect(quickStats.contactsToday).toBe(1);
    expect(quickStats.viewsToday).toBe(1);

    // Check Dashboard Analytics before Customer 2:
    let dashboard = await getProviderDashboardAnalytics(provider.id);
    expect(dashboard.stats.contactsToday).toBe(1);
    expect(dashboard.contactsCard.counts[0]).toBe(1);
    expect(dashboard.contactsCard.callsCounts[0]).toBe(1);
    expect(dashboard.contactsCard.whatsAppCounts[0]).toBe(1);
    expect(dashboard.viewsCard.counts[0]).toBe(1);

    // 4. Customer 2 clicks WhatsApp once
    await api().post("/api/v1/discovery/events").send({
      sessionId: customerSession2,
      event: "whatsapp_click",
      providerPublicId: provider.providerId,
    });

    // 5. Check Quick Stats after Customer 2:
    // Now there are 2 unique customers, so contactsToday MUST BE EXACTLY 2!
    quickStats = await getProviderQuickStats(provider.id);
    expect(quickStats.contactsToday).toBe(2);

    // Check Dashboard Analytics after Customer 2:
    dashboard = await getProviderDashboardAnalytics(provider.id);
    expect(dashboard.stats.contactsToday).toBe(2);
    expect(dashboard.contactsCard.counts[0]).toBe(2);
    expect(dashboard.contactsCard.callsCounts[0]).toBe(1); // Only customer 1 called
    expect(dashboard.contactsCard.whatsAppCounts[0]).toBe(2); // Both customer 1 & 2 whatsapped

    // 6. Customer 1 clicks Call 10 more times -> count must REMAIN 2!
    for (let i = 0; i < 10; i++) {
      await api().post("/api/v1/discovery/events").send({
        sessionId: customerSession1,
        event: "call_click",
        providerPublicId: provider.providerId,
      });
    }

    quickStats = await getProviderQuickStats(provider.id);
    expect(quickStats.contactsToday).toBe(2);

    dashboard = await getProviderDashboardAnalytics(provider.id);
    expect(dashboard.stats.contactsToday).toBe(2);
    expect(dashboard.contactsCard.counts[0]).toBe(2);
  });
});

