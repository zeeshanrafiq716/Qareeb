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

  // Core Brand Colors (Updated to brand purple)
  static const Color primary = Color(0xFF8B53FE);
  static const Color primaryLight = Color(0xFFA67AFE);
  static const Color primaryDark = Color(0xFF7032F0);

  // Brand Accents
  static const Color mintAccent = Color(0xFFA67AFE);
  static const Color mintGlow = Color(0xFFBA98FE);
  static const Color mintLight = Color(0xFFF0EAFE);

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
  static const Color roadLine = Color(0x208B53FE); // Purple map road line
  static const Color roadLineDark = Color(0x28162220);
  static const Color trackBackground = Color(0xFF2D3C38);

  // Gradients
  /// Redesigned Customer Splash Top Purple Gradient:
  /// linear-gradient(180.52deg, #8B53FE -66.75%, rgba(139, 83, 254, 0.37284) -0.59%, rgba(139, 83, 254, 0) 29.8%)
  static const LinearGradient topPurpleGlow = LinearGradient(
    begin: Alignment(0.009, -1.0),
    end: Alignment(-0.009, 1.0),
    stops: [0.0, 0.3968, 0.5790, 1.0],
    colors: [
      Color(0xFF8B53FE), // #8B53FE at -66.75%
      Color(0x5F8B53FE), // rgba(139, 83, 254, 0.37284) at -0.59%
      Color(0x008B53FE), // rgba(139, 83, 254, 0) at 29.8%
      Color(0x008B53FE),
    ],
  );

  /// Redesigned Customer Splash Bottom White Gradient:
  /// linear-gradient(180deg, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 0.817605) 43.97%, rgba(255, 255, 255, 0.92) 76.78%, #FFFFFF 100%)
  static const LinearGradient bottomWhiteGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.4397, 0.7678, 1.0],
    colors: [
      Color(0x00FFFFFF), // rgba(255, 255, 255, 0) 0%
      Color(0xD1FFFFFF), // rgba(255, 255, 255, 0.817605) 43.97%
      Color(0xEBFFFFFF), // rgba(255, 255, 255, 0.92) 76.78%
      Color(0xFFFFFFFF), // #FFFFFF 100%
    ],
  );

  /// Route glowing line purple gradient
  static const LinearGradient routeGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0xFF8B53FE),
      Color(0xFFA67AFE),
    ],
  );
}
