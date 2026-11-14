import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/security/biometric_helper.dart';
import '../../../providers/backend_provider.dart';
import '../../customer/auth/data/customer_auth_store.dart';
import '../../customer/auth/presentation/customer_signup_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../provider/auth/data/provider_registration_state.dart';
import '../../provider/splash/presentation/provider_splash_screen.dart';
import 'widgets/animated_route_widget.dart';
import 'widgets/branding_header_widget.dart';
import 'widgets/loading_indicator_widget.dart';
import 'widgets/map_background_painter.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _routeAnimController;
  late AnimationController _loadingProgressController;

  Timer? _navTimer;
  bool _requiresBiometricUnlock = false;

  @override
  void initState() {
    super.initState();

    // 1. Route drawing & vehicle reveal animation
    _routeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    // 2. Continuous smooth loading progress controller
    _loadingProgressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // 3. Perform backend health & category sync in background
    _syncWithBackend();

    // 4. Ensure provider mode goes strictly to ProviderSplashScreen without showing customer splash
    _checkModeAndScheduleNavigation();
  }

  Future<void> _checkModeAndScheduleNavigation() async {
    final mode = await ProviderRegistrationStore.instance.getActiveAppMode();
    if (!mounted) return;

    if (mode == 'provider') {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const ProviderSplashScreen(),
          transitionDuration: Duration.zero,
        ),
      );
      return;
    }

    // Check if customer has already signed up
    final isSignedUp = await CustomerAuthStore.instance.isSignedUp();
    if (!mounted) return;

    if (isSignedUp) {
      final prefs = await SharedPreferences.getInstance();
      final biometricEnabled = prefs.getBool('customer_biometric_login') ?? false;

      if (biometricEnabled) {
        _navTimer = Timer(const Duration(milliseconds: 1600), () async {
          if (!mounted) return;
          final tr = ref.read(translationsProvider);
          final authenticated = await BiometricHelper.authenticate(
            context: context,
            localizedReason: tr.isArabic
                ? 'يرجى تأكيد الهوية بالبصمة لفتح تطبيق زشو'
                : 'Authenticate with Face ID or fingerprint to unlock Zesho',
          );
          if (!mounted) return;
          if (authenticated) {
            _navigateToHome();
          } else {
            setState(() {
              _requiresBiometricUnlock = true;
            });
          }
        });
      } else {
        _navTimer = Timer(const Duration(milliseconds: 1800), _navigateToHome);
      }
    } else {
      _navTimer = Timer(const Duration(milliseconds: 1800), _navigateToCustomerSignup);
    }
  }

  void _navigateToCustomerSignup() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const CustomerSignupScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _navigateToHome() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const HomeScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _syncWithBackend() async {
    try {
      final backend = ref.read(backendServiceProvider);

      // Check server health
      final health = await backend.checkHealth();
      if (health.isHealthy) {
        await backend.getCategories();
      }
    } catch (_) {
      // Graceful fallback keeping exact design message
    }
  }

  @override
  void deactivate() {
    _routeAnimController.stop();
    _loadingProgressController.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _routeAnimController.stop();
    _loadingProgressController.stop();
    _routeAnimController.dispose();
    _loadingProgressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // If screen width > 500 (e.g. Web Desktop browser), center in an authentic iPhone frame (390 x 844)
            final bool isDesktopWeb = constraints.maxWidth > 500;
            final double containerWidth = isDesktopWeb ? 390.0 : constraints.maxWidth;
            final double containerHeight = isDesktopWeb ? 844.0 : constraints.maxHeight;

            final splashContent = GestureDetector(
              onTap: _navigateToHome,
              behavior: HitTestBehavior.opaque,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isDesktopWeb ? 40.0 : 0.0),
                child: Container(
                  width: containerWidth,
                  height: containerHeight,
                  color: Colors.white,
                child: Stack(
                  children: [
                    // 1. Procedural Voronoi Road Network Background with Dual Gradients
                    Positioned.fill(
                      child: CustomPaint(
                        painter: MapBackgroundPainter(),
                      ),
                    ),

                    // 2. Animated Polyline Route, User Pin, and Destination Vehicle
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _routeAnimController,
                        builder: (context, _) {
                          return AnimatedRouteWidget(
                            progress: _routeAnimController.value,
                          );
                        },
                      ),
                    ),

                    // 3. Central Brand Typography & Slogan
                    // Exactly positioned at reference specifications (~46% viewport)
                    Positioned(
                      left: 20,
                      right: 20,
                      top: containerHeight * 0.46,
                      child: const BrandingHeaderWidget(),
                    ),

                    // 5. Bottom Loading Progress Bar, Status Text & Home Indicator Bar
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: isDesktopWeb ? 12 : (MediaQuery.of(context).padding.bottom + 8),
                      child: AnimatedBuilder(
                        animation: _loadingProgressController,
                        builder: (context, _) {
                          // Smooth continuous filling animation (0.35 to 0.95)
                          final double progress = 0.35 + (_loadingProgressController.value * 0.60);
                          return LoadingIndicatorWidget(
                            progress: progress,
                            statusText: tr.loadingNearbyServices,
                          );
                        },
                      ),
                    ),

                    if (_requiresBiometricUnlock)
                      Positioned(
                        bottom: (isDesktopWeb ? 12 : (MediaQuery.of(context).padding.bottom + 8)) + 60,
                        left: 20,
                        right: 20,
                        child: Center(
                          child: InkWell(
                            onTap: () async {
                              HapticFeedback.lightImpact();
                              final tr = ref.read(translationsProvider);
                              final authenticated = await BiometricHelper.authenticate(
                                context: context,
                                localizedReason: tr.isArabic
                                    ? 'يرجى تأكيد الهوية بالبصمة لفتح تطبيق زشو'
                                    : 'Authenticate with biometrics to unlock Zesho',
                              );
                              if (authenticated && mounted) {
                                _navigateToHome();
                              }
                            },
                            borderRadius: BorderRadius.circular(16.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFF252527),
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.14),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 22.0),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    ref.watch(translationsProvider).isArabic
                                        ? 'فتح القفل بالبصمة'
                                        : 'Unlock with Biometrics',
                                    style: (ref.watch(translationsProvider).isArabic
                                            ? GoogleFonts.cairo
                                            : GoogleFonts.inter)(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                color: const Color(0xFFF0F1F5), // Clean modern outer backdrop for web preview
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(42),
                    border: Border.all(
                      color: const Color(0xFF8B53FE).withValues(alpha: 0.20),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B53FE).withValues(alpha: 0.12),
                        blurRadius: 40,
                        spreadRadius: 6,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: splashContent,
                ),
              );
            }

            return splashContent;
          },
        ),
      ),
    );
  }
}
