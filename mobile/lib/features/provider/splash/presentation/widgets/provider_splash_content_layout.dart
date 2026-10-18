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
    final double actualHeight = height ?? designHeight;
    final double horizontalLeft = ((actualWidth - 350.0) / 2).clamp(12.0, 20.0);

    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: actualWidth,
          height: actualHeight,
          child: Stack(
            children: [
              // Inner content layout branding:
              // width: 350; height: 122; left: 20px; angle: 0 deg; opacity: 1; gap: 20px;
              Positioned(
                top: 0.0,
                left: horizontalLeft,
                child: const ProviderBottomContent(),
              ),

              // Indicator bar:
              // width: 350; height: 27; left: 20px;
              // On design frame (273h): 273 - 64 - 27 = 182px from top (753px in screen canvas)
              Positioned(
                bottom: bottomPadding ?? 64.0,
                left: horizontalLeft,
                child: const ProviderIndicatorBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
