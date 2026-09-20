/** Customer UX when search returns no online providers (empty map). */
export function buildCustomerEmptyState({ count, radiusKm, category }) {
  if (count > 0) return null;
  return {
    screen: "empty_map",
    title: {
      en: "No providers nearby right now",
      ar: "لا يوجد مزوّدون متاحون بالقرب منك حالياً",
    },
    message: {
      en: "Try another category, increase search radius, or check again in a few minutes.",
      ar: "جرّب فئة أخرى، أو وسّع نطاق البحث، أو حاول مرة أخرى بعد قليل.",
    },
    hints: [
      { en: "Providers must be online with a fresh location to appear.", ar: "يجب أن يكون المزوّد متصلاً وموقعه محدّثاً." },
      { en: "Your pin shows your area — exact provider locations stay private until you open a profile.", ar: "الخريطة تعرض منطقتك فقط — مواقع المزوّدين تقريبية لحماية الخصوصية." },
    ],
    actions: {
      widenRadius: true,
      changeCategory: true,
      retry: true,
    },
    rtl: {
      layoutDirection: "rtl",
      note: "Mobile app must mirror title/message/hints for Arabic (RTL) on this screen.",
    },
    searchContext: {
      radiusKm,
      category: category ? { slug: category.slug, name: category.name } : null,
    },
  };
}
