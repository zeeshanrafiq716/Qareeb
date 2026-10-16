import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_branding_header.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_splash_background.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';

/// Provider Phone Number Verification Screen
/// Implements exact manual branding specifications:
///
/// phone number verification screen layout:
///   width: 390;
///   height: 844;
///   angle: 0 deg;
///   opacity: 1;
///   background: #FFFFFF;
///   background: #1F292829;
///   backdrop-filter: blur(8px);
class PhoneVerificationScreen extends StatelessWidget {
  const PhoneVerificationScreen({super.key});

  static const double designWidth = 390.0;
  static const double designHeight = 844.0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: ProviderColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: ProviderColors.background,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktopWeb = constraints.maxWidth > 500;
            final double containerWidth = isDesktopWeb ? designWidth : constraints.maxWidth;
            final double containerHeight = isDesktopWeb ? designHeight : constraints.maxHeight;

            final double topSafeArea = MediaQuery.of(context).padding.top;
            final double headerTop = isDesktopWeb
                ? 150.0
                : (containerHeight < 750
                    ? (topSafeArea + 16.0)
                    : (topSafeArea + 48.0).clamp(50.0, 150.0));

            final Widget screenContent = Opacity(
              opacity: 1.0, // opacity: 1
              child: Transform.rotate(
                angle: 0.0, // angle: 0 deg
                child: Container(
                  width: containerWidth,
                  height: containerHeight,
                  color: ProviderColors.background,
                  child: Stack(
                    children: [
                      // RepaintBoundary isolates and GPU-caches the backdrop filter for 60/120fps buttery smoothness
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: Stack(
                            children: [
                              // 1. Underneath Scene: Car background image (car1.png)
                              Positioned.fill(
                                child: Image.asset(
                                  'assets/images/car1.png',
                                  width: containerWidth,
                                  height: containerHeight,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                ),
                              ),

                              // 2. Dual Gradient Overlay
                              const Positioned.fill(
                                child: CustomPaint(
                                  painter: ProviderSplashBackgroundPainter(drawBase: false),
                                ),
                              ),

                              // 3. Header Branding in background
                              Positioned(
                                top: headerTop,
                                left: (containerWidth - 226.0) / 2,
                                child: const ProviderBrandingHeader(),
                              ),

                              // 4. Frosted Glass Blur (backdrop-filter: blur(8px))
                              //    and Tint Overlay (background: #1F292829)
                              Positioned.fill(
                                child: ClipRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 8.0,
                                      sigmaY: 8.0,
                                    ),
                                    child: Container(
                                      color: ProviderColors.backdropTint, // #1F292829
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Ready for next manual step (e.g. white bottom card layout)
                    ],
                  ),
                ),
              ),
            );

            if (isDesktopWeb) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFF141C1A),
                alignment: Alignment.center,
                child: Container(
                  width: designWidth,
                  height: designHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: ProviderColors.mintGlow.withValues(alpha: 0.25),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.60),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: ProviderColors.mintGlow.withValues(alpha: 0.08),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(38),
                    child: screenContent,
                  ),
                ),
              );
            }

            return screenContent;
          },
        ),
      ),
    );
  }
}
