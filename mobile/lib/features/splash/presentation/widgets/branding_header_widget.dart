import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/app_locale.dart';

class BrandingHeaderWidget extends StatelessWidget {
  const BrandingHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final screenWidth = MediaQuery.of(context).size.width;

    // Scale font size dynamically while maintaining exact proportion
    // Reference is 72px at 390px viewport width
    final double titleFontSize = (screenWidth / 390.0 * 68.0).clamp(48.0, 72.0);
    final double sloganFontSize = (screenWidth / 390.0 * 20.0).clamp(16.0, 20.0);
    final double dotSize = (screenWidth / 390.0 * 12.0).clamp(9.0, 13.0);

    final bool isArabic = tr.isArabic;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand Name + Accent Dot
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Text(
              isArabic ? 'قريب' : 'QAREEB',
              style: isArabic
                  ? tr.font(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C2926),
                      letterSpacing: 0.0,
                      height: 1.0,
                    )
                  : GoogleFonts.inter(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1C2926),
                      letterSpacing: -0.5,
                      height: 1.0,
                    ),
            ),
            const SizedBox(width: 4),
            // Purple Accent Dot
            Padding(
              padding: EdgeInsets.only(top: titleFontSize * 0.12),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: const BoxDecoration(
                  color: Color(0xFF8B53FE),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x668B53FE),
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

        // Tagline
        Text(
          isArabic
              ? 'الناس. الخدمات. أقرب.'
              : 'People. Services. Closer.',
          textAlign: TextAlign.center,
          style: isArabic
              ? tr.font(
                  fontSize: sloganFontSize,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF566663),
                  letterSpacing: 0.0,
                  height: 1.1,
                )
              : GoogleFonts.inter(
                  fontSize: sloganFontSize,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF566663),
                  letterSpacing: 0.1,
                  height: 1.1,
                ),
        ),
      ],
    );
  }
}
