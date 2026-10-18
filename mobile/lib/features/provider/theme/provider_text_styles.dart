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
  /// font-family: Inter; font-weight: 600 (Semi Bold); font-size: 36px; color: #FFFFFF;
  static TextStyle bottomHeadline = GoogleFonts.inter(
    fontSize: 36.0,
    fontWeight: FontWeight.w600,
    color: const Color(0xFFFFFFFF),
    letterSpacing: 0.0,
    height: 1.05,
  );

  /// Bottom Subtitle:
  /// "Manage service requests reach customers \nand stay connected in real time."
  /// font-family: Inter; font-weight: 400 (Regular); font-size: 16px; color: #FFFFFF;
  static TextStyle bottomSubtitle = GoogleFonts.inter(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFFFFFFFF),
    letterSpacing: 0.0,
    height: 1.35,
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

  /// Card Heading Title:
  /// "Start with your phone number"
  /// font-family: Inter; font-weight: 600 (Semi Bold); font-size: 20px; line-height: 24px; color: #1C2926;
  static TextStyle cardHeadingTitle = GoogleFonts.inter(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 24.0 / 20.0,
  );

  /// Card Heading Subtitle:
  /// "Enter your phone number to access your account \nand receive service requests."
  /// font-family: Inter; font-weight: 400 (Regular); font-size: 12px; line-height: 100%; color: #566663;
  static TextStyle cardHeadingSubtitle = GoogleFonts.inter(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF566663),
    letterSpacing: 0.0,
    height: 1.0,
  );

  /// Phone Input Label:
  /// "Phone Number"
  /// font-family: Inter; font-weight: 500 (Medium); font-size: 14px; line-height: 22px; color: #1C2926;
  static TextStyle phoneInputLabel = GoogleFonts.inter(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// Country Code: "+966"
  /// font-family: Inter; font-weight: 500 (Medium); font-size: 14px; line-height: 22px; color: #1C2926;
  static TextStyle phoneCode = GoogleFonts.inter(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// Phone Number Input:
  /// font-family: Inter; font-weight: 400 (Regular); font-size: 14px; line-height: 22px; color: #1C2926;
  static TextStyle phoneInput = GoogleFonts.inter(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// Phone Number Placeholder: "50 123 4567"
  /// font-family: Inter; font-weight: 400 (Regular); font-size: 14px; line-height: 22px; color: #566663;
  static TextStyle phonePlaceholder = GoogleFonts.inter(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF566663),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// Continue Button Text: "Continue"
  /// font-family: Inter; font-weight: 500 (Medium); font-size: 14px; line-height: 22px; color: #FFFFFF;
  static TextStyle continueButtonText = GoogleFonts.inter(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFFFFFFFF),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// Divider "or" text:
  /// font-family: Inter; font-weight: 400 (Regular); font-size: 14px; line-height: 22px; color: #566663;
  static TextStyle orDividerText = GoogleFonts.inter(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF566663),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// WhatsApp Button Text: "Continue with WhatsApp"
  /// font-family: Inter; font-weight: 500 (Medium); font-size: 14px; line-height: 22px; color: #1C2926;
  static TextStyle whatsappButtonText = GoogleFonts.inter(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// Security Notice: "Your Number is safe with us."
  /// font-family: Inter; font-weight: 400 (Regular); font-size: 12px; line-height: 100%; color: #566663;
  static TextStyle securityNotice = GoogleFonts.inter(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF566663),
    letterSpacing: 0.0,
    height: 1.0,
  );
}


