import 'package:flutter/material.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_header_back_button.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Upload Documents Screen Header Widget (Screen 7)
/// Implements exact Figma branding specifications following previous screen headers:
///
/// header layout:
///   width: 350;
///   height: 36;
///   top: 56px;
///   left: 20px;
///   gap: 16px;
///   angle: 0 deg;
///   opacity: 1;
///
/// branding:
///   - 36x36 circular white back button with subtle shadow and `<` vector chevron
///   - gap: 16px
///   - Title: "Upload Documents" (Inter 600 SemiBold 16px line-height 22px #1C2926)
///   - Subtitle: "Upload the required documents for verification." (Inter 400 Regular 12px line-height 16px #566663)
class ProviderUploadDocumentsHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  const ProviderUploadDocumentsHeader({
    super.key,
    this.title = 'Upload Documents',
    this.subtitle = 'Upload the required documents for verification.',
    this.onBack,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 36.0;
  static const double designTop = 56.0;
  static const double designLeft = 20.0;
  static const double designGap = 16.0;
  static const double contentWidth = 298.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: designWidth,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Icon layout: 36x36 circular white back button matching previous branding
              ProviderHeaderBackButton(
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
              ),

              // gap: 16px;
              const SizedBox(width: designGap),

              // 2. Content: Title + Subtitle
              Expanded(
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: ProviderTextStyles.profileDetailsHeaderTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        subtitle,
                        style: ProviderTextStyles.profileDetailsHeaderSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
