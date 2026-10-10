import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class BrandingHeaderWidget extends StatelessWidget {
  const BrandingHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Scale font size dynamically while maintaining exact proportion
    // Reference is 72px at 390px viewport width
    final double titleFontSize = (screenWidth / 390.0 * 68.0).clamp(48.0, 72.0);
    final double sloganFontSize = (screenWidth / 390.0 * 20.0).clamp(16.0, 20.0);
    final double dotSize = (screenWidth / 390.0 * 12.0).clamp(9.0, 13.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // QAREEB + Brand Accent Dot
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QAREEB',
              style: AppTextStyles.brandTitle(fontSize: titleFontSize),
            ),
            const SizedBox(width: 4),
            // Mint Accent Dot matching reference
            Padding(
              padding: EdgeInsets.only(top: titleFontSize * 0.12),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: const BoxDecoration(
                  color: AppColors.mintAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mintGlow,
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Tagline: People. Services. Closer.
        Text(
          'People. Services. Closer.',
          textAlign: TextAlign.center,
          style: AppTextStyles.slogan(fontSize: sloganFontSize),
        ),
      ],
    );
  }
}
