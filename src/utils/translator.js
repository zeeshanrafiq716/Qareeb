/**
 * Bilingual Translation Utility for Qareeb System
 * Provides automated, high-accuracy Arabic translation for service categories and vehicle types.
 *
 * Supports:
 * 1. Curated Gulf/Saudi domain dictionary for automotive, towing, recovery, and heavy machinery
 * 2. Real-time online translation (Google Translate API)
 * 3. Token-based and phonetic transliteration fallback for offline environments
 * 4. Zero English leakage (never outputs "خدمة EnglishWord")
 */

export const ARABIC_DICTIONARY = {
  // Heavy machinery & specialized vehicles
  "loader": "لودر / شيول",
  "wheel loader": "شيول / لودر",
  "backhoe loader": "حفار لودر",
  "water tank": "وايت ماء / صهريج مياه",
  "water tanker": "وايت ماء / صهريج مياه",
  "watertank": "وايت ماء",
  "tank": "خزان / صهريج",
  "tanker": "صهريج / وايت",
  "sewage tanker": "وايت صرف صحي",
  "sewage tank": "وايت صرف صحي",
  "fuel tanker": "صهريج وقود / بنزين",
  "fuel tank": "خزان وقود",
  "crane": "كرين / رافعة",
  "mobile crane": "كرين متنقل",
  "forklift": "رافعة شوكية",
  "bulldozer": "بلدوزر",
  "excavator": "حفار",
  "dumper": "شاحنة قلاب",
  "dump truck": "شاحنة قلاب",
  "tipper": "شاحنة تفريغ",
  "trailer": "تريلا / مقطورة",
  "lowbed": "لوبد / سطحة منخفضة",
  "lowbed trailer": "لوبد سطحة ثقيلة",
  "generator": "مولد كهرباء",
  "air compressor": "كمبروسر هواء",

  // Common service categories and workshops
  "workhouse": "ورشة عمل",
  "workshop": "ورشة عمل",
  "work house": "ورشة عمل",
  "garage": "كراج / ورشة",
  "repair shop": "ورشة إصلاح",
  "car repair": "إصلاح وصيانة السيارات",
  "auto repair": "إصلاح وصيانة السيارات",
  "maintenance": "صيانة دورية",
  "service": "خدمة",
  "services": "خدمات",
  "inspection": "فحص سيارات",
  "periodic inspection": "فحص دوري",
  "computer check": "فحص كمبيوتر للسيارات",

  // Roadside & Towing
  "flatbed": "سطحة",
  "flatbed truck": "سطحة",
  "flatbed tow truck": "سطحة عادية",
  "hydraulic low flatbed": "سطحة هيدروليك",
  "hydraulic flatbed": "سطحة هيدروليك",
  "wheel lift": "ونش رفع",
  "wheel lift tow truck": "ونش رفع",
  "heavy duty": "خدمة شاقة / ثقيل",
  "heavy duty recovery truck": "سطحة ثقيل",
  "heavy duty recovery": "إنقاذ وسحب ثقيل",
  "recovery truck": "شاحنة إنقاذ",
  "recovery": "إنقاذ وسحب",
  "tow": "ونش",
  "towing": "ونش",
  "towing truck": "ونش",
  "tow truck": "ونش سحب",
  "winch": "ونش",
  "covered carrier": "سطحة مغلقة VIP",
  "closed carrier": "سطحة مغلقة",
  "carrier": "ناقلة",
  "car carrier": "ناقلة سيارات",
  "motorbike carrier": "سطحة دبابات",
  "bike carrier": "سطحة دبابات",

  // Mechanics & Specialists
  "mechanic": "ميكانيكي",
  "electrician": "كهربائي سيارات",
  "auto electrician": "كهربائي سيارات",
  "plumber": "سباك",
  "carpenter": "نجار",
  "locksmith": "فتح أقفال ومفاتيح",
  "lockout": "فتح أقفال",
  "key replacement": "نسخ وبرمجة مفاتيح",
  "dent repair": "سمكرة وتعديل صدمات",
  "dent removal": "شفط صدمات بدون بوية",
  "paint": "دهان وبوية سيارات",
  "painting": "رش وبوية سيارات",

  // Roadside Emergencies
  "battery": "شحن وتبديل بطارية",
  "battery boost": "اشتراك بطارية",
  "battery replacement": "تبديل بطارية",
  "battery jumpstart": "اشتراك بطارية",
  "jumpstart": "اشتراك بطارية",
  "tire": "إصلاح وتبديل إطارات",
  "tyre": "إصلاح وتبديل إطارات",
  "tire repair": "إصلاح بنشر",
  "flat tire": "تبديل إطار / بنشر",
  "puncture": "رقع بنشر",
  "wheel balance": "ترصيص عجلات",
  "fuel": "توصيل وقود",
  "fuel delivery": "توصيل بنزين / ديزل",
  "gas delivery": "توصيل وقود",
  "petrol delivery": "توصيل بنزين",
  "diesel delivery": "توصيل ديزل",
  "emergency": "طوارئ",
  "emergency beacon": "طوارئ الطريق",

  // Vehicles & Transportation
  "ride": "توصيل",
  "ride sedan": "توصيل",
  "sedan": "سيدان",
  "pickup": "وانيت",
  "pickup truck": "وانيت",
  "van": "فان",
  "family van": "فان",
  "truck": "شاحنة",
  "suv": "سيارة دفع رباعي",
  "minivan": "ميني فان",
  "bus": "حافلة",
  "motorbike": "دراجة نارية",
  "motorcycle": "دباب",
  "scooter": "سكوتر",

  // General Services & Cleaning
  "cleaning": "خدمات تنظيف",
  "car wash": "غسيل سيارات متنقل",
  "mobile car wash": "غسيل متنقل",
  "oil change": "تغيير زيت وفلتر",
  "oil": "تغيير زيت",
  "brake": "فرامل وفحمات",
  "brakes": "فرامل وفحمات",
  "ac": "صيانة تكييف",
  "air conditioning": "صيانة تكييف",
  "ac repair": "تصليح مكيفات",
  "tinting": "تظليل عازل حراري",
  "window tinting": "تظليل زجاج",
  "polishing": "تلميع ساطع",
  "car detailing": "تلميع وسيراميك",
  "moving": "نقل عفش",
  "furniture moving": "نقل أثاث",
  "delivery": "توصيل ونقل",
};

/**
 * Extracts Arabic text inside parentheses if present e.g. "Flatbed (سطحة)" -> "سطحة"
 */
export function extractArabicInParentheses(text) {
  if (!text) return null;
  const match = text.match(/\(([\u0600-\u06FF\s]+)\)/);
  return match ? match[1].trim() : null;
}

/**
 * Strips Arabic parentheses from English name e.g. "Flatbed (سطحة)" -> "Flatbed"
 */
export function stripArabicParentheses(text) {
  if (!text) return "";
  return text.replace(/\s*\([\u0600-\u06FF\s]+\)\s*/g, " ").trim();
}

/**
 * Online Google Translate fallback (free public endpoint)
 */
async function fetchOnlineTranslation(text) {
  try {
    const url = `https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=ar&dt=t&q=${encodeURIComponent(text)}`;
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 3500);
    const res = await fetch(url, { signal: controller.signal });
    clearTimeout(timer);
    if (!res.ok) return null;
    const data = await res.json();
    if (data && data[0] && data[0][0] && data[0][0][0]) {
      const translated = data[0][0][0].trim();
      // Ensure it contains Arabic characters
      if (/[\u0600-\u06FF]/.test(translated)) {
        return translated;
      }
    }
    return null;
  } catch {
    return null;
  }
}

/**
 * Synchronous dictionary + transliteration translation
 */
export function autoTranslateToArabicSync(text) {
  if (!text || typeof text !== "string") return "";
  const trimmed = text.trim();
  if (!trimmed) return "";

  // If already predominantly Arabic, return as-is
  const arabicChars = (trimmed.match(/[\u0600-\u06FF]/g) || []).length;
  if (arabicChars > trimmed.length / 2) {
    return trimmed;
  }

  // 1. Check parenthetical Arabic
  const inParentheses = extractArabicInParentheses(trimmed);
  if (inParentheses) return inParentheses;

  // 2. Exact match in dictionary
  const lower = stripArabicParentheses(trimmed).toLowerCase();
  if (ARABIC_DICTIONARY[lower]) {
    return ARABIC_DICTIONARY[lower];
  }

  // 3. Normalized match (remove extra spaces and hyphens)
  const normalized = lower.replace(/[-_]/g, " ").replace(/\s+/g, " ");
  if (ARABIC_DICTIONARY[normalized]) {
    return ARABIC_DICTIONARY[normalized];
  }

  // 4. Token replacement matching
  for (const [enKey, arVal] of Object.entries(ARABIC_DICTIONARY)) {
    if (normalized === enKey || normalized.startsWith(enKey + " ") || normalized.endsWith(" " + enKey)) {
      return arVal;
    }
  }

  // 5. Individual word translation & assembly
  const words = normalized.split(" ");
  const translatedWords = words.map((w) => ARABIC_DICTIONARY[w] || "");
  const validTranslated = translatedWords.filter(Boolean);
  if (validTranslated.length > 0 && validTranslated.length >= words.length / 2) {
    return validTranslated.join(" ");
  }

  // 6. Transliteration for popular automotive terms that may not be in dict
  const translitMap = {
    loader: "لودر",
    crane: "كرين",
    trailer: "تريلا",
    tank: "تانكي / صهريج",
    tanker: "وايت",
    water: "مياه",
    service: "خدمة",
    towing: "ونش",
    recovery: "إنقاذ",
    express: "سريع",
    vip: "مميز",
  };
  for (const [en, ar] of Object.entries(translitMap)) {
    if (normalized.includes(en)) {
      return ar;
    }
  }

  // Default clean Arabic phrase (NEVER leak "EnglishWord" in Arabic field)
  return "خدمة معتمدة";
}

/**
 * Asynchronous Auto-Translator (Dictionary first -> Google Translate API -> Sync fallback)
 */
export async function autoTranslateToArabic(text) {
  if (!text || typeof text !== "string") return "";
  const trimmed = text.trim();
  if (!trimmed) return "";

  // If already Arabic
  const arabicChars = (trimmed.match(/[\u0600-\u06FF]/g) || []).length;
  if (arabicChars > trimmed.length / 2) {
    return trimmed;
  }

  // 1. Parentheses check
  const inParentheses = extractArabicInParentheses(trimmed);
  if (inParentheses) return inParentheses;

  const cleaned = stripArabicParentheses(trimmed).toLowerCase().trim();

  // 2. High-priority exact dictionary match (specialized Saudi terminology)
  if (ARABIC_DICTIONARY[cleaned]) {
    return ARABIC_DICTIONARY[cleaned];
  }

  // 3. Online Google Translate (accurate for any arbitrary English word like "Loader", "Water Tank", etc.)
  const online = await fetchOnlineTranslation(cleaned);
  if (online) {
    return online;
  }

  // 4. Fallback to synchronous dictionary & token engine
  return autoTranslateToArabicSync(text);
}
