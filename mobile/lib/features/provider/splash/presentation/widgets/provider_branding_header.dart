import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Splash Screen Branding Header Widget
/// Implements exact Figma branding specifications:
///
/// text layout:
///   width: 226; height: 64; top: 150px; left: 82px; angle: 0 deg; opacity: 1; gap: 12px;
///
/// 1st row layout:
///   width: 210; height: 40; angle: 0 deg; opacity: 1; gap: 10px;
///
/// left side img layout:
///   width: 40; height: 40; angle: 0 deg; opacity: 1;
///   img: assets/images/q.png
///
/// content: QAREEB
///   width: 160; height: 29; angle: 0 deg; opacity: 1;
///   font-family: Inter; font-weight: 600 (Semi Bold); font-size: 40px;
///   leading-trim: CAP_HEIGHT; line-height: 100%; letter-spacing: 0%; color: #FFFFFF;
///
/// ellipse layout:
///   width: 12; height: 12; angle: 0 deg; opacity: 1; background: #9FFFCB;
///
/// content: Service always near you
///   width: 226; height: 12; angle: 0 deg; opacity: 1;
///   font-family: Inter; font-weight: 400 (Regular); font-size: 16px;
///   leading-trim: CAP_HEIGHT; line-height: 100%; letter-spacing: 0%;
///   text-align: center; color: #FFFFFF;
class ProviderBrandingHeader extends StatelessWidget {
  const ProviderBrandingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic || ProviderTextStyles.isArabic;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand Name (قريب / QAREEB) + Purple Dot
        Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                isArabic ? 'قريب' : 'QAREEB',
                style: ProviderTextStyles.brandTitle,
              ),
              const SizedBox(width: 6.0),
              // Accent Dot: 10 x 10, #8B53FE
              Container(
                width: 10.0,
                height: 10.0,
                margin: EdgeInsets.only(top: isArabic ? 4.0 : 2.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF8B53FE),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        // Subtitle: Service always near you (Arabic: الخدمة دائماً بقربك)
        Text(
          context.l10n.serviceAlwaysNearYou,
          textAlign: TextAlign.center,
          style: ProviderTextStyles.slogan,
        ),
      ],
    );
  }
}
