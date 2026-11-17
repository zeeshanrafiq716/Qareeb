import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/localization/app_locale.dart';
import '../../provider/auth/data/provider_registration_state.dart';
import 'splash_screen.dart';
import '../../provider/auth/presentation/widgets/provider_animated_button.dart';
import '../../provider/auth/presentation/widgets/provider_animated_language_toggle.dart';
import '../../provider/splash/presentation/provider_splash_screen.dart';
import '../../provider/theme/provider_colors.dart';
import 'widgets/animated_route_widget.dart';
import 'widgets/branding_header_widget.dart';
import 'widgets/map_background_painter.dart';

/// Role chooser (390×844): customer vs provider.
class AppModeSelectionScreen extends ConsumerStatefulWidget {
  const AppModeSelectionScreen({super.key});

  static const double designWidth = 390.0;
  static const double designHeight = 844.0;

  @override
  ConsumerState<AppModeSelectionScreen> createState() => _AppModeSelectionScreenState();
}

class _AppModeSelectionScreenState extends ConsumerState<AppModeSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _routeAnimController;

  @override
  void initState() {
    super.initState();
    _routeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
  }

  @override
  void dispose() {
    _routeAnimController.dispose();
    super.dispose();
  }

  Future<void> _goCustomer() async {
    HapticFeedback.mediumImpact();
    await ProviderRegistrationStore.instance.setActiveAppMode('customer');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  Future<void> _goProvider() async {
    HapticFeedback.mediumImpact();
    await ProviderRegistrationStore.instance.setActiveAppMode('provider');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProviderSplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appLocaleProvider);
    final isArabic = context.isArabic;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    final title = isArabic
        ? 'كيف تريد استخدام زشو؟'
        : 'How Would You Like to Use ZESHO?';
    final subtitle = isArabic
        ? 'احصل على المساعدة على الطريق أو قدّم خدمات المركبات عبر زشو.'
        : 'Get roadside assistance or provide vehicle services with ZESHO.';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mediaQuery = MediaQuery.of(context);
            final bool isDesktopWeb = constraints.maxWidth > 500;
            final double containerWidth =
                isDesktopWeb ? AppModeSelectionScreen.designWidth : constraints.maxWidth;
            final double containerHeight = isDesktopWeb
                ? AppModeSelectionScreen.designHeight
                : constraints.maxHeight;
            final double topSafe = mediaQuery.padding.top;
            final double toggleTop = topSafe + 16.0;
            final double brandTop = math.max(
              toggleTop + 56.0,
              containerHeight * 0.46,
            );

            final Widget frame = SizedBox(
              width: containerWidth,
              height: containerHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: MapBackgroundPainter(),
                    ),
                  ),
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
                  Positioned(
                    top: toggleTop,
                    left: 0,
                    right: 0,
                    child: const Center(
                      child: ProviderAnimatedLanguageToggle(),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    top: brandTop,
                    child: const BrandingHeaderWidget(),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: math.max(24.0, mediaQuery.padding.bottom + 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1C2926),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF566663),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 22.0),
                        ProviderAnimatedButton(
                          key: const Key('app_mode_customer_button'),
                          height: 52.0,
                          backgroundColor: ProviderColors.primaryButton,
                          foregroundColor: Colors.white,
                          onTap: _goCustomer,
                          text: isArabic ? 'أنا عميل' : "I'm a Customer",
                          icon: Icon(
                            isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                            size: 18.0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        ProviderAnimatedButton(
                          key: const Key('app_mode_provider_button'),
                          height: 52.0,
                          backgroundColor: const Color(0xFF1C2926),
                          foregroundColor: Colors.white,
                          onTap: _goProvider,
                          text: isArabic ? 'أنا مزود خدمة' : "I'm a Provider",
                          icon: Icon(
                            isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                            size: 18.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

            if (isDesktopWeb) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFF0F1F5),
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(42),
                    border: Border.all(
                      color: const Color(0xFF8B53FE).withValues(alpha: 0.2),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B53FE).withValues(alpha: 0.12),
                        blurRadius: 40,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: frame,
                  ),
                ),
              );
            }

            return frame;
          },
        ),
      ),
    );
  }
}