import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';

/// Provider App Dedicated Text Styles
/// Segregated to keep customer side styles completely untouched.
/// Dynamically selects Cairo for Arabic and Inter for English to prevent text clipping.
class ProviderTextStyles {
  ProviderTextStyles._();

  static bool _manualArabic = true;
  static bool get isArabic => _manualArabic;
  static set isArabic(bool val) => _manualArabic = val;

  static TextStyle _font({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    double? letterSpacing,
    bool? isArabicOverride,
  }) {
    final arabic = isArabicOverride ?? isArabic;
    return AppTypography.fontForLocale(
      isArabic: arabic,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height ?? (arabic ? 1.28 : 1.15),
      letterSpacing: arabic ? 0.0 : letterSpacing,
    );
  }

  /// QAREEB / قريب brand title
  static TextStyle get brandTitle => _font(
    fontSize: isArabic ? 34.0 : 30.0,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF231F20),
    letterSpacing: isArabic ? 0.0 : 0.2,
    height: isArabic ? 1.25 : 1.0,
    isArabicOverride: isArabic,
  );

  /// Slogan: "Service always near you"
  static TextStyle get slogan => _font(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF566663),
    letterSpacing: 0.0,
    height: 1.30,
  );

  /// Bottom Headline
  static TextStyle get bottomHeadline => _font(
    fontSize: 30.0,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 1.30,
  );

  /// Bottom Subtitle
  static TextStyle get bottomSubtitle => _font(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF6B7280),
    letterSpacing: 0.0,
    height: 1.45,
  );

  /// Indicator Status Text
  static TextStyle get indicatorStatus => _font(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF71717A),
    letterSpacing: 0.0,
    height: 1.25,
  );

  /// Card Heading Title
  static TextStyle get cardHeadingTitle => _font(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 24.0 / 20.0,
  );

  /// Card Heading Subtitle
  static TextStyle get cardHeadingSubtitle => _font(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF566663),
    letterSpacing: 0.0,
    height: 1.25,
  );

  /// Phone Input Label
  static TextStyle get phoneInputLabel => _font(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// Country Code: "+966"
  static TextStyle get phoneCode => _font(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// Phone Number Input
  static TextStyle get phoneInput => _font(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// Phone Number Placeholder
  static TextStyle get phonePlaceholder => _font(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF566663),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// Continue Button Text
  static TextStyle get continueButtonText => _font(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFFFFFFFF),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// Divider "or" text
  static TextStyle get orDividerText => _font(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF566663),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// WhatsApp Button Text
  static TextStyle get whatsappButtonText => _font(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// Security Notice
  static TextStyle get securityNotice => _font(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF566663),
    letterSpacing: 0.0,
    height: 1.15,
  );

  /// OTP Digit
  static TextStyle get otpDigit => _font(
    fontSize: 20.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF000000),
    letterSpacing: 0.0,
    height: 22.0 / 20.0,
  );

  /// Resend Timer Label
  static TextStyle get resendTimerText => _font(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF566663),
    letterSpacing: 0.0,
    height: 1.15,
  );

  /// Resend Timer Value Span
  static TextStyle get resendTimerSpan => _font(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF566663),
    letterSpacing: 0.0,
    height: 1.15,
  );

  /// Change Phone Number Button Text
  static TextStyle get changePhoneButtonText => _font(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// Header Title
  static TextStyle get headerTitle => _font(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 24.0 / 16.0,
  );

  /// Provider Profile Details Header Title
  static TextStyle get profileDetailsHeaderTitle => _font(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 22.0 / 16.0,
  );

  /// Provider Profile Details Header Subtitle
  static TextStyle get profileDetailsHeaderSubtitle => _font(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF566663),
    letterSpacing: 0.0,
    height: 16.0 / 12.0,
  );

  /// Verification Successful Title
  static TextStyle get verificationSuccessfulTitle => _font(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 24.0 / 20.0,
  );

  /// Verification Successful Subtitle
  static TextStyle get verificationSuccessfulSubtitle => _font(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF566663),
    letterSpacing: 0.0,
    height: 1.25,
  );

  /// Admin Approval Pending Title
  static TextStyle get adminApprovalPendingTitle => _font(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 24.0 / 20.0,
  );

  /// Admin Approval Pending Subtitle
  static TextStyle get adminApprovalPendingSubtitle => _font(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF566663),
    letterSpacing: 0.0,
    height: 1.25,
  );

  /// Step Card Title
  static TextStyle get stepCardTitle => _font(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// Step Card Subtitle
  static TextStyle get stepCardSubtitle => _font(
    fontSize: 10.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF566663),
    letterSpacing: 0.0,
    height: 1.35,
  );

  /// Back to Home Primary Button Text
  static TextStyle get backToHomeButtonText => _font(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFFFFFFFF),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// Back to Home Secondary/Dark Button Text
  static TextStyle get backToHomeDarkButtonText => _font(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// Personal Information Heading
  static TextStyle get personalInformationHeading => _font(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// Profile Field Label
  static TextStyle get profileInputLabel => _font(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 22.0 / 12.0,
  );

  /// Profile Field Label Span
  static TextStyle get profileInputLabelSpan => _font(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF566663),
    letterSpacing: 0.0,
    height: 22.0 / 12.0,
  );

  /// Profile Field Input Text
  static TextStyle get profileInputText => _font(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// Profile Field Input Placeholder
  static TextStyle get profileInputPlaceholder => _font(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF566663),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// What's Next? Card Title
  static TextStyle get whatsNextTitle => _font(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF1C2926),
    letterSpacing: 0.0,
    height: 22.0 / 14.0,
  );

  /// What's Next? Card Subtitle
  static TextStyle get whatsNextSubtitle => _font(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF566663),
    letterSpacing: 0.0,
    height: 14.0 / 12.0,
  );
}

