import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/provider/auth/presentation/phone_verification_screen.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_bottom_content.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_branding_header.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_indicator_bar.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_splash_background.dart';
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

  @override
  void initState() {
    super.initState();
    // Auto-transition to PhoneVerificationScreen after splash display (2.8 seconds)
    _timer = Timer(const Duration(milliseconds: 2800), _navigateToVerification);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache assets in GPU memory for instant, zero-jank rendering
    precacheImage(const AssetImage('assets/images/car1.png'), context);
    precacheImage(const AssetImage('assets/images/q.png'), context);
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
        transitionDuration: const Duration(milliseconds: 650),
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

            // Dynamic bottom offsets so content never sticks to the bottom on real mobile screens:
            // Desktop web stays 100% exact to reference (844 - 753 - 27 = 64px from bottom)
            final double indicatorBottom = isDesktopWeb
                ? (designHeight - 753.0 - 27.0) // 64.0px
                : (bottomSafeArea + 24.0);

            // Bottom text sits above indicator bar (844 - 570 - 122 = 152px from bottom on web)
            final double bottomTextBottom = isDesktopWeb
                ? (designHeight - 570.0 - 122.0) // 152.0px
                : (indicatorBottom + 27.0 + (containerHeight < 750 ? 20.0 : 36.0));

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
                      // 1. Car background image (car1.png)
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/car1.png',
                          width: containerWidth,
                          height: containerHeight,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
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
                      // 4. Bottom text layout: (width: 350, height: 122)
                      Positioned(
                        bottom: bottomTextBottom,
                        left: isDesktopWeb ? 20.0 : ((containerWidth - 350.0) / 2).clamp(12.0, 24.0),
                        right: isDesktopWeb ? 20.0 : null,
                        child: const ProviderBottomContent(),
                      ),
                      // 5. Indicator bar: (width: 350, height: 27)
                      Positioned(
                        bottom: indicatorBottom,
                        left: isDesktopWeb ? 20.0 : ((containerWidth - 350.0) / 2).clamp(12.0, 24.0),
                        right: isDesktopWeb ? 20.0 : null,
                        child: const ProviderIndicatorBar(),
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
