import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Provider App Dedicated Text Styles
/// Segregated to keep customer side styles completely untouched.
class ProviderTextStyles {
  ProviderTextStyles._();

  /// QAREEB brand title:
  /// font-family: Inter;
  /// font-weight: 600 (Semi Bold);
  /// font-size: 40px;
  /// line-height: 100%;
  /// letter-spacing: 0%;
  /// color: #FFFFFF;
  static TextStyle brandTitle = GoogleFonts.inter(
    fontSize: 40.0,
    fontWeight: FontWeight.w600,
    color: const Color(0xFFFFFFFF),
    letterSpacing: 0.0,
    height: 1.0,
  );

  /// Slogan: "Service always near you"
  /// font-family: Inter;
  /// font-weight: 400 (Regular);
  /// font-size: 16px;
  /// line-height: 100%;
  /// letter-spacing: 0%;
  /// text-align: center;
  /// color: #FFFFFF;
  static TextStyle slogan = GoogleFonts.inter(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFFFFFFFF),
    letterSpacing: 0.0,
    height: 1.0,
  );

  /// Bottom Headline:
  /// "Ready to respond\nBuilt to deliver"
  /// font-family: Inter; font-weight: 600 (Semi Bold); font-size: 36px; line-height: 100%; color: #FFFFFF;
  static TextStyle bottomHeadline = GoogleFonts.inter(
    fontSize: 36.0,
    fontWeight: FontWeight.w600,
    color: const Color(0xFFFFFFFF),
    letterSpacing: 0.0,
    height: 35.0 / 36.0,
  );

  /// Bottom Subtitle:
  /// "Manage service requests reach customers \nand stay connected in real time."
  /// font-family: Inter; font-weight: 400 (Regular); font-size: 16px; line-height: 20px; color: #FFFFFF;
  static TextStyle bottomSubtitle = GoogleFonts.inter(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFFFFFFFF),
    letterSpacing: 0.0,
    height: 20.0 / 16.0,
  );

  /// Indicator Status Text:
  /// "Getting things ready..."
  /// font-family: Inter; font-weight: 400 (Regular); font-size: 12px; line-height: 100%; color: #E0E0E0;
  static TextStyle indicatorStatus = GoogleFonts.inter(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFFE0E0E0),
    letterSpacing: 0.0,
    height: 1.0,
  );
}
