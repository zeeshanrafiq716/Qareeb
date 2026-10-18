import 'package:flutter/material.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';

/// Provider Card Top Handle Bar Widget
/// Implements exact Figma branding specifications:
///
/// bar layout:
///   width: 60;
///   height: 4;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 60px;
///   background: #EFF0ED;
class ProviderCardHandleBar extends StatelessWidget {
  const ProviderCardHandleBar({super.key});

  static const double designWidth = 60.0;
  static const double designHeight = 4.0;
  static const double designTop = 12.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: Container(
          width: designWidth,
          height: designHeight,
          decoration: BoxDecoration(
            color: ProviderColors.cardHandleBar, // background: #EFF0ED
            borderRadius: BorderRadius.circular(60.0), // border-radius: 60px
          ),
        ),
      ),
    );
  }
}
