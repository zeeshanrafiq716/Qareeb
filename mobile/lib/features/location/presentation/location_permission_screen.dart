import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pickup_delivery_screen.dart';

/// Location Permission screen displayed when selecting any category service.
/// Designed strictly according to branding specifications:
/// - Container: width 390; height 843; top: 1px; angle: 0 deg; opacity: 1; scale: crop
/// - Background Map Image: assets/images/BG image.png
/// - Gradient Overlay: linear-gradient(180deg, rgba(255, 255, 255, 0) 21.53%, #FFFFFF 45.6%)
/// - Header: Circular shadow back button + Service Title
class LocationPermissionScreen extends StatelessWidget {
  final String serviceName;

  const LocationPermissionScreen({
    super.key,
    this.serviceName = 'Pickup & Delivery',
  });

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
            final double containerWidth = isDesktopWeb ? 390.0 : constraints.maxWidth;
            final double containerHeight = isDesktopWeb
                ? math.min(844.0, (constraints.maxHeight - 32.0).clamp(520.0, 844.0))
                : constraints.maxHeight;
            final double contentHeight = math.max(containerHeight, 760.0);

            final screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
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
                      // 1. Background Map Image (scale: crop / BoxFit.cover)
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/BG image.png',
                          width: containerWidth,
                          height: contentHeight,
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

                  // 3. Heading Branding Layout:
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
                          // < branding:
                          // width: 36; height: 36; angle: 0 deg; opacity: 1; border-width: 1px;
                          // background: #FFFFFF; border: 1px solid #172623; box-shadow: 0px -2px 12px 0px #00000014;
                          GestureDetector(
                            onTap: () => Navigator.of(context).maybePop(),
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

                          // content: Pickup & Delivery
                          // width: 298; height: 12; font-family: Inter; font-weight: 500; font-size: 16px; line-height: 22px; background: #1C2926;
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

                  // 4. Ellipse Shape Branding:
                  // width: 123.99999237060547; height: 123.99999237060547;
                  // top: 168px; left: 133px; angle: 0 deg; opacity: 1;
                  // background: #F0FFF7; box-shadow: 0px 0px 4px 0px #9FFFCB66 inset;
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
                        color: const Color(0xFFF0FFF7),
                        border: Border.all(
                          color: const Color(0x669FFFCB), // #9FFFCB66
                          width: 1.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x669FFFCB), // #9FFFCB66
                            blurRadius: 4.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 5. Image Layout Branding & Image Branding:
                  // img layout branding: width: 97.04349517822266; height: 97.04349517822266; top: 182.47px; left: 147.47px;
                  // img: Group 5.png available in assets folder
                  // img branding: width: 70; height: 70; top: 196px; left: 161px;
                  Positioned(
                    top: 182.47,
                    left: containerWidth >= 390
                        ? 147.47
                        : (containerWidth - 97.0435) / 2,
                    width: 97.0435,
                    height: 97.0435,
                    child: Center(
                      child: Image.asset(
                        'assets/images/Group 5.png',
                        width: 97.0435,
                        height: 97.0435,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.location_on_rounded,
                          size: 70.0,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                    ),
                  ),

                  // 6. "Nearby Providers" Badges Branding:
                  // badges branding: width: 112; height: 54; top: 150px; left: 20px;
                  // background: #FFFFFF; box-shadow: 0px 1px 8px 0px #0000000F;
                  // inner layout branding: width: 112; height: 44; top: 150px; left: 20px; gap: 10px;
                  // border-radius: 8px; padding: 8px 12px 8px 8px; background: #FFFFFF;
                  // content: Nearby Providers; width: 54; height: 24; 12px Inter Regular 400; color: #566663;
                  // icon branding: width: 28; height: 28; inner branding: width: 16; height: 14; color: #1D8070;
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
                              // Icon container: width: 28; height: 28; circular
                              Container(
                                width: 28.0,
                                height: 28.0,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFEDFAF4),
                                ),
                                child: const Center(
                                  child: CustomPaint(
                                    size: Size(16.0, 14.0),
                                    painter: _NearbyPinPainter(
                                      color: Color(0xFF1D8070),
                                    ),
                                  ),
                                ),
                              ),

                              // gap: 10px;
                              const SizedBox(width: 10.0),

                              // content: Nearby Providers
                              // width: 54; height: 24; font-family: Inter; font-weight: 400; font-size: 12px; line-height: 100%; color: #566663;
                              SizedBox(
                                width: 54.0,
                                height: 24.0,
                                child: Text(
                                  'Nearby\nProviders',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF566663),
                                    height: 1.0, // line-height: 100%
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

                  // 7. "Fast Delivery" Badges Branding (2nd badge):
                  // width: 105; height: 54; top: 130px; left: 265px;
                  // inner branding: width: 105; height: 44; top: 130px; left: 265px; gap: 10px;
                  // border-radius: 8px; padding: 8px 12px 8px 8px; background: #FFFFFF;
                  // content: Fast\nDelivery; width: 47; height: 24; font-family: Inter; font-weight: 400; font-size: 12px; color: #566663;
                  // icon car branding: width: 28; height: 28; icon inner branding: width: 16; height: 12; color: #1D8070;
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
                        tailX: 24.0, // bottom-left pointer towards center beacon
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
                              // Icon container: width: 28; height: 28; circular
                              Container(
                                width: 28.0,
                                height: 28.0,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFEDFAF4),
                                ),
                                child: const Center(
                                  child: CustomPaint(
                                    size: Size(16.0, 12.0),
                                    painter: _FastDeliveryCarPainter(
                                      color: Color(0xFF1D8070),
                                    ),
                                  ),
                                ),
                              ),

                              // gap: 10px;
                              const SizedBox(width: 10.0),

                              // content: Fast Delivery
                              // width: 47; height: 24; font-family: Inter; font-weight: 400; font-size: 12px; line-height: 100%; color: #566663;
                              SizedBox(
                                width: 47.0,
                                height: 24.0,
                                child: Text(
                                  'Fast\nDelivery',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF566663),
                                    height: 1.0, // line-height: 100%
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

                  // 8. "Real-time Tracking" Badges Branding (3rd badge):
                  // width: 113; height: 54; top: 270px; left: 251px;
                  // inner branding: width: 113; height: 44; top: 270px; left: 251px; gap: 10px;
                  // border-radius: 8px; padding: 8px 12px 8px 8px; background: #FFFFFF;
                  // content: Real-time\nTracking; width: 55; height: 24; font-family: Inter; font-weight: 400; font-size: 12px; color: #566663;
                  // icon tracking branding: width: 28; height: 28; icon inner branding: width: 14; height: 14; color: #1D8070;
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
                        tailX: 24.0, // bottom-left pointer under icon
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
                              // Icon container: width: 28; height: 28; circular
                              Container(
                                width: 28.0,
                                height: 28.0,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFEDFAF4),
                                ),
                                child: const Center(
                                  child: CustomPaint(
                                    size: Size(14.0, 14.0),
                                    painter: _RealTimeTrackingArrowPainter(
                                      color: Color(0xFF1D8070),
                                    ),
                                  ),
                                ),
                              ),

                              // gap: 10px;
                              const SizedBox(width: 10.0),

                              // content: Real-time Tracking
                              // width: 55; height: 24; font-family: Inter; font-weight: 400; font-size: 12px; line-height: 100%; color: #566663;
                              SizedBox(
                                width: 55.0,
                                height: 24.0,
                                child: Text(
                                  'Real-time\nTracking',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF566663),
                                    height: 1.0, // line-height: 100%
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
                  // 9. Location Permission Main Content Widget Branding:
                  // 16px padding from left/right screen edges
                  Positioned(
                    top: 348.0,
                    left: 16.0,
                    right: 16.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                          // content layout branding: gap: 12px;
                          SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // inner branding: content: Find Providers near you
                                // width: 350; height: 15; font-family: Inter; font-weight: 600; font-size: 20px; line-height: 24px; color: #1C2926;
                                Text(
                                  'Find Providers near you',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1C2926),
                                    height: 24.0 / 20.0,
                                    letterSpacing: 0.0,
                                  ),
                                ),

                                // gap: 12px;
                                const SizedBox(height: 12.0),

                                // content: Wee need your location to show nearby providers for Pickup & Delivery.
                                Text(
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

                          // gap: 20px;
                          const SizedBox(height: 20.0),

                          // 10. Next Widget Branding (Feature details card):
                          // White card with 16px padding from left/right of screen
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

                                // gap: 20px;
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

                                // gap: 20px;
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

                          // gap: 20px;
                          const SizedBox(height: 20.0),

                          // 11. CTA Component Branding:
                          SizedBox(
                            width: double.infinity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Button
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => PickupDeliveryScreen(
                                          serviceName: serviceName,
                                        ),
                                      ),
                                    );
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: double.infinity,
                                    height: 52.0,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1D8070),
                                      borderRadius: BorderRadius.circular(12.0),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x261D8070),
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
                                              // icon branding: width: 16; height: 16; white filled navigation arrow
                                              const CustomPaint(
                                                size: Size(16.0, 16.0),
                                                painter: _FilledNavigationArrowPainter(color: Colors.white),
                                              ),

                                              // gap: 10px;
                                              const SizedBox(width: 10.0),

                                              // content: Allow Location
                                              // width: 98; height: 10; Inter Medium 14px; line-height: 22px; color: #FFFFFF
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

                                          // vector > branding: width: 6; height: 12; angle: -180 deg; border: 0.8px solid #FFFFFF
                                          const Align(
                                            alignment: Alignment.centerRight,
                                            child: CustomPaint(
                                              size: Size(6.0, 12.0),
                                              painter: _RightChevronPainter(color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // gap: 16px;
                                const SizedBox(height: 16.0),

                                // after button branding: content: You can change this later in Settings
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
                                              color: const Color(0xFF1D8070),
                                              decoration: TextDecoration.underline,
                                              decorationColor: const Color(0xFF1D8070),
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
        );

            if (isDesktopWeb) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFF141C1A),
                child: Center(
                  child: Container(
                    width: containerWidth,
                    height: containerHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(42),
                      border: Border.all(
                        color: const Color(0xFF9FFFCB).withValues(alpha: 0.35),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 40,
                          spreadRadius: 8,
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
        // left icon branding: width: 36; height: 36; border-radius: 8px; background: #F0F5F2;
        Container(
          width: 36.0,
          height: 36.0,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F5F2),
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

        // gap: 12px;
        const SizedBox(width: 12.0),

        // content layout branding
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // inner content branding: title (Inter Medium 500, 12px, line-height: 22px, color: #1C2926)
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

              // inner content branding: subtitle with comfortable line height between wrapped lines
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF566663),
                  height: 1.5, // 15px line-height for clean breathing room between lines
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
    this.shadowColor = const Color(0x0F000000), // #0000000F
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
    final double halfTailWidth = 8.0;
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
  const _FastDeliveryCarPainter({this.color = const Color(0xFF1D8070)});

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

    // Front-view car tires peeking out on left and right
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
    // Start at bottom left of main body
    bodyPath.moveTo(1.5, h * 0.88);
    // Left side up to hood
    bodyPath.lineTo(1.5, h * 0.52);
    // Hood to windshield
    bodyPath.lineTo(3.2, h * 0.44);
    // Up along windshield pillar to roof
    bodyPath.lineTo(4.4, h * 0.08);
    // Roof top curve
    bodyPath.quadraticBezierTo(w * 0.5, 0.0, w - 4.4, h * 0.08);
    // Down right windshield pillar
    bodyPath.lineTo(w - 3.2, h * 0.44);
    // Right hood
    bodyPath.lineTo(w - 1.5, h * 0.52);
    // Down right body
    bodyPath.lineTo(w - 1.5, h * 0.88);
    // Bottom bumper line
    bodyPath.quadraticBezierTo(w * 0.5, h * 0.94, 1.5, h * 0.88);
    bodyPath.close();

    canvas.drawPath(bodyPath, strokePaint);

    // Windshield divider line
    final windshieldPath = Path();
    windshieldPath.moveTo(3.6, h * 0.44);
    windshieldPath.quadraticBezierTo(w * 0.5, h * 0.46, w - 3.6, h * 0.44);
    canvas.drawPath(windshieldPath, strokePaint);

    // Two circular headlights
    canvas.drawCircle(Offset(4.2, h * 0.68), 1.2, strokePaint);
    canvas.drawCircle(Offset(w - 4.2, h * 0.68), 1.2, strokePaint);

    // Front grille / center bar
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
  const _RealTimeTrackingArrowPainter({this.color = const Color(0xFF1D8070)});

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
    // Tip pointing towards top-right
    path.moveTo(w * 0.92, h * 0.08);
    // Down-left edge to left wing
    path.lineTo(w * 0.08, h * 0.50);
    // Inner center notch
    path.lineTo(w * 0.50, h * 0.50);
    // Down-right edge to bottom wing
    path.lineTo(w * 0.50, h * 0.92);
    // Close back to tip
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Outlined nearby location pin with circular target base
class _NearbyPinPainter extends CustomPainter {
  final Color color;
  const _NearbyPinPainter({this.color = const Color(0xFF1D8070)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double cx = size.width / 2.0;

    // Bottom target oval ring
    final rect = Rect.fromCenter(
      center: Offset(cx, size.height - 2.5),
      width: size.width - 2.0,
      height: 5.0,
    );
    canvas.drawOval(rect, paint);

    // Vertical stem
    canvas.drawLine(
      Offset(cx, 4.0),
      Offset(cx, size.height - 2.5),
      paint,
    );

    // Top pin circle
    canvas.drawCircle(Offset(cx, 3.0), 2.2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Outlined GPS crosshairs target icon matching Figma #1D8070 branding
class _GpsCrosshairsPainter extends CustomPainter {
  final Color color;
  const _GpsCrosshairsPainter({this.color = const Color(0xFF1D8070)});

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

    // Center circle outline
    canvas.drawCircle(Offset(cx, cy), radius, strokePaint);

    // Center dot
    canvas.drawCircle(Offset(cx, cy), 1.8, fillPaint);

    // 4 cardinal tick marks
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

/// Fast service lightning bolt icon matching Figma #1D8070 branding
class _FastServiceBoltPainter extends CustomPainter {
  final Color color;
  const _FastServiceBoltPainter({this.color = const Color(0xFF1D8070)});

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

/// Privacy shield icon with checkmark matching Figma #1D8070 branding
class _PrivacyShieldPainter extends CustomPainter {
  final Color color;
  const _PrivacyShieldPainter({this.color = const Color(0xFF1D8070)});

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
    // Tip at top-right
    path.moveTo(w * 0.95, h * 0.05);
    // Down-left to far wing
    path.lineTo(w * 0.05, h * 0.48);
    // Center notch
    path.lineTo(w * 0.48, h * 0.48);
    // Down to bottom wing
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
