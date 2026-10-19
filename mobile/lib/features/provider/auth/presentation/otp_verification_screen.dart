import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_otp_card.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_branding_header.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_splash_background.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';

/// Provider OTP Verification Screen (Screen 3)
/// Appears when user taps "Continue" on PhoneVerificationScreen.
/// Implements exact Figma branding specifications:
///
/// card layout branding:
///   width: 390;
///   height: 371;
///   angle: 0 deg;
///   opacity: 1;
///   top: 473px;
///   border-top-left-radius: 28px;
///   border-top-right-radius: 28px;
///   background: #FFFFFF;
///   box-shadow: 0px -2px 12px 0px #00000014;
class OtpVerificationScreen extends StatelessWidget {
  final Widget? cardContent;

  const OtpVerificationScreen({
    super.key,
    this.cardContent,
  });

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

            // Card layout geometry:
            // width: 390, height: 371, top: 473px (in 390x844 frame, 473 + 371 = 844)
            final double cardTop = isDesktopWeb
                ? ProviderOtpCard.designTop
                : (containerHeight - ProviderOtpCard.designHeight)
                    .clamp(topSafeArea + 100.0, containerHeight - 150.0);
            final double cardHeight = isDesktopWeb
                ? ProviderOtpCard.designHeight
                : (containerHeight - cardTop);

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
                              // 1. Underneath Scene: Car background image (car1.jpg 138KB fast load, falling back to car1.png)
                              Positioned.fill(
                                child: Image.asset(
                                  'assets/images/car1.jpg',
                                  width: containerWidth,
                                  height: containerHeight,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  gaplessPlayback: true,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/car1.png',
                                      width: containerWidth,
                                      height: containerHeight,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.center,
                                      gaplessPlayback: true,
                                    );
                                  },
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

                      // 5. Back Navigation Button
                      Positioned(
                        top: isDesktopWeb ? 32.0 : (topSafeArea + 12.0),
                        left: 16.0,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).maybePop(),
                            borderRadius: BorderRadius.circular(24.0),
                            child: Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  width: 1.0,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18.0,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 6. New OTP White Bottom Card Layout
                      //    width: 390; height: 371; top: 473px;
                      //    border-top-left-radius: 28px; border-top-right-radius: 28px;
                      //    angle: 0 deg; opacity: 1; background: #FFFFFF;
                      //    box-shadow: 0px -2px 12px 0px #00000014;
                      Positioned(
                        top: cardTop,
                        left: 0,
                        right: 0,
                        bottom: isDesktopWeb ? null : 0,
                        height: isDesktopWeb ? ProviderOtpCard.designHeight : null,
                        child: ProviderOtpCard(
                          width: containerWidth,
                          height: isDesktopWeb ? ProviderOtpCard.designHeight : cardHeight,
                          child: cardContent,
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
                color: const Color(0xFF141C1A),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Container(
                    width: designWidth,
                    height: designHeight,
                    margin: const EdgeInsets.symmetric(vertical: 24.0),
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
