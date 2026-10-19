import 'package:flutter/material.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_content_layout.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_handle_bar.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_scroll_behavior.dart';
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
  static const double designHeight = 471.0;
  static const double designTop = 373.0;

  @override
  Widget build(BuildContext context) {
    final double cardWidth = width ?? designWidth;
    final double cardHeight = height ?? designHeight;

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
                // 1. Frictionless Scrollable Content Area: easily scrollable on touch, mouse, trackpad
                Positioned.fill(
                  child: ScrollConfiguration(
                    behavior: const ProviderCardScrollBehavior(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          minHeight: cardHeight > 80.0 ? cardHeight - 80.0 : 0.0,
                        ),
                        color: Colors.transparent,
                        padding: const EdgeInsets.only(
                          top: 26.0,
                          bottom: 24.0, // comfortable user-friendly clearance
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: SizedBox(
                                width: ProviderCardContentLayout.designWidth,
                                child: child ?? const ProviderCardContentLayout(),
                              ),
                            ),
                            const SizedBox(height: 24.0),
                            const ProviderCardBottomIndicator(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Bar layout (Top Handle): width: 60; height: 4; top: 12px; background: #EFF0ED;
                // Pinned at top; IgnorePointer ensures drags on the handle bar smoothly scroll the card
                const Positioned(
                  top: ProviderCardHandleBar.designTop, // 12.0px
                  child: IgnorePointer(
                    child: ProviderCardHandleBar(),
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
