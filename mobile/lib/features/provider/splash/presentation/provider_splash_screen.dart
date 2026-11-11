import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';
import 'package:mobile/features/provider/auth/presentation/admin_approval_screen.dart';
import 'package:mobile/features/provider/auth/presentation/phone_verification_screen.dart';
import 'package:mobile/features/provider/auth/presentation/provider_blocked_screen.dart';
import 'package:mobile/features/provider/home/presentation/provider_home_screen.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_animated_language_toggle.dart';
import 'package:mobile/services/backend_service.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_bottom_content.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_branding_header.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_indicator_bar.dart';
import 'package:mobile/features/provider/splash/presentation/widgets/provider_splash_background.dart';

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
    _startSplashFlow();
  }

  Future<void> _startSplashFlow() async {
    // 1. Load persisted registration & session state
    await ProviderRegistrationStore.instance.loadFromPrefs();

    // 2. If token exists, sync status from backend in background
    _syncStatusWithBackend();

    // 3. Auto-transition after branding animation completes (2.8s)
    _timer = Timer(const Duration(milliseconds: 2800), _navigateToNextScreen);
  }

  Future<void> _syncStatusWithBackend() async {
    try {
      final token = ProviderRegistrationStore.instance.data.authToken;
      if (token != null && token.isNotEmpty) {
        final backend = BackendService(ApiClient());
        final accountState = await backend.checkProviderAccountState();

        if (accountState.status == ProviderAccountStatus.deleted) {
          await ProviderRegistrationStore.instance.clear();
          return;
        }

        if (accountState.status == ProviderAccountStatus.blocked) {
          ProviderRegistrationStore.instance.update(
            (data) => data.copyWith(
              status: 'BLOCKED',
              isOnline: false,
            ),
          );
          return;
        }

        final serverStatus = accountState.rawStatus;
        if (accountState.profile != null && accountState.profile!.isNotEmpty) {
          ProviderRegistrationStore.instance.updateFromBackendProfile(accountState.profile!);
        }
        if (serverStatus.isNotEmpty) {
          final isApproved = accountState.status == ProviderAccountStatus.approved;
          final isPending = accountState.status == ProviderAccountStatus.pendingVerification;
          ProviderRegistrationStore.instance.update(
            (data) => data.copyWith(
              status: serverStatus,
              isOnboardingCompleted: isApproved || isPending || data.isOnboardingCompleted,
            ),
          );
        }
      }
    } catch (_) {
      // Offline fallback: keep local persisted status
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      precacheImage(const AssetImage('assets/images/truk.png'), context);
    }
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    _timer?.cancel();

    final data = ProviderRegistrationStore.instance.data;
    final Widget destination;

    // Check account status and route appropriately
    if (data.isBlocked || data.status == 'BLOCKED') {
      destination = const ProviderBlockedScreen();
    } else if (data.status == 'APPROVED') {
      destination = const ProviderHomeScreen();
    } else if (data.status == 'SUSPENDED') {
      destination = const AdminApprovalScreen(isSuspended: true);
    } else if (data.isOnboardingCompleted || data.status == 'PENDING_VERIFICATION') {
      destination = const AdminApprovalScreen();
    } else {
      destination = const PhoneVerificationScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => destination,
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
            final double toggleTop = topSafeArea > 0 ? (topSafeArea + 16.0) : 48.0;
            final double headerTop = isDesktopWeb
                ? 120.0
                : (toggleTop + 36.0 + 16.0).clamp(90.0, 140.0);

            // Bottom content layout: starts below the truck fade around 560px in 844h frame
            final double bottomContentTop = isDesktopWeb
                ? 560.0
                : (containerHeight * (560.0 / designHeight)).clamp(headerTop + 320.0, containerHeight - 215.0);

            final Widget screenContent = GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _navigateToNextScreen,
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

                    // 2. Full-bleed Exact Artwork (truk.png)
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

                    // 3. Top Centered Animated Language Toggle
                    Positioned(
                      top: toggleTop,
                      left: 0,
                      right: 0,
                      child: const Center(
                        child: ProviderAnimatedLanguageToggle(),
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
