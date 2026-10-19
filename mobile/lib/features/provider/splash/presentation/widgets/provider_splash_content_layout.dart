import 'package:flutter/material.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_bottom_content.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_indicator_bar.dart';

/// Provider Splash Screen Content Layout Branding Widget
/// Implements exact Figma branding specifications:
///
/// content layout branding of splash screen :
///   width: 390;
///   height: 273;
///   top: 571px;
///   angle: 0 deg;
///   opacity: 1;
///
/// inner content layout branding:
///   width: 350;
///   height: 122;
///   left: 20px;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 20px;
///
/// indicator bar:
///   width: 350;
///   height: 27;
///   left: 20px;
///   top: 753px (182px relative to container);
///   bottom: 64px (273 - 182 - 27);
class ProviderSplashContentLayout extends StatelessWidget {
  final double? width;
  final double? height;
  final double? bottomPadding;

  const ProviderSplashContentLayout({
    super.key,
    this.width,
    this.height,
    this.bottomPadding,
  });

  static const double designWidth = 390.0;
  static const double designHeight = 273.0;
  static const double designTop = 571.0;

  @override
  Widget build(BuildContext context) {
    final double actualWidth = width ?? designWidth;
    final double horizontalPadding = ((actualWidth - 330.0) / 2).clamp(24.0, 32.0);

    return SizedBox(
      width: actualWidth,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inner content: Ready to respond / Built to deliver
            const ProviderBottomContent(),
            const SizedBox(height: 36.0),
            // Centered Indicator bar: track #E5E7EB, pill #8B53FE
            const Center(
              child: ProviderIndicatorBar(),
            ),
            SizedBox(height: bottomPadding ?? 32.0),
          ],
        ),
      ),
    );
  }
}
