import 'package:flutter/material.dart';

/// Qareeb App Brand & UI Color Palette
/// Derived exactly from the brand guideline & Figma specifications:
/// - Primary: #1D8070
/// - Accent Mint: #9FFFCB (and rgba(102, 255, 172))
/// - Dark Slate/Charcoal: #1F2927
/// - Pure White: #FFFFFF
/// - Text Muted: #E0E0E0
class AppColors {
  AppColors._();

  // Core Brand Colors
  static const Color primary = Color(0xFF1D8070);
  static const Color primaryLight = Color(0xFF28A08D);
  static const Color primaryDark = Color(0xFF12584D);

  // Mint Accents
  static const Color mintAccent = Color(0xFF9FFFCB);
  static const Color mintGlow = Color(0xFF66FFAC);
  static const Color mintLight = Color(0xFFD6FFE9);

  // Dark Canvas & Backgrounds
  static const Color background = Color(0xFF1F2927);
  static const Color surfaceDark = Color(0xFF253330);
  static const Color surfaceElevated = Color(0xFF2C3B38);
  static const Color cardBg = Color(0xFF23312E);

  // Neutral & Typography
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF9EAFA9);
  static const Color textDisabled = Color(0xFF60736E);

  // Roads & Map Vectors
  static const Color roadLine = Color(0x1E9FFFCB); // Subtle mint grid
  static const Color roadLineDark = Color(0x28162220);
  static const Color trackBackground = Color(0xFF2D3C38);

  // Gradients
  /// Top mint atmospheric ambient glow from specs:
  /// linear-gradient(180deg, rgba(102, 255, 172, 0.8) -28.97%, rgba(102, 255, 172, 0.0511174) 50.78%, rgba(102, 255, 172, 0) 62.86%)
  static const LinearGradient topMintGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5078, 0.6286],
    colors: [
      Color(0xCC66FFAC), // rgba(102, 255, 172, 0.8)
      Color(0x0D66FFAC), // rgba(102, 255, 172, 0.0511174)
      Color(0x0066FFAC), // rgba(102, 255, 172, 0)
    ],
  );

  /// Bottom shading gradient from specs:
  /// linear-gradient(180deg, rgba(31, 41, 39, 0) 0%, rgba(31, 41, 39, 0.817605) 43.97%, rgba(31, 41, 39, 0.92) 76.78%, #1F2927 100%)
  static const LinearGradient bottomDarkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.4397, 0.7678, 1.0],
    colors: [
      Color(0x001F2927), // rgba(31, 41, 39, 0)
      Color(0xD11F2927), // rgba(31, 41, 39, 0.817605)
      Color(0xEB1F2927), // rgba(31, 41, 39, 0.92)
      Color(0xFF1F2927), // #1F2927
    ],
  );

  /// Route glowing line gradient
  static const LinearGradient routeGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0xFF66FFAC),
      Color(0xFF9FFFCB),
    ],
  );
}
