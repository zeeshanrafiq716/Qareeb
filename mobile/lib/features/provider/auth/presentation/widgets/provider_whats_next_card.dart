import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider What's Next Card Widget
/// Implements exact Figma branding specifications:
///
/// next card branding:
///   width: 350;
///   height: 77;
///   gap: 12px;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 12px;
///   padding: 16px;
///   background: #F2F5F4;
///
/// left side icon branding:
///   width: 36;
///   height: 36;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 67.5px;
///   background: #DDF0E3;
///
/// icon inner branding:
///   width: 28;
///   height: 28;
///   angle: 0 deg;
///   opacity: 1;
///   top: 4.5px;
///   left: 4px;
///   background: #1D8070;
///
/// content layout:
///   width: 270;
///   height: 45;
///   gap: 12px;
///   angle: 0 deg;
///   opacity: 1;
///
/// content: What's Next?
///   width: 270;
///   height: 10;
///   font-family: Inter;
///   font-weight: 500;
///   font-style: Medium;
///   font-size: 14px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 22px;
///   letter-spacing: 0px;
///   background: #1C2926;
///
/// content: You'll be notified once approved usually \nwithin 1–24 hours.
///   width: 270;
///   height: 23;
///   font-family: Inter;
///   font-weight: 400;
///   font-style: Regular;
///   font-size: 12px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 14px;
///   letter-spacing: 0px;
///   background: #566663;
class ProviderWhatsNextCard extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const ProviderWhatsNextCard({
    super.key,
    this.title,
    this.subtitle,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 77.0;
  static const double cardPadding = 16.0;
  static const double designGap = 12.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: designHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: cardPadding,
            vertical: 14.0,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F5F4), // background: #F2F5F4
            borderRadius: BorderRadius.circular(12.0), // border-radius: 12px
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side icon branding: width: 36; height: 36; border-radius: 67.5px; bg: #DDF0E3;
              Container(
                width: 36.0,
                height: 36.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0EAFE),
                  shape: BoxShape.circle, // border-radius: 67.5px
                ),
                child: Center(
                  child: Container(
                    width: 28.0,
                    height: 28.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B53FE),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '!',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Gap: 12px
              const SizedBox(width: designGap),

              // Content layout: width: 270; height: 45;
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Content: What's Next? (Inter 500 Medium 14px line-height 22px #1C2926)
                    Text(
                      title ?? context.l10n.whatsNext,
                      style: ProviderTextStyles.whatsNextTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2.0),
                    // Content: You'll be notified once approved usually \nwithin 1–24 hours.
                    Text(
                      subtitle ?? context.l10n.whatsNextSubtitle,
                      style: ProviderTextStyles.whatsNextSubtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
