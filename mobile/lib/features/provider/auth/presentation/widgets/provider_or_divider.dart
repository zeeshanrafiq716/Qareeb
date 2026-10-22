import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Or Divider Widget
/// Implements exact Figma branding specifications:
///
/// next layout branding:
///   width: 300;
///   height: 10;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 12px;
///
/// left-side horizontal line branding:
///   width: 131;
///   height: 1.2000000476837158;
///   border-radius: 20px;
///   background: #DEE0DF;
///
/// content: or
///   width: 14; height: 10; angle: 0 deg; opacity: 1;
///   font-family: Inter; font-weight: 400 (Regular); font-size: 14px;
///   leading-trim: CAP_HEIGHT; line-height: 22px; letter-spacing: 0px;
///   color: #566663;
///
/// right-side horizontal branding:
///   width: 131;
///   height: 1.2000000476837158;
///   border-radius: 20px;
///   background: #DEE0DF;
class ProviderOrDivider extends StatelessWidget {
  const ProviderOrDivider({super.key});

  static const double designWidth = 300.0;
  static const double lineWidth = 131.0;
  static const double lineHeight = 1.2;
  static const double designGap = 12.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // left-side horizontal line
              Expanded(
                child: Container(
                  height: lineHeight,
                  decoration: BoxDecoration(
                    color: ProviderColors.dividerLine, // #DEE0DF
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: designGap),
                child: Text(
                  context.l10n.orDividerText,
                  style: ProviderTextStyles.orDividerText,
                ),
              ),

              // right-side horizontal line
              Expanded(
                child: Container(
                  height: lineHeight,
                  decoration: BoxDecoration(
                    color: ProviderColors.dividerLine, // #DEE0DF
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
