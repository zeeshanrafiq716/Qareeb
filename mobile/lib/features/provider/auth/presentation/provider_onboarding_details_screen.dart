import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_scroll_behavior.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_onboarding_details_content_layout.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_onboarding_details_header.dart';

/// Provider Onboarding Details Screen
/// Restored consolidated onboarding screen containing:
/// - Provider Personal details (Full Name, Phone read-only, WhatsApp manual)
/// - Vehicle details (Plate Number, Color manual)
/// - Service Category & Vehicle Type note (assigned by Admin upon review)
/// - Direct "Continue" transition into Upload Documents screen
class ProviderOnboardingDetailsScreen extends StatelessWidget {
  final Widget? body;

  const ProviderOnboardingDetailsScreen({
    super.key,
    this.body,
  });

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
            final double bottomSafeArea = MediaQuery.of(context).padding.bottom;
            final double headerTop = isDesktopWeb
                ? ProviderOnboardingDetailsHeader.designTop
                : (topSafeArea > 0
                    ? (topSafeArea + 12.0)
                    : ProviderOnboardingDetailsHeader.designTop);

            final Widget screenContent = Opacity(
              opacity: 1.0,
              child: Transform.rotate(
                angle: 0.0,
                child: Container(
                  width: containerWidth,
                  height: containerHeight,
                  color: Colors.white,
                  child: Stack(
                    children: [
                      // 1. Header Layout
                      Positioned(
                        top: headerTop,
                        left: 20.0,
                        right: 20.0,
                        child: const ProviderOnboardingDetailsHeader(),
                      ),

                      // 2. Body Content Slot (Scrolls smoothly with bouncing physics and ample bottom room)
                      Positioned.fill(
                        top: headerTop + ProviderOnboardingDetailsHeader.designHeight + 12.0,
                        bottom: 0.0,
                        child: ScrollConfiguration(
                          behavior: const ProviderCardScrollBehavior(),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                            padding: EdgeInsets.only(
                              left: 20.0,
                              right: 20.0,
                              top: 8.0,
                              bottom: bottomSafeArea > 0 ? (bottomSafeArea + 32.0) : 40.0,
                            ),
                            child: body ?? const ProviderOnboardingDetailsContentLayout(),
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
