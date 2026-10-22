import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_animated_language_toggle.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_header_back_button.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Admin Approval Screen Header Widget
/// Implements exact Figma branding specifications following previous screen headers:
///
/// header layout:
///   width: 350;
///   height: 36;
///   top: 56px;
///   left: 20px;
///   gap: 14px;
///   angle: 0 deg;
///   opacity: 1;
///
/// icon layout:
///   width: 36;
///   height: 36;
///
/// content: Admin Approval
///   width: 298;
///   font-family: Inter; font-weight: 500 (Medium); font-size: 16px;
///   line-height: 24px; color: #1C2926;
class ProviderAdminApprovalHeader extends StatelessWidget {
  final String? title;
  final VoidCallback? onBack;

  const ProviderAdminApprovalHeader({
    super.key,
    this.title,
    this.onBack,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 36.0;
  static const double designTop = 56.0;
  static const double designLeft = 20.0;
  static const double designGap = 12.0;

  @override
  Widget build(BuildContext context) {
    final String displayTitle = (title != null && title!.isNotEmpty)
        ? (context.isArabic ? context.auto(title) : title!)
        : context.l10n.adminApprovalTitle;

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
              // 1. Icon layout: 36x36 circular white back button matching previous branding
              ProviderHeaderBackButton(
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
              ),

              // gap: 12px
              const SizedBox(width: designGap),

              // 2. Content: Admin Approval / موافقة الإدارة
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    displayTitle,
                    style: ProviderTextStyles.headerTitle,
                    maxLines: 1,
                  ),
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
