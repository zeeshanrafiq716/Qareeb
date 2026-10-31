import 'package:flutter/material.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_content_layout.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_handle_bar.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';

/// Provider Phone Verification Card Widget
/// Implements exact Figma branding specifications:
///
/// card layout:
///   width: 390;
///   height: 471;
///   top: 373px;
///   border-top-left-radius: 28px;
///   border-top-right-radius: 28px;
///   angle: 0 deg;
///   opacity: 1;
///   background: #FFFFFF;
///   box-shadow: 0px -2px 12px 0px #00000014;
///
/// Features frictionless, ultra-easy drag scrolling:
/// - Supports mouse click-and-drag, touch, and trackpad gestures via [ProviderCardScrollBehavior]
/// - Springy [BouncingScrollPhysics] with [AlwaysScrollableScrollPhysics]
/// - Full-width transparent hit-test backdrop so dragging anywhere on the card scrolls smoothly
/// - Pinned top grab handle and bottom indicator wrapped with [IgnorePointer]
class ProviderAuthCard extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;

  const ProviderAuthCard({
    super.key,
    this.child,
    this.width,
    this.height,
  });

  static const double designWidth = 390.0;
  static const double designHeight = 560.0;
  static const double designTop = 284.0;
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
                // 1. Content Area with equal left-to-right padding and clamping scroll
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: 24.0,
                      left: horizontalPadding,
                      right: horizontalPadding,
                      bottom: bottomSafeArea > 0 ? (bottomSafeArea + 24.0) : 26.0,
                    ),
                    child: child ?? const ProviderCardContentLayout(),
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
