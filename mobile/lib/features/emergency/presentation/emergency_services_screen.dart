import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home/presentation/widgets/bottom_nav_bar_widget.dart';
import '../../home/presentation/home_screen.dart';
import '../../location/presentation/location_permission_screen.dart';

/// Screen displayed when clicking on "Need urgent assistance?" card.
/// Strictly implemented according to incremental Figma specifications:
///
/// 1. Background Gradient Container:
/// - width: 390; height: 265;
/// - background: linear-gradient(0deg, #FFFFFF, #FFFFFF),
///   linear-gradient(180.52deg, #8B53FE -66.75%, rgba(139, 83, 254, 0.37284) -0.59%, rgba(139, 83, 254, 0) 29.8%);
///
/// 2. Header Heading Layout:
/// - width: 350; height: 36;
/// - top: 56px; left: 20px;
/// - justify-content: space-between;
/// - angle: 0 deg; opacity: 1;
class EmergencyServicesScreen extends StatefulWidget {
  const EmergencyServicesScreen({super.key});

  @override
  State<EmergencyServicesScreen> createState() => _EmergencyServicesScreenState();
}

class _EmergencyServicesScreenState extends State<EmergencyServicesScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildPillBadge({
    required Widget icon,
    required String label,
  }) {
    return Container(
      height: 28.0,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(31.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000), // #0000000F
            blurRadius: 8.0,
            offset: Offset(0, 1),
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 6.0),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.0,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1C2926),
              height: 1.0,
              letterSpacing: 0.0,
            ),
          ),
        ],
      ),
    );
  }

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
            final double horizontalPadding = containerWidth < 360 ? 16.0 : 20.0;

            // Content cards block ends at 740.0px (285px top + 455px categories section).
            // Clearance ensures the 5th card comfortably scrolls above the floating bottom navigation bar
            // without creating excessive blank void that causes bottom overscroll/stuck issues.
            final double bottomNavClearance = isDesktopWeb
                ? 100.0
                : (MediaQuery.of(context).padding.bottom + 95.0);
            final double contentHeight = math.max(containerHeight, 740.0 + bottomNavClearance);

            final screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                children: [
                  // Smooth, effortless scroll view with full touch, trackpad, and mouse drag support
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
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        child: SizedBox(
                          width: containerWidth,
                          height: contentHeight,
                          child: Stack(
                            children: [
                   // 1. Specified Figma Header Background Container:
                  // width: 390; height: 265;
                  // background: linear-gradient(180.52deg, #8B53FE -66.75%, rgba(139, 83, 254, 0.37284) -0.59%, rgba(139, 83, 254, 0) 29.8%)
                  Positioned(
                    top: 0,
                    left: 0,
                    width: containerWidth,
                    height: 265.0,
                    child: Container(
                      width: containerWidth,
                      height: 265.0,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.009, -1.0),
                          end: Alignment(-0.009, 1.0),
                          stops: [0.0, 1.0],
                          colors: [
                            Color(0x5F8B53FE), // rgba(139, 83, 254, 0.37284) -0.59%
                            Color(0x008B53FE), // rgba(139, 83, 254, 0) 29.8%
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 2. Header Heading Layout:
                  // width: 350; height: 36; top: 56px; left: 20px;
                  // justify-content: space-between; angle: 0 deg; opacity: 1;
                  Positioned(
                    top: 56.0,
                    left: horizontalPadding,
                    right: horizontalPadding,
                    height: 36.0,
                    child: SizedBox(
                      height: 36.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left Side Group: Back Button + Screen Title Block
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Back Button: width 36; height 36; circular
                              GestureDetector(
                                onTap: () => Navigator.of(context).maybePop(),
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 36.0,
                                  height: 36.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 8.0,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 15.0,
                                      color: Color(0xFF1C2926),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12.0),

                              // Title Block: "Emergency Services" & "Get help, fast."
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Emergency Services',
                                    style: GoogleFonts.inter(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1C2926),
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    'Get help, fast.',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF566663),
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Right Side Group: Notification Bell Button (width: 36; height: 36; border: 1px solid #525252)
                          Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFF525252),
                                width: 1.0,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.notifications_none_rounded,
                                size: 18.0,
                                color: Color(0xFF525252),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Emergency Card Branding:
                  // width: 350; height: 110; top: 116px; left: 20px;
                  // angle: 0 deg; opacity: 1; gap: 10px;
                  // border-width: 1px; border-radius: 12px; padding: 16px;
                  // background: #FFFFFF; border: 1px solid #FFDBC2;
                  // box-shadow: 0px 1px 8px 0px #0000000F;
                  Positioned(
                    top: 116.0,
                    left: horizontalPadding,
                    right: horizontalPadding,
                    height: 110.0,
                    child: Container(
                      height: 110.0,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: const Color(0xFFFFDBC2),
                          width: 1.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F000000), // #0000000F (opacity: 0.059)
                            blurRadius: 8.0,
                            offset: Offset(0, 1),
                            spreadRadius: 0.0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Card inner left-side content layout branding:
                          Expanded(
                            child: SizedBox(
                              height: 75.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // content: Emergency
                                  Text(
                                    'Emergency',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFFFF6E05),
                                      letterSpacing: 0.0,
                                    ),
                                  ),

                                  // content: Get Help Now
                                  Text(
                                    'Get Help Now',
                                    style: GoogleFonts.inter(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1C2926),
                                      letterSpacing: 0.0,
                                    ),
                                  ),

                                  // content: We’ll connect you with the nearest available emergency team.
                                  Text(
                                    'We’ll connect you with the nearest\navailable emergency team.',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF566663),
                                      height: 1.15,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 8.0),

                          // Right img branding:
                          SizedBox(
                            width: 92.0,
                            height: 76.0,
                            child: Stack(
                              children: [
                                // Beacon graphic matching uploaded Figma reference
                                Positioned.fill(
                                  child: Image.asset(
                                    'assets/images/emergency_card_beacon.png',
                                    width: 92.0,
                                    height: 76.0,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Color(0xFFFF6E05),
                                        size: 40.0,
                                      );
                                    },
                                  ),
                                ),

                                // Linear gradient overlay fading bottom to white:
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        stops: [0.24, 0.53, 0.91],
                                        colors: [
                                          Color(0x00FFFFFF), // rgba(255, 255, 255, 0)
                                          Color(0x80FFFFFF), // rgba(255, 255, 255, 0.5)
                                          Color(0xFFFFFFFF), // #FFFFFF
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 5. Badges/Pills Row Layout:
                  // width: 350; height: 28; top: 238px; left: 20px;
                  // Perfectly equal gaps (8.0px) between badges, scaling cleanly on mobile devices without distortion
                  Positioned(
                    top: 238.0,
                    left: horizontalPadding,
                    right: horizontalPadding,
                    height: 28.0,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 1. Verified Providers Badge
                            _buildPillBadge(
                              icon: const SizedBox(
                                width: 10.0,
                                height: 12.0,
                                child: Center(
                                  child: CustomPaint(
                                    size: Size(10.0, 11.0),
                                    painter: OutlinedShieldPainter(color: Color(0xFFFF6E05)),
                                  ),
                                ),
                              ),
                              label: 'Verified Providers',
                            ),

                            // Equal gap between badges
                            const SizedBox(width: 8.0),

                            // 2. Quick Response Badge
                            _buildPillBadge(
                              icon: const SizedBox(
                                width: 9.0,
                                height: 10.0,
                                child: Center(
                                  child: CustomPaint(
                                    size: Size(9.0, 10.0),
                                    painter: OutlinedLightningPainter(color: Color(0xFFFF6E05)),
                                  ),
                                ),
                              ),
                              label: 'Quick Response',
                            ),

                            // Equal gap between badges
                            const SizedBox(width: 8.0),

                            // 3. Live Tracking Badge
                            _buildPillBadge(
                              icon: const SizedBox(
                                width: 9.0,
                                height: 10.0,
                                child: Center(
                                  child: CustomPaint(
                                    size: Size(9.0, 10.0),
                                    painter: OutlinedLocationPinPainter(color: Color(0xFFFF6E05)),
                                  ),
                                ),
                              ),
                              label: 'Live Tracking',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 6. Next Widget Section Branding:
                  // width: 351; height: 455; top: 285px; left: 20px;
                  // angle: 0 deg; opacity: 1; gap: 16px;
                  Positioned(
                    top: 285.0,
                    left: horizontalPadding,
                    right: horizontalPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading Section:
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // content : Choose Your Services
                            Text(
                              'Choose Your Services',
                              style: GoogleFonts.inter(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1C2926),
                                height: 1.0,
                                letterSpacing: 0.0,
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            // content: Choose a service to get immediate help.
                            Text(
                              'Choose a service to get immediate help.',
                              style: GoogleFonts.inter(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF566663),
                                height: 1.0,
                                letterSpacing: 0.0,
                              ),
                            ),
                          ],
                        ),

                        // gap: 16px;
                        const SizedBox(height: 16.0),

                        // Catagories Section:
                        Column(
                          children: [
                            // 1. Ambulance Card:
                            _EmergencyCategoryCard(
                              title: 'Ambulance',
                              subtitle: 'Medical emergency',
                              imagePath: 'assets/images/ambulance.png',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LocationPermissionScreen(
                                      serviceName: 'Ambulance',
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12.0),

                            // 2. Police Card:
                            _EmergencyCategoryCard(
                              title: 'Police',
                              subtitle: 'Crime & security',
                              imagePath: 'assets/images/police.png',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LocationPermissionScreen(
                                      serviceName: 'Police',
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12.0),

                            // 3. Fire Brigade Card:
                            _EmergencyCategoryCard(
                              title: 'Fire Brigade',
                              subtitle: 'Fire & rescue response',
                              imagePath: 'assets/images/fire_brigade.png',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LocationPermissionScreen(
                                      serviceName: 'Fire Brigade',
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12.0),

                            // 4. Towing Card:
                            _EmergencyCategoryCard(
                              title: 'Tow Truck',
                              subtitle: 'Roadside vehicle breakdown',
                              imagePath: 'assets/images/towing.png',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LocationPermissionScreen(
                                      serviceName: 'Tow Truck',
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12.0),

                            // 5. Hospital Card:
                            _EmergencyCategoryCard(
                              title: 'Hospital',
                              subtitle: 'Urgent medical center',
                              imagePath: 'assets/images/hospital.png',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LocationPermissionScreen(
                                      serviceName: 'Hospital',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
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

                // Floating Bottom Navigation Bar (exact width: 292, centered, identical placement as HomeScreen)
                Positioned(
                  left: (containerWidth - 292.0) / 2,
                  width: 292.0,
                  bottom: isDesktopWeb ? 16.0 : (MediaQuery.of(context).padding.bottom + 12.0),
                  child: BottomNavBarWidget(
                    initialIndex: 0,
                    onTabSelected: (index) {
                      if (index == 0) {
                        Navigator.of(context).maybePop();
                      } else {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => HomeScreen(initialTabIndex: index),
                          ),
                          (route) => route.isFirst,
                        );
                      }
                    },
                  ),
                ),
        ],
      ),
    );

            if (isDesktopWeb) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFF0F1F5), // Clean modern outer backdrop for web preview
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerSignal: (pointerSignal) {
                    if (pointerSignal is PointerScrollEvent && _scrollController.hasClients) {
                      final RenderBox? box = context.findRenderObject() as RenderBox?;
                      if (box != null) {
                        final localPos = pointerSignal.localPosition;
                        final centerX = box.size.width / 2;
                        final centerY = box.size.height / 2;
                        final phoneRect = Rect.fromCenter(
                          center: Offset(centerX, centerY),
                          width: containerWidth,
                          height: containerHeight,
                        );
                        if (!phoneRect.contains(localPos)) {
                          final double target = (_scrollController.offset + pointerSignal.scrollDelta.dy)
                              .clamp(0.0, _scrollController.position.maxScrollExtent);
                          _scrollController.jumpTo(target);
                        }
                      }
                    }
                  },
                  child: Center(
                    child: Container(
                      width: containerWidth,
                      height: containerHeight,
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
                      clipBehavior: Clip.antiAlias,
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

/// Outlined lightning bolt vector icon matching uploaded Figma reference
class OutlinedLightningPainter extends CustomPainter {
  final Color color;
  const OutlinedLightningPainter({this.color = const Color(0xFFFF6E05)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.60, 0.0);
    path.lineTo(size.width * 0.12, size.height * 0.52);
    path.lineTo(size.width * 0.46, size.height * 0.52);
    path.lineTo(size.width * 0.36, size.height);
    path.lineTo(size.width * 0.88, size.height * 0.42);
    path.lineTo(size.width * 0.54, size.height * 0.42);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Outlined location map pin vector with center dot matching uploaded Figma reference
class OutlinedLocationPinPainter extends CustomPainter {
  final Color color;
  const OutlinedLocationPinPainter({this.color = const Color(0xFFFF6E05)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double cx = size.width / 2.0;
    final double r = size.width * 0.44;
    final double cy = r + 0.4;

    final path = Path();
    path.moveTo(cx, size.height);
    path.cubicTo(
      cx - r * 0.95, size.height * 0.66,
      cx - r, cy + r * 0.6,
      cx - r, cy,
    );
    path.arcToPoint(
      Offset(cx + r, cy),
      radius: Radius.circular(r),
      clockwise: true,
    );
    path.cubicTo(
      cx + r, cy + r * 0.6,
      cx + r * 0.95, size.height * 0.66,
      cx, size.height,
    );
    canvas.drawPath(path, paint);

    // Inner target dot
    canvas.drawCircle(Offset(cx, cy), size.width * 0.14, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Outlined shield vector with subtle checkmark
class OutlinedShieldPainter extends CustomPainter {
  final Color color;
  const OutlinedShieldPainter({this.color = const Color(0xFFFF6E05)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;

    final path = Path();
    path.moveTo(w * 0.5, 0.4);
    path.lineTo(w * 0.92, h * 0.20);
    path.lineTo(w * 0.92, h * 0.52);
    path.cubicTo(w * 0.92, h * 0.78, w * 0.5, h, w * 0.5, h);
    path.cubicTo(w * 0.5, h, w * 0.08, h * 0.78, w * 0.08, h * 0.52);
    path.lineTo(w * 0.08, h * 0.20);
    path.close();
    canvas.drawPath(path, paint);

    // Inner checkmark
    final checkPath = Path();
    checkPath.moveTo(w * 0.32, h * 0.50);
    checkPath.lineTo(w * 0.46, h * 0.64);
    checkPath.lineTo(w * 0.68, h * 0.38);
    canvas.drawPath(checkPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Category Card widget for emergency services
/// Dimensions and styles strictly derived from Figma CSS:
/// - width: 351; height: 72; padding: 16px; gap: 16px;
/// - border-radius: 8px; background: #FFFFFF; box-shadow: 0px 1px 10px 0px #00000014;
/// - card img placement on left side: width: 66; height: 40;
/// - content layout styling: width: 237; height: 28; justify-content: space-between;
/// - inner content: width: 96; height: 28; gap: 12px;
///   - title: 12px Inter Medium (500), #1C2926
///   - subtitle: 10px Inter Regular (400), #566663
/// - right arrow vector >: width: 5; height: 10; color: #566663;
class _EmergencyCategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback? onTap;

  const _EmergencyCategoryCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 72.0,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000), // #00000014 (opacity: ~0.08)
              blurRadius: 10.0,
              offset: Offset(0, 1),
              spreadRadius: 0.0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // card img placement styling on left side:
            // width: 66; height: 40;
            SizedBox(
              width: 66.0,
              height: 40.0,
              child: Image.asset(
                imagePath,
                width: 66.0,
                height: 40.0,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.emergency_outlined,
                  color: Color(0xFFFF6E05),
                  size: 28.0,
                ),
              ),
            ),

            // gap: 16px;
            const SizedBox(width: 16.0),

            // content layout styling:
            // width: 237; height: 28; justify-content: space-between;
            Expanded(
              child: SizedBox(
                height: 28.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // inner content styling:
                    // width: 96; height: 28; gap: 12px;
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // content: title (12px Inter Medium, #1C2926)
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1C2926),
                            height: 1.0,
                            letterSpacing: 0.0,
                          ),
                        ),

                        // content: subtitle (10px Inter Regular, #566663)
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF566663),
                            height: 1.0,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ],
                    ),

                    // vector > styling on right side:
                    // width: 5; height: 10; border-width: 0.6px; border: 0.6px solid #566663;
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18.0,
                      color: Color(0xFF566663),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
