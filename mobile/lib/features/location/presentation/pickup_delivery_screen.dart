import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'find_provider_screen.dart';
import 'widgets/top_down_car_widget.dart';

/// Screen displayed after allowing location access for Pickup & Delivery.
/// - Cars are active across the COMPLETE MAP
/// - When a car enters the circle radius, it arrives near the customer
/// - When clicked: car size slightly increases and its color turns WHITE
class PickupDeliveryScreen extends ConsumerStatefulWidget {
  final String serviceName;

  const PickupDeliveryScreen({
    super.key,
    this.serviceName = 'Pickup & Delivery',
  });

  @override
  ConsumerState<PickupDeliveryScreen> createState() => _PickupDeliveryScreenState();
}

class FakeCar {
  final int id;
  final String name;
  final Color baseColor;
  // Route center and geometry on complete map (390 x 844)
  final double routeCenterX;
  final double routeCenterY;
  final double radiusX;
  final double radiusY;
  final double routeTilt; // in radians
  final double startAngleRad;
  final double speedFactor; // 1.0 (CCW) or -1.0 (CW)

  const FakeCar({
    required this.id,
    required this.name,
    this.baseColor = const Color(0xFF1D8070),
    required this.routeCenterX,
    required this.routeCenterY,
    required this.radiusX,
    required this.radiusY,
    this.routeTilt = 0.0,
    required this.startAngleRad,
    required this.speedFactor,
  });

  /// Calculate continuous position on the map, bounded strictly inside square beacon criteria
  Offset calculatePosition(
    double t,
    double screenWidth, {
    double beaconTop = 112.0,
    double beaconHeight = 570.0,
  }) {
    // Adapt horizontally for larger web widths
    final double cx = routeCenterX + (screenWidth - 390.0) / 2.0;
    final double cy = routeCenterY;

    final double theta = startAngleRad + speedFactor * 2.0 * math.pi * t;

    final double cosTheta = math.cos(theta);
    final double sinTheta = math.sin(theta);
    final double cosTilt = math.cos(routeTilt);
    final double sinTilt = math.sin(routeTilt);

    final double rawX = cx + (radiusX * cosTheta * cosTilt - radiusY * sinTheta * sinTilt);
    final double rawY = cy + (radiusX * cosTheta * sinTilt + radiusY * sinTheta * cosTilt);

    // Boundary criteria: Cars and badges remain strictly inside the square criteria
    final double minX = 46.0;
    final double maxX = screenWidth - 46.0;
    final double minY = beaconTop + 45.0;
    final double maxY = beaconTop + beaconHeight - 65.0;

    final double liveX = rawX.clamp(minX, maxX);
    final double liveY = rawY.clamp(minY, maxY);

    return Offset(liveX, liveY);
  }

  /// Calculate continuous analytic heading angle (in clock degrees)
  double calculateHeading(double t) {
    final double theta = startAngleRad + speedFactor * 2.0 * math.pi * t;

    final double cosTheta = math.cos(theta);
    final double sinTheta = math.sin(theta);
    final double cosTilt = math.cos(routeTilt);
    final double sinTilt = math.sin(routeTilt);

    final double dTheta = speedFactor * 2.0 * math.pi;

    final double vx = (-radiusX * sinTheta * cosTilt - radiusY * cosTheta * sinTilt) * dTheta;
    final double vy = (-radiusX * sinTheta * sinTilt + radiusY * cosTheta * cosTilt) * dTheta;

    return math.atan2(vx, -vy) * 180.0 / math.pi;
  }
}

class _PickupDeliveryScreenState extends ConsumerState<PickupDeliveryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _radarController;
  late final AnimationController _carMotionController;
  int? _selectedCarId;
  int _selectedProviderCount = 10;

  // Cars naturally distributed across the square beacon area without overflowing:
  // - Kept well within horizontal margins and square rounded bounds
  // - Kept safely below top header and above bottom edge/button
  // - Roaming smoothly into and out of customer proximity
  static const List<FakeCar> fakeCars = [
    // 1. Uzair: Mid-North near customer center
    FakeCar(
      id: 1,
      name: 'Uzair',
      baseColor: Color(0xFF108C7B), // Turns WHITE on tap
      routeCenterX: 155.0,
      routeCenterY: 340.0,
      radiusX: 38.0,
      radiusY: 34.0,
      routeTilt: 0.12,
      startAngleRad: math.pi,
      speedFactor: 1.0,
    ),
    // 2. Adnan: North central district
    FakeCar(
      id: 2,
      name: 'Adnan',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 195.0,
      routeCenterY: 225.0,
      radiusX: 44.0,
      radiusY: 32.0,
      routeTilt: -0.1,
      startAngleRad: -math.pi / 2.0,
      speedFactor: -1.0,
    ),
    // 3. Abdul: East district
    FakeCar(
      id: 3,
      name: 'Abdul',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 275.0,
      routeCenterY: 320.0,
      radiusX: 36.0,
      radiusY: 38.0,
      routeTilt: 0.05,
      startAngleRad: 0.0,
      speedFactor: 1.0,
    ),
    // 4. Mehmood: North-West district
    FakeCar(
      id: 4,
      name: 'Mehmood',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 115.0,
      routeCenterY: 215.0,
      radiusX: 35.0,
      radiusY: 32.0,
      routeTilt: 0.15,
      startAngleRad: -2.3,
      speedFactor: -1.0,
    ),
    // 5. Ubaid: West district
    FakeCar(
      id: 5,
      name: 'Ubaid',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 95.0,
      routeCenterY: 325.0,
      radiusX: 32.0,
      radiusY: 36.0,
      routeTilt: -0.1,
      startAngleRad: 2.8,
      speedFactor: 1.0,
    ),
    // 6. Rayan: North-East district
    FakeCar(
      id: 6,
      name: 'Rayan',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 275.0,
      routeCenterY: 215.0,
      radiusX: 36.0,
      radiusY: 32.0,
      routeTilt: -0.15,
      startAngleRad: -0.8,
      speedFactor: -1.0,
    ),
    // 7. Omar: South-East district
    FakeCar(
      id: 7,
      name: 'Omar',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 265.0,
      routeCenterY: 460.0,
      radiusX: 34.0,
      radiusY: 34.0,
      routeTilt: 0.15,
      startAngleRad: 1.1,
      speedFactor: 1.0,
    ),
    // 8. Saad: South avenue
    FakeCar(
      id: 8,
      name: 'Saad',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 195.0,
      routeCenterY: 480.0,
      radiusX: 40.0,
      radiusY: 32.0,
      routeTilt: -0.08,
      startAngleRad: 1.7,
      speedFactor: -1.0,
    ),
    // 9. Hassan: South-West district
    FakeCar(
      id: 9,
      name: 'Hassan',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 115.0,
      routeCenterY: 445.0,
      radiusX: 34.0,
      radiusY: 34.0,
      routeTilt: 0.12,
      startAngleRad: 2.2,
      speedFactor: 1.0,
    ),
    // 10. Ahmad: South-Central avenue
    FakeCar(
      id: 10,
      name: 'Ahmad',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 210.0,
      routeCenterY: 405.0,
      radiusX: 36.0,
      radiusY: 32.0,
      routeTilt: 0.0,
      startAngleRad: math.pi / 2.0,
      speedFactor: -1.0,
    ),
    // 11. Bilal: Mid-North
    FakeCar(
      id: 11,
      name: 'Bilal',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 160.0,
      routeCenterY: 260.0,
      radiusX: 38.0,
      radiusY: 34.0,
      routeTilt: 0.1,
      startAngleRad: 0.5,
      speedFactor: 1.0,
    ),
    // 12. Tariq: North-East
    FakeCar(
      id: 12,
      name: 'Tariq',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 230.0,
      routeCenterY: 250.0,
      radiusX: 42.0,
      radiusY: 32.0,
      routeTilt: -0.12,
      startAngleRad: -1.2,
      speedFactor: -1.0,
    ),
    // 13. Hamza: South-West
    FakeCar(
      id: 13,
      name: 'Hamza',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 135.0,
      routeCenterY: 380.0,
      radiusX: 36.0,
      radiusY: 30.0,
      routeTilt: 0.08,
      startAngleRad: 2.5,
      speedFactor: 1.0,
    ),
    // 14. Zeeshan: South-East
    FakeCar(
      id: 14,
      name: 'Zeeshan',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 255.0,
      routeCenterY: 360.0,
      radiusX: 34.0,
      radiusY: 38.0,
      routeTilt: -0.15,
      startAngleRad: 0.8,
      speedFactor: -1.0,
    ),
    // 15. Farhan: Central East
    FakeCar(
      id: 15,
      name: 'Farhan',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 185.0,
      routeCenterY: 350.0,
      radiusX: 40.0,
      radiusY: 35.0,
      routeTilt: 0.05,
      startAngleRad: -2.0,
      speedFactor: 1.0,
    ),
    // 16. Kashif: Mid-West
    FakeCar(
      id: 16,
      name: 'Kashif',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 110.0,
      routeCenterY: 300.0,
      radiusX: 32.0,
      radiusY: 34.0,
      routeTilt: -0.1,
      startAngleRad: 1.8,
      speedFactor: -1.0,
    ),
    // 17. Noman: East avenue
    FakeCar(
      id: 17,
      name: 'Noman',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 280.0,
      routeCenterY: 410.0,
      radiusX: 35.0,
      radiusY: 32.0,
      routeTilt: 0.14,
      startAngleRad: -0.5,
      speedFactor: 1.0,
    ),
    // 18. Salman: South-West district
    FakeCar(
      id: 18,
      name: 'Salman',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 125.0,
      routeCenterY: 470.0,
      radiusX: 38.0,
      radiusY: 30.0,
      routeTilt: -0.06,
      startAngleRad: 3.0,
      speedFactor: -1.0,
    ),
    // 19. Imran: South-East avenue
    FakeCar(
      id: 19,
      name: 'Imran',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 245.0,
      routeCenterY: 480.0,
      radiusX: 36.0,
      radiusY: 34.0,
      routeTilt: 0.1,
      startAngleRad: 1.4,
      speedFactor: 1.0,
    ),
    // 20. Waqas: South central
    FakeCar(
      id: 20,
      name: 'Waqas',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 175.0,
      routeCenterY: 430.0,
      radiusX: 40.0,
      radiusY: 32.0,
      routeTilt: -0.08,
      startAngleRad: -1.7,
      speedFactor: -1.0,
    ),
    // 21. Asad: Mid-Central
    FakeCar(
      id: 21,
      name: 'Asad',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 215.0,
      routeCenterY: 320.0,
      radiusX: 35.0,
      radiusY: 36.0,
      routeTilt: 0.12,
      startAngleRad: 0.2,
      speedFactor: 1.0,
    ),
    // 22. Faisal: Mid-West avenue
    FakeCar(
      id: 22,
      name: 'Faisal',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 145.0,
      routeCenterY: 320.0,
      radiusX: 33.0,
      radiusY: 35.0,
      routeTilt: -0.14,
      startAngleRad: -2.5,
      speedFactor: -1.0,
    ),
    // 23. Junaid: North-East avenue
    FakeCar(
      id: 23,
      name: 'Junaid',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 270.0,
      routeCenterY: 250.0,
      radiusX: 37.0,
      radiusY: 30.0,
      routeTilt: 0.07,
      startAngleRad: 2.1,
      speedFactor: 1.0,
    ),
    // 24. Rashid: North-West
    FakeCar(
      id: 24,
      name: 'Rashid',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 105.0,
      routeCenterY: 240.0,
      radiusX: 34.0,
      radiusY: 32.0,
      routeTilt: -0.09,
      startAngleRad: -0.9,
      speedFactor: -1.0,
    ),
    // 25. Danish: North avenue
    FakeCar(
      id: 25,
      name: 'Danish',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 185.0,
      routeCenterY: 210.0,
      radiusX: 42.0,
      radiusY: 30.0,
      routeTilt: 0.15,
      startAngleRad: 1.9,
      speedFactor: 1.0,
    ),
    // 26. Kamran: North-East corner
    FakeCar(
      id: 26,
      name: 'Kamran',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 260.0,
      routeCenterY: 200.0,
      radiusX: 35.0,
      radiusY: 33.0,
      routeTilt: -0.11,
      startAngleRad: -1.4,
      speedFactor: -1.0,
    ),
    // 27. Shoaib: South avenue
    FakeCar(
      id: 27,
      name: 'Shoaib',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 150.0,
      routeCenterY: 490.0,
      radiusX: 39.0,
      radiusY: 31.0,
      routeTilt: 0.09,
      startAngleRad: 0.7,
      speedFactor: 1.0,
    ),
    // 28. Haris: South-East district
    FakeCar(
      id: 28,
      name: 'Haris',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 225.0,
      routeCenterY: 440.0,
      radiusX: 37.0,
      radiusY: 33.0,
      routeTilt: -0.13,
      startAngleRad: -2.2,
      speedFactor: -1.0,
    ),
    // 29. Naveed: South-West avenue
    FakeCar(
      id: 29,
      name: 'Naveed',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 115.0,
      routeCenterY: 420.0,
      radiusX: 33.0,
      radiusY: 35.0,
      routeTilt: 0.11,
      startAngleRad: 2.8,
      speedFactor: 1.0,
    ),
    // 30. Babar: Central district
    FakeCar(
      id: 30,
      name: 'Babar',
      baseColor: Color(0xFF108C7B),
      routeCenterX: 205.0,
      routeCenterY: 280.0,
      radiusX: 38.0,
      radiusY: 34.0,
      routeTilt: -0.07,
      startAngleRad: 0.0,
      speedFactor: -1.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // 1. Radar sweep rotation (9.5s smooth loop)
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9500),
    )..repeat();

    // 2. Continuous ambient car cruising across complete map (smooth 120s calm pace)
    _carMotionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    _carMotionController.dispose();
    super.dispose();
  }

  void _onCarTapped(int carId) {
    setState(() {
      _selectedCarId = (_selectedCarId == carId) ? null : carId;
    });
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
            final double contentHeight = math.max(containerHeight, 844.0);

            final double beaconLeft = containerWidth >= 390
                ? 20.0
                : ((containerWidth - 350.0) / 2).clamp(10.0, 20.0);
            final double beaconTop = 112.0;
            final double beaconWidth = containerWidth >= 390
                ? 350.0
                : (containerWidth - (beaconLeft * 2.0));
            final double beaconHeight = 570.0;
            final double bottomCardTop = beaconTop + beaconHeight + 14.0;
            final double bottomCardHeight = math.max(148.0, contentHeight - bottomCardTop);

            // Customer location anchor at center of square beacon area on screen
            final Offset customerCenter = Offset(containerWidth / 2.0, beaconTop + beaconHeight / 2.0);

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
                        // 1. Map Widget & Card with minor top, left, right padding
                        Positioned(
                          top: beaconTop,
                          left: beaconLeft,
                          width: beaconWidth,
                          height: beaconHeight,
                          child: Container(
                            key: const Key('map_widget_beacon'),
                            width: beaconWidth,
                            height: beaconHeight,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: const Color(0xFFCCFFE3), // 1px solid #CCFFE3
                                width: 1.0,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 16.0,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              clipBehavior: Clip.hardEdge,
                              children: [
                                // Background Map Image clipped inside padded card
                                Positioned.fill(
                                  child: Image.asset(
                                    'assets/images/BG image.png',
                                    width: beaconWidth,
                                    height: beaconHeight,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
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

                                // Radial Gradient Overlay on Map:
                                // radial-gradient(53.9% 41.56% at 50% 50%, rgba(159, 255, 203, 0.4) 0%, rgba(159, 255, 203, 0.12) 100%)
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: const BoxDecoration(
                                      gradient: RadialGradient(
                                        center: Alignment.center,
                                        radius: 0.539,
                                        colors: [
                                          Color(0x669FFFCB), // rgba(159, 255, 203, 0.4) 0%
                                          Color(0x1F9FFFCB), // rgba(159, 255, 203, 0.12) 100%
                                        ],
                                        stops: [0.0, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                                // Animated curved radar sweep sector across square
                                Positioned.fill(
                                  child: AnimatedBuilder(
                                    animation: _radarController,
                                    builder: (context, child) {
                                      final double breath = (math.sin(_radarController.value * 4.0 * math.pi - math.pi / 2.0) + 1.0) / 2.0;
                                      final double dynamicOpacity = (0.35 + 0.55 * breath).clamp(0.2, 1.0);

                                      return Transform.rotate(
                                        angle: -_radarController.value * 2.0 * math.pi,
                                        alignment: Alignment.center,
                                        child: Opacity(
                                          opacity: dynamicOpacity,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: CustomPaint(
                                      key: const Key('animated_radar_sector'),
                                      size: Size(beaconWidth, beaconHeight),
                                      painter: const _RadarSectorPainter(),
                                    ),
                                  ),
                                ),

                                // Light bold animated circle around customer pin
                                Positioned(
                                  top: (beaconHeight - 210.0) / 2.0,
                                  left: (beaconWidth - 210.0) / 2.0,
                                  width: 210.0,
                                  height: 210.0,
                                  child: AnimatedBuilder(
                                    animation: _radarController,
                                    builder: (context, child) {
                                      final double wave = (math.sin(_radarController.value * 4.0 * math.pi) + 1.0) / 2.0;
                                      final double scale = 0.95 + 0.10 * wave; // Smooth breathing pulse
                                      final double opacity = (0.75 + 0.25 * wave).clamp(0.0, 1.0);

                                      return Transform.scale(
                                        scale: scale,
                                        child: Opacity(
                                          opacity: opacity,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      key: const Key('customer_pin_animated_circle'),
                                      width: 210.0,
                                      height: 210.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0x1F9FFFCB),
                                        border: Border.all(
                                          color: const Color(0xFF9FFFCB),
                                          width: 2.2, // Light bold stroke
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x389FFFCB),
                                            blurRadius: 18.0,
                                            spreadRadius: 2.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Inner light bold animated wave circle
                                Positioned(
                                  top: (beaconHeight - 100.0) / 2.0,
                                  left: (beaconWidth - 100.0) / 2.0,
                                  width: 100.0,
                                  height: 100.0,
                                  child: AnimatedBuilder(
                                    animation: _radarController,
                                    builder: (context, child) {
                                      final double wave = (math.cos(_radarController.value * 4.0 * math.pi) + 1.0) / 2.0;
                                      final double scale = 0.92 + 0.14 * wave;
                                      final double opacity = (0.60 + 0.40 * wave).clamp(0.0, 1.0);

                                      return Transform.scale(
                                        scale: scale,
                                        child: Opacity(
                                          opacity: opacity,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      key: const Key('customer_pin_inner_pulse'),
                                      width: 100.0,
                                      height: 100.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0x189FFFCB),
                                        border: Border.all(
                                          color: const Color(0xFF9FFFCB),
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Rotated layout branding
                                Positioned(
                                  top: (beaconHeight - 320.0) / 2.0,
                                  left: (beaconWidth - 320.0) / 2.0,
                                  width: 320.0,
                                  height: 320.0,
                                  child: Transform.rotate(
                                    key: const Key('radar_rotated_layout'),
                                    angle: 65.53 * math.pi / 180.0,
                                    alignment: Alignment.center,
                                    child: const SizedBox(
                                      width: 320.0,
                                      height: 320.0,
                                    ),
                                  ),
                                ),

                                // Customer Real GPS Center Beacon
                                Positioned(
                                  top: (beaconHeight - 24.0) / 2.0,
                                  left: (beaconWidth - 24.0) / 2.0,
                                  child: Container(
                                    key: const Key('user_gps_center_marker'),
                                    width: 24.0,
                                    height: 24.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF1D8070),
                                      border: Border.all(color: Colors.white, width: 2.2),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x381D8070),
                                          blurRadius: 10.0,
                                          spreadRadius: 2.0,
                                        ),
                                        BoxShadow(
                                          color: Color(0x1F000000),
                                          blurRadius: 4.0,
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.my_location,
                                        size: 11.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 3. CARS ON THE COMPLETE MAP:
                        // - Roaming across the square beacon area (100% width x 65% height)
                        // - When entering customer proximity -> "wo customer k pass aa gaye"
                        // - When clicked: size slightly increases (1.28x) AND color becomes WHITE (#FFFFFF)
                        AnimatedBuilder(
                          animation: _carMotionController,
                          builder: (context, _) {
                            final double progress = _carMotionController.value;

                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                for (final car in fakeCars)
                                  () {
                                    final Offset livePos = car.calculatePosition(
                                      progress,
                                      containerWidth,
                                      beaconTop: beaconTop,
                                      beaconHeight: beaconHeight,
                                    );
                                    final double heading = car.calculateHeading(progress);
                                    final bool isSelected = _selectedCarId == car.id;

                                    // Proximity check to customer pin animated circle (radius 110px)
                                    final double distPx = (livePos - customerCenter).distance;
                                    final bool isInsideRadius = distPx <= 110.0;

                                    // Dynamic distance in km based on proximity to customer
                                    final double distanceKm = isInsideRadius
                                        ? (0.2 + (distPx / 110.0) * 0.5).clamp(0.2, 0.7)
                                        : (0.7 + ((distPx - 110.0) / 90.0) * 0.7);

                                    return Positioned(
                                      top: livePos.dy - 14.25,
                                      left: livePos.dx - 8.25,
                                      child: TopDownCarWidget(
                                        key: ValueKey('fake_car_${car.id}'),
                                        width: 16.5,
                                        height: 28.5,
                                        angle: heading,
                                        opacity: 1.0,
                                        driverName: car.name,
                                        distanceKm: distanceKm,
                                        bodyColor: car.baseColor,
                                        showBadge: true,
                                        isSelected: isSelected, // Turns WHITE and scales 1.28x
                                        isInsideRadius: isInsideRadius,
                                        onTap: () => _onCarTapped(car.id),
                                      ),
                                    );
                                  }(),
                              ],
                            );
                          },
                        ),

                        // 4. Current Location Button (Positioned in square card corner)
                        // width: 36; height: 36;
                        // border-radius: 8px; background: #FFFFFF; box-shadow: 0px 1px 8px 0px #0000000F;
                        Positioned(
                          top: beaconTop + beaconHeight - 36.0 - 12.0,
                          left: beaconLeft + beaconWidth - 36.0 - 12.0,
                          width: 36.0,
                          height: 36.0,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Centering to your location...',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFF1D8070),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              key: const Key('current_location_button'),
                              width: 36.0,
                              height: 36.0,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0F000000),
                                    blurRadius: 8.0,
                                    offset: Offset(0, 1),
                                    spreadRadius: 0.0,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.my_location_rounded,
                                  size: 20.0,
                                  color: Color(0xFF1D8070),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 5. Header Branding:
                        // width: 350; height: 36; gap: 16px; top: 56px; left: 20px;
                        Positioned(
                          top: 56.0,
                          left: containerWidth >= 390
                              ? 20.0
                              : ((containerWidth - 350.0) / 2).clamp(10.0, 20.0),
                          width: containerWidth >= 390
                              ? 350.0
                              : (containerWidth - 40.0).clamp(280.0, 350.0),
                          height: 36.0,
                          child: SizedBox(
                            width: containerWidth >= 390
                                ? 350.0
                                : (containerWidth - 40.0).clamp(280.0, 350.0),
                            height: 36.0,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
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
                                        color: const Color(0xFF566663),
                                        width: 1.0,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x14000000),
                                          blurRadius: 12.0,
                                          offset: Offset(0, -2),
                                          spreadRadius: 0.0,
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: CustomPaint(
                                        size: Size(6.0, 13.0),
                                        painter: _BackChevronPainter(
                                          color: Color(0xFF566663),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: SizedBox(
                                    width: 298.0,
                                    child: Text(
                                      widget.serviceName,
                                      style: GoogleFonts.inter(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF1C2926),
                                        height: 22.0 / 16.0,
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

                        // 6. Bottom Widget Layout
                        // 6. Bottom Widget Layout
                        Positioned(
                          top: bottomCardTop,
                          left: 0.0,
                          width: containerWidth,
                          height: bottomCardHeight,
                          child: Container(
                            key: const Key('bottom_widget_layout'),
                            width: containerWidth,
                            height: bottomCardHeight,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(28.0),
                                topRight: Radius.circular(28.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x14000000), // #00000014
                                  offset: Offset(0, -2),
                                  blurRadius: 12.0,
                                  spreadRadius: 0.0,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Inner card content placed at start of card
                                Positioned(
                                  top: 20.0,
                                  left: containerWidth >= 390 ? 20.0 : 16.0,
                                  right: containerWidth >= 390 ? 20.0 : 16.0,
                                  child: _selectedCarId != null
                                      ? _buildSelectedDriverCard(
                                          containerWidth,
                                          customerCenter,
                                          beaconTop,
                                          beaconHeight,
                                        )
                                      : _buildProvidersInnerCard(containerWidth),
                                ),

                                // Bottom Bar Layout: positioned near bottom of card
                                Positioned(
                                  bottom: 8.0,
                                  left: 0.0,
                                  right: 0.0,
                                  height: 24.0,
                                  child: Center(
                                    // Bar branding: width: 134; height: 4; border-radius: 100px; background: #1C2926;
                                    child: Container(
                                      key: const Key('bottom_bar_indicator'),
                                      width: 134.0,
                                      height: 4.0,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1C2926),
                                        borderRadius: BorderRadius.circular(100.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

  /// Inner card branding: 18 Providers nearby + Find a Provider button
  Widget _buildProvidersInnerCard(double containerWidth) {
    final double cardWidth = containerWidth >= 390
        ? 350.0
        : (containerWidth - 40.0).clamp(280.0, 350.0);

    return SizedBox(
      width: cardWidth,
      height: 41.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side content: width: 152; height: 33; gap: 12px;
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Inner content: 18 Providers nearby (16px, weight 500, line-height 22px, #1C2926)
              Text(
                '18 Providers nearby',
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                style: GoogleFonts.inter(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1C2926),
                  height: 1.15,
                  letterSpacing: 0.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2.0),
              // Content: Within 1 km radius (12px, weight 400, line-height 22px, #566663)
              Text(
                'Within 1 km radius',
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF566663),
                  height: 1.15,
                  letterSpacing: 0.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          // Right side layout: height: 41; border-radius: 60px; padding: 16px; background: #F2F5F4;
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FindProviderScreen(
                    serviceCategory: widget.serviceName,
                  ),
                ),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 41.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F5F4),
                borderRadius: BorderRadius.circular(60.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Content: View all (12px, weight 400, line-height 22px, #1C2926)
                  Text(
                    'View all',
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1C2926),
                      height: 1.15,
                      letterSpacing: 0.0,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(width: 8.0),
                  // Vector > branding: width: 4; height: 8; angle: -180 deg; border: 0.6px solid #1C2926;
                  const CustomPaint(
                    size: Size(4.0, 8.0),
                    painter: _ChevronRightVectorPainter(
                      color: Color(0xFF1C2926),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  /// Selected driver details card within bottom widget matching branding
  Widget _buildSelectedDriverCard(
    double containerWidth,
    Offset customerCenter,
    double beaconTop,
    double beaconHeight,
  ) {
    final selectedCar = fakeCars.firstWhere(
      (c) => c.id == _selectedCarId,
      orElse: () => fakeCars.first,
    );

    // Live distance and arrival status
    final livePos = selectedCar.calculatePosition(
      _carMotionController.value,
      containerWidth,
      beaconTop: beaconTop,
      beaconHeight: beaconHeight,
    );
    final double distPx = (livePos - customerCenter).distance;
    final bool isNearCustomer = distPx <= 110.0;
    final double displayDistKm = isNearCustomer
        ? (0.2 + (distPx / 110.0) * 0.5).clamp(0.2, 0.7)
        : (0.7 + ((distPx - 110.0) / 90.0) * 0.7);

    final double cardWidth = containerWidth >= 390
        ? 350.0
        : (containerWidth - 40.0).clamp(280.0, 350.0);

    return SizedBox(
      key: const Key('selected_driver_card'),
      width: cardWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Circular avatar matching left side icon branding
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F5F2),
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: const Center(
                  child: CustomPaint(
                    size: Size(18.0, 16.0),
                    painter: _ProviderCarVectorPainter(
                      color: Color(0xFF1D8070),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          selectedCar.name,
                          style: GoogleFonts.inter(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1C2926),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            'SELECTED',
                            style: GoogleFonts.inter(
                              fontSize: 9.0,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2.0),
                    Row(
                      children: [
                        Icon(
                          Icons.near_me,
                          size: 11.0,
                          color: isNearCustomer
                              ? const Color(0xFF059669)
                              : const Color(0xFF566663),
                        ),
                        const SizedBox(width: 3.0),
                        Text(
                          isNearCustomer
                              ? '${displayDistKm.toStringAsFixed(1)} km • Near Customer'
                              : '${displayDistKm.toStringAsFixed(1)} km • En Route',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: isNearCustomer
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isNearCustomer
                              ? const Color(0xFF059669)
                              : const Color(0xFF566663),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedCarId = null),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 28.0,
                  height: 28.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close,
                      size: 16.0,
                      color: Color(0xFF566663),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18.0),
          SizedBox(
            width: double.infinity,
            height: 44.0,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF1D8070),
                    content: Text(
                      'Pickup confirmed with ${selectedCar.name}!',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D8070),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                'Confirm ${selectedCar.name.split(' ').first}',
                style: GoogleFonts.inter(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Back chevron vector < matching Figma: width: 6; height: 13; border: 1px solid #566663
class _BackChevronPainter extends CustomPainter {
  final Color color;
  const _BackChevronPainter({this.color = const Color(0xFF566663)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width - 0.5, 0.5);
    path.lineTo(0.5, size.height / 2.0);
    path.lineTo(size.width - 0.5, size.height - 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated curved radar sector matching Figma design:
/// Translucent bright mint-green wash (#9FFFCB) sweeping smoothly in circle
class _RadarSectorPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;

  const _RadarSectorPainter({
    this.startAngle = -math.pi / 2.0, // 12 o'clock (top)
    this.sweepAngle = 65.53 * math.pi / 180.0, // 65.53 deg trailing behind leading edge
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final radius = math.max(size.width, size.height);

    // Clip to rounded square bounds to prevent sweep bleeding
    canvas.clipRRect(RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(24.0),
    ));

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
      )
      ..close();

    final sweepGradient = SweepGradient(
      center: Alignment.center,
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [
        Color(0x9E9FFFCB),
        Color(0x739FFFCB),
        Color(0x409FFFCB),
        Color(0x189FFFCB),
      ],
      stops: const [0.0, 0.35, 0.70, 1.0],
      tileMode: TileMode.clamp,
    );

    final fillPaint = Paint()
      ..shader = sweepGradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    final leadingRayPaint = Paint()
      ..color = const Color(0xCC9FFFCB)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - radius),
      leadingRayPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadarSectorPainter oldDelegate) => false;
}

/// Vector car branding matching Figma specifications:
/// width: 18; height: 16; top: 10px; left: 9px; background: #1D8070
class _ProviderCarVectorPainter extends CustomPainter {
  final Color color;
  const _ProviderCarVectorPainter({this.color = const Color(0xFF1D8070)});

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

    // Tires peeking out on left and right
    const double tireW = 2.0;
    const double tireH = 3.6;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.2, h * 0.62, tireW, tireH),
        const Radius.circular(0.8),
      ),
      fillPaint,
    );
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

    // Windshield divider line
    final windshieldPath = Path();
    windshieldPath.moveTo(3.6, h * 0.44);
    windshieldPath.quadraticBezierTo(w * 0.5, h * 0.46, w - 3.6, h * 0.44);
    canvas.drawPath(windshieldPath, strokePaint);

    // Two circular headlights
    canvas.drawCircle(Offset(4.2, h * 0.68), 1.1, strokePaint);
    canvas.drawCircle(Offset(w - 4.2, h * 0.68), 1.1, strokePaint);

    // Front bumper line
    canvas.drawLine(
      Offset(w * 0.38, h * 0.72),
      Offset(w * 0.62, h * 0.72),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vector group/providers branding matching Figma specifications:
/// Dual user silhouettes (foreground user + background user with cutout contour)
class _ProviderGroupVectorPainter extends CustomPainter {
  final Color color;
  final Color backgroundColor;

  const _ProviderGroupVectorPainter({
    this.color = const Color(0xFF1D8070),
    this.backgroundColor = const Color(0xFFF0F5F2),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final cutoutPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // Scale / center within the provided size (normalized around 20.0 x 19.0)
    final double scaleX = size.width / 20.0;
    final double scaleY = size.height / 19.0;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    // --- 1. Background Person (Person 2 - Right side) ---
    // Head 2
    canvas.drawCircle(const Offset(14.5, 4.4), 3.6, fillPaint);

    // Torso 2 (shoulder peeking out on right)
    final body2RRect = RRect.fromRectAndCorners(
      const Rect.fromLTRB(9.5, 10.8, 18.2, 18.2),
      topLeft: const Radius.circular(5.0),
      topRight: const Radius.circular(5.0),
      bottomLeft: const Radius.circular(3.2),
      bottomRight: const Radius.circular(3.2),
    );
    canvas.drawRRect(body2RRect, fillPaint);

    // --- 2. Cutout Contour of Foreground Person (creates transparent gap) ---
    // Head 1 cutout
    canvas.drawCircle(const Offset(7.0, 4.8), 3.8, cutoutPaint);

    // Torso 1 cutout
    final body1RRect = RRect.fromRectAndCorners(
      const Rect.fromLTRB(0.8, 10.8, 13.2, 18.2),
      topLeft: const Radius.circular(5.0),
      topRight: const Radius.circular(5.0),
      bottomLeft: const Radius.circular(3.2),
      bottomRight: const Radius.circular(3.2),
    );
    canvas.drawRRect(body1RRect, cutoutPaint);

    // --- 3. Foreground Person (Person 1 - Left side) ---
    // Head 1 fill
    canvas.drawCircle(const Offset(7.0, 4.8), 3.8, fillPaint);

    // Torso 1 fill
    canvas.drawRRect(body1RRect, fillPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ProviderGroupVectorPainter oldDelegate) =>
      color != oldDelegate.color || backgroundColor != oldDelegate.backgroundColor;
}

/// Vector chevron right matching Figma specifications:
/// width: 4; height: 8; angle: -180 deg; border-width: 0.6px; border: 0.6px solid #1C2926
class _ChevronRightVectorPainter extends CustomPainter {
  final Color color;
  const _ChevronRightVectorPainter({this.color = const Color(0xFF1C2926)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0.5, 0.5)
      ..lineTo(size.width - 0.5, size.height / 2.0)
      ..lineTo(0.5, size.height - 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



