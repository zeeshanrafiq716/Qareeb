import 'package:flutter/material.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_auth_form_layout.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_heading.dart';

/// Provider Auth Card Inner Content Layout Widget
/// Implements exact Figma branding specifications:
///
/// inner content layout:
///   width: 350;
///   height: 435.22216796875;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 40px;
class ProviderCardContentLayout extends StatelessWidget {
  final Widget? formContent;

  const ProviderCardContentLayout({
    super.key,
    this.formContent,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 435.22216796875;
  static const double designGap = 40.0;
  static const double designTop = 24.0;

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
              // 1. Heading Content Layout (width: 350, height: 51, gap: 12)
              const ProviderCardHeading(),

              // Gap: 40px between heading and upcoming form layout
              const SizedBox(height: designGap),

              // 2. Next Widget Layout: width: 350; height: 280.22; gap: 20px;
              formContent ?? const ProviderAuthFormLayout(),
            ],
          ),
        ),
      ),
    );
  }
}
