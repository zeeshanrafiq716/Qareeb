import 'package:flutter/material.dart';

/// Provider App Dedicated Branding Colors & Gradients
/// Completely segregated from customer app to prevent any styling/layout disturbance
class ProviderColors {
  ProviderColors._();

  // Canvas & Background
  static const Color background = Color(0xFF1F2927);

  // Mint Accent Colors
  static const Color mintAccent = Color(0xFF9FFFCB);
  static const Color mintGlow = Color(0xFF66FFAC);

  // Exact Top Mint Linear Gradient (180deg)
  // linear-gradient(180deg, rgba(102, 255, 172, 0.8) -33.53%, rgba(102, 255, 172, 0.460552) 4.23%, rgba(102, 255, 172, 0.25553) 27.03%, rgba(102, 255, 172, 0) 62.38%)
  static const Color topGlowStart = Color(0xCC66FFAC); // rgba(102, 255, 172, 0.8)
  static const Color topGlowMid1 = Color(0x7566FFAC);  // rgba(102, 255, 172, 0.460552)
  static const Color topGlowMid2 = Color(0x4166FFAC);  // rgba(102, 255, 172, 0.25553)
  static const Color topGlowEnd = Color(0x0066FFAC);   // rgba(102, 255, 172, 0)

  // Exact Bottom Dark Linear Gradient (180deg)
  // linear-gradient(180deg, rgba(31, 41, 39, 0) 50%, rgba(31, 41, 39, 0.398199) 57.27%, rgba(31, 41, 39, 0.817605) 71.17%, rgba(31, 41, 39, 0.92) 82.55%, #1F2927 100%)
  static const Color bottomDarkStart = Color(0x001F2927); // rgba(31, 41, 39, 0)
  static const Color bottomDarkMid1 = Color(0x661F2927);  // rgba(31, 41, 39, 0.398199)
  static const Color bottomDarkMid2 = Color(0xD11F2927);  // rgba(31, 41, 39, 0.817605)
  static const Color bottomDarkMid3 = Color(0xEB1F2927);  // rgba(31, 41, 39, 0.92)
  static const Color bottomDarkEnd = Color(0xFF1F2927);   // #1F2927

  // Phone Verification Screen Backdrop Tint
  // background: #1F292829;
  static const Color backdropTint = Color(0x291F2928);
}
