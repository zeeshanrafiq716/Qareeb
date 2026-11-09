import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { renderAsync } from '@resvg/resvg-js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const adminDir = path.resolve(__dirname, '../admin/public/assets/categories');
const mobileDir = path.resolve(__dirname, '../mobile/assets/images');
const mobileCatDir = path.resolve(__dirname, '../mobile/assets/images/categories');

// Common 3D realistic studio gradients & filters
const DEFS = `
  <defs>
    <!-- Realistic 3D White Bodywork -->
    <linearGradient id="body_white_3d" x1="0.1" y1="0" x2="0.3" y2="1">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="25%" stop-color="#FAFAFA"/>
      <stop offset="60%" stop-color="#EEF2F6"/>
      <stop offset="85%" stop-color="#D9E2EC"/>
      <stop offset="100%" stop-color="#BCCCDC"/>
    </linearGradient>
    <linearGradient id="body_white_roof" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="100%" stop-color="#E2E8F0"/>
    </linearGradient>
    <linearGradient id="body_shadow" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#94A3B8"/>
      <stop offset="100%" stop-color="#475569"/>
    </linearGradient>

    <!-- Tinted Glass Window Reflection -->
    <linearGradient id="glass_3d" x1="0.1" y1="0" x2="0.8" y2="1">
      <stop offset="0%" stop-color="#E0F2FE" stop-opacity="0.95"/>
      <stop offset="25%" stop-color="#BAE6FD" stop-opacity="0.9"/>
      <stop offset="55%" stop-color="#38BDF8" stop-opacity="0.85"/>
      <stop offset="80%" stop-color="#0284C7" stop-opacity="0.9"/>
      <stop offset="100%" stop-color="#0F172A" stop-opacity="0.95"/>
    </linearGradient>

    <!-- Chrome & Polished Metal -->
    <linearGradient id="chrome_metal" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="25%" stop-color="#94A3B8"/>
      <stop offset="50%" stop-color="#F8FAFC"/>
      <stop offset="75%" stop-color="#64748B"/>
      <stop offset="100%" stop-color="#E2E8F0"/>
    </linearGradient>

    <!-- Alloy Rim -->
    <linearGradient id="alloy_rim" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#F8FAFC"/>
      <stop offset="40%" stop-color="#CBD5E1"/>
      <stop offset="80%" stop-color="#64748B"/>
      <stop offset="100%" stop-color="#334155"/>
    </linearGradient>

    <!-- Stainless Steel Tank (Water) -->
    <linearGradient id="steel_tank_water" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#E0F2FE"/>
      <stop offset="18%" stop-color="#BAE6FD"/>
      <stop offset="35%" stop-color="#38BDF8"/>
      <stop offset="50%" stop-color="#0284C7"/>
      <stop offset="70%" stop-color="#0369A1"/>
      <stop offset="100%" stop-color="#0C4A6E"/>
    </linearGradient>

    <!-- Fuel Tank (Amber / Gold) -->
    <linearGradient id="fuel_tank_grad" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#FEF3C7"/>
      <stop offset="20%" stop-color="#FDE68A"/>
      <stop offset="45%" stop-color="#F59E0B"/>
      <stop offset="75%" stop-color="#D97706"/>
      <stop offset="100%" stop-color="#92400E"/>
    </linearGradient>

    <!-- Amber Beacon Bar -->
    <linearGradient id="beacon_amber" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#F59E0B"/>
      <stop offset="50%" stop-color="#FEF08A"/>
      <stop offset="100%" stop-color="#D97706"/>
    </linearGradient>

    <!-- Drop Shadow Filter -->
    <filter id="soft_shadow" x="-10%" y="-10%" width="120%" height="130%">
      <feDropShadow dx="0" dy="4" stdDeviation="3.5" flood-color="#0F172A" flood-opacity="0.18"/>
    </filter>
  </defs>
`;

// Realistic Contact Ground Shadow
const GROUND_SHADOW = `
  <ellipse cx="98" cy="105" rx="76" ry="6.5" fill="#0F172A" opacity="0.16"/>
  <ellipse cx="98" cy="105" rx="58" ry="3.5" fill="#0F172A" opacity="0.22"/>
`;

// Photorealistic 3D Wheels
const WHEEL_3D = (cx, cy = 86, r = 13.5) => `
  <g transform="translate(${cx}, ${cy})">
    <!-- Tire Outer Rubber -->
    <circle cx="0" cy="0" r="${r}" fill="#1E293B"/>
    <circle cx="0" cy="0" r="${r - 1}" fill="#0F172A"/>
    <!-- Tire Tread Ring -->
    <circle cx="0" cy="0" r="${r - 2.5}" fill="#1E293B"/>
    <!-- Alloy Wheel -->
    <circle cx="0" cy="0" r="${r - 4}" fill="url(#alloy_rim)"/>
    <!-- Rim Spokes -->
    <circle cx="0" cy="0" r="${r - 7.5}" fill="#334155"/>
    <circle cx="0" cy="0" r="${r - 9.5}" fill="url(#chrome_metal)"/>
    <circle cx="0" cy="0" r="2" fill="#0F172A"/>
  </g>
`;

// Template A: Realistic White Service Van (HiAce style, 3/4 side-front)
function renderServiceVan(equipmentSvg, roofSvg = '') {
  return `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 196 120" width="196" height="120" fill="none">
  ${DEFS}
  ${GROUND_SHADOW}
  <g filter="url(#soft_shadow)">
    <!-- Van Body Roof -->
    <path d="M34 42 Q36 34 46 34 L138 34 Q146 34 150 40 L166 60 Q170 66 170 72 L170 86 L32 86 Q30 86 30 78 L30 52 Q30 42 34 42 Z" fill="url(#body_white_3d)"/>
    <!-- Lower Body Sill & Shadow -->
    <path d="M30 82 L170 82 L170 86 L30 86 Z" fill="#94A3B8" opacity="0.6"/>
    <!-- Wheel Arch Cutouts -->
    <path d="M42 86 A16 16 0 0 1 74 86 Z" fill="#0F172A"/>
    <path d="M128 86 A16 16 0 0 1 160 86 Z" fill="#0F172A"/>

    <!-- Front Windshield & Side Windows -->
    <!-- Windshield -->
    <path d="M144 38 L162 60 L136 60 L134 38 Z" fill="url(#glass_3d)"/>
    <!-- Front Door Window -->
    <path d="M112 40 L132 40 L134 60 L112 60 Z" fill="url(#glass_3d)"/>
    <!-- Middle Sliding Window -->
    <path d="M72 40 L108 40 L108 60 L72 60 Z" fill="url(#glass_3d)"/>
    <!-- Rear Quarter Window -->
    <path d="M36 42 Q40 40 48 40 L68 40 L68 60 L34 60 Z" fill="url(#glass_3d)"/>

    <!-- Door Seams & Handle -->
    <line x1="110" y1="38" x2="110" y2="82" stroke="#CBD5E1" stroke-width="1.2"/>
    <line x1="70" y1="38" x2="70" y2="82" stroke="#CBD5E1" stroke-width="1.2"/>
    <rect x="114" y="64" width="8" height="2" rx="1" fill="#475569"/>
    <rect x="74" y="64" width="8" height="2" rx="1" fill="#475569"/>

    <!-- Aerodynamic Side Mirror -->
    <path d="M136 54 L142 54 Q144 54 144 58 L142 62 L136 60 Z" fill="url(#body_white_3d)"/>
    <rect x="137" y="55" width="5" height="5" rx="1" fill="#38BDF8"/>

    <!-- Front Headlight & Chrome Grille -->
    <path d="M166 66 L171 68 Q172 70 171 74 L165 74 Z" fill="#F8FAFC"/>
    <path d="M166 68 L170 70 L170 72 L166 72 Z" fill="#38BDF8" opacity="0.8"/>
    <rect x="170" y="70" width="2" height="3" fill="#F59E0B"/>
    <rect x="162" y="74" width="10" height="3" rx="1" fill="url(#chrome_metal)"/>
    <!-- Front Bumper -->
    <rect x="164" y="78" width="7" height="6" rx="2" fill="#E2E8F0"/>

    <!-- Roof Rack & Custom Equipment Mounted -->
    ${roofSvg}
    ${equipmentSvg}

    <!-- Wheels -->
    ${WHEEL_3D(58, 86, 13.5)}
    ${WHEEL_3D(144, 86, 13.5)}
  </g>
</svg>
`;
}

// Template B: Realistic White Commercial Pickup (Hilux style)
function renderPickupTruck(bedContentSvg, roofSvg = '') {
  return `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 196 120" width="196" height="120" fill="none">
  ${DEFS}
  ${GROUND_SHADOW}
  <g filter="url(#soft_shadow)">
    <!-- Cab Body -->
    <path d="M78 44 Q80 36 90 36 L130 36 Q138 36 142 44 L154 60 L166 62 Q172 64 172 72 L172 84 L78 84 Z" fill="url(#body_white_3d)"/>
    <!-- Cargo Bed -->
    <path d="M26 62 L80 62 L80 84 L26 84 Q24 84 24 80 L24 66 Q24 62 26 62 Z" fill="url(#body_white_3d)"/>
    <rect x="24" y="60" width="56" height="4" rx="1.5" fill="url(#chrome_metal)"/>
    <!-- Bed Inner Wall -->
    <rect x="28" y="64" width="50" height="16" fill="#334155" opacity="0.15"/>

    <!-- Wheel Arch Cutouts -->
    <path d="M38 84 A16 16 0 0 1 70 84 Z" fill="#0F172A"/>
    <path d="M128 84 A16 16 0 0 1 160 84 Z" fill="#0F172A"/>

    <!-- Cab Windshield & Door Window -->
    <path d="M128 40 L146 58 L124 58 L122 40 Z" fill="url(#glass_3d)"/>
    <path d="M92 40 L120 40 L122 58 L90 58 Z" fill="url(#glass_3d)"/>
    <line x1="120" y1="40" x2="120" y2="82" stroke="#CBD5E1" stroke-width="1.2"/>
    <rect x="96" y="64" width="8" height="2" rx="1" fill="#475569"/>

    <!-- Mirror -->
    <path d="M124 52 L130 52 L130 57 L124 56 Z" fill="url(#body_white_3d)"/>

    <!-- Headlight & Grille -->
    <path d="M164 66 L171 67 Q172 69 171 73 L164 73 Z" fill="#F8FAFC"/>
    <rect x="170" y="69" width="2" height="3" fill="#F59E0B"/>
    <rect x="160" y="72" width="12" height="4" rx="1" fill="url(#chrome_metal)"/>
    <rect x="162" y="78" width="10" height="6" rx="2" fill="#E2E8F0"/>

    ${roofSvg}
    ${bedContentSvg}

    <!-- Wheels -->
    ${WHEEL_3D(54, 84, 13.5)}
    ${WHEEL_3D(144, 84, 13.5)}
  </g>
</svg>
`;
}

// Template C: Realistic Commercial Dyna / Heavy Truck
function renderDynaTruck(flatbedSvg, beaconColor = '#F59E0B') {
  return `
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 196 120" width="196" height="120" fill="none">
  ${DEFS}
  ${GROUND_SHADOW}
  <g filter="url(#soft_shadow)">
    <!-- Cab-over Dyna Cabin -->
    <path d="M116 38 Q120 32 130 32 L154 32 Q164 32 168 42 L174 62 Q176 68 176 76 L176 84 L114 84 Z" fill="url(#body_white_3d)"/>
    <!-- Large Panoramic Windshield -->
    <path d="M128 36 L154 36 Q160 36 164 44 L168 58 L128 58 Z" fill="url(#glass_3d)"/>
    <!-- Door Window -->
    <path d="M118 40 L126 40 L126 58 L118 58 Z" fill="url(#glass_3d)"/>
    <!-- Aerodynamic Roof Air Deflector -->
    <path d="M122 28 Q130 26 148 26 Q156 26 160 32 L120 32 Z" fill="url(#body_white_roof)"/>
    <!-- Warning Beacon Bar -->
    <rect x="134" y="23" width="18" height="4" rx="2" fill="${beaconColor}"/>

    <!-- Grille & Headlights -->
    <rect x="166" y="68" width="10" height="4" rx="1" fill="url(#chrome_metal)"/>
    <path d="M170 62 L175 64 L175 68 L170 68 Z" fill="#F8FAFC"/>
    <rect x="174" y="65" width="2" height="2" fill="#F59E0B"/>
    <rect x="166" y="74" width="10" height="7" rx="2" fill="#E2E8F0"/>

    <!-- Chassis Beam -->
    <rect x="20" y="76" width="100" height="8" rx="2" fill="#334155"/>
    <path d="M34 84 A16 16 0 0 1 66 84 Z" fill="#0F172A"/>
    <path d="M74 84 A16 16 0 0 1 106 84 Z" fill="#0F172A"/>
    <path d="M136 84 A16 16 0 0 1 168 84 Z" fill="#0F172A"/>

    ${flatbedSvg}

    <!-- Dual Rear Wheels & Front Steer Wheel -->
    ${WHEEL_3D(50, 84, 13.5)}
    ${WHEEL_3D(90, 84, 13.5)}
    ${WHEEL_3D(152, 84, 13.5)}
  </g>
</svg>
`;
}

// 26 Realistic Category SVG Definitions
const CATEGORY_SVGS = {
  // 1. Tow Truck - Flatbed tow truck with car loaded
  tow_truck: renderDynaTruck(`
    <!-- Tilted Hydraulic Flatbed Deck -->
    <path d="M16 64 L118 64 L110 76 L8 76 Z" fill="url(#chrome_metal)"/>
    <rect x="14" y="62" width="102" height="3" rx="1.5" fill="#64748B"/>
    <!-- Winch Tower -->
    <rect x="108" y="44" width="8" height="20" fill="#475569"/>
    <circle cx="112" cy="48" r="3" fill="#94A3B8"/>
    <line x1="112" y1="50" x2="68" y2="64" stroke="#CBD5E1" stroke-width="2" stroke-dasharray="3 1.5"/>
    <!-- Small Sedan Car Loaded on Flatbed -->
    <g transform="translate(30, 44)">
      <path d="M8 16 Q12 8 20 8 L44 8 Q50 8 54 14 L62 20 L4 20 Z" fill="url(#body_white_3d)"/>
      <path d="M22 10 L42 10 L48 16 L22 16 Z" fill="url(#glass_3d)"/>
      <circle cx="16" cy="20" r="5" fill="#1E293B"/>
      <circle cx="48" cy="20" r="5" fill="#1E293B"/>
    </g>
  `),

  // 2. Tyre & Puncture Repair - Mobile Tyre Service Van with Tyres & Compressor
  tyre_repair: renderServiceVan(`
    <!-- Mounted Tyres on Rear Door / Roof -->
    <g transform="translate(48, 52)">
      <circle cx="0" cy="0" r="10" fill="#1E293B"/>
      <circle cx="0" cy="0" r="5.5" fill="url(#alloy_rim)"/>
      <circle cx="0" cy="0" r="2" fill="#334155"/>
    </g>
    <g transform="translate(64, 52)">
      <circle cx="0" cy="0" r="10" fill="#0F172A"/>
      <circle cx="0" cy="0" r="5.5" fill="url(#alloy_rim)"/>
      <circle cx="0" cy="0" r="2" fill="#334155"/>
    </g>
    <!-- Air Compressor Tank & Impact Wrench Badge -->
    <rect x="80" y="48" width="16" height="8" rx="4" fill="#DC2626"/>
    <circle cx="84" cy="52" r="2" fill="#FFFFFF"/>
    <path d="M86 46 L90 44 L92 46 Z" fill="#94A3B8"/>
  `, `
    <!-- Roof Warning Lightbar -->
    <rect x="74" y="29" width="34" height="5" rx="2.5" fill="url(#beacon_amber)"/>
  `),

  // 3. Fuel Delivery - Emergency Fuel Tanker Pickup with Dispenser Hose
  fuel_delivery: renderPickupTruck(`
    <!-- Commercial Fuel Tank on Bed -->
    <rect x="30" y="48" width="46" height="16" rx="6" fill="url(#fuel_tank_grad)"/>
    <rect x="34" y="44" width="12" height="5" rx="2.5" fill="#D97706"/>
    <!-- Fuel Pump Meter & Hose Reel -->
    <circle cx="68" cy="56" r="6" fill="#1E293B"/>
    <circle cx="68" cy="56" r="3" fill="#F59E0B"/>
    <path d="M68 62 Q72 68 76 66 L78 62" stroke="#1E293B" stroke-width="2.5" fill="none"/>
    <!-- Flammable Hazard Diamond -->
    <polygon points="46,56 50,52 54,56 50,60" fill="#DC2626"/>
  `, `
    <rect x="100" y="31" width="20" height="5" rx="2.5" fill="url(#beacon_amber)"/>
  `),

  // 4. Car Mechanic - Mobile Mechanic Diagnostic Van with Red Tool Chest
  car_mechanic: renderServiceVan(`
    <!-- Professional Red Tool Chest & Diagnostic Screen -->
    <rect x="42" y="48" width="20" height="15" rx="2" fill="#DC2626"/>
    <line x1="44" y1="53" x2="60" y2="53" stroke="#FEE2E2" stroke-width="1.5"/>
    <line x1="44" y1="57" x2="60" y2="57" stroke="#FEE2E2" stroke-width="1.5"/>
    <!-- Chrome Mechanic Wrench -->
    <path d="M72 48 L82 58 M80 48 L70 58" stroke="url(#chrome_metal)" stroke-width="2.5" stroke-linecap="round"/>
  `, `
    <rect x="78" y="29" width="30" height="5" rx="2.5" fill="url(#beacon_amber)"/>
  `),

  // 5. Small Pickup (Dyna) - Clean White Commercial Pickup Truck
  small_pickup_dyna: renderPickupTruck(`
    <!-- Clean Cargo Bed with Side Guardrails -->
    <line x1="26" y1="54" x2="78" y2="54" stroke="url(#chrome_metal)" stroke-width="2.5"/>
    <line x1="40" y1="54" x2="40" y2="62" stroke="url(#chrome_metal)" stroke-width="2"/>
    <line x1="64" y1="54" x2="64" y2="62" stroke="url(#chrome_metal)" stroke-width="2"/>
  `),

  // 6. Large Pickup (Dyna) - Heavy Cab-Over Dyna Commercial Cargo Truck
  large_pickup_dyna: renderDynaTruck(`
    <!-- Heavy Commercial Cargo Box Body -->
    <rect x="14" y="32" width="98" height="44" rx="3" fill="url(#body_white_3d)"/>
    <line x1="14" y1="46" x2="112" y2="46" stroke="#E2E8F0" stroke-width="1.5"/>
    <line x1="14" y1="60" x2="112" y2="60" stroke="#E2E8F0" stroke-width="1.5"/>
    <line x1="62" y1="32" x2="62" y2="76" stroke="#CBD5E1" stroke-width="1.5"/>
    <rect x="58" y="52" width="8" height="4" rx="1" fill="#475569"/>
  `),

  // 7. Small Water Tanker - Medium Potable Water Tanker Truck
  small_water_tanker: renderDynaTruck(`
    <!-- Cylindrical Water Tank Body -->
    <rect x="18" y="40" width="92" height="36" rx="14" fill="url(#steel_tank_water)"/>
    <!-- Dome Manhole & Inspection Ladder -->
    <rect x="56" y="34" width="16" height="7" rx="3" fill="url(#chrome_metal)"/>
    <line x1="52" y1="42" x2="52" y2="74" stroke="url(#chrome_metal)" stroke-width="2"/>
    <line x1="48" y1="50" x2="56" y2="50" stroke="url(#chrome_metal)" stroke-width="1.5"/>
    <line x1="48" y1="60" x2="56" y2="60" stroke="url(#chrome_metal)" stroke-width="1.5"/>
  `, '#0284C7'),

  // 8. Large Water Tanker - Heavy Multi-Axle Water Tanker Truck
  large_water_tanker: renderDynaTruck(`
    <!-- Extended Heavy Capacity Stainless Tank -->
    <rect x="12" y="34" width="102" height="42" rx="18" fill="url(#steel_tank_water)"/>
    <rect x="38" y="28" width="14" height="7" rx="3" fill="url(#chrome_metal)"/>
    <rect x="74" y="28" width="14" height="7" rx="3" fill="url(#chrome_metal)"/>
    <!-- Rear Hose Storage Tube -->
    <rect x="10" y="66" width="104" height="6" rx="3" fill="url(#chrome_metal)"/>
  `, '#0284C7'),

  // 9. Battery Jump Start - Roadside Service Van with Booster Cables
  battery_jump_start: renderServiceVan(`
    <!-- Heavy-Duty Battery Jump Starter Unit -->
    <rect x="44" y="50" width="22" height="14" rx="3" fill="#1E293B"/>
    <circle cx="50" cy="57" r="3" fill="#DC2626"/>
    <circle cx="60" cy="57" r="3" fill="#0F172A"/>
    <!-- Red & Black Booster Cable Clamps -->
    <path d="M50 50 Q52 42 66 42 L72 46" stroke="#DC2626" stroke-width="2.5" fill="none"/>
    <path d="M60 50 Q64 45 74 46 L78 50" stroke="#0F172A" stroke-width="2.5" fill="none"/>
    <polygon points="72,44 76,42 74,47" fill="#DC2626"/>
    <polygon points="78,48 82,46 80,51" fill="#0F172A"/>
  `),

  // 10. AC Technician - HVAC Service Van with AC Outdoor Unit & Ladder
  ac_technician: renderServiceVan(`
    <!-- AC Outdoor Condenser Unit on Side/Inside -->
    <rect x="42" y="48" width="22" height="16" rx="2" fill="url(#body_white_3d)" stroke="#94A3B8" stroke-width="1"/>
    <circle cx="53" cy="56" r="6" fill="#334155"/>
    <line x1="53" y1="50" x2="53" y2="62" stroke="#64748B" stroke-width="1.5"/>
    <line x1="47" y1="56" x2="59" y2="56" stroke="#64748B" stroke-width="1.5"/>
  `, `
    <!-- Aluminum Service Extension Ladder on Roof -->
    <line x1="40" y1="30" x2="136" y2="30" stroke="url(#chrome_metal)" stroke-width="2"/>
    <line x1="40" y1="33" x2="136" y2="33" stroke="url(#chrome_metal)" stroke-width="2"/>
    ${Array.from({length: 8}, (_, i) => `<line x1="${48 + i * 11}" y1="29" x2="${48 + i * 11}" y2="34" stroke="url(#chrome_metal)" stroke-width="1.5"/>`).join('')}
  `),

  // 11. Electrician - Electrical Van with Cable Reels & Meter
  electrician: renderServiceVan(`
    <!-- Cable Reel Drum -->
    <g transform="translate(54, 55)">
      <circle cx="0" cy="0" r="10" fill="#D97706"/>
      <circle cx="0" cy="0" r="7" fill="#F59E0B"/>
      <circle cx="0" cy="0" r="3" fill="#1E293B"/>
    </g>
    <!-- Lightning Volt Badge -->
    <polygon points="76,46 70,55 75,55 71,64 80,53 75,53" fill="#FACC15"/>
  `, `
    <!-- Ladder on Roof -->
    <line x1="40" y1="30" x2="136" y2="30" stroke="url(#chrome_metal)" stroke-width="2"/>
    <line x1="40" y1="33" x2="136" y2="33" stroke="url(#chrome_metal)" stroke-width="2"/>
    ${Array.from({length: 8}, (_, i) => `<line x1="${48 + i * 11}" y1="29" x2="${48 + i * 11}" y2="34" stroke="url(#chrome_metal)" stroke-width="1.5"/>`).join('')}
  `),

  // 12. Plumber - Plumbing Van with Copper Pipes & Pipe Wrench
  plumber: renderServiceVan(`
    <!-- Copper & PVC Pipe Stack on Side -->
    <rect x="40" y="50" width="30" height="3" rx="1.5" fill="#D97706"/>
    <rect x="40" y="54" width="30" height="3" rx="1.5" fill="#38BDF8"/>
    <rect x="40" y="58" width="30" height="3" rx="1.5" fill="#D97706"/>
    <!-- Red Pipe Wrench -->
    <path d="M76 48 L84 56 M80 46 L76 50" stroke="#DC2626" stroke-width="3" stroke-linecap="round"/>
  `, `
    <line x1="40" y1="30" x2="136" y2="30" stroke="url(#chrome_metal)" stroke-width="2"/>
    <line x1="40" y1="33" x2="136" y2="33" stroke="url(#chrome_metal)" stroke-width="2"/>
  `),

  // 13. House Cleaning - Professional Cleaning Fleet Van with Vacuum Unit
  house_cleaning: renderServiceVan(`
    <!-- Commercial Vacuum Tank Unit -->
    <rect x="44" y="48" width="16" height="15" rx="4" fill="#0284C7"/>
    <path d="M48 48 Q44 40 56 42 L64 48" stroke="#0F172A" stroke-width="2.5" fill="none"/>
    <rect x="68" y="52" width="12" height="10" rx="2" fill="#10B981"/>
    <!-- Sparkle Stars -->
    <polygon points="86,46 88,42 90,46 94,48 90,50 88,54 86,50 82,48" fill="#FACC15"/>
  `),

  // 14. Washing Machine Tech - Appliance Van with Washing Drum Symbol
  washing_machine_tech: renderServiceVan(`
    <!-- Washing Machine Front Drum -->
    <rect x="44" y="46" width="22" height="18" rx="3" fill="url(#body_white_3d)" stroke="#94A3B8" stroke-width="1"/>
    <circle cx="55" cy="56" r="6" fill="#38BDF8" opacity="0.6"/>
    <circle cx="55" cy="56" r="3" fill="#0284C7"/>
    <circle cx="49" cy="49" r="1.5" fill="#334155"/>
    <circle cx="53" cy="49" r="1.5" fill="#334155"/>
  `),

  // 15. Refrigerator Tech - Refrigeration Van with Manifold Gauges
  refrigerator_tech: renderServiceVan(`
    <!-- Dual Refrigeration Manifold Gauges (Blue Low / Red High) -->
    <circle cx="50" cy="52" r="5" fill="#0284C7"/>
    <circle cx="50" cy="52" r="3.5" fill="#FFFFFF"/>
    <circle cx="62" cy="52" r="5" fill="#DC2626"/>
    <circle cx="62" cy="52" r="3.5" fill="#FFFFFF"/>
    <line x1="50" y1="57" x2="56" y2="62" stroke="#334155" stroke-width="2"/>
    <line x1="62" y1="57" x2="56" y2="62" stroke="#334155" stroke-width="2"/>
  `),

  // 16. Appliance Technician - Appliance Van with Multi-tool
  appliance_technician: renderServiceVan(`
    <!-- Home Appliance Icon / Microwave & Screwdriver -->
    <rect x="44" y="48" width="20" height="14" rx="2" fill="#334155"/>
    <rect x="46" y="50" width="11" height="10" fill="#38BDF8" opacity="0.8"/>
    <circle cx="60" cy="53" r="1.5" fill="#F8FAFC"/>
    <circle cx="60" cy="57" r="1.5" fill="#F8FAFC"/>
  `),

  // 17. Tiles & Ceramic - Contractor Pickup with Stacked Tile Boxes
  tiles_ceramic: renderPickupTruck(`
    <!-- Stacked Ceramic Tile Boxes & Manual Cutter -->
    <rect x="34" y="52" width="18" height="12" rx="1" fill="#EA580C"/>
    <rect x="54" y="52" width="18" height="12" rx="1" fill="#C2410C"/>
    <line x1="34" y1="56" x2="52" y2="56" stroke="#FED7AA" stroke-width="1.5"/>
    <line x1="54" y1="56" x2="72" y2="56" stroke="#FED7AA" stroke-width="1.5"/>
    <!-- Tile Cutter Rail -->
    <line x1="30" y1="48" x2="74" y2="48" stroke="url(#chrome_metal)" stroke-width="2.5"/>
  `),

  // 18. Carpenter - Woodworking Pickup with Timber Planks
  carpenter: renderPickupTruck(`
    <!-- Stacked Hardwood Timber Planks on Rack -->
    <rect x="22" y="46" width="56" height="5" rx="1" fill="#B45309"/>
    <rect x="26" y="51" width="52" height="5" rx="1" fill="#D97706"/>
    <rect x="30" y="56" width="48" height="5" rx="1" fill="#F59E0B"/>
    <!-- Hand Saw Angle -->
    <polygon points="70,40 78,46 76,50 68,44" fill="#94A3B8"/>
  `),

  // 19. Painter - Painting Van with Paint Buckets & Rollers
  painter: renderServiceVan(`
    <!-- Paint Cans with Color Splashes -->
    <rect x="44" y="52" width="12" height="12" rx="2" fill="#94A3B8"/>
    <ellipse cx="50" cy="52" rx="6" ry="2" fill="#38BDF8"/>
    <rect x="60" y="52" width="12" height="12" rx="2" fill="#94A3B8"/>
    <ellipse cx="66" cy="52" rx="6" ry="2" fill="#FACC15"/>
    <!-- Paint Roller -->
    <rect x="76" y="46" width="10" height="4" rx="2" fill="#8B53FE"/>
    <path d="M81 50 L81 58 L77 60" stroke="#334155" stroke-width="2" fill="none"/>
  `, `
    <line x1="40" y1="30" x2="136" y2="30" stroke="url(#chrome_metal)" stroke-width="2"/>
    <line x1="40" y1="33" x2="136" y2="33" stroke="url(#chrome_metal)" stroke-width="2"/>
  `),

  // 20. Pest Control - Extermination Van with Chemical Tank & Wand
  pest_control: renderServiceVan(`
    <!-- Pressurized Spray Tank & Misting Wand -->
    <rect x="46" y="48" width="14" height="16" rx="4" fill="#EAB308"/>
    <circle cx="53" cy="46" r="3" fill="#CA8A04"/>
    <path d="M53 46 Q46 40 64 42 L72 46" stroke="#334155" stroke-width="2" fill="none"/>
    <line x1="72" y1="46" x2="80" y2="52" stroke="url(#chrome_metal)" stroke-width="2"/>
  `),

  // 21. Network Technician - Telecom Van with Satellite Dish & Fiber
  network_technician: renderServiceVan(`
    <!-- Satellite Dish Antenna on Roof -->
    <path d="M80 32 A14 14 0 0 1 104 32" stroke="url(#chrome_metal)" stroke-width="3" fill="none"/>
    <line x1="92" y1="32" x2="92" y2="24" stroke="url(#chrome_metal)" stroke-width="2"/>
    <circle cx="92" cy="23" r="2.5" fill="#38BDF8"/>
    <!-- Wi-Fi Waves Badge -->
    <path d="M50 56 A6 6 0 0 1 58 56" stroke="#38BDF8" stroke-width="2" fill="none"/>
    <path d="M46 52 A12 12 0 0 1 62 52" stroke="#0284C7" stroke-width="2" fill="none"/>
  `),

  // 22. CCTV Technician - Surveillance Security Van with Dome Cameras
  cctv_technician: renderServiceVan(`
    <!-- Mounted Bullet Security Cameras -->
    <g transform="translate(56, 52)">
      <rect x="-8" y="-4" width="14" height="7" rx="2" fill="#1E293B"/>
      <circle cx="7" cy="-0.5" r="3.5" fill="#38BDF8"/>
      <line x1="-8" y1="0" x2="-14" y2="4" stroke="#475569" stroke-width="2"/>
    </g>
    <g transform="translate(76, 52)">
      <rect x="-8" y="-4" width="14" height="7" rx="2" fill="#1E293B"/>
      <circle cx="7" cy="-0.5" r="3.5" fill="#38BDF8"/>
    </g>
  `),

  // 23. Curtain Installation - Decor Van with Drapery Rods
  curtain_installation: renderServiceVan(`
    <!-- Telescoping Curtain Track Rods & Drapery -->
    <line x1="42" y1="50" x2="82" y2="50" stroke="url(#chrome_metal)" stroke-width="3"/>
    <circle cx="42" cy="50" r="3" fill="#D97706"/>
    <circle cx="82" cy="50" r="3" fill="#D97706"/>
    <!-- Folded Curtain Fabric -->
    <path d="M48 52 Q52 64 56 52 Q60 64 64 52 Q68 64 72 52" stroke="#8B53FE" stroke-width="3" fill="none"/>
  `),

  // 24. Doors & Locks - Locksmith Van with Key Cutting Machine
  doors_locks: renderServiceVan(`
    <!-- Locksmith Key Symbol & Smart Lock Cylinder -->
    <circle cx="50" cy="54" r="5" fill="url(#chrome_metal)"/>
    <rect x="54" y="52" width="14" height="4" fill="url(#chrome_metal)"/>
    <rect x="62" y="56" width="3" height="3" fill="url(#chrome_metal)"/>
    <rect x="66" y="56" width="2" height="2" fill="url(#chrome_metal)"/>
    <!-- Brass Mortise Lock Box -->
    <rect x="74" y="48" width="12" height="16" rx="2" fill="#F59E0B"/>
    <circle cx="80" cy="54" r="2" fill="#1E293B"/>
  `),

  // 25. Construction & Renovation - Construction Truck with Bricks & Hard Hat
  construction_renovation: renderPickupTruck(`
    <!-- Construction Brickwork & Masonry Box -->
    <rect x="32" y="54" width="14" height="8" rx="1" fill="#B91C1C"/>
    <rect x="48" y="54" width="14" height="8" rx="1" fill="#991B1B"/>
    <rect x="40" y="46" width="14" height="8" rx="1" fill="#B91C1C"/>
    <!-- Yellow Builder Safety Helmet -->
    <path d="M64 54 A8 8 0 0 1 78 54 Z" fill="#FACC15"/>
    <rect x="62" y="54" width="18" height="2" rx="1" fill="#EAB308"/>
  `),

  // 26. Pool Maintenance - Pool Service Pickup with Filtration Pump & Skimmer
  pool_maintenance: renderPickupTruck(`
    <!-- Pool Circulation Pump Unit -->
    <rect x="34" y="52" width="16" height="12" rx="3" fill="#0284C7"/>
    <circle cx="42" cy="58" r="4" fill="#38BDF8"/>
    <!-- Telescoping Pool Skimmer Net -->
    <line x1="28" y1="44" x2="74" y2="44" stroke="url(#chrome_metal)" stroke-width="2"/>
    <ellipse cx="28" cy="44" rx="4" ry="7" fill="none" stroke="#38BDF8" stroke-width="2"/>
    <path d="M28 37 Q22 44 28 51" fill="#BAE6FD" opacity="0.6"/>
  `),
};

async function generateAll() {
  await fs.mkdir(adminDir, { recursive: true });
  await fs.mkdir(mobileDir, { recursive: true });
  await fs.mkdir(mobileCatDir, { recursive: true });

  console.log(`Generating 26 realistic white fleet category icons...`);

  for (const [key, svg] of Object.entries(CATEGORY_SVGS)) {
    // 1. Save SVG
    const svgPath = path.join(adminDir, `${key}.svg`);
    await fs.writeFile(svgPath, svg.trim());

    // 2. Render high-res PNG (392x240 - 4x retina for exact 98x60 container)
    const resvg = await renderAsync(svg, {
      fitTo: { mode: 'width', value: 392 },
      shapeRendering: 2,
      textRendering: 1,
      imageRendering: 0,
    });
    const pngBuffer = resvg.asPng();

    // 3. Save to admin public folder
    await fs.writeFile(path.join(adminDir, `${key}.png`), pngBuffer);

    // 4. Save to mobile images folders
    await fs.writeFile(path.join(mobileDir, `${key}.png`), pngBuffer);
    await fs.writeFile(path.join(mobileCatDir, `${key}.png`), pngBuffer);

    console.log(`✓ Generated ${key}.png (${pngBuffer.length} bytes)`);
  }

  console.log(`All 26 realistic vehicle category icons successfully generated!`);
}

generateAll().catch(console.error);

