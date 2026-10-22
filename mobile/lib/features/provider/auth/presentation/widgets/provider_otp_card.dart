import 'package:flutter/material.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_handle_bar.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_otp_content_layout.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';

/// Provider OTP Verification Card Widget (Screen 3 Card)
/// Implements exact Figma branding specifications:
///
/// card layout branding:
///   width: 390;
///   height: 420;
///   top: 424px;
///   border-top-left-radius: 28px;
///   border-top-right-radius: 28px;
///   background: #FFFFFF;
///   box-shadow: 0px -2px 12px 0px #00000014;
class ProviderOtpCard extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;

  const ProviderOtpCard({
    super.key,
    this.child,
    this.width,
    this.height,
  });

  static const double designWidth = 390.0;
  static const double designHeight = 420.0;
  static const double designTop = 424.0;
  static const double horizontalPadding = 20.0;

  @override
  Widget build(BuildContext context) {
    final double cardWidth = width ?? designWidth;
    final double cardHeight = height ?? designHeight;
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: const BoxDecoration(
            color: ProviderColors.cardBackground, // background: #FFFFFF
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28.0), // border-top-left-radius: 28px
              topRight: Radius.circular(28.0), // border-top-right-radius: 28px
            ),
            boxShadow: [
              BoxShadow(
                color: ProviderColors.cardShadow, // box-shadow: 0px -2px 12px 0px #00000014
                offset: Offset(0, -2),
                blurRadius: 12.0,
                spreadRadius: 0.0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28.0),
              topRight: Radius.circular(28.0),
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // 1. Fixed, Non-Scrollable Content Area with equal left-to-right padding (20px each)
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 24.0,
                      left: horizontalPadding,
                      right: horizontalPadding,
                      bottom: bottomSafeArea > 0 ? (bottomSafeArea + 24.0) : 26.0,
                    ),
                    child: child ?? const ProviderOtpContentLayout(),
                  ),
                ),

                // 2. Bar layout (Top Handle): width: 60; height: 4; top: 12px; background: #EFF0ED;
                const Positioned(
                  top: ProviderCardHandleBar.designTop, // 12.0px
                  child: IgnorePointer(
                    child: ProviderCardHandleBar(),
                  ),
                ),

                // 3. Pinned Bottom Indicator Bar: with safe-area offset so it never gets stuck in bottom
                Positioned(
                  bottom: bottomSafeArea > 0 ? (bottomSafeArea + 8.0) : 14.0,
                  left: 0,
                  right: 0,
                  child: const IgnorePointer(
                    child: ProviderCardBottomIndicator(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
