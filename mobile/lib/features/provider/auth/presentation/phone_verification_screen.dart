import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_animated_language_toggle.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_auth_card.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_branding_header.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_splash_background.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';

/// Provider Phone Number Verification Screen (2nd Screen)
/// Implements exact branding specifications:
///
/// phone number verification screen layout:
///   width: 390;
///   height: 844;
///   angle: 0 deg;
///   opacity: 1;
///   background: #FFFFFF;
///   background: #FFFFFF1A;
///   backdrop-filter: blur(8px);
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
class PhoneVerificationScreen extends StatelessWidget {
  const PhoneVerificationScreen({super.key});

  static const double designWidth = 390.0;
  static const double designHeight = 844.0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktopWeb = constraints.maxWidth > 500;
            final double containerWidth = isDesktopWeb ? designWidth : constraints.maxWidth;
            final double containerHeight = isDesktopWeb ? designHeight : constraints.maxHeight;

            final double topSafeArea = MediaQuery.of(context).padding.top;
            final double toggleTop = topSafeArea > 0 ? (topSafeArea + 16.0) : 48.0;
            final double headerTop = isDesktopWeb
                ? 120.0
                : (toggleTop + 36.0 + 16.0).clamp(90.0, 140.0);

            // Card layout geometry:
            // width: 390, height: 534, top: 310px (in 390x844 frame, 310 + 534 = 844)
            final double cardTop = isDesktopWeb
                ? ProviderAuthCard.designTop
                : (containerHeight - ProviderAuthCard.designHeight)
                    .clamp(topSafeArea + 80.0, containerHeight - 200.0);
            final double cardHeight = isDesktopWeb
                ? ProviderAuthCard.designHeight
                : (containerHeight - cardTop);

            final Widget screenContent = Opacity(
              opacity: 1.0, // opacity: 1
              child: Transform.rotate(
                angle: 0.0, // angle: 0 deg
                child: Container(
                  width: containerWidth,
                  height: containerHeight,
                  color: Colors.white,
                  child: Stack(
                    children: [
                      // Underneath Scene: Splash screen background (truk.png + branding header)
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: Stack(
                            children: [
                              // 1. Base White Canvas
                              Positioned.fill(
                                child: Container(color: Colors.white),
                              ),

                              // 2. Full-bleed Exact Splash Artwork (truk.png)
                              //    Contains top purple gradient glow, recovery flatbed truck, and bottom white fade
                              Positioned.fill(
                                child: Image.asset(
                                  'assets/images/truk.png',
                                  width: containerWidth,
                                  height: containerHeight,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                  gaplessPlayback: true,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const CustomPaint(
                                      painter: ProviderSplashBrandingPainter(),
                                    );
                                  },
                                ),
                              ),

                              // 3. Header Branding in background: QAREEB • / Service always near you
                              Positioned(
                                top: headerTop,
                                left: 0,
                                right: 0,
                                child: const Center(
                                  child: ProviderBrandingHeader(),
                                ),
                              ),

                              // 4. Frosted Glass Blur & Overlay:
                              //    background: #FFFFFF1A;
                              //    backdrop-filter: blur(8px);
                              Positioned.fill(
                                child: ClipRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 2.0,
                                      sigmaY: 2.0,
                                    ),
                                    child: Container(
                                      color: const Color(0x1AFFFFFF), // background: #FFFFFF1A
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 5. White Bottom Card Layout
                      //    width: 390; height: 534; top: 310px;
                      //    border-top-left-radius: 28px; border-top-right-radius: 28px;
                      //    angle: 0 deg; opacity: 1; background: #FFFFFF;
                      //    box-shadow: 0px -2px 12px 0px #00000014;
                      Positioned(
                        top: cardTop,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ProviderAuthCard(
                          width: containerWidth,
                          height: cardHeight,
                        ),
                      ),

                      // 6. Centered Animated Language Toggle
                      Positioned(
                        top: toggleTop,
                        left: 0,
                        right: 0,
                        child: const Center(
                          child: ProviderAnimatedLanguageToggle(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            if (isDesktopWeb) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFF3F4F6),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Container(
                    width: designWidth,
                    height: designHeight,
                    margin: const EdgeInsets.symmetric(vertical: 24.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(44),
                      border: Border.all(
                        color: const Color(0xFF8B53FE).withValues(alpha: 0.35),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 36,
                          spreadRadius: 6,
                        ),
                        BoxShadow(
                          color: const Color(0xFF8B53FE).withValues(alpha: 0.12),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(42),
                      child: screenContent,
                    ),
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
