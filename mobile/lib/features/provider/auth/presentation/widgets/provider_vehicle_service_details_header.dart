import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
///   - Title: "Vehicle & Service Details"
///   - Animated Language Toggle on right
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Icon layout: 36x36 circular white back button matching previous branding
              ProviderHeaderBackButton(
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
              ),

              // gap: 12px;
              const SizedBox(width: designGap),

              // 2. Content: Title (+ optional Subtitle)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        title != null
                            ? (context.isArabic ? context.auto(title) : title!)
                            : (context.isArabic ? 'تفاصيل المركبة والخدمة' : 'Vehicle & Service Details'),
                        style: GoogleFonts.inter(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C2926),
                        ),
                        maxLines: 1,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2.0),
                      Text(
                        context.isArabic ? context.auto(subtitle) : subtitle!,
                        style: ProviderTextStyles.profileDetailsHeaderSubtitle,
                        maxLines: 2,
                        softWrap: true,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12.0),

              // 3. Animated Language Toggle in header
              const ProviderAnimatedLanguageToggle.compact(),
            ],
          ),
        ),
      ),
    );
  }
}
