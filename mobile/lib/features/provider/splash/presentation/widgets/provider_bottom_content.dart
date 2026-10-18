import 'package:flutter/material.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Splash Screen Inner Content Layout Branding
/// Implements exact Figma branding specifications:
///
/// inner content layout branding:
///   width: 350;
///   height: 122;
///   left: 20px;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 20px;
///
/// content: Ready to respond\nBuilt to deliver
///   width: 350; height: 70; angle: 0 deg; opacity: 1;
///   font-family: Inter; font-weight: 600 (Semi Bold); font-size: 36px;
///   leading-trim: CAP_HEIGHT; line-height: 100%; letter-spacing: 0%; color: #FFFFFF;
///
/// content: Manage service requests reach customers \nand stay connected in real time.
///   width: 350; height: 32; angle: 0 deg; opacity: 1;
///   font-family: Inter; font-weight: 400 (Regular); font-size: 16px;
///   leading-trim: CAP_HEIGHT; line-height: 20px; letter-spacing: 0%; color: #FFFFFF;
class ProviderBottomContent extends StatelessWidget {
  const ProviderBottomContent({super.key});

  static const double designWidth = 350.0;
  static const double designHeight = 122.0;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Headline: Ready to respond\nBuilt to deliver (36px, Semi Bold, #FFFFFF)
              Text(
                'Ready to respond\nBuilt to deliver',
                style: ProviderTextStyles.bottomHeadline,
              ),
              const SizedBox(height: 16.0), // gap
              // Subtext: Manage service requests reach customers \nand stay connected in real time.
              Text(
                'Manage service requests reach customers \nand stay connected in real time.',
                style: ProviderTextStyles.bottomSubtitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
