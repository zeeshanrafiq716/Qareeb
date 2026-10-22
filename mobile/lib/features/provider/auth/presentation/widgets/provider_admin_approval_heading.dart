import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Admin Approval Screen Heading Content Layout Widget
/// Implements exact Figma branding specifications:
///
/// content layout:
///   width: 350;
///   height: 51;
///   gap: 12px;
///   angle: 0 deg;
///   opacity: 1;
///
/// content: Admin Approval pending
///   width: 350;
///   height: 15;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 600;
///   font-style: Semi Bold;
///   font-size: 20px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 24px;
///   letter-spacing: 0px;
///   text-align: center;
///   background: #1C2926;
///
/// content: Your account is submitted our team \nis reviewing it.
///   width: 350;
///   height: 24;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 400;
///   font-style: Regular;
///   font-size: 12px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 100%;
///   letter-spacing: 0px;
///   text-align: center;
///   background: #566663;
class ProviderAdminApprovalHeading extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const ProviderAdminApprovalHeading({
    super.key,
    this.title,
    this.subtitle,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 51.0;
  static const double designGap = 12.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: designWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title: "Admin Approval pending" (Inter 600 SemiBold 20px line-height 24px #1C2926)
              SizedBox(
                width: designWidth,
                child: Text(
                  title ?? context.l10n.adminApprovalPendingTitle,
                  textAlign: TextAlign.center,
                  style: ProviderTextStyles.adminApprovalPendingTitle,
                ),
              ),

              // Gap: 12px
              const SizedBox(height: designGap),

              // Subtitle: "Your account is submitted our team \nis reviewing it." (Inter 400 Regular 12px line-height 100% #566663)
              SizedBox(
                width: designWidth,
                child: Text(
                  subtitle ?? context.l10n.adminApprovalPendingSubtitle,
                  textAlign: TextAlign.center,
                  style: ProviderTextStyles.adminApprovalPendingSubtitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
