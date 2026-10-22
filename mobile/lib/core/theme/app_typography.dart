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
      return GoogleFonts.cairo(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height ?? 1.15,
        letterSpacing: 0.0,
        decoration: decoration,
        decorationColor: decorationColor,
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
