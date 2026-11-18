import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared typography + spacing for provider request bottom sheets
/// (active request, request details, etc.).
class ProviderRequestSheetTypography {
  ProviderRequestSheetTypography._();

  static const double sectionGap = 14.0;
  static const double labelGap = 5.0;
  static const double serviceThumb = 60.0;
  static const double iconBox = 40.0;
  static const double iconGlyph = 20.0;
  static const double titleLg = 16.0;
  static const double valueMd = 13.0;
  static const double bodyMd = 13.0;
  static const double labelSm = 12.0;
  static const double subtextSize = 13.0;
  static const double avatar = 48.0;
  static const double stepLabel = 10.5;

  static const Color labelDark = Color(0xFF1C1C1E);
  static const Color subtextLight = Color(0xFF75757A);

  static TextStyle title(bool isArabic) => isArabic
      ? GoogleFonts.cairo(
          fontSize: titleLg,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF252527),
          height: 1.2,
        )
      : GoogleFonts.inter(
          fontSize: titleLg,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF252527),
          height: 1.2,
        );

  static TextStyle subtext(
    bool isArabic, {
    FontWeight weight = FontWeight.w400,
    Color color = subtextLight,
  }) =>
      isArabic
          ? GoogleFonts.cairo(
              fontSize: subtextSize,
              fontWeight: weight,
              color: color,
              height: 1.25,
            )
          : GoogleFonts.inter(
              fontSize: subtextSize,
              fontWeight: weight,
              color: color,
              height: 1.25,
            );

  /// Primary row label — dark (Customer Location, Distance Away, Customer, …).
  static TextStyle label(bool isArabic) => isArabic
      ? GoogleFonts.cairo(
          fontSize: labelSm,
          fontWeight: FontWeight.w500,
          color: labelDark,
          height: 1.2,
        )
      : GoogleFonts.inter(
          fontSize: labelSm,
          fontWeight: FontWeight.w500,
          color: labelDark,
          height: 1.2,
        );

  /// Value under a label in metric cards — light subtext.
  static TextStyle value(bool isArabic) => isArabic
      ? GoogleFonts.cairo(
          fontSize: valueMd,
          fontWeight: FontWeight.w400,
          color: subtextLight,
          height: 1.25,
        )
      : GoogleFonts.inter(
          fontSize: valueMd,
          fontWeight: FontWeight.w400,
          color: subtextLight,
          height: 1.25,
        );

  /// Secondary line under a dark label (address, name, note body).
  static TextStyle body(bool isArabic, {FontWeight weight = FontWeight.w400}) =>
      isArabic
          ? GoogleFonts.cairo(
              fontSize: bodyMd,
              fontWeight: weight,
              color: subtextLight,
              height: 1.2,
            )
          : GoogleFonts.inter(
              fontSize: bodyMd,
              fontWeight: weight,
              color: subtextLight,
              height: 1.2,
            );

  static TextStyle stepLabelStyle(
    bool isArabic, {
    required FontWeight fontWeight,
    required Color color,
  }) =>
      isArabic
          ? GoogleFonts.cairo(
              fontSize: stepLabel,
              fontWeight: fontWeight,
              color: color,
              height: 1.2,
            )
          : GoogleFonts.inter(
              fontSize: stepLabel,
              fontWeight: fontWeight,
              color: color,
              height: 1.2,
            );
}