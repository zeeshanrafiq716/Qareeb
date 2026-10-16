import 'package:flutter/material.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Splash Screen Bottom Text Widget
/// Implements exact Figma branding specifications:
///
/// bottom text layout:
///   width: 350; height: 122; top: 570px; left: 20px; angle: 0 deg; opacity: 1; gap: 20px;
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Headline: Ready to respond\nBuilt to deliver (36px, Semi Bold, #FFFFFF)
          Text(
            'Ready to respond\nBuilt to deliver',
            style: ProviderTextStyles.bottomHeadline,
          ),
          const SizedBox(height: 20.0), // gap: 20px
          // Subtext: Manage service requests reach customers \nand stay connected in real time.
          Text(
            'Manage service requests reach customers \nand stay connected in real time.',
            style: ProviderTextStyles.bottomSubtitle,
          ),
        ],
      ),
    );
  }
}
