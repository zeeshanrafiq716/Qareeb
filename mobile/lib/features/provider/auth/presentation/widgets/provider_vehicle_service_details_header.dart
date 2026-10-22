import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_animated_language_toggle.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_header_back_button.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Vehicle & Service Details Screen Header Widget (Screen 6)
/// Implements exact Figma branding specifications following previous screen header:
///
/// header layout:
///   width: 350;
///   height: ~56;
///   top: 56px;
///   left: 20px;
///   gap: 16px;
///   angle: 0 deg;
///   opacity: 1;
///
/// branding:
///   - 36x36 circular white back button with subtle shadow and `<` vector icon
///   - gap: 16px
///   - Title: "Vehicle & Service Details" (Inter 600 SemiBold 16px line-height 22px #1C2926)
///   - Subtitle: "Select a service category and enter\nyour vehicle details." (Inter 400 Regular 12px line-height 16px #566663)
class ProviderVehicleServiceDetailsHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;

  const ProviderVehicleServiceDetailsHeader({
    super.key,
    this.title,
    this.subtitle,
    this.onBack,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 46.0;
  static const double designTop = 56.0;
  static const double designLeft = 20.0;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Icon layout: 36x36 circular white back button matching previous branding
              ProviderHeaderBackButton(
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
              ),

              // gap: 12px;
              const SizedBox(width: designGap),

              // 2. Content: Title + 2-line Subtitle
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        title != null ? (context.isArabic ? context.auto(title) : title!) : context.l10n.vehicleServiceDetailsTitle,
                        style: ProviderTextStyles.profileDetailsHeaderTitle,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle != null ? (context.isArabic ? context.auto(subtitle) : subtitle!) : context.l10n.vehicleServiceSubtitle,
                      style: ProviderTextStyles.profileDetailsHeaderSubtitle,
                      maxLines: 2,
                      softWrap: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12.0),

              // 3. Animated Language Toggle in header
              const Padding(
                padding: EdgeInsets.only(top: 2.0),
                child: ProviderAnimatedLanguageToggle.compact(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
