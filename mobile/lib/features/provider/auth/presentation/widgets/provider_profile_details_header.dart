import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_animated_language_toggle.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_header_back_button.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Profile Details Screen Header Widget
/// Implements exact Figma branding specifications:
///
/// header layout:
///   width: 350;
///   height: 36;
///   angle: 0 deg;
///   opacity: 1;
///   top: 56px;
///   left: 20px;
///   gap: 16px;
///
/// follow previous screen header branding:
///   - 36x36 circular white back button with subtle shadow and `<` vector
///   - gap: 16px
///   - Title: "Personal Information"
///   - Animated language toggle on top right
class ProviderProfileDetailsHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;

  const ProviderProfileDetailsHeader({
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
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Icon layout: 36x36 back button matching previous branding
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
                            : (context.isArabic ? 'المعلومات الشخصية' : 'Personal Information'),
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

              // 3. Animated Language Toggle in header (strictly preserved)
              const ProviderAnimatedLanguageToggle.compact(),
            ],
          ),
        ),
      ),
    );
  }
}
