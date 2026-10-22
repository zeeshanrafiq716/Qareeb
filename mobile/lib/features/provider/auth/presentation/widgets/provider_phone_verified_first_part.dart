import 'package:flutter/material.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_phone_verified_success_badge.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_verification_success_heading.dart';

/// Provider Phone Verified 1st Content Part Layout Widget
/// Implements exact Figma branding specifications:
///
/// 1st content part layout:
///   width: 350;
///   height: 151;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 20px;
///
/// Contains:
///   1. ProviderPhoneVerifiedSuccessBadge (width: 174, height: 80)
///   Gap: 20px
///   2. ProviderVerificationSuccessHeading (width: 350, height: 51, gap: 12px)
///   Total height = 80 + 20 + 51 = 151px!
class ProviderPhoneVerifiedFirstPart extends StatelessWidget {
  final Widget? child;
  final List<Widget>? children;

  const ProviderPhoneVerifiedFirstPart({
    super.key,
    this.child,
    this.children,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 151.0;
  static const double designGap = 20.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: double.infinity,
          child: child ??
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildSeparatedChildren(),
              ),
        ),
      ),
    );
  }

  List<Widget> _buildSeparatedChildren() {
    final list = children ??
        const [
          ProviderPhoneVerifiedSuccessBadge(),
          ProviderVerificationSuccessHeading(),
        ];

    final List<Widget> items = [];
    for (int i = 0; i < list.length; i++) {
      items.add(list[i]);
      if (i < list.length - 1) {
        items.add(const SizedBox(height: designGap));
      }
    }
    return items;
  }
}
