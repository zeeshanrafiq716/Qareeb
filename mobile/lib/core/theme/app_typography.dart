import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized Typography engine for QAREEB app.
/// Automatically switches between Cairo (Arabic) and Inter (English)
/// with proportional line-heights and ascender safety.
class AppTypography {
  AppTypography._();

  static TextStyle font({
    required BuildContext context,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return fontForLocale(
      isArabic: isArabic,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }

  static TextStyle fontForLocale({
    bool isArabic = true,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    if (isArabic) {
      // Cairo requires a clean line-height of at least 1.25 to prevent clipping of Arabic dots and diacritics
      final double effectiveHeight = height != null
          ? (height < 1.22 ? 1.22 : height)
          : 1.28;

      return GoogleFonts.cairo(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: effectiveHeight,
        letterSpacing: 0.0,
        decoration: decoration,
        decorationColor: decorationColor,
      ).copyWith(
        fontFamilyFallback: const ['Cairo', 'Tajawal', 'Segoe UI', 'Arial', 'sans-serif'],
      );
    } else {
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
        decorationColor: decorationColor,
      );
    }
  }
}

/// Handy extension on BuildContext to quickly access font styles anywhere
extension TypographyContextExtension on BuildContext {
  TextStyle font({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    return AppTypography.font(
      context: this,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }
}
