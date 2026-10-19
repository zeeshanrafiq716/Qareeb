import 'package:flutter/material.dart';

/// Provider App Dedicated Branding Colors & Gradients
/// Completely segregated from customer app to prevent any styling/layout disturbance
class ProviderColors {
  ProviderColors._();

  // Canvas & Background
  static const Color background = Color(0xFF1F2927);

  // Provider Renewed Brand Colors
  static const Color providerPrimary = Color(0xFF8B53FE); // indicator loader: #8B53FE
  static const Color splashOverlay = Color(0x1AFFFFFF);   // background: #FFFFFF1A
  static const double splashBlur = 200.5124053955078;     // backdrop-filter: blur(200.5124053955078px)
  static const Color splashBackground = Color(0xFFFFFFFF); // clean white canvas
  static const Color splashGlow = Color(0xFFDECFFC);      // top soft purple glow

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

  // Phone Verification Card
  // background: #FFFFFF;
  static const Color cardBackground = Color(0xFFFFFFFF);
  // box-shadow: 0px -2px 12px 0px #00000014;
  static const Color cardShadow = Color(0x14000000);
  // bar layout background: #EFF0ED;
  static const Color cardHandleBar = Color(0xFFEFF0ED);

  // Phone Verification Card Typography
  // background: #1C2926;
  static const Color cardTitle = Color(0xFF1C2926);
  // background: #566663;
  static const Color cardSubtitle = Color(0xFF566663);

  // Phone Number Widget Layout & Buttons
  // background: #F2F5F4;
  static const Color inputBackground = Color(0xFFF2F5F4);
  // background: #8B53FE;
  static const Color primaryButton = Color(0xFF8B53FE);
  // border: 1px solid #566663 / placeholder
  static const Color dropdownBorder = Color(0xFF566663);
  static const Color inputPlaceholder = Color(0xFF566663);
  // KSA Flag Green
  static const Color saudiGreen = Color(0xFF006C35);

  // Or Divider & WhatsApp Branding
  // background: #DEE0DF;
  static const Color dividerLine = Color(0xFFDEE0DF);
  // background: #25D366;
  static const Color whatsappGreen = Color(0xFF25D366);

  // OTP Verification Card Branding
  // background: #EBFFF4;
  static const Color otpActiveBackground = Color(0xFFEBFFF4);
  // ellipse background: #ADB8B4;
  static const Color otpDotPlaceholder = Color(0xFFADB8B4);

  // Profile Steps Icon Background: #E2F0E6
  static const Color profileIconBackground = Color(0xFFE2F0E6);
}



