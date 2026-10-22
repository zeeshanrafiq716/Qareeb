import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider OTP Card Heading Widget
/// Implements exact Figma branding specifications:
///
/// heading layout:
///   width: 350;
///   height: 36;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 12px;
///
/// content: One more step ahead.
///   width: 350; height: 15; angle: 0 deg; opacity: 1;
///   font-family: Inter; font-weight: 600 (Semi Bold); font-size: 20px;
///   leading-trim: CAP_HEIGHT; line-height: 24px; letter-spacing: 0px;
///   text-align: center; color: #1C2926;
///
/// content: We’ve sent a 4-digit code to your phone.
///   width: 350; height: 9; angle: 0 deg; opacity: 1;
///   font-family: Inter; font-weight: 400 (Regular); font-size: 12px;
///   leading-trim: CAP_HEIGHT; line-height: 100%; letter-spacing: 0px;
///   text-align: center; color: #566663;
class ProviderOtpHeading extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const ProviderOtpHeading({
    super.key,
    this.title,
    this.subtitle,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 36.0;
  static const double designGap = 4.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title: "One more step ahead." (Inter 600 SemiBold 20px line-height 24px #1C2926)
              SizedBox(
                width: double.infinity,
                child: Text(
                  title ?? context.l10n.oneMoreStepAhead,
                  textAlign: TextAlign.center,
                  style: ProviderTextStyles.cardHeadingTitle.copyWith(height: 1.15),
                ),
              ),

              const SizedBox(height: designGap), // reduced gap: 4px

              // Subtitle: "We’ve sent a 4-digit code to your phone." (Inter 400 Regular 12px #566663)
              SizedBox(
                width: double.infinity,
                child: Text(
                  subtitle ?? context.l10n.codeSentToPhone,
                  textAlign: TextAlign.center,
                  style: ProviderTextStyles.cardHeadingSubtitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
