import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  /// QAREEB brand title style (Inter, Semi Bold 600, 72px)
  static TextStyle brandTitle({double fontSize = 64}) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: AppColors.textWhite,
      letterSpacing: -0.5,
      height: 1.0,
    );
  }

  /// People. Services. Closer. slogan (Inter, Regular 400, 20px)
  static TextStyle slogan({double fontSize = 18}) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: AppColors.textMuted,
      letterSpacing: 0.1,
      height: 1.1,
    );
  }

  /// Subtitle & status
  static TextStyle statusText = GoogleFonts.inter(
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted.withValues(alpha: 0.85),
    letterSpacing: 0.2,
  );

  /// User badge text
  static TextStyle badgeText = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.background,
    letterSpacing: 0.2,
  );

  /// Headline styles
  static TextStyle headingLarge = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
  );

  static TextStyle headingMedium = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
