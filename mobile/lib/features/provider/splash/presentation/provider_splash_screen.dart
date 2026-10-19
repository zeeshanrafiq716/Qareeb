import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/provider/auth/presentation/phone_verification_screen.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_branding_header.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_splash_background.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_splash_content_layout.dart';
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
    // Auto-transition to PhoneVerificationScreen after optimal display (1.8 seconds)
    _timer = Timer(const Duration(milliseconds: 1800), _navigateToVerification);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      precacheImage(const AssetImage('assets/images/car1.png'), context);
      precacheImage(const AssetImage('assets/images/q.png'), context);
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
            // For desktop/web browser view, center in authentic 390x844 frame
            final bool isDesktopWeb = constraints.maxWidth > 500;
            final double containerWidth = isDesktopWeb ? designWidth : constraints.maxWidth;
            final double containerHeight = isDesktopWeb ? designHeight : constraints.maxHeight;

            final double bottomSafeArea = MediaQuery.of(context).padding.bottom;
            final double topSafeArea = MediaQuery.of(context).padding.top;

            // Content layout branding of splash screen geometry:
            // width: 390; height: 273; top: 571px; angle: 0 deg; opacity: 1;
            final double contentLayoutTop = isDesktopWeb
                ? ProviderSplashContentLayout.designTop // 571.0px
                : (containerHeight - ProviderSplashContentLayout.designHeight)
                    .clamp(topSafeArea + 120.0, containerHeight - 240.0);
            final double contentLayoutHeight = isDesktopWeb
                ? ProviderSplashContentLayout.designHeight // 273.0px
                : (containerHeight - contentLayoutTop);

            // Header top position adapting gracefully on mobile notches
            final double headerTop = isDesktopWeb
                ? 150.0
                : (containerHeight < 750
                    ? (topSafeArea + 16.0)
                    : (topSafeArea + 48.0).clamp(50.0, 150.0));

            final Widget screenContent = GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _navigateToVerification,
              child: Opacity(
                opacity: 1.0, // opacity: 1
                child: Transform.rotate(
                  angle: 0.0, // angle: 0 deg
                  child: Container(
                    width: containerWidth,
                    height: containerHeight,
                    color: ProviderColors.background,
                  child: Stack(
                    children: [
                      // 1. Car background image (car1.jpg 138KB fast load, falling back to car1.png)
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
                      // 2. Dual Gradient Overlay matching exact branding
                      const Positioned.fill(
                        child: CustomPaint(
                          painter: ProviderSplashBackgroundPainter(drawBase: false),
                        ),
                      ),
                      // 3. Header Branding layout (width: 226, height: 64)
                      Positioned(
                        top: headerTop,
                        left: (containerWidth - 226.0) / 2,
                        child: const ProviderBrandingHeader(),
                      ),
                      // 4. Content layout branding of splash screen:
                      //    width: 390; height: 273; top: 571px; angle: 0 deg; opacity: 1;
                      Positioned(
                        top: contentLayoutTop,
                        left: 0,
                        right: 0,
                        bottom: isDesktopWeb ? null : 0,
                        height: isDesktopWeb ? ProviderSplashContentLayout.designHeight : null,
                        child: ProviderSplashContentLayout(
                          width: containerWidth,
                          height: isDesktopWeb ? ProviderSplashContentLayout.designHeight : contentLayoutHeight,
                          bottomPadding: isDesktopWeb ? 64.0 : (bottomSafeArea + 24.0),
                        ),
                      ),
                    ],
                  ),
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
