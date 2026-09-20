/** Deep links for direct customer ↔ provider contact (Qareeb does not host calls or chat). */

export function whatsAppDigits(e164Phone) {
  return String(e164Phone).replace(/^\+/, "");
}

/**
 * @param {string} providerPhone E.164
 * @param {number|undefined} customerLat
 * @param {number|undefined} customerLng
 */
export function buildDirectContactActions(providerPhone, customerLat, customerLng) {
  const phone = providerPhone;
  const digits = whatsAppDigits(phone);
  const callUrl = `tel:${phone}`;
  const whatsappUrl = `https://wa.me/${digits}`;

  const hasCustomerLocation =
    customerLat !== undefined &&
    customerLng !== undefined &&
    Number.isFinite(Number(customerLat)) &&
    Number.isFinite(Number(customerLng));

  let shareLocation = null;
  if (hasCustomerLocation) {
    const lat = Number(customerLat);
    const lng = Number(customerLng);
    const mapsUrl = `https://maps.google.com/?q=${lat},${lng}`;
    const message = `Hi, I'm nearby and need your service. My location: ${mapsUrl}`;
    shareLocation = {
      mapsUrl,
      whatsappUrl: `https://wa.me/${digits}?text=${encodeURIComponent(message)}`,
      label: "Share location",
      note: "Opens WhatsApp with your location — chat is between you and the provider.",
    };
  }

  return {
    hostedByQareeb: false,
    disclaimer:
      "Contact happens directly between you and the provider. Qareeb does not host calls or chat.",
    phone,
    actions: {
      call: { url: callUrl, label: "Call", opens: "native_dialer" },
      whatsapp: { url: whatsappUrl, label: "WhatsApp", opens: "whatsapp" },
      shareLocation,
    },
  };
}
