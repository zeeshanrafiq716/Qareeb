import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/provider_model.dart';
import '../../../providers/backend_provider.dart';
import '../../../services/location_service.dart';
import 'find_provider_screen.dart';
import 'send_request_screen.dart';
import 'widgets/top_down_car_widget.dart';

/// Screen displayed after allowing location access for Pickup & Delivery.
/// Features a real draggable interactive map, authentic nearby provider cars
/// covering proper geographic distances, and brand purple styling.
class PickupDeliveryScreen extends ConsumerStatefulWidget {
  final String serviceName;

  const PickupDeliveryScreen({
    super.key,
    this.serviceName = 'Pickup & Delivery',
  });

  @override
  ConsumerState<PickupDeliveryScreen> createState() => _PickupDeliveryScreenState();
}

/// Model representing a realistic nearby driver on the map
class NearbyDriverOnMap {
  final int id;
  final String name;
  final String vehicle;
  final double rating;
  final int reviews;
  final double initialDistanceKm;
  final double baseDistancePx;
  final double angleRad;
  final double roadAngle;
  final double roadLengthPx;
  final double speed;
  final Color roofColor;

  const NearbyDriverOnMap({
    required this.id,
    required this.name,
    this.vehicle = 'Sedan • AC',
    this.rating = 4.9,
    this.reviews = 120,
    required this.initialDistanceKm,
    required this.baseDistancePx,
    required this.angleRad,
    required this.roadAngle,
    this.roadLengthPx = 55.0,
    this.speed = 0.8,
    this.roofColor = const Color(0xFFA67AFE),
  });

  /// Computes live position on the map space relative to user center
  Offset calculatePosition(double t, Offset userCenter) {
    final double baseX = userCenter.dx + baseDistancePx * math.cos(angleRad);
    final double baseY = userCenter.dy + baseDistancePx * math.sin(angleRad);
    final double patrol = math.sin(t * speed * 2.0 * math.pi) * (roadLengthPx / 2.0);
    return Offset(
      baseX + patrol * math.cos(roadAngle),
      baseY + patrol * math.sin(roadAngle),
    );
  }

  /// Calculates car heading (facing forward along direction of motion)
  double calculateHeading(double t) {
    final double vel = math.cos(t * speed * 2.0 * math.pi);
    if (vel >= 0) {
      return (roadAngle * 180.0 / math.pi) + 90.0;
    } else {
      return (roadAngle * 180.0 / math.pi) - 90.0;
    }
  }

  /// Dynamic distance in km from user position
  double liveDistanceKm(Offset livePos, Offset userCenter) {
    final double distPx = (livePos - userCenter).distance;
    return double.parse((distPx / 160.0).clamp(0.2, 5.0).toStringAsFixed(1));
  }
}

class _PickupDeliveryScreenState extends ConsumerState<PickupDeliveryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _radarController;
  late final AnimationController _carMotionController;
  late final AnimationController _recenterController;

  int? _selectedCarId;
  Offset _mapPanOffset = Offset.zero;
  double _mapZoomScale = 1.0;
  bool _isDraggingMap = false;

  /// Realistic, clean, well-spaced nearby providers covering proper distance across the map
  static const List<NearbyDriverOnMap> nearbyDrivers = [
    // 1. Uzair Ahmed - 0.4 km away (North-West, within inner radar ring)
    NearbyDriverOnMap(
      id: 1,
      name: 'Uzair Ahmed',
      vehicle: 'Toyota Corolla • AC',
      rating: 4.9,
      reviews: 142,
      initialDistanceKm: 0.4,
      baseDistancePx: 68.0,
      angleRad: -2.2, // ~126° (North-West)
      roadAngle: 0.4,
      roadLengthPx: 45.0,
      speed: 0.8,
    ),
    // 2. Muhammad Bilal - 0.7 km away (North-East, outer ring)
    NearbyDriverOnMap(
      id: 2,
      name: 'Muhammad Bilal',
      vehicle: 'Honda Civic • AC',
      rating: 4.8,
      reviews: 95,
      initialDistanceKm: 0.7,
      baseDistancePx: 115.0,
      angleRad: -0.75, // ~43° (North-East)
      roadAngle: -0.6,
      roadLengthPx: 55.0,
      speed: 0.9,
    ),
    // 3. Adnan Said - 0.9 km away (East avenue)
    NearbyDriverOnMap(
      id: 3,
      name: 'Adnan Said',
      vehicle: 'Toyota Hilux • Pickup',
      rating: 4.9,
      reviews: 118,
      initialDistanceKm: 0.9,
      baseDistancePx: 148.0,
      angleRad: 0.15, // ~9° (East)
      roadAngle: 1.4,
      roadLengthPx: 60.0,
      speed: 0.7,
    ),
    // 4. Abdul Ahad - 1.2 km away (South-East district)
    NearbyDriverOnMap(
      id: 4,
      name: 'Abdul Ahad',
      vehicle: 'Hyundai Elantra • AC',
      rating: 5.0,
      reviews: 215,
      initialDistanceKm: 1.2,
      baseDistancePx: 195.0,
      angleRad: 1.65, // ~95° (South-East)
      roadAngle: -0.8,
      roadLengthPx: 70.0,
      speed: 1.0,
    ),
    // 5. Mehmood Ali - 1.5 km away (South-West district)
    NearbyDriverOnMap(
      id: 5,
      name: 'Mehmood Ali',
      vehicle: 'Toyota HiAce • Van',
      rating: 4.9,
      reviews: 88,
      initialDistanceKm: 1.5,
      baseDistancePx: 245.0,
      angleRad: 2.65, // ~152° (South-West)
      roadAngle: 0.9,
      roadLengthPx: 75.0,
      speed: 0.85,
    ),
    // 6. Hamza Sheikh - 2.0 km away (West main road)
    NearbyDriverOnMap(
      id: 6,
      name: 'Hamza Sheikh',
      vehicle: 'Suzuki Swift • Sedan',
      rating: 4.7,
      reviews: 80,
      initialDistanceKm: 2.0,
      baseDistancePx: 310.0,
      angleRad: 3.5, // ~200° (West)
      roadAngle: -1.2,
      roadLengthPx: 85.0,
      speed: 0.75,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // 1. Radar animation pulse
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    // 2. Continuous ambient car cruising across road segments
    _carMotionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    // 3. Smooth map recentering animation controller
    _recenterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void deactivate() {
    _radarController.stop();
    _carMotionController.stop();
    _recenterController.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _radarController.dispose();
    _carMotionController.dispose();
    _recenterController.dispose();
    super.dispose();
  }

  void _onCarTapped(int carId) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedCarId = (_selectedCarId == carId) ? null : carId;
    });
  }

  void _recenterMap() {
    HapticFeedback.lightImpact();
    final startOffset = _mapPanOffset;
    final tween = Tween<Offset>(begin: startOffset, end: Offset.zero);
    _recenterController.reset();
    final Animation<Offset> anim = tween.animate(
      CurvedAnimation(parent: _recenterController, curve: Curves.easeOutCubic),
    );
    anim.addListener(() {
      setState(() {
        _mapPanOffset = anim.value;
      });
    });
    _recenterController.forward();
  }

  void _zoomIn() {
    HapticFeedback.selectionClick();
    setState(() {
      _mapZoomScale = (_mapZoomScale + 0.15).clamp(0.75, 1.6);
    });
  }

  void _zoomOut() {
    HapticFeedback.selectionClick();
    setState(() {
      _mapZoomScale = (_mapZoomScale - 0.15).clamp(0.75, 1.6);
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

            final double beaconLeft = containerWidth >= 390
                ? 20.0
                : ((containerWidth - 350.0) / 2).clamp(10.0, 20.0);
            const double beaconTop = 108.0;
            final double beaconWidth = containerWidth >= 390
                ? 350.0
                : (containerWidth - (beaconLeft * 2.0));
            final double beaconHeight = (containerHeight - 270.0).clamp(380.0, 560.0);
            final double bottomCardTop = beaconTop + beaconHeight + 12.0;
            final double bottomCardHeight = math.max(140.0, containerHeight - bottomCardTop);

            final userLocAsync = ref.watch(userLocationProvider);
            final userLoc = userLocAsync.value ?? UserLocation.defaultLocation;

            final providersAsync = ref.watch(nearbyProvidersProvider);
            final liveProviders = providersAsync.value ?? const <ProviderModel>[];

            final screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                children: [
                  // 1. REAL INTERACTIVE DRAGGABLE MAP BEACON AREA
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
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: const Color(0xFF8B53FE).withValues(alpha: 0.18),
                          width: 1.2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 18.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: (details) {
                          setState(() {
                            _isDraggingMap = true;
                          });
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            _mapPanOffset = Offset(
                              (_mapPanOffset.dx + details.delta.dx).clamp(-400.0, 400.0),
                              (_mapPanOffset.dy + details.delta.dy).clamp(-350.0, 350.0),
                            );
                          });
                        },
                        onPanEnd: (details) {
                          setState(() {
                            _isDraggingMap = false;
                          });
                        },
                        child: MouseRegion(
                          cursor: _isDraggingMap
                              ? SystemMouseCursors.grabbing
                              : SystemMouseCursors.grab,
                          child: Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                              // A. Real Map Tile Layer (OpenStreetMap / CartoDB Voyager)
                              _RealMapTileLayer(
                                centerLat: userLoc.latitude,
                                centerLng: userLoc.longitude,
                                zoom: 15,
                                panOffset: _mapPanOffset,
                                width: beaconWidth,
                                height: beaconHeight,
                                scale: _mapZoomScale,
                              ),

                              // B. Purple Radar Outer Animated Pulse Circle
                              Positioned(
                                top: (beaconHeight - 210.0) / 2.0 + _mapPanOffset.dy,
                                left: (beaconWidth - 210.0) / 2.0 + _mapPanOffset.dx,
                                width: 210.0,
                                height: 210.0,
                                child: IgnorePointer(
                                  child: AnimatedBuilder(
                                    animation: _radarController,
                                    builder: (context, child) {
                                      final double wave = (math.sin(_radarController.value * 4.0 * math.pi) + 1.0) / 2.0;
                                      final double scale = 0.95 + 0.10 * wave;
                                      final double opacity = (0.65 + 0.35 * wave).clamp(0.0, 1.0);
                                      return Transform.scale(
                                        scale: scale,
                                        child: Opacity(opacity: opacity, child: child),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0x188B53FE),
                                        border: Border.all(
                                          color: const Color(0xFF8B53FE),
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // C. Purple Radar Inner Bold Wave Circle
                              Positioned(
                                top: (beaconHeight - 100.0) / 2.0 + _mapPanOffset.dy,
                                left: (beaconWidth - 100.0) / 2.0 + _mapPanOffset.dx,
                                width: 100.0,
                                height: 100.0,
                                child: IgnorePointer(
                                  child: AnimatedBuilder(
                                    animation: _radarController,
                                    builder: (context, child) {
                                      final double wave = (math.cos(_radarController.value * 4.0 * math.pi) + 1.0) / 2.0;
                                      final double scale = 0.92 + 0.14 * wave;
                                      final double opacity = (0.50 + 0.50 * wave).clamp(0.0, 1.0);
                                      return Transform.scale(
                                        scale: scale,
                                        child: Opacity(opacity: opacity, child: child),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0x188B53FE),
                                        border: Border.all(
                                          color: const Color(0xFF8B53FE),
                                          width: 1.8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // D. Customer Location Center Beacon
                              Positioned(
                                top: (beaconHeight - 30.0) / 2.0 + _mapPanOffset.dy,
                                left: (beaconWidth - 30.0) / 2.0 + _mapPanOffset.dx,
                                child: Tooltip(
                                  message: 'Your Location: ${userLoc.cityName}',
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            userLoc.isGpsDetected
                                                ? 'GPS: ${userLoc.coordinatesDisplay} • ${userLoc.cityName}'
                                                : 'Location: ${userLoc.cityName}',
                                            style: GoogleFonts.inter(
                                              fontSize: 12.0,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          backgroundColor: const Color(0xFF8B53FE),
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      key: const Key('user_gps_center_marker'),
                                      width: 30.0,
                                      height: 30.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF8B53FE),
                                        border: Border.all(color: Colors.white, width: 2.6),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x408B53FE),
                                            blurRadius: 12.0,
                                            spreadRadius: 3.0,
                                          ),
                                          BoxShadow(
                                            color: Color(0x20000000),
                                            blurRadius: 4.0,
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.my_location,
                                          size: 14.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // E. Realistic Nearby Provider Cars (properly spaced, zero badge overlap)
                              AnimatedBuilder(
                                animation: _carMotionController,
                                builder: (context, _) {
                                  final double progress = _carMotionController.value;
                                  final Offset centerOnMap = Offset(beaconWidth / 2.0, beaconHeight / 2.0);

                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      for (final car in nearbyDrivers)
                                        () {
                                          final Offset livePos = car.calculatePosition(progress, centerOnMap);
                                          final double heading = car.calculateHeading(progress);
                                          final bool isSelected = _selectedCarId == car.id;
                                          final double distKm = car.liveDistanceKm(livePos, centerOnMap);

                                          final double finalX = livePos.dx + _mapPanOffset.dx;
                                          final double finalY = livePos.dy + _mapPanOffset.dy;

                                          return Positioned(
                                            top: finalY - 14.25,
                                            left: finalX - 8.25,
                                            child: TopDownCarWidget(
                                              key: ValueKey('driver_car_${car.id}'),
                                              width: 16.5,
                                              height: 28.5,
                                              angle: heading,
                                              opacity: 1.0,
                                              driverName: car.name.split(' ').first,
                                              distanceKm: distKm,
                                              bodyColor: car.roofColor,
                                              showBadge: true,
                                              isSelected: isSelected,
                                              isInsideRadius: distKm <= 0.8,
                                              onTap: () => _onCarTapped(car.id),
                                            ),
                                          );
                                        }(),
                                    ],
                                  );
                                },
                              ),

                              // F. Floating Hint Pill at Top of Map
                              Positioned(
                                top: 12.0,
                                left: 0.0,
                                right: 0.0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.94),
                                      borderRadius: BorderRadius.circular(20.0),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x12000000),
                                          blurRadius: 8.0,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.pan_tool_alt_rounded,
                                          size: 13.0,
                                          color: Color(0xFF8B53FE),
                                        ),
                                        const SizedBox(width: 5.0),
                                        Text(
                                          '6 Drivers nearby • Drag map to explore',
                                          style: GoogleFonts.inter(
                                            fontSize: 11.0,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF1C2926),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // G. Floating Map Controls (Zoom in, Zoom out, Recenter)
                              Positioned(
                                bottom: 16.0,
                                right: 14.0,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildFloatingButton(
                                      icon: Icons.add_rounded,
                                      tooltip: 'Zoom in',
                                      onTap: _zoomIn,
                                    ),
                                    const SizedBox(height: 8.0),
                                    _buildFloatingButton(
                                      icon: Icons.remove_rounded,
                                      tooltip: 'Zoom out',
                                      onTap: _zoomOut,
                                    ),
                                    const SizedBox(height: 8.0),
                                    _buildFloatingButton(
                                      icon: Icons.my_location_rounded,
                                      tooltip: 'Recenter on my location',
                                      iconColor: const Color(0xFF8B53FE),
                                      onTap: _recenterMap,
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

                  // 2. HEADER BRANDING:
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
                            key: const Key('pickup_delivery_back_button'),
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

                  // 3. BOTTOM WIDGET / PROVIDERS CARD
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
                            color: Color(0x14000000),
                            offset: Offset(0, -2),
                            blurRadius: 12.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 12.0),
                            child: _selectedCarId != null
                                ? _buildSelectedDriverCard(
                                    containerWidth,
                                    liveProviders,
                                  )
                                : _buildProvidersInnerCard(
                                    containerWidth,
                                    liveProviders,
                                    userLoc,
                                  ),
                          ),

                          // Bottom home indicator bar
                          Positioned(
                            bottom: 8.0,
                            left: 0.0,
                            right: 0.0,
                            height: 24.0,
                            child: Center(
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
            );

            if (isDesktopWeb) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFF0F1F5),
                child: Center(
                  child: Container(
                    width: containerWidth,
                    height: containerHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(42),
                      border: Border.all(
                        color: const Color(0xFF8B53FE).withValues(alpha: 0.25),
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

  /// Floating button helper for map controls
  Widget _buildFloatingButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF1C2926),
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 36.0,
          height: 36.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 8.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20.0,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }

  /// Default Inner card branding: 6 Providers nearby + View all button
  Widget _buildProvidersInnerCard(
    double containerWidth,
    List<ProviderModel> liveProviders,
    UserLocationModel userLoc,
  ) {
    final double cardWidth = containerWidth >= 390
        ? 350.0
        : (containerWidth - 40.0).clamp(280.0, 350.0);

    final int count = liveProviders.isNotEmpty ? liveProviders.length : nearbyDrivers.length;
    final String locationSubtitle = (userLoc.cityName.isNotEmpty && userLoc.cityName != 'Detecting Location...')
        ? 'Within 2 km radius • ${userLoc.cityName}'
        : 'Within 2 km radius';

    return SizedBox(
      width: cardWidth,
      height: 41.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count Providers nearby',
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
              Text(
                locationSubtitle,
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

          // Right side View all button
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
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(width: 8.0),
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

  /// Selected driver details card within bottom widget
  Widget _buildSelectedDriverCard(
    double containerWidth,
    List<ProviderModel> liveProviders,
  ) {
    final selectedCar = nearbyDrivers.firstWhere(
      (c) => c.id == _selectedCarId,
      orElse: () => nearbyDrivers.first,
    );

    final double cardWidth = containerWidth >= 390
        ? 350.0
        : (containerWidth - 40.0).clamp(280.0, 350.0);

    final String driverName = selectedCar.name;

    return SizedBox(
      key: const Key('selected_driver_card'),
      width: cardWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EAFE),
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: const Center(
                  child: CustomPaint(
                    size: Size(18.0, 16.0),
                    painter: _ProviderCarVectorPainter(
                      color: Color(0xFF8B53FE),
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
                        Flexible(
                          child: Text(
                            driverName,
                            style: GoogleFonts.inter(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C2926),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            'ONLINE',
                            style: GoogleFonts.inter(
                              fontSize: 9.0,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3.0),
                    Row(
                      children: [
                        const Icon(
                          Icons.near_me_rounded,
                          size: 11.0,
                          color: Color(0xFF8B53FE),
                        ),
                        const SizedBox(width: 3.0),
                        Text(
                          '${selectedCar.initialDistanceKm} km away • ${selectedCar.vehicle}',
                          style: GoogleFonts.inter(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF566663),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 14.0),
          SizedBox(
            width: double.infinity,
            height: 44.0,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SendRequestScreen(
                      serviceCategory: widget.serviceName,
                      providerName: driverName,
                      distance: '${selectedCar.initialDistanceKm} km',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B53FE),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                'Confirm ${driverName.split(' ').first}',
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

/// Real Map Tile Layer supporting OpenStreetMap & CartoDB tiles with offline fallback
class _RealMapTileLayer extends StatelessWidget {
  final double centerLat;
  final double centerLng;
  final int zoom;
  final Offset panOffset;
  final double width;
  final double height;
  final double scale;

  const _RealMapTileLayer({
    required this.centerLat,
    required this.centerLng,
    this.zoom = 15,
    required this.panOffset,
    required this.width,
    required this.height,
    this.scale = 1.0,
  });

  static int _lon2tileX(double lon, int z) {
    return ((lon + 180.0) / 360.0 * (1 << z)).floor();
  }

  static int _lat2tileY(double lat, int z) {
    final double latRad = lat * math.pi / 180.0;
    return ((1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) / 2.0 * (1 << z)).floor();
  }

  static double _tileX2pixel(double lon, int z) {
    return (lon + 180.0) / 360.0 * (1 << z) * 256.0;
  }

  static double _tileY2pixel(double lat, int z) {
    final double latRad = lat * math.pi / 180.0;
    return (1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) / 2.0 * (1 << z) * 256.0;
  }

  @override
  Widget build(BuildContext context) {
    const double tileSize = 256.0;
    final int baseTileX = _lon2tileX(centerLng, zoom);
    final int baseTileY = _lat2tileY(centerLat, zoom);

    final double centerPixelX = _tileX2pixel(centerLng, zoom);
    final double centerPixelY = _tileY2pixel(centerLat, zoom);
    final double subTileOffsetX = centerPixelX - (baseTileX * tileSize);
    final double subTileOffsetY = centerPixelY - (baseTileY * tileSize);

    final double viewportCenterX = width / 2.0 + panOffset.dx;
    final double viewportCenterY = height / 2.0 + panOffset.dy;

    final List<Widget> tileWidgets = [];

    for (int dx = -2; dx <= 2; dx++) {
      for (int dy = -2; dy <= 2; dy++) {
        final int tileX = baseTileX + dx;
        final int tileY = baseTileY + dy;

        final double tileLeft = viewportCenterX - subTileOffsetX + (dx * tileSize);
        final double tileTop = viewportCenterY - subTileOffsetY + (dy * tileSize);

        final String tileUrl =
            'https://basemaps.cartocdn.com/rastertiles/voyager/$zoom/$tileX/$tileY.png';

        tileWidgets.add(
          Positioned(
            left: tileLeft,
            top: tileTop,
            width: tileSize,
            height: tileSize,
            child: Image.network(
              tileUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/BG image.png',
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        );
      }
    }

    return ClipRect(
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.center,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/BG image.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              ...tileWidgets,
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B53FE).withValues(alpha: 0.04),
                  ),
                ),
              ),
            ],
          ),
        ),
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

/// Vector car branding matching Figma specifications
class _ProviderCarVectorPainter extends CustomPainter {
  final Color color;
  const _ProviderCarVectorPainter({this.color = const Color(0xFF8B53FE)});

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

    // Tires peeking out
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

    // Car main body
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

    // Windshield divider
    final windshieldPath = Path();
    windshieldPath.moveTo(3.6, h * 0.44);
    windshieldPath.quadraticBezierTo(w * 0.5, h * 0.46, w - 3.6, h * 0.44);
    canvas.drawPath(windshieldPath, strokePaint);

    // Headlights
    canvas.drawCircle(Offset(4.2, h * 0.68), 1.1, strokePaint);
    canvas.drawCircle(Offset(w - 4.2, h * 0.68), 1.1, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vector chevron right matching Figma specifications:
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

    final path = Path();
    path.moveTo(0.5, 0.5);
    path.lineTo(size.width - 0.5, size.height / 2.0);
    path.lineTo(0.5, size.height - 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
