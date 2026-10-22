import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Auth Card Heading Widget
/// Implements exact Figma branding specifications:
///
/// heading content layout:
///   width: 350;
///   height: 51;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 12px;
///
/// content: Start with your phone number
///   width: 350; height: 15; angle: 0 deg; opacity: 1;
///   font-family: Inter; font-weight: 600 (Semi Bold); font-size: 20px;
///   leading-trim: CAP_HEIGHT; line-height: 24px; letter-spacing: 0px;
///   text-align: center; color: #1C2926;
///
/// content: Enter your phone number to access your account \nand receive service requests.
///   width: 350; height: 24; angle: 0 deg; opacity: 1;
///   font-family: Inter; font-weight: 400 (Regular); font-size: 12px;
///   leading-trim: CAP_HEIGHT; line-height: 100%; letter-spacing: 0px;
///   text-align: center; color: #566663;
class ProviderCardHeading extends StatelessWidget {
  const ProviderCardHeading({super.key});

  static const double designWidth = 350.0;
  static const double designHeight = 51.0;

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
              // Title: "Start with your phone number" (20px, 600, #1C2926)
              SizedBox(
                width: double.infinity,
                child: Text(
                  context.l10n.startWithPhoneNumber,
                  textAlign: TextAlign.center,
                  style: ProviderTextStyles.cardHeadingTitle,
                ),
              ),
              const SizedBox(height: 8.0), // gap: 8px
              // Subtitle: "Enter your phone number to access your account and receive service requests."
              SizedBox(
                width: double.infinity,
                child: Text(
                  context.l10n.enterPhoneSubtitle,
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
