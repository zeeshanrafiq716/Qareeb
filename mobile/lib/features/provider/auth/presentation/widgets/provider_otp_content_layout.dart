import 'package:flutter/material.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_handle_bar.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_change_phone_button.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_otp_heading.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_otp_input_row.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_otp_timer_row.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_verify_code_button.dart';

/// Provider OTP Card Content Layout Branding Widget
/// Implements exact Figma branding specifications:
///
/// content layout branding:
///   width: 390;
///   height: 359;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 40px;
///   top: 12px;
///   padding-right: 20px;
///   padding-left: 20px;
///
/// inner content layout:
///   width: 350;
///   height: 295;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 20px;
class ProviderOtpContentLayout extends StatelessWidget {
  final Widget? innerContent;
  final List<Widget>? children;
  final bool showHandleBar;

  const ProviderOtpContentLayout({
    super.key,
    this.innerContent,
    this.children,
    this.showHandleBar = false,
  });

  static const double designWidth = 390.0;
  static const double designHeight = 359.0;
  static const double designTop = 12.0;
  static const double designGap = 40.0;
  static const double horizontalPadding = 20.0;

  static const double innerWidth = 350.0;
  static const double innerHeight = 295.0;
  static const double innerGap = 20.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: designWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showHandleBar) ...[
                  // 1. Top grab handle pill bar: width: 60; height: 4; border-radius: 60px; background: #EFF0ED;
                  const ProviderCardHandleBar(),

                  // Gap: 40px
                  const SizedBox(height: designGap),
                ],

                // 2. inner content layout: width: 350; height: 295; gap: 20px;
                innerContent ??
                    ProviderOtpInnerContentLayout(
                      children: children,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Provider OTP Inner Content Layout Widget
/// Implements exact Figma branding specifications:
///
/// inner content layout:
///   width: 350;
///   height: 295;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 20px;
class ProviderOtpInnerContentLayout extends StatelessWidget {
  final List<Widget>? children;

  const ProviderOtpInnerContentLayout({
    super.key,
    this.children,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 295.0;
  static const double designGap = 20.0;

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
            children: _buildSeparatedChildren(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSeparatedChildren() {
    final List<Widget> list = children ??
        const [
          ProviderOtpHeading(),
          ProviderOtpInputRow(),
          ProviderOtpTimerRow(),
          ProviderVerifyCodeButton(),
          ProviderChangePhoneButton(),
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
