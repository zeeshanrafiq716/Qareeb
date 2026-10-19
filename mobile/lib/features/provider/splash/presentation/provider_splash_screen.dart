import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/provider/auth/presentation/phone_verification_screen.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_bottom_content.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_branding_header.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_indicator_bar.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';

/// Provider Splash Screen
/// Implemented strictly according to manual branding specifications:
/// - width: 390
/// - height: 844
/// - angle: 0 deg
/// - opacity: 1
/// - background: dual linear-gradient (Top mint glow + Bottom dark slate fade)
///
/// Automatically transitions to PhoneVerificationScreen when ready.
class ProviderSplashScreen extends StatefulWidget {
  const ProviderSplashScreen({super.key});

  static const double designWidth = 390.0;
  static const double designHeight = 844.0;

  @override
  State<ProviderSplashScreen> createState() => _ProviderSplashScreenState();
}

class _ProviderSplashScreenState extends State<ProviderSplashScreen> {
  static const double designWidth = 390.0;
  static const double designHeight = 844.0;

  Timer? _timer;
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    // Auto-transition to PhoneVerificationScreen after display (3.2 seconds)
    _timer = Timer(const Duration(milliseconds: 3200), _navigateToVerification);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      precacheImage(const AssetImage('assets/images/black.png'), context);
    }
  }

  void _navigateToVerification() {
    if (!mounted) return;
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const PhoneVerificationScreen(),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
            // For desktop/web browser view, center in authentic 390x844 frame
            final bool isDesktopWeb = constraints.maxWidth > 500;
            final double containerWidth = isDesktopWeb ? designWidth : constraints.maxWidth;
            final double containerHeight = isDesktopWeb ? designHeight : constraints.maxHeight;

            final double bottomSafeArea = MediaQuery.of(context).padding.bottom;
            final double topSafeArea = MediaQuery.of(context).padding.top;

            // Proportional scaling for mobile screens based on design frame (390 x 844)
            final double scaleX = containerWidth / designWidth;
            final double scaleY = containerHeight / designHeight;

            // Exact img alignment branding specifications:
            // width: 349; height: 473; angle: 0 deg; opacity: 1; top: 150px; left: 41px;
            final double imgLeft = isDesktopWeb ? 41.0 : (41.0 * scaleX);
            final double imgTop = isDesktopWeb ? 150.0 : (150.0 * scaleY);
            final double imgWidth = isDesktopWeb ? 349.0 : (349.0 * scaleX);
            final double imgHeight = isDesktopWeb ? 473.0 : (473.0 * scaleY);

            final double headerTop = isDesktopWeb
                ? 130.0
                : (topSafeArea + 36.0).clamp(44.0, 130.0);

            // Bottom content layout top at 571px in 844h design frame
            final double bottomContentTop = isDesktopWeb
                ? 571.0
                : (imgTop + imgHeight - (55.0 * scaleY)).clamp(headerTop + 240.0, containerHeight - 220.0);

            final Widget screenContent = GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _navigateToVerification,
              child: Container(
                width: containerWidth,
                height: containerHeight,
                color: Colors.white,
                child: Stack(
                  children: [
                    // 1. Base White Canvas
                    Positioned.fill(
                      child: Container(color: Colors.white),
                    ),

                    // 2. Soft Purple/Lavender Top Gradient Glow
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: containerHeight * 0.42,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 0.40, 0.75, 1.0],
                            colors: [
                              Color(0xFFDECFFC), // soft lavender glow
                              Color(0xFFEADBFE), // mid lavender glow
                              Color(0x66F5EFFF), // subtle fade
                              Color(0x00FFFFFF), // blends seamlessly into white
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 3. Exact user specification:
                    //    background: #FFFFFF1A;
                    //    backdrop-filter: blur(200.5124053955078px)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: containerHeight * 0.45,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 200.5124053955078,
                            sigmaY: 200.5124053955078,
                          ),
                          child: Container(
                            color: const Color(0x1AFFFFFF), // background: #FFFFFF1A
                          ),
                        ),
                      ),
                    ),

                    // 4. Middle Car Image (black.png)
                    //    img alignment:
                    //    width: 349; height: 473; angle: 0 deg; opacity: 1; top: 150px; left: 41px;
                    Positioned(
                      top: imgTop,
                      left: imgLeft,
                      width: imgWidth,
                      height: imgHeight,
                      child: Opacity(
                        opacity: 1.0, // opacity: 1
                        child: Transform.rotate(
                          angle: 0.0, // angle: 0 deg
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.0, 0.65, 0.88, 1.0],
                                colors: [
                                  Colors.white,
                                  Colors.white,
                                  Colors.white54,
                                  Colors.transparent,
                                ],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.dstIn,
                            child: Image.asset(
                              'assets/images/black.png',
                              width: imgWidth,
                              height: imgHeight,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              gaplessPlayback: true,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 5. Centered Branding Header: QAREEB • / Service always near you
                    Positioned(
                      top: headerTop,
                      left: 0,
                      right: 0,
                      child: const Center(
                        child: ProviderBrandingHeader(),
                      ),
                    ),

                    // 6. Bottom Text Content:
                    //    "Ready to respond\nBuilt to deliver"
                    //    "Manage service requests reach customers\nand stay connected in real time."
                    Positioned(
                      top: bottomContentTop,
                      left: 28.0,
                      right: 28.0,
                      child: const ProviderBottomContent(),
                    ),

                    // 7. Centered Indicator Loader:
                    //    Track: #E5E7EB, Pill: #8B53FE, "Getting things ready..."
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: isDesktopWeb ? 46.0 : (bottomSafeArea + 32.0),
                      child: const Center(
                        child: ProviderIndicatorBar(),
                      ),
                    ),

                    // 8. iOS Home Indicator Bar
                    Positioned(
                      left: (containerWidth - 134.0) / 2,
                      bottom: isDesktopWeb ? 12.0 : (bottomSafeArea > 0 ? (bottomSafeArea / 2) : 10.0),
                      child: Container(
                        width: 134.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C2926),
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                    ),
                  ],
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
