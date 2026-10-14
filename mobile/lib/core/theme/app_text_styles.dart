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

  /// Category card title branding: Inter Medium 500, 12px, line-height 22px, letter-spacing 0px
  static TextStyle categoryCardTitle = GoogleFonts.inter(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF172623),
    height: 22.0 / 12.0,
    letterSpacing: 0.0,
  );

  /// Category card subtitle branding: Inter Regular 400, 10px, line-height 22px, letter-spacing 0px
  static TextStyle categoryCardSubtitle = GoogleFonts.inter(
    fontSize: 10.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF566663),
    height: 22.0 / 10.0,
    letterSpacing: 0.0,
  );
}
