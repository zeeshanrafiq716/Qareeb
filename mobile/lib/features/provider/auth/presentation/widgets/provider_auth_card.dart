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
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: Container(
          width: width ?? designWidth,
          height: height ?? designHeight,
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
                // 1. Bar layout (Top Handle): width: 60; height: 4; top: 12px; background: #EFF0ED;
                const Positioned(
                  top: ProviderCardHandleBar.designTop, // 12.0px
                  child: ProviderCardHandleBar(),
                ),

                // 2. Inner Content Layout: width: 350; height: 435.22; gap: 40px;
                Positioned(
                  top: ProviderCardContentLayout.designTop, // 24.0px
                  child: child ?? const ProviderCardContentLayout(),
                ),

                // 3. Bottom Indicator Bar: width: 134; height: 4; border-radius: 100px; background: #1C2926;
                const Positioned(
                  bottom: 8.0,
                  left: 0,
                  right: 0,
                  child: ProviderCardBottomIndicator(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
