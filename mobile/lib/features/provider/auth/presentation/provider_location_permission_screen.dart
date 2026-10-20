import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/provider/auth/presentation/admin_approval_screen.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';

/// Provider Location Permission Screen
/// Follows the exact same branding and visual design as the Customer side LocationPermissionScreen:
/// - Background Map Image: assets/images/BG image.png
/// - Gradient Overlay: linear-gradient(180deg, rgba(255, 255, 255, 0) 21.53%, #FFFFFF 45.6%)
/// - Circular Back Button (36x36) + Service Title
/// - Glowing Center Beacon (124x124 ellipse in #F0FFF7) + Group 5.png pin (97.04x97.04)
/// - 3 Speech Bubble Tooltips: "Nearby Providers", "Fast Delivery", "Real-time Tracking"
/// - White Feature Details Card (16px radius, shadow) with GPS, bolt, and privacy rows
/// - "Allow Location" CTA Button (#1D8070, 52px height) + "You can change this later in Settings"
class ProviderLocationPermissionScreen extends StatelessWidget {
  final String serviceName;
  final String? headline;
  final String? description;
  final VoidCallback? onAllowLocation;
  final VoidCallback? onBack;

  const ProviderLocationPermissionScreen({
    super.key,
    this.serviceName = 'Pickup & Delivery',
    this.headline,
    this.description,
    this.onAllowLocation,
    this.onBack,
  });

  static const double designWidth = 390.0;
  static const double designHeight = 844.0;

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
            final double containerWidth = isDesktopWeb ? designWidth : constraints.maxWidth;
            final double containerHeight = isDesktopWeb ? designHeight : constraints.maxHeight;
            final double bottomSafeArea = MediaQuery.of(context).padding.bottom;
            final double contentHeight = math.max(containerHeight, 810.0);

            final screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                children: [
                  // 1. Background Map Image (fills entire screen)
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/BG image.png',
                      width: containerWidth,
                      height: containerHeight,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFF3F4F6),
                        child: const Center(
                          child: Icon(
                            Icons.map_outlined,
                            size: 48,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. Specified Figma Gradient Overlay:
                  // background: linear-gradient(180deg, rgba(255, 255, 255, 0) 21.53%, #FFFFFF 45.6%)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.2153, 0.456],
                          colors: [
                            Color(0x00FFFFFF), // rgba(255, 255, 255, 0) above 21.53%
                            Color(0xFFFFFFFF), // solid #FFFFFF at and below 45.6%
                          ],
                          tileMode: TileMode.clamp,
                        ),
                      ),
                    ),
                  ),

                  // 3. Scrollable Content Area: full-height smooth scrolling
                  Positioned.fill(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        scrollbars: false,
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                          PointerDeviceKind.trackpad,
                          PointerDeviceKind.stylus,
                          PointerDeviceKind.invertedStylus,
                          PointerDeviceKind.unknown,
                        },
                      ),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        child: SizedBox(
                          width: containerWidth,
                          height: contentHeight,
                          child: Stack(
                            children: [
                              // Heading Branding Layout:
                              Positioned(
                          top: 56.0,
                          left: 16.0,
                          right: 16.0,
                          height: 36.0,
                          child: SizedBox(
                            height: 36.0,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Circular back button with drop shadow
                                GestureDetector(
                                  onTap: onBack ?? () => Navigator.of(context).maybePop(),
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: 36.0,
                                    height: 36.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFFFFFFF),
                                      border: Border.all(
                                        color: const Color(0xFF172623),
                                        width: 1.0,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x14000000), // #00000014
                                          blurRadius: 12.0,
                                          offset: Offset(0, -2),
                                          spreadRadius: 0.0,
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 15.0,
                                        color: Color(0xFF172623),
                                      ),
                                    ),
                                  ),
                                ),

                                // gap: 16px;
                                const SizedBox(width: 16.0),

                                // Service Title
                                Expanded(
                                  child: SizedBox(
                                    width: 298.0,
                                    child: Text(
                                      serviceName,
                                      style: GoogleFonts.inter(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500, // Medium 500
                                        color: const Color(0xFF1C2926),
                                        height: 22.0 / 16.0, // line-height: 22px
                                        letterSpacing: 0.0,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 4. Main Ellipse Branding:
                        // background: #F0EAFE; box-shadow: 0px 0px 4px 0px #E9E0FE inset;
                        Positioned(
                          top: 168.0,
                          left: (containerWidth - 124.0) / 2,
                          width: 124.0,
                          height: 124.0,
                          child: Container(
                            width: 124.0,
                            height: 124.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF0EAFE),
                              border: Border.all(
                                color: const Color(0xFFE9E0FE),
                                width: 2.0,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x40E9E0FE),
                                  blurRadius: 4.0,
                                  spreadRadius: 0.0,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 5. Inner Ellipse Branding:
                        // background: #EAE0FE; box-shadow: 0px 0px 4px 0px #DACBFE inset;
                        Positioned(
                          top: 181.48,
                          left: (containerWidth - 97.04) / 2,
                          width: 97.04,
                          height: 97.04,
                          child: Container(
                            width: 97.04,
                            height: 97.04,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFEAE0FE),
                              border: Border.all(
                                color: const Color(0xFFDACBFE),
                                width: 2.0,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x40DACBFE),
                                  blurRadius: 4.0,
                                  spreadRadius: 0.0,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 6. Center Location Icon Branding:
                        // background: linear-gradient(139.03deg, #8B53FE -28.34%, #A67AFE 40.05%, #BA98FE 92.02%)
                        Positioned(
                          top: 204.0,
                          left: (containerWidth - 50.0) / 2,
                          width: 50.0,
                          height: 64.0,
                          child: const BrandLocationPinWidget(
                            width: 50.0,
                            height: 64.0,
                          ),
                        ),

                        // 7. "Nearby Providers" Badges Branding:
                        // width: 112; height: 54; top: 150px; left: 20px;
                        Positioned(
                          top: 150.0,
                          left: containerWidth >= 390
                              ? 20.0
                              : ((containerWidth - 350.0) / 2).clamp(10.0, 20.0),
                          width: 112.0,
                          height: 54.0,
                          child: CustomPaint(
                            painter: const _TooltipBubblePainter(
                              color: Color(0xFFFFFFFF),
                              shadowColor: Color(0x0F000000), // #0000000F
                              blurRadius: 8.0,
                              shadowOffset: Offset(0, 1),
                              tailX: 76.0,
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                width: 112.0,
                                height: 44.0,
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  right: 12.0,
                                  bottom: 8.0,
                                  left: 8.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 28.0,
                                      height: 28.0,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFF0EAFE),
                                      ),
                                      child: const Center(
                                        child: CustomPaint(
                                          size: Size(16.0, 14.0),
                                          painter: _NearbyPinPainter(
                                            color: Color(0xFF8B53FE),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10.0),
                                    SizedBox(
                                      width: 54.0,
                                      height: 24.0,
                                      child: Text(
                                        'Nearby\nProviders',
                                        style: GoogleFonts.inter(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF566663),
                                          height: 1.0,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 8. "Fast Delivery" Badges Branding (2nd badge):
                        // width: 105; height: 54; top: 130px; left: 265px;
                        Positioned(
                          top: 130.0,
                          left: containerWidth >= 390
                              ? 265.0
                              : (containerWidth - 105.0 - 15.0).clamp(160.0, 265.0),
                          width: 105.0,
                          height: 54.0,
                          child: CustomPaint(
                            painter: const _TooltipBubblePainter(
                              color: Color(0xFFFFFFFF),
                              shadowColor: Color(0x0F000000), // #0000000F
                              blurRadius: 8.0,
                              shadowOffset: Offset(0, 1),
                              tailX: 24.0,
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                width: 105.0,
                                height: 44.0,
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  right: 12.0,
                                  bottom: 8.0,
                                  left: 8.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 28.0,
                                      height: 28.0,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFF0EAFE),
                                      ),
                                      child: const Center(
                                        child: CustomPaint(
                                          size: Size(16.0, 12.0),
                                          painter: _FastDeliveryCarPainter(
                                            color: Color(0xFF8B53FE),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10.0),
                                    SizedBox(
                                      width: 47.0,
                                      height: 24.0,
                                      child: Text(
                                        'Fast\nDelivery',
                                        style: GoogleFonts.inter(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF566663),
                                          height: 1.0,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 9. "Real-time Tracking" Badges Branding (3rd badge):
                        // width: 113; height: 54; top: 270px; left: 251px;
                        Positioned(
                          top: 270.0,
                          left: containerWidth >= 390
                              ? 251.0
                              : (containerWidth - 113.0 - 20.0).clamp(140.0, 251.0),
                          width: 113.0,
                          height: 54.0,
                          child: CustomPaint(
                            painter: const _TooltipBubblePainter(
                              color: Color(0xFFFFFFFF),
                              shadowColor: Color(0x0F000000), // #0000000F
                              blurRadius: 8.0,
                              shadowOffset: Offset(0, 1),
                              tailX: 24.0,
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                width: 113.0,
                                height: 44.0,
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  right: 12.0,
                                  bottom: 8.0,
                                  left: 8.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 28.0,
                                      height: 28.0,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFF0EAFE),
                                      ),
                                      child: const Center(
                                        child: CustomPaint(
                                          size: Size(14.0, 14.0),
                                          painter: _RealTimeTrackingArrowPainter(
                                            color: Color(0xFF8B53FE),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10.0),
                                    SizedBox(
                                      width: 55.0,
                                      height: 24.0,
                                      child: Text(
                                        'Real-time\nTracking',
                                        style: GoogleFonts.inter(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF566663),
                                          height: 1.0,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 9. Location Permission Main Content Widget Branding:
                        Positioned(
                          top: 348.0,
                          left: 16.0,
                          right: 16.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Content heading and description
                              SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      headline ?? 'Find Providers near you',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1C2926),
                                        height: 24.0 / 20.0,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                    const SizedBox(height: 12.0),
                                    Text(
                                      description ??
                                          'Wee need your location to show nearby\nproviders for $serviceName.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF566663),
                                        height: 1.35,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20.0),

                              // Feature details white card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  borderRadius: BorderRadius.circular(16.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x0F000000), // #0000000F
                                      blurRadius: 10.0,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Item 1: See nearby providers
                                    _buildFeatureRow(
                                      icon: const CustomPaint(
                                        size: Size(20.0, 20.0),
                                        painter: _GpsCrosshairsPainter(),
                                      ),
                                      title: 'See nearby providers',
                                      subtitle: 'Find available pickup & delivery teams around you.',
                                    ),

                                    const SizedBox(height: 20.0),

                                    // Item 2: Fast service
                                    _buildFeatureRow(
                                      icon: const CustomPaint(
                                        size: Size(20.0, 20.0),
                                        painter: _FastServiceBoltPainter(),
                                      ),
                                      title: 'Fast service',
                                      subtitle: 'Get quicker and more accurate results.',
                                    ),

                                    const SizedBox(height: 20.0),

                                    // Item 3: Your privacy matters
                                    _buildFeatureRow(
                                      icon: const CustomPaint(
                                        size: Size(20.0, 20.0),
                                        painter: _PrivacyShieldPainter(),
                                      ),
                                      title: 'Your privacy matters',
                                      subtitle: 'Your location is only used for this service and can be changed anhytime',
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20.0),

                              // CTA Component: Allow Location Button + Settings Footnote
                              SizedBox(
                                width: double.infinity,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        if (onAllowLocation != null) {
                                          onAllowLocation!();
                                        } else {
                                          Navigator.of(context).push(
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation, secondaryAnimation) =>
                                                  const AdminApprovalScreen(),
                                              transitionsBuilder:
                                                  (context, animation, secondaryAnimation, child) {
                                                final curved = CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeInOutCubic,
                                                );
                                                return FadeTransition(
                                                  opacity: curved,
                                                  child: SlideTransition(
                                                    position: Tween<Offset>(
                                                      begin: const Offset(0.04, 0),
                                                      end: Offset.zero,
                                                    ).animate(curved),
                                                    child: child,
                                                  ),
                                                );
                                              },
                                              transitionDuration: const Duration(milliseconds: 350),
                                            ),
                                          );
                                        }
                                      },
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        width: double.infinity,
                                        height: 52.0,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8B53FE),
                                          borderRadius: BorderRadius.circular(12.0),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x268B53FE),
                                              blurRadius: 10.0,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  const CustomPaint(
                                                    size: Size(16.0, 16.0),
                                                    painter: _FilledNavigationArrowPainter(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10.0),
                                                  Text(
                                                    'Allow Location',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14.0,
                                                      fontWeight: FontWeight.w500,
                                                      color: const Color(0xFFFFFFFF),
                                                      height: 22.0 / 14.0,
                                                      letterSpacing: 0.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Align(
                                                alignment: Alignment.centerRight,
                                                child: CustomPaint(
                                                  size: Size(6.0, 12.0),
                                                  painter: _RightChevronPainter(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16.0),

                                    // Settings Footnote
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Opening Location Settings...'),
                                            backgroundColor: Color(0xFF1C2926),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      behavior: HitTestBehavior.opaque,
                                      child: SizedBox(
                                        width: 350.0,
                                        child: Text.rich(
                                          TextSpan(
                                            text: 'You can change this later in ',
                                            style: GoogleFonts.inter(
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF566663),
                                              height: 1.0,
                                              letterSpacing: 0.0,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Settings',
                                                style: GoogleFonts.inter(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(0xFF8B53FE),
                                                  decoration: TextDecoration.underline,
                                                  decorationColor: const Color(0xFF8B53FE),
                                                  height: 1.0,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24.0),
                                    // Flexible bottom indicator bar that scrolls naturally with content
                                    const ProviderCardBottomIndicator(),
                                    SizedBox(height: math.max(bottomSafeArea, 16.0)),
                                  ],
                                ),
                              ),
                            ],
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
                    clipBehavior: Clip.antiAlias,
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

  Widget _buildFeatureRow({
    required Widget icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36.0,
          height: 36.0,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EAFE),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: SizedBox(
              width: 20.0,
              height: 20.0,
              child: icon,
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1C2926),
                  height: 1.2,
                  letterSpacing: 0.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4.0),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF566663),
                  height: 1.5,
                  letterSpacing: 0.0,
                ),
                maxLines: 2,
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tooltip speech bubble with configurable pointer tail and drop shadow
class _TooltipBubblePainter extends CustomPainter {
  final Color color;
  final Color shadowColor;
  final double blurRadius;
  final Offset shadowOffset;
  final double tailX;

  const _TooltipBubblePainter({
    this.color = Colors.white,
    this.shadowColor = const Color(0x0F000000),
    this.blurRadius = 8.0,
    this.shadowOffset = const Offset(0, 1),
    this.tailX = 76.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double bodyHeight = 44.0;
    const double r = 8.0;
    final path = Path();

    // Top edge & corners
    path.moveTo(r, 0);
    path.lineTo(size.width - r, 0);
    path.arcToPoint(Offset(size.width, r), radius: const Radius.circular(r));

    // Right edge & corner
    path.lineTo(size.width, bodyHeight - r);
    path.arcToPoint(Offset(size.width - r, bodyHeight), radius: const Radius.circular(r));

    // Bottom edge with tail pointing down towards beacon
    const double halfTailWidth = 8.0;
    final double clampedTailX = tailX.clamp(r + halfTailWidth, size.width - r - halfTailWidth);

    path.lineTo(clampedTailX + halfTailWidth, bodyHeight);
    path.lineTo(clampedTailX, size.height);
    path.lineTo(clampedTailX - halfTailWidth, bodyHeight);

    // Left edge & corner
    path.lineTo(r, bodyHeight);
    path.arcToPoint(Offset(0, bodyHeight - r), radius: const Radius.circular(r));
    path.lineTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: const Radius.circular(r));
    path.close();

    // WebGL2 safe shadow without SkShadowUtils compilation crash
    final shadowPath = path.shift(const Offset(0, 1.5));
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = const Color(0x1F000000)
        ..style = PaintingStyle.fill,
    );

    // Draw bubble fill
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _TooltipBubblePainter oldDelegate) =>
      oldDelegate.tailX != tailX || oldDelegate.color != color;
}

/// Front-view car vector icon matching Figma fast delivery branding
class _FastDeliveryCarPainter extends CustomPainter {
  final Color color;
  const _FastDeliveryCarPainter({this.color = const Color(0xFF8B53FE)});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    const double tireW = 2.0;
    const double tireH = 3.6;
    // Left tire
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.2, h * 0.62, tireW, tireH),
        const Radius.circular(0.8),
      ),
      fillPaint,
    );
    // Right tire
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w - tireW - 0.2, h * 0.62, tireW, tireH),
        const Radius.circular(0.8),
      ),
      fillPaint,
    );

    // Car main body and cabin
    final bodyPath = Path();
    bodyPath.moveTo(1.5, h * 0.88);
    bodyPath.lineTo(1.5, h * 0.52);
    bodyPath.lineTo(3.2, h * 0.44);
    bodyPath.lineTo(4.4, h * 0.08);
    bodyPath.quadraticBezierTo(w * 0.5, 0.0, w - 4.4, h * 0.08);
    bodyPath.lineTo(w - 3.2, h * 0.44);
    bodyPath.lineTo(w - 1.5, h * 0.52);
    bodyPath.lineTo(w - 1.5, h * 0.88);
    bodyPath.quadraticBezierTo(w * 0.5, h * 0.94, 1.5, h * 0.88);
    bodyPath.close();

    canvas.drawPath(bodyPath, strokePaint);

    final windshieldPath = Path();
    windshieldPath.moveTo(3.6, h * 0.44);
    windshieldPath.quadraticBezierTo(w * 0.5, h * 0.46, w - 3.6, h * 0.44);
    canvas.drawPath(windshieldPath, strokePaint);

    canvas.drawCircle(Offset(4.2, h * 0.68), 1.2, strokePaint);
    canvas.drawCircle(Offset(w - 4.2, h * 0.68), 1.2, strokePaint);

    canvas.drawLine(
      Offset(w * 0.40, h * 0.72),
      Offset(w * 0.60, h * 0.72),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Outlined navigation arrow icon matching Figma real-time tracking branding
class _RealTimeTrackingArrowPainter extends CustomPainter {
  final Color color;
  const _RealTimeTrackingArrowPainter({this.color = const Color(0xFF8B53FE)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(w * 0.92, h * 0.08);
    path.lineTo(w * 0.08, h * 0.50);
    path.lineTo(w * 0.50, h * 0.50);
    path.lineTo(w * 0.50, h * 0.92);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Outlined nearby location pin with circular target base
class _NearbyPinPainter extends CustomPainter {
  final Color color;
  const _NearbyPinPainter({this.color = const Color(0xFF8B53FE)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double cx = size.width / 2.0;

    final rect = Rect.fromCenter(
      center: Offset(cx, size.height - 2.5),
      width: size.width - 2.0,
      height: 5.0,
    );
    canvas.drawOval(rect, paint);

    canvas.drawLine(
      Offset(cx, 4.0),
      Offset(cx, size.height - 2.5),
      paint,
    );

    canvas.drawCircle(Offset(cx, 3.0), 2.2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Outlined GPS crosshairs target icon matching Figma #8B53FE branding
class _GpsCrosshairsPainter extends CustomPainter {
  final Color color;
  const _GpsCrosshairsPainter({this.color = const Color(0xFF8B53FE)});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double cx = size.width / 2.0;
    final double cy = size.height / 2.0;
    final double radius = size.width * 0.32;

    canvas.drawCircle(Offset(cx, cy), radius, strokePaint);
    canvas.drawCircle(Offset(cx, cy), 1.8, fillPaint);

    const double tickInner = 0.36;
    const double tickOuter = 0.50;

    canvas.drawLine(
      Offset(cx, cy - size.height * tickInner),
      Offset(cx, cy - size.height * tickOuter),
      strokePaint,
    );
    canvas.drawLine(
      Offset(cx, cy + size.height * tickInner),
      Offset(cx, cy + size.height * tickOuter),
      strokePaint,
    );
    canvas.drawLine(
      Offset(cx - size.width * tickInner, cy),
      Offset(cx - size.width * tickOuter, cy),
      strokePaint,
    );
    canvas.drawLine(
      Offset(cx + size.width * tickInner, cy),
      Offset(cx + size.width * tickOuter, cy),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fast service lightning bolt icon matching Figma #8B53FE branding
class _FastServiceBoltPainter extends CustomPainter {
  final Color color;
  const _FastServiceBoltPainter({this.color = const Color(0xFF8B53FE)});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(w * 0.58, h * 0.08);
    path.lineTo(w * 0.22, h * 0.54);
    path.lineTo(w * 0.50, h * 0.54);
    path.lineTo(w * 0.42, h * 0.92);
    path.lineTo(w * 0.78, h * 0.44);
    path.lineTo(w * 0.50, h * 0.44);
    path.close();

    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Privacy shield icon with checkmark matching Figma #8B53FE branding
class _PrivacyShieldPainter extends CustomPainter {
  final Color color;
  const _PrivacyShieldPainter({this.color = const Color(0xFF8B53FE)});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final shieldPath = Path();
    shieldPath.moveTo(w * 0.5, h * 0.08);
    shieldPath.lineTo(w * 0.88, h * 0.22);
    shieldPath.lineTo(w * 0.88, h * 0.56);
    shieldPath.quadraticBezierTo(w * 0.88, h * 0.84, w * 0.5, h * 0.96);
    shieldPath.quadraticBezierTo(w * 0.12, h * 0.84, w * 0.12, h * 0.56);
    shieldPath.lineTo(w * 0.12, h * 0.22);
    shieldPath.close();

    canvas.drawPath(shieldPath, fillPaint);

    final checkPath = Path();
    checkPath.moveTo(w * 0.35, h * 0.52);
    checkPath.lineTo(w * 0.46, h * 0.63);
    checkPath.lineTo(w * 0.65, h * 0.42);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Filled white navigation arrow icon for Allow Location button
class _FilledNavigationArrowPainter extends CustomPainter {
  final Color color;
  const _FilledNavigationArrowPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(w * 0.95, h * 0.05);
    path.lineTo(w * 0.05, h * 0.48);
    path.lineTo(w * 0.48, h * 0.48);
    path.lineTo(w * 0.48, h * 0.95);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 6x12 right chevron icon matching Figma border: 0.8px solid #FFFFFF
class _RightChevronPainter extends CustomPainter {
  final Color color;
  const _RightChevronPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(1.0, 1.0);
    path.lineTo(size.width - 1.0, size.height / 2.0);
    path.lineTo(1.0, size.height - 1.0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Brand Location Pin Widget with smooth teardrop geometry,
/// vibrant purple gradient: linear-gradient(139.03deg, #8B53FE -28.34%, #A67AFE 40.05%, #BA98FE 92.02%)
/// and centered white circular donut ring.
class BrandLocationPinWidget extends StatelessWidget {
  final double width;
  final double height;

  const BrandLocationPinWidget({
    super.key,
    this.width = 50.0,
    this.height = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        size: Size(width, height),
        painter: const _BrandLocationPinPainter(),
      ),
    );
  }
}

class _BrandLocationPinPainter extends CustomPainter {
  const _BrandLocationPinPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final double r = w * 0.48;
    final Offset center = Offset(w * 0.5, r + 2.0);

    const double theta = 0.35;
    const double startAngle = theta;
    const double sweepAngle = 2 * math.pi - 2 * theta;

    final path = Path();
    path.arcTo(
      Rect.fromCircle(center: center, radius: r),
      startAngle,
      -sweepAngle,
      false,
    );

    final tipPoint = Offset(center.dx, h - 2.0);
    path.cubicTo(
      center.dx - r * 0.95, center.dy + r * 0.75,
      center.dx - 6.0, tipPoint.dy - 12.0,
      tipPoint.dx - 2.0, tipPoint.dy - 1.0,
    );

    path.quadraticBezierTo(
      tipPoint.dx, tipPoint.dy + 2.0,
      tipPoint.dx + 2.0, tipPoint.dy - 1.0,
    );

    path.cubicTo(
      center.dx + 6.0, tipPoint.dy - 12.0,
      center.dx + r * 0.95, center.dy + r * 0.75,
      center.dx + r * math.cos(theta), center.dy + r * math.sin(theta),
    );
    path.close();

    canvas.drawShadow(path, const Color(0x338B53FE), 8.0, true);

    const gradient = LinearGradient(
      begin: Alignment(-0.65, -0.76),
      end: Alignment(0.65, 0.76),
      stops: [0.0, 0.4005, 0.9202],
      colors: [
        Color(0xFF8B53FE),
        Color(0xFFA67AFE),
        Color(0xFFBA98FE),
      ],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    final double ringRadius = r * 0.44;
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5;

    canvas.drawCircle(center, ringRadius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _BrandLocationPinPainter oldDelegate) => false;
}

