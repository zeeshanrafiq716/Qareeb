import 'package:flutter/material.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Verification Success Heading Content Layout Widget
/// Implements exact Figma branding specifications:
///
/// content layout:
///   width: 350;
///   height: 51;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 12px;
///
/// content: Verification Successful
///   width: 350;
///   height: 15;
///   font-family: Inter; font-weight: 600 (Semi Bold); font-size: 20px;
///   line-height: 24px; letter-spacing: 0px; text-align: center; color: #1C2926;
///
/// content: Your phone is verified. Complete your profile \nto receive service requests.
///   width: 350;
///   height: 24;
///   font-family: Inter; font-weight: 400 (Regular); font-size: 12px;
///   line-height: 100%; letter-spacing: 0px; text-align: center; color: #566663;
class ProviderVerificationSuccessHeading extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const ProviderVerificationSuccessHeading({
    super.key,
    this.title,
    this.subtitle,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 51.0;
  static const double designGap = 12.0;

  static const String defaultTitle = 'Verification Successful';
  static const String defaultSubtitle =
      'Your phone is verified. Complete your profile \nto receive service requests.';

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: designWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Content: Verification Successful (Inter 600 Semi Bold 20px line-height 24px #1C2926)
              Text(
                title ?? defaultTitle,
                style: ProviderTextStyles.verificationSuccessfulTitle,
                textAlign: TextAlign.center,
              ),

              // gap: 12px;
              const SizedBox(height: designGap),

              // 2. Content: Your phone is verified. Complete your profile \nto receive service requests.
              // (Inter 400 Regular 12px line-height 100% #566663)
              Text(
                subtitle ?? defaultSubtitle,
                style: ProviderTextStyles.verificationSuccessfulSubtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
