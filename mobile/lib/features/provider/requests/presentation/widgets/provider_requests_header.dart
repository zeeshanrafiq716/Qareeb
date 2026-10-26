import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_animated_language_toggle.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_header_back_button.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Requests Screen Header Widget
/// Implements exact previous screens branding with chevron back icon, title, subtitle, and language toggle:
///
/// branding:
///   - 36x36 circular white back button with subtle shadow and `<` vector icon
///   - gap: 12px
///   - Title: "Requests" (Inter 600 SemiBold 16px line-height 22px #1C2926)
///   - Subtitle: "Manage and track incoming service requests" (Inter 400 Regular 12px line-height 16px #566663)
///   - gap: 12px
///   - Animated Language Toggle on right side of header (compact: 96x30)
class ProviderRequestsHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;

  const ProviderRequestsHeader({
    super.key,
    this.title,
    this.subtitle,
    this.onBack,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 36.0;
  static const double designTop = 56.0;
  static const double designLeft = 20.0;
  static const double designGap = 12.0;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;
    final String effectiveTitle = title ?? (isArabic ? 'الطلبات' : 'Requests');
    final bool hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: double.infinity,
          height: designHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Icon layout: 36x36 circular white back button with chevron icon
              ProviderHeaderBackButton(
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
              ),

              // gap: 12px;
              const SizedBox(width: designGap),

              // 2. Content: Title (Subtitle removed from Requests header)
              Expanded(
                child: hasSubtitle
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              effectiveTitle,
                              style:
                                  ProviderTextStyles.profileDetailsHeaderTitle,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              subtitle!,
                              style: ProviderTextStyles
                                  .profileDetailsHeaderSubtitle,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          effectiveTitle,
                          style: ProviderTextStyles.headerTitle,
                          maxLines: 1,
                        ),
                      ),
              ),

              const SizedBox(width: designGap),

              // 3. Animated Language Toggle on the right side of header
              const ProviderAnimatedLanguageToggle.compact(),
            ],
          ),
        ),
      ),
    );
  }
}
