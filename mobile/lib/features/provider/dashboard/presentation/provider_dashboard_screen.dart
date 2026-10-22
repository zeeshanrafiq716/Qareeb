import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_scroll_behavior.dart';
import 'package:mobile/features/provider/dashboard/presentation/widgets/provider_dashboard_header.dart';
import 'package:mobile/features/provider/dashboard/presentation/widgets/provider_profile_views_card.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';

/// Provider Dashboard Screen
/// Opens when user taps on "Views today" stat card.
/// Implements exact previous screens branding with back button, title, subtitle, and language toggle.
class ProviderDashboardScreen extends StatefulWidget {
  final int initialTabIndex;

  const ProviderDashboardScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  static const double designWidth = 392.0;
  static const double designHeight = 844.0;

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  @override
  Widget build(BuildContext context) {
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
            final bool isDesktopWeb = constraints.maxWidth > 500;
            final double containerWidth = isDesktopWeb
                ? ProviderDashboardScreen.designWidth
                : constraints.maxWidth;
            final double containerHeight = isDesktopWeb
                ? ProviderDashboardScreen.designHeight
                : constraints.maxHeight;

            final double topSafeArea = MediaQuery.of(context).padding.top;
            final double bottomSafeArea = MediaQuery.of(context).padding.bottom;
            final double headerTop = isDesktopWeb
                ? ProviderDashboardHeader.designTop
                : (topSafeArea > 0 ? (topSafeArea + 12.0) : ProviderDashboardHeader.designTop);

            final Widget screenContent = Opacity(
              opacity: 1.0,
              child: Container(
                width: containerWidth,
                height: containerHeight,
                color: Colors.white,
                child: Stack(
                  children: [
                    // Top Purple Glow Gradient
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: containerHeight * 0.28,
                      child: const IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.009, -1.0),
                              end: Alignment(-0.009, 1.0),
                              stops: [0.0, 1.0],
                              colors: [
                                Color(0x5F8B53FE),
                                Color(0x008B53FE),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 1. Header Layout with back button, title, subtitle, and language toggle
                    Positioned(
                      top: headerTop,
                      left: 20.0,
                      right: 20.0,
                      child: const ProviderDashboardHeader(),
                    ),

                    // 2. Scrollable Dashboard Body
                    // next widget branding:
                    //   width: 350; height: 850; top: 116px; left: 20px; gap: 12px;
                    Positioned.fill(
                      top: headerTop + ProviderDashboardHeader.designHeight + 14.0,
                      bottom: 0.0,
                      child: ScrollConfiguration(
                        behavior: const ProviderCardScrollBehavior(),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(
                            left: 20.0,
                            right: 20.0,
                            top: 0.0,
                            bottom: math.max(bottomSafeArea + 24.0, 32.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: const [
                              // Profile Views Card (350x377) matching exact branding
                              ProviderProfileViewsCard(),
                            ],
                          ),
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
                color: const Color(0xFF141C1A),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Container(
                    width: ProviderDashboardScreen.designWidth,
                    height: ProviderDashboardScreen.designHeight,
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
