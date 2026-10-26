import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/localization/app_locale.dart';
import '../../../models/provider_model.dart';
import '../../../providers/backend_provider.dart';
import '../../../services/location_service.dart';
import 'find_provider_screen.dart';
import 'send_request_screen.dart';
import 'widgets/provider_detail_card_widget.dart';
import 'widgets/top_down_car_widget.dart';

/// Coordinate representation for geographical road calculations
class MapLatLng {
  final double latitude;
  final double longitude;

  const MapLatLng(this.latitude, this.longitude);
}

/// Standard Web Mercator (EPSG:3857) projection matching Google Maps & OpenStreetMap
class MercatorProjection {
  static double latToY(double lat, double zoom) {
    final double latRad = lat * math.pi / 180.0;
    final double sinLat = math.sin(latRad).clamp(-0.9999, 0.9999);
    return (128.0 / math.pi) * (1 << zoom.toInt()) * (math.pi - math.log((1.0 + sinLat) / (1.0 - sinLat)) / 2.0);
  }

  static double lngToX(double lng, double zoom) {
    return (128.0 / math.pi) * (1 << zoom.toInt()) * ((lng * math.pi / 180.0) + math.pi);
  }

  static double xToLng(double x, double zoom) {
    final double n = 256.0 * (1 << zoom.toInt());
    return (x / n) * 360.0 - 180.0;
  }

  static double yToLat(double y, double zoom) {
    final double n = 256.0 * (1 << zoom.toInt());
    final double u = math.pi * (1.0 - 2.0 * y / n);
    final double latRad = 2.0 * math.atan(math.exp(u)) - (math.pi / 2.0);
    return latRad * 180.0 / math.pi;
  }
}

/// Real road polyline path with segment distance, interpolation, and smooth corner turning
class RoadPath {
  final List<MapLatLng> waypoints;
  late final List<double> segmentDistances;
  late final List<double> segmentBearings;
  late final double totalDistance;

  RoadPath(this.waypoints) {
    segmentDistances = [];
    segmentBearings = [];
    double sum = 0.0;
    for (int i = 0; i < waypoints.length - 1; i++) {
      final d = haversineDistance(waypoints[i], waypoints[i + 1]);
      segmentDistances.add(d);
      segmentBearings.add(calculateBearing(waypoints[i], waypoints[i + 1]));
      sum += d;
    }
    totalDistance = sum > 0 ? sum : 0.001;
  }

  /// Calculates geodesic distance in meters between two coordinates
  static double haversineDistance(MapLatLng p1, MapLatLng p2) {
    const double r = 6371000.0; // Earth radius in meters
    final dLat = (p2.latitude - p1.latitude) * math.pi / 180.0;
    final dLng = (p2.longitude - p1.longitude) * math.pi / 180.0;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(p1.latitude * math.pi / 180.0) *
            math.cos(p2.latitude * math.pi / 180.0) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  /// Calculates forward bearing in degrees (0..360, 0=North) from start to end
  static double calculateBearing(MapLatLng start, MapLatLng end) {
    final double lat1 = start.latitude * math.pi / 180.0;
    final double lng1 = start.longitude * math.pi / 180.0;
    final double lat2 = end.latitude * math.pi / 180.0;
    final double lng2 = end.longitude * math.pi / 180.0;
    final double dLng = lng2 - lng1;
    final double y = math.sin(dLng) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    final double bearing = math.atan2(y, x) * 180.0 / math.pi;
    return (bearing + 360.0) % 360.0;
  }

  /// Evaluates car's live position and heading angle along the road.
  /// Smooth normal forward cruising along streets with realistic gradual corner turns.
  ({MapLatLng position, double heading}) evaluate(double t) {
    if (waypoints.isEmpty) {
      return (position: const MapLatLng(0, 0), heading: 0.0);
    }
    if (waypoints.length == 1) {
      return (position: waypoints.first, heading: 0.0);
    }

    final double clampedT = t.clamp(0.0, 1.0);
    final double targetDist = clampedT * totalDistance;

    double accumulated = 0.0;
    for (int i = 0; i < waypoints.length - 1; i++) {
      final segDist = segmentDistances[i];
      if (accumulated + segDist >= targetDist || i == waypoints.length - 2) {
        final double fraction = (segDist > 0)
            ? ((targetDist - accumulated) / segDist).clamp(0.0, 1.0)
            : 0.0;

        final MapLatLng p1 = waypoints[i];
        final MapLatLng p2 = waypoints[i + 1];

        final double lat = p1.latitude + fraction * (p2.latitude - p1.latitude);
        final double lng = p1.longitude + fraction * (p2.longitude - p1.longitude);

        final double currentBearing = segmentBearings[i];
        double heading = currentBearing;

        // Smooth gradual corner turn during the last 20% of the segment
        if (fraction > 0.80 && i < segmentBearings.length - 1) {
          final double turnFraction = ((fraction - 0.80) / 0.20).clamp(0.0, 1.0);
          final double nextBearing = segmentBearings[i + 1];
          heading = interpolateAngle(currentBearing, nextBearing, turnFraction);
        } else if (fraction > 0.80 && i == segmentBearings.length - 1) {
          // If closed loop, smoothly turn towards first segment bearing
          final double turnFraction = ((fraction - 0.80) / 0.20).clamp(0.0, 1.0);
          final double nextBearing = segmentBearings.first;
          heading = interpolateAngle(currentBearing, nextBearing, turnFraction);
        }

        return (position: MapLatLng(lat, lng), heading: heading);
      }
      accumulated += segDist;
    }

    final MapLatLng pLast = waypoints.last;
    return (
      position: pLast,
      heading: segmentBearings.isNotEmpty ? segmentBearings.last : 0.0,
    );
  }

  /// Calculates shortest-arc angle interpolation (e.g. 350° to 10° is +20°, not -340°)
  static double interpolateAngle(double a1, double a2, double t) {
    double diff = (a2 - a1) % 360.0;
    if (diff > 180.0) diff -= 360.0;
    if (diff < -180.0) diff += 360.0;
    return (a1 + diff * t + 360.0) % 360.0;
  }

  /// Evaluates car's live position and heading angle along a street line.
  /// Smoothly patrols forward and backward along the road (ping-pong street cruising).
  ({MapLatLng position, double heading}) evaluatePatrol(double progress) {
    if (waypoints.isEmpty) {
      return (position: const MapLatLng(0, 0), heading: 0.0);
    }
    if (waypoints.length == 1) {
      return (position: waypoints.first, heading: 0.0);
    }

    // 2.0 cycle: 0.0..1.0 forward along street, 1.0..2.0 backward along street
    final double cycle = (progress % 2.0 + 2.0) % 2.0;
    final bool isForward = cycle <= 1.0;
    final double t = isForward ? cycle : (2.0 - cycle);

    final result = evaluate(t);
    final double fwdHeading = result.heading;
    final double revHeading = (fwdHeading + 180.0) % 360.0;

    double heading = isForward ? fwdHeading : revHeading;

    // Smooth turnaround around the ends
    if (cycle > 0.95 && cycle < 1.05) {
      final double turnFrac = ((cycle - 0.95) / 0.10).clamp(0.0, 1.0);
      heading = interpolateAngle(fwdHeading, revHeading, turnFrac);
    } else if (cycle > 1.95 || cycle < 0.05) {
      final double c = cycle > 1.95 ? (cycle - 1.95) : (cycle + 0.05);
      final double turnFrac = (c / 0.10).clamp(0.0, 1.0);
      heading = interpolateAngle(revHeading, fwdHeading, turnFrac);
    }

    return (position: result.position, heading: heading);
  }
}

/// Model representing a nearby driver patrolling a designated road corridor
class NearbyDriverRoute {
  final int id;
  final String name;
  final String vehicle;
  final double rating;
  final int reviews;
  final double initialDistanceKm;
  final Color roofColor;
  final double speedFactor;
  final double startPhase;
  final List<MapLatLng> waypoints;
  late final RoadPath roadPath;

  NearbyDriverRoute({
    required this.id,
    required this.name,
    this.vehicle = 'Sedan • AC',
    this.rating = 4.9,
    this.reviews = 120,
    required this.initialDistanceKm,
    this.roofColor = const Color(0xFFA67AFE),
    this.speedFactor = 1.0,
    this.startPhase = 0.0,
    required this.waypoints,
  }) {
    roadPath = RoadPath(waypoints);
  }

  /// Calculates dynamic live distance in km from user position
  double liveDistanceKm(MapLatLng carPos, MapLatLng userPos) {
    final dMeters = RoadPath.haversineDistance(carPos, userPos);
    return double.parse((dMeters / 1000.0).clamp(0.1, 15.0).toStringAsFixed(1));
  }
}

/// Screen displayed for Pickup & Delivery featuring:
/// - Infinite drag & drop like Google Maps (no boundary clamping)
/// - Original top-down car design with driver name & distance badge
/// - Real road path markings & smooth car turning along road curves
class PickupDeliveryScreen extends ConsumerStatefulWidget {
  final String serviceName;

  const PickupDeliveryScreen({
    super.key,
    this.serviceName = 'Pickup & Delivery',
  });

  @override
  ConsumerState<PickupDeliveryScreen> createState() => _PickupDeliveryScreenState();
}

class _PickupDeliveryScreenState extends ConsumerState<PickupDeliveryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _radarController;
  late final AnimationController _carMotionController;
  late final AnimationController _recenterController;

  int? _selectedCarId;
  bool _isDraggingMap = false;
  bool _isFullViewMode = false;

  // Real-time GPS location trace state
  UserLocation? _exactTracedLocation;
  bool _isTracingGps = false;

  // Dynamic provider count filter: 3, 5, or 10 nearest providers
  int _selectedProviderCount = 5;
  AnimationController? _zoomAnimationController;
  Animation<double>? _zoomAnimation;

  double _zoom = 13.0; // Natural view framing nearest 5 providers
  double? _centerPixelX;
  double? _centerPixelY;

  List<NearbyDriverRoute>? _driverRoutes;
  double? _lastBuiltLat;
  double? _lastBuiltLng;

  @override
  void initState() {
    super.initState();

    // 1. Radar wave pulse
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    // 2. Normal, realistic city cruising speed along street corridors
    _carMotionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    // 3. Smooth map recentering animation controller
    _recenterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _radarController.dispose();
    _carMotionController.dispose();
    _recenterController.dispose();
    _zoomAnimationController?.dispose();
    super.dispose();
  }

  /// Generates realistic linear road corridors for each service provider (single road line, no closed boxes)
  /// Distributed naturally within 5 km and 10 km so radius filters dynamically highlight nearby vs distant providers.
  List<NearbyDriverRoute> _generateDriverRoutes(double centerLat, double centerLng) {
    return [
      // 1. Uzair Ahmed (~0.4 km - incoming car heading to customer)
      NearbyDriverRoute(
        id: 1,
        name: 'Uzair Ahmed',
        vehicle: 'Toyota Corolla • AC',
        rating: 4.9,
        reviews: 142,
        initialDistanceKm: 0.4,
        roofColor: const Color(0xFFA67AFE),
        speedFactor: 0.85,
        startPhase: 0.2,
        waypoints: [
          MapLatLng(centerLat + 0.0032, centerLng + 0.0020),
          MapLatLng(centerLat + 0.0008, centerLng + 0.0020),
          MapLatLng(centerLat + 0.0008, centerLng),
          MapLatLng(centerLat, centerLng),
        ],
      ),
      // 2. Muhammad Bilal (~0.8 km)
      NearbyDriverRoute(
        id: 2,
        name: 'Muhammad Bilal',
        vehicle: 'Honda Civic • AC',
        rating: 4.8,
        reviews: 95,
        initialDistanceKm: 0.8,
        roofColor: const Color(0xFF8B53FE),
        speedFactor: 0.80,
        startPhase: 0.7,
        waypoints: [
          MapLatLng(centerLat - 0.0055, centerLng + 0.0036),
          MapLatLng(centerLat - 0.0014, centerLng + 0.0036),
          MapLatLng(centerLat - 0.0014, centerLng),
          MapLatLng(centerLat, centerLng),
        ],
      ),
      // 3. Adnan Said (~1.2 km)
      NearbyDriverRoute(
        id: 3,
        name: 'Adnan Said',
        vehicle: 'Toyota Hilux • Pickup',
        rating: 4.9,
        reviews: 118,
        initialDistanceKm: 1.2,
        roofColor: const Color(0xFF7C3AED),
        speedFactor: 0.90,
        startPhase: 0.4,
        waypoints: [
          MapLatLng(centerLat + 0.0080, centerLng - 0.0052),
          MapLatLng(centerLat + 0.0022, centerLng - 0.0052),
          MapLatLng(centerLat + 0.0022, centerLng),
          MapLatLng(centerLat, centerLng),
        ],
      ),
      // 4. Abdul Ahad (~1.8 km)
      NearbyDriverRoute(
        id: 4,
        name: 'Abdul Ahad',
        vehicle: 'Hyundai Elantra • AC',
        rating: 5.0,
        reviews: 215,
        initialDistanceKm: 1.8,
        roofColor: const Color(0xFF6D28D9),
        speedFactor: 0.80,
        startPhase: 0.9,
        waypoints: [
          MapLatLng(centerLat - 0.0110, centerLng - 0.0080),
          MapLatLng(centerLat - 0.0028, centerLng - 0.0080),
          MapLatLng(centerLat - 0.0028, centerLng),
          MapLatLng(centerLat, centerLng),
        ],
      ),
      // 5. Mehmood Ali (~2.5 km)
      NearbyDriverRoute(
        id: 5,
        name: 'Mehmood Ali',
        vehicle: 'Toyota HiAce • Van',
        rating: 4.9,
        reviews: 88,
        initialDistanceKm: 2.5,
        roofColor: const Color(0xFF9333EA),
        speedFactor: 0.85,
        startPhase: 0.1,
        waypoints: [
          MapLatLng(centerLat + 0.0145, centerLng + 0.0110),
          MapLatLng(centerLat + 0.0038, centerLng + 0.0110),
          MapLatLng(centerLat + 0.0038, centerLng),
          MapLatLng(centerLat, centerLng),
        ],
      ),
      // 6. Hamza Sheikh (~3.3 km)
      NearbyDriverRoute(
        id: 6,
        name: 'Hamza Sheikh',
        vehicle: 'Suzuki Swift • Sedan',
        rating: 4.7,
        reviews: 80,
        initialDistanceKm: 3.3,
        roofColor: const Color(0xFFA855F7),
        speedFactor: 0.85,
        startPhase: 0.6,
        waypoints: [
          MapLatLng(centerLat - 0.0210, centerLng + 0.0160),
          MapLatLng(centerLat - 0.0050, centerLng + 0.0160),
          MapLatLng(centerLat - 0.0050, centerLng),
          MapLatLng(centerLat, centerLng),
        ],
      ),
      // 7. Zeeshan Tariq (~4.1 km)
      NearbyDriverRoute(
        id: 7,
        name: 'Zeeshan Tariq',
        vehicle: 'Kia Sportage • SUV',
        rating: 4.9,
        reviews: 164,
        initialDistanceKm: 4.1,
        roofColor: const Color(0xFF7E22CE),
        speedFactor: 0.85,
        startPhase: 0.3,
        waypoints: [
          MapLatLng(centerLat + 0.0260, centerLng - 0.0195),
          MapLatLng(centerLat + 0.0062, centerLng - 0.0195),
          MapLatLng(centerLat + 0.0062, centerLng),
          MapLatLng(centerLat, centerLng),
        ],
      ),
      // 8. Usman Farooq (~5.0 km)
      NearbyDriverRoute(
        id: 8,
        name: 'Usman Farooq',
        vehicle: 'Honda City • AC',
        rating: 4.8,
        reviews: 110,
        initialDistanceKm: 5.0,
        roofColor: const Color(0xFF8B5CF6),
        speedFactor: 0.80,
        startPhase: 0.8,
        waypoints: [
          MapLatLng(centerLat - 0.0320, centerLng - 0.0240),
          MapLatLng(centerLat - 0.0075, centerLng - 0.0240),
          MapLatLng(centerLat - 0.0075, centerLng),
          MapLatLng(centerLat, centerLng),
        ],
      ),
      // 9. Kashif Raza (~5.9 km)
      NearbyDriverRoute(
        id: 9,
        name: 'Kashif Raza',
        vehicle: 'Suzuki Cultus • AC',
        rating: 4.6,
        reviews: 72,
        initialDistanceKm: 5.9,
        roofColor: const Color(0xFF6B21A8),
        speedFactor: 0.85,
        startPhase: 0.5,
        waypoints: [
          MapLatLng(centerLat + 0.0380, centerLng + 0.0280),
          MapLatLng(centerLat + 0.0090, centerLng + 0.0280),
          MapLatLng(centerLat + 0.0090, centerLng),
          MapLatLng(centerLat, centerLng),
        ],
      ),
      // 10. Farhan Malik (~6.9 km)
      NearbyDriverRoute(
        id: 10,
        name: 'Farhan Malik',
        vehicle: 'Hyundai Tucson • SUV',
        rating: 4.9,
        reviews: 135,
        initialDistanceKm: 6.9,
        roofColor: const Color(0xFF581C87),
        speedFactor: 0.85,
        startPhase: 0.4,
        waypoints: [
          MapLatLng(centerLat - 0.0440, centerLng + 0.0330),
          MapLatLng(centerLat - 0.0105, centerLng + 0.0330),
          MapLatLng(centerLat - 0.0105, centerLng),
          MapLatLng(centerLat, centerLng),
        ],
      ),
    ];
  }

  void _onCarTapped(int carId) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedCarId = (_selectedCarId == carId) ? null : carId;
    });
  }

  void _recenterMap(double centerLat, double centerLng) {
    HapticFeedback.lightImpact();
    final targetX = MercatorProjection.lngToX(centerLng, _zoom);
    final targetY = MercatorProjection.latToY(centerLat, _zoom);

    final startX = _centerPixelX ?? targetX;
    final startY = _centerPixelY ?? targetY;

    _recenterController.reset();
    final tweenX = Tween<double>(begin: startX, end: targetX);
    final tweenY = Tween<double>(begin: startY, end: targetY);

    final Animation<double> anim = CurvedAnimation(
      parent: _recenterController,
      curve: Curves.easeOutCubic,
    );
    anim.addListener(() {
      setState(() {
        _centerPixelX = tweenX.evaluate(anim);
        _centerPixelY = tweenY.evaluate(anim);
      });
    });
    _recenterController.forward();
  }

  /// Traces customer's exact device GPS location live.
  /// Bypasses cache, refreshes global location state, repositions map beacon, and recalculates nearby routes.
  Future<void> _traceCurrentGps() async {
    if (_isTracingGps) return;
    HapticFeedback.mediumImpact();

    setState(() {
      _isTracingGps = true;
    });

    final tr = ref.read(translationsProvider);

    // Initial feedback: Tracing GPS
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 14.0,
                height: 14.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                tr.isArabic ? 'جارٍ تحديد موقع GPS الدقيق...' : 'Tracing exact GPS location...',
                style: tr.font(fontSize: 12.0, color: Colors.white),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF8B53FE),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    try {
      final locService = ref.read(locationServiceProvider);
      final freshLoc = await locService.traceExactGps();

      if (!mounted) return;

      setState(() {
        _exactTracedLocation = freshLoc;
        _driverRoutes = _generateDriverRoutes(freshLoc.latitude, freshLoc.longitude);
        _lastBuiltLat = freshLoc.latitude;
        _lastBuiltLng = freshLoc.longitude;
        _isTracingGps = false;
      });

      // Smoothly animate map camera directly to exact traced GPS
      _recenterMap(freshLoc.latitude, freshLoc.longitude);

      // Refresh global providers so other screens stay updated
      ref.refresh(userLocationProvider);
      ref.refresh(nearbyProvidersProvider);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                freshLoc.isGpsDetected ? Icons.my_location_rounded : Icons.location_off_rounded,
                size: 16.0,
                color: Colors.white,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  freshLoc.isGpsDetected
                      ? (tr.isArabic
                          ? 'تم تحديد GPS بدقة: ${freshLoc.exactCoordinatesDisplay} (${freshLoc.cityName})'
                          : 'Exact GPS Traced: ${freshLoc.exactCoordinatesDisplay} (${freshLoc.cityName})')
                      : (tr.isArabic
                          ? 'خدمة الموقع غير مفعلة في جهازك'
                          : 'Device location is OFF. Please turn ON location in device settings.'),
                  style: tr.font(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: freshLoc.isGpsDetected ? const Color(0xFF1C2926) : const Color(0xFFE11D48),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isTracingGps = false;
      });
      final curLoc = _exactTracedLocation ?? ref.read(userLocationProvider).value ?? UserLocation.defaultLocation;
      _recenterMap(curLoc.latitude, curLoc.longitude);
    }
  }

  void _zoomIn() {
    HapticFeedback.selectionClick();
    if (_zoom >= 18.0) return;
    setState(() {
      final curLng = MercatorProjection.xToLng(_centerPixelX!, _zoom);
      final curLat = MercatorProjection.yToLat(_centerPixelY!, _zoom);
      _zoom += 0.5;
      _centerPixelX = MercatorProjection.lngToX(curLng, _zoom);
      _centerPixelY = MercatorProjection.latToY(curLat, _zoom);
    });
  }

  void _zoomOut() {
    HapticFeedback.selectionClick();
    if (_zoom <= 10.0) return;
    setState(() {
      final curLng = MercatorProjection.xToLng(_centerPixelX!, _zoom);
      final curLat = MercatorProjection.yToLat(_centerPixelY!, _zoom);
      _zoom -= 0.5;
      _centerPixelX = MercatorProjection.lngToX(curLng, _zoom);
      _centerPixelY = MercatorProjection.latToY(curLat, _zoom);
    });
  }

  /// Calculates the dynamic circle radius in meters so that exactly the nearest [count] providers
  /// are enclosed within the animated radar circle.
  double _calculateRadiusForCount(int count, MapLatLng userPos) {
    if (_driverRoutes == null || _driverRoutes!.isEmpty) {
      if (count <= 2) return 1000.0;
      if (count <= 4) return 1800.0;
      if (count <= 6) return 3000.0;
      if (count <= 8) return 5200.0;
      return 7500.0;
    }
    final distances = _driverRoutes!.map((d) {
      return RoadPath.haversineDistance(d.roadPath.waypoints.first, userPos);
    }).toList()
      ..sort();

    final int idx = (count - 1).clamp(0, distances.length - 1);
    final double buffer = count <= 2
        ? 300.0
        : (count <= 5 ? 420.0 : (count <= 8 ? 550.0 : 650.0));
    return distances[idx] + buffer;
  }

  /// Calculates the ideal camera zoom level for framing the selected provider count circle
  double _calculateZoomForCount(int count) {
    if (count <= 2) return 14.4;
    if (count <= 4) return 13.8;
    if (count <= 6) return 13.0;
    if (count <= 8) return 12.3;
    return 11.7;
  }

  /// Changes the active provider count filter (3, 5, or 10 providers)
  /// Smoothly animates the map zoom to naturally fit the new radius circle
  void _selectProviderCountFilter(int count) {
    if (_selectedProviderCount == count) return;
    HapticFeedback.selectionClick();

    final double targetZoom = _calculateZoomForCount(count);
    final double startZoom = _zoom;

    setState(() {
      _selectedProviderCount = count;
    });

    if (_centerPixelX != null && _centerPixelY != null) {
      final centerLng = MercatorProjection.xToLng(_centerPixelX!, _zoom);
      final centerLat = MercatorProjection.yToLat(_centerPixelY!, _zoom);

      _zoomAnimationController?.dispose();
      _zoomAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 550),
      );

      _zoomAnimation = Tween<double>(begin: startZoom, end: targetZoom).animate(
        CurvedAnimation(
          parent: _zoomAnimationController!,
          curve: Curves.easeInOutCubic,
        ),
      )..addListener(() {
          setState(() {
            _zoom = _zoomAnimation!.value;
            _centerPixelX = MercatorProjection.lngToX(centerLng, _zoom);
            _centerPixelY = MercatorProjection.latToY(centerLat, _zoom);
          });
        });

      _zoomAnimationController!.forward();
    }
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

    return PopScope(
      canPop: !_isFullViewMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isFullViewMode) {
          setState(() {
            _isFullViewMode = false;
          });
        }
      },
      child: Scaffold(
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
              final double beaconWidth = containerWidth >= 390
                  ? 350.0
                  : (containerWidth - (beaconLeft * 2.0));

              final double safeTop = math.max(12.0, MediaQuery.of(context).padding.top);
              final double sliderTop = isDesktopWeb ? 16.0 : (safeTop + 4.0);
              const double sliderHeight = 56.0;
              final double headerTop = sliderTop + sliderHeight + 8.0;
              const double headerHeight = 36.0;
              final double beaconTop = headerTop + headerHeight + 10.0;
              final double beaconHeight = (containerHeight - beaconTop - 160.0).clamp(320.0, 520.0);
              final double bottomCardTop = beaconTop + beaconHeight + 10.0;
              final double bottomCardHeight = math.max(140.0, containerHeight - bottomCardTop);

              final double effectiveBeaconTop = _isFullViewMode ? 0.0 : beaconTop;
              final double effectiveBeaconLeft = _isFullViewMode ? 0.0 : beaconLeft;
              final double effectiveBeaconWidth = _isFullViewMode ? containerWidth : beaconWidth;
              final double effectiveBeaconHeight = _isFullViewMode ? containerHeight : beaconHeight;

              final userLocAsync = ref.watch(userLocationProvider);
              final userLoc = _exactTracedLocation ?? userLocAsync.value ?? UserLocation.defaultLocation;
              final userPos = MapLatLng(userLoc.latitude, userLoc.longitude);
              final double targetCircleRadiusMeters = _calculateRadiusForCount(_selectedProviderCount, userPos);

              if (_driverRoutes == null ||
                  _lastBuiltLat != userLoc.latitude ||
                  _lastBuiltLng != userLoc.longitude) {
                _driverRoutes = _generateDriverRoutes(userLoc.latitude, userLoc.longitude);
                _lastBuiltLat = userLoc.latitude;
                _lastBuiltLng = userLoc.longitude;
              }

              // Initialize or sync center pixel coordinates to user location
              _centerPixelX ??= MercatorProjection.lngToX(userLoc.longitude, _zoom);
              _centerPixelY ??= MercatorProjection.latToY(userLoc.latitude, _zoom);

              // Calculate geographic scale in meters per pixel using Web Mercator
              final double metersPerPixel = (156543.03392 * math.cos(userLoc.latitude * math.pi / 180.0)) / (1 << _zoom.toInt());

              final double leftPx = _centerPixelX! - (effectiveBeaconWidth / 2.0);
              final double topPx = _centerPixelY! - (effectiveBeaconHeight / 2.0);

            // User GPS position in on-screen pixels
            final double userScreenX = MercatorProjection.lngToX(userLoc.longitude, _zoom) - leftPx;
            final double userScreenY = MercatorProjection.latToY(userLoc.latitude, _zoom) - topPx;

            final providersAsync = ref.watch(nearbyProvidersProvider);
            final liveProviders = providersAsync.value ?? const <ProviderModel>[];

            final screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                children: [
                  // 1. REAL INTERACTIVE DRAGGABLE MAP BEACON (INFINITE DRAG & DROP)
                  Positioned(
                    top: effectiveBeaconTop,
                    left: effectiveBeaconLeft,
                    width: effectiveBeaconWidth,
                    height: effectiveBeaconHeight,
                    child: Container(
                      key: const Key('map_widget_beacon'),
                      width: effectiveBeaconWidth,
                      height: effectiveBeaconHeight,
                      decoration: BoxDecoration(
                        borderRadius: _isFullViewMode
                            ? BorderRadius.zero
                            : BorderRadius.circular(20.0),
                        border: _isFullViewMode
                            ? null
                            : Border.all(
                                color: const Color(0xFF8B53FE).withValues(alpha: 0.18),
                                width: 1.2,
                              ),
                        boxShadow: _isFullViewMode
                            ? null
                            : const [
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
                        // INFINITE DRAGGING: No clamp restriction! You can drag as much as you want anywhere!
                        onPanUpdate: (details) {
                          setState(() {
                            _centerPixelX = _centerPixelX! - details.delta.dx;
                            _centerPixelY = _centerPixelY! - details.delta.dy;
                          });
                        },
                        onPanEnd: (details) {
                          setState(() {
                            _isDraggingMap = false;
                          });
                        },
                        onTap: () {
                          if (_selectedCarId != null) {
                            setState(() {
                              _selectedCarId = null;
                            });
                          }
                        },
                        child: MouseRegion(
                          cursor: _isDraggingMap
                              ? SystemMouseCursors.grabbing
                              : SystemMouseCursors.grab,
                          child: Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                              // A. Real Slippy Map Layer (Google Road Tiles / OSM) with Infinite Viewport Loading
                              _DynamicMapTileLayer(
                                centerPixelX: _centerPixelX!,
                                centerPixelY: _centerPixelY!,
                                zoom: _zoom,
                                width: effectiveBeaconWidth,
                                height: effectiveBeaconHeight,
                              ),

                              // B. Light Purple Route Line Tracking & Covering Road to Customer
                              Positioned.fill(
                                child: AnimatedBuilder(
                                  animation: _carMotionController,
                                  builder: (context, _) {
                                    return CustomPaint(
                                      painter: _RoadMarkingsPainter(
                                        routes: _driverRoutes!,
                                        zoom: _zoom,
                                        leftPx: leftPx,
                                        topPx: topPx,
                                        selectedId: _selectedCarId,
                                        animProgress: _carMotionController.value,
                                        userPos: userPos,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // B2. Complete Road Distance Badge Marked on the Route Line
                              () {
                                final activeDriver = (_selectedCarId != null)
                                    ? _driverRoutes!.firstWhere(
                                        (r) => r.id == _selectedCarId,
                                        orElse: () => _driverRoutes!.first,
                                      )
                                    : _driverRoutes!.first;

                                final double totalRoadKm = activeDriver.initialDistanceKm;
                                final midPoint = activeDriver.roadPath.waypoints.length > 2
                                    ? activeDriver.roadPath.waypoints[1]
                                    : activeDriver.roadPath.waypoints.first;
                                final double badgeScreenX = MercatorProjection.lngToX(midPoint.longitude, _zoom) - leftPx;
                                final double badgeScreenY = MercatorProjection.latToY(midPoint.latitude, _zoom) - topPx;

                                return Positioned(
                                  left: badgeScreenX - 58.0,
                                  top: badgeScreenY - 26.0,
                                  child: IgnorePointer(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFB892FF), // light purple
                                        borderRadius: BorderRadius.circular(14.0),
                                        border: Border.all(color: Colors.white, width: 1.5),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x45B892FF),
                                            blurRadius: 10.0,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.route_rounded,
                                            size: 13.0,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4.5),
                                          Text(
                                            tr.isArabic
                                                ? 'مسافة الطريق: ${totalRoadKm.toStringAsFixed(1)} كم'
                                                : 'Road Distance: ${totalRoadKm.toStringAsFixed(1)} km',
                                            style: tr.font(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              height: 1.1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }(),

                              // C & D. Dynamic Animated Radius Circle & Proximity Ring (Adjusts smoothly according to applied provider count filter)
                              TweenAnimationBuilder<double>(
                                key: const ValueKey('animated_radius_circle_builder'),
                                tween: Tween<double>(
                                  begin: targetCircleRadiusMeters,
                                  end: targetCircleRadiusMeters,
                                ),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeInOutCubic,
                                builder: (context, animRadiusMeters, _) {
                                  final double outerRadiusPx = animRadiusMeters / metersPerPixel;
                                  final double innerRadiusPx = outerRadiusPx * 0.45;

                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // C. Customer User Radius Outer Animated Radar Circle (Reduced subtle opacity)
                                      Positioned(
                                        left: userScreenX - outerRadiusPx,
                                        top: userScreenY - outerRadiusPx,
                                        width: outerRadiusPx * 2.0,
                                        height: outerRadiusPx * 2.0,
                                        child: IgnorePointer(
                                          child: AnimatedBuilder(
                                            animation: _radarController,
                                            builder: (context, child) {
                                              final double wave = (math.sin(_radarController.value * 2.0 * math.pi) + 1.0) / 2.0;
                                              final double opacity = 0.35 + 0.15 * wave;
                                              return Opacity(
                                                opacity: opacity,
                                                child: child,
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: const Color(0xFF8B53FE).withValues(alpha: 0.025),
                                                border: Border.all(
                                                  color: const Color(0xFF8B53FE).withValues(alpha: 0.28),
                                                  width: 1.2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF8B53FE).withValues(alpha: 0.04),
                                                    blurRadius: 10.0,
                                                    spreadRadius: 1.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // D. Immediate Proximity Inner Ring (Reduced subtle opacity)
                                      Positioned(
                                        left: userScreenX - innerRadiusPx,
                                        top: userScreenY - innerRadiusPx,
                                        width: innerRadiusPx * 2.0,
                                        height: innerRadiusPx * 2.0,
                                        child: IgnorePointer(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color(0xFF8B53FE).withValues(alpha: 0.015),
                                              border: Border.all(
                                                color: const Color(0xFF8B53FE).withValues(alpha: 0.18),
                                                width: 1.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              // E. Customer Location Center Beacon
                              Positioned(
                                left: userScreenX - 15.0,
                                top: userScreenY - 15.0,
                                child: Tooltip(
                                  message: userLoc.isGpsDetected
                                      ? (tr.isArabic
                                          ? 'موقعك: ${userLoc.cityName}'
                                          : 'Your Location: ${userLoc.cityName}')
                                      : (tr.isArabic
                                          ? 'خدمة الموقع غير مفعلة'
                                          : 'Location is OFF (Showing default location)'),
                                  child: Container(
                                    key: const Key('user_gps_center_marker'),
                                    width: 30.0,
                                    height: 30.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: userLoc.isGpsDetected
                                          ? const Color(0xFF8B53FE)
                                          : const Color(0xFF6B7280),
                                      border: Border.all(color: Colors.white, width: 2.6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: userLoc.isGpsDetected
                                              ? const Color(0x408B53FE)
                                              : const Color(0x306B7280),
                                          blurRadius: 12.0,
                                          spreadRadius: 3.0,
                                        ),
                                        const BoxShadow(
                                          color: Color(0x20000000),
                                          blurRadius: 4.0,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        userLoc.isGpsDetected ? Icons.my_location : Icons.location_off_rounded,
                                        size: 14.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // F. 60 FPS SMOOTH CARS TRACING REAL ROADS WITH NAME & REAL DISTANCE BADGE!
                              AnimatedBuilder(
                                animation: _carMotionController,
                                builder: (context, _) {
                                  final double animProgress = _carMotionController.value;

                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      for (final driver in _driverRoutes!)
                                        () {
                                          final double p = (animProgress * driver.speedFactor * 2.0 + driver.startPhase);
                                          final live = driver.roadPath.evaluatePatrol(p);

                                          final double carX = MercatorProjection.lngToX(live.position.longitude, _zoom) - leftPx;
                                          final double carY = MercatorProjection.latToY(live.position.latitude, _zoom) - topPx;

                                          final bool isSelected = _selectedCarId == driver.id;
                                          final double distMeters = RoadPath.haversineDistance(live.position, userPos);
                                          final double realDistKm = double.parse((distMeters / 1000.0).toStringAsFixed(1));
                                          final bool isInsideRadius = distMeters <= targetCircleRadiusMeters;

                                          // Render exact aerodynamic car with Name & Real Distance Badge!
                                          return Positioned(
                                            left: carX - 45.0, // center horizontally (width = 90.0)
                                            top: carY - 51.5, // center vertically on car (height = 74.0)
                                            width: 90.0,
                                            height: 74.0,
                                            child: TopDownCarWidget(
                                              key: ValueKey('driver_car_${driver.id}'),
                                              width: 18.0,
                                              height: 31.0,
                                              angle: live.heading, // dynamic road bearing along street
                                              opacity: isInsideRadius ? 1.0 : 0.76,
                                              driverName: driver.name.split(' ').first,
                                              distanceKm: realDistKm,
                                              bodyColor: driver.roofColor,
                                              showBadge: true,
                                              isSelected: isSelected,
                                              isInsideRadius: isInsideRadius,
                                              onTap: () {
                                                _onCarTapped(driver.id);
                                                ProviderDetailCardWidget.showAsBottomSheet(
                                                  context: context,
                                                  providerName: driver.name,
                                                  serviceCategory: tr.categoryName(widget.serviceName, widget.serviceName),
                                                  vehicleName: driver.vehicle,
                                                  distance: tr.isArabic ? '${realDistKm.toStringAsFixed(1)} كم' : '${realDistKm.toStringAsFixed(1)} km',
                                                  estimatedTime: tr.isArabic ? '${(realDistKm * 3.5).round().clamp(1, 99)} د' : '${(realDistKm * 3.5).round().clamp(1, 99)} min',
                                                  rating: driver.rating,
                                                  tripsCount: driver.reviews,
                                                );
                                              },
                                            ),
                                          );
                                        }(),
                                    ],
                                  );
                                },
                              ),



                              // G. Full View Button in Map Top (Toggles complete full screen interactive map)
                              if (!_isFullViewMode)
                                Positioned(
                                  top: 12.0,
                                  right: 12.0,
                                  child: Tooltip(
                                    message: tr.isArabic ? 'عرض الخريطة بالكامل' : 'Full map view',
                                    child: GestureDetector(
                                      key: const Key('map_full_view_toggle_button'),
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        setState(() {
                                          _isFullViewMode = true;
                                        });
                                      },
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.95),
                                          borderRadius: BorderRadius.circular(16.0),
                                          border: Border.all(
                                            color: const Color(0xFF8B53FE).withValues(alpha: 0.25),
                                            width: 1.0,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x18000000),
                                              blurRadius: 8.0,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.fullscreen_rounded,
                                              size: 18.0,
                                              color: Color(0xFF8B53FE),
                                            ),
                                            const SizedBox(width: 4.0),
                                            Text(
                                              tr.isArabic ? 'عرض كامل' : 'Full View',
                                              style: tr.font(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF1C2926),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              // H. Floating Map Controls (Zoom in, Zoom out, Recenter)
                              Positioned(
                                bottom: (_isFullViewMode && _selectedCarId != null) ? 150.0 : 16.0,
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
                                      key: const Key('current_location_button'),
                                      icon: userLoc.isGpsDetected ? Icons.my_location_rounded : Icons.location_off_rounded,
                                      tooltip: userLoc.isGpsDetected
                                          ? (tr.isArabic ? 'تحديد موقعي الدقيق' : 'Trace my exact GPS location')
                                          : (tr.isArabic ? 'الموقع مغلق - اضغط لتشغيل GPS' : 'Location is OFF - Tap to enable GPS'),
                                      iconColor: userLoc.isGpsDetected ? const Color(0xFF8B53FE) : const Color(0xFFEF4444),
                                      isLoading: _isTracingGps,
                                      onTap: _traceCurrentGps,
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

                  // 2. TOP PROVIDER COUNT SLIDER CARD (At very top of screen in standard view):
                  if (!_isFullViewMode)
                    Positioned(
                      top: sliderTop,
                      left: beaconLeft,
                      width: beaconWidth,
                      child: _buildTopProviderSliderCard(),
                    ),

                  // 3. HEADER BRANDING (Back button & service title, below the top slider in standard view):
                  if (!_isFullViewMode)
                    Positioned(
                      top: headerTop,
                      left: beaconLeft,
                      width: beaconWidth,
                      height: headerHeight,
                      child: SizedBox(
                        width: beaconWidth,
                        height: headerHeight,
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
                                child: Center(
                                  child: Transform.scale(
                                    scaleX: (tr.isArabic || Directionality.of(context) == TextDirection.rtl) ? -1.0 : 1.0,
                                    child: const CustomPaint(
                                      size: Size(6.0, 13.0),
                                      painter: _BackChevronPainter(
                                        color: Color(0xFF566663),
                                      ),
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
                                  tr.categoryName(widget.serviceName, widget.serviceName),
                                  style: tr.font(
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

                  // 4. BOTTOM WIDGET / PROVIDERS CARD (In standard view)
                  if (!_isFullViewMode)
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

                  // 5. FULL VIEW TOP FLOATING BAR: Back button (<) and Provider count filter slider
                  if (_isFullViewMode)
                    Positioned(
                      top: isDesktopWeb ? 16.0 : (safeTop + 4.0),
                      left: containerWidth >= 390 ? 20.0 : 12.0,
                      right: containerWidth >= 390 ? 20.0 : 12.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                key: const Key('full_view_back_button'),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  setState(() => _isFullViewMode = false);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 36.0,
                                  height: 36.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(0xFF566663),
                                      width: 1.0,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x18000000),
                                        blurRadius: 10.0,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Transform.scale(
                                      scaleX: (tr.isArabic || Directionality.of(context) == TextDirection.rtl) ? -1.0 : 1.0,
                                      child: const CustomPaint(
                                        size: Size(6.0, 13.0),
                                        painter: _BackChevronPainter(
                                          color: Color(0xFF566663),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(20.0),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x14000000),
                                        blurRadius: 10.0,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          tr.categoryName(widget.serviceName, widget.serviceName),
                                          style: tr.font(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1C2926),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8B53FE).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: Text(
                                          tr.isArabic ? 'خريطة كاملة' : 'Full Map',
                                          style: tr.font(
                                            fontSize: 11.0,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF8B53FE),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          _buildTopProviderSliderCard(),
                        ],
                      ),
                    ),

                  // 6. FULL VIEW FLOATING SELECTED DRIVER CARD (When a car is selected on full map)
                  if (_isFullViewMode && _selectedCarId != null)
                    Positioned(
                      bottom: 24.0,
                      left: containerWidth >= 390 ? 20.0 : 12.0,
                      right: containerWidth >= 390 ? 20.0 : 12.0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 14.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 20.0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _buildSelectedDriverCard(
                          containerWidth,
                          liveProviders,
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
    ),
  );
  }

  /// Top provider count slider card located at the very top of the screen above the header
  Widget _buildTopProviderSliderCard() {
    final tr = ref.watch(translationsProvider);

    return Container(
      key: const Key('top_provider_slider_card'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14.0, 7.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFF8B53FE).withValues(alpha: 0.18),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Top Label Row (Nearest Providers + Current Count Badge)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.people_alt_rounded,
                    size: 15.0,
                    color: Color(0xFF8B53FE),
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    tr.isArabic ? 'مزودو الخدمة الأقرب' : 'Nearest Providers',
                    style: tr.font(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1C2926),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B53FE).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  tr.isArabic
                      ? '$_selectedProviderCount مزودين'
                      : '$_selectedProviderCount Providers',
                  style: tr.font(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF8B53FE),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2.0),

          // 2. Bottom Slider Bar (Sleek slider with brand purple active track & round white thumb)
          SizedBox(
            height: 26.0,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3.5,
                activeTrackColor: const Color(0xFF8B53FE),
                inactiveTrackColor: const Color(0xFFE5E7EB),
                thumbColor: Colors.white,
                overlayColor: const Color(0xFF8B53FE).withValues(alpha: 0.14),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 8.0,
                  elevation: 2.5,
                  pressedElevation: 4.0,
                ),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
              ),
              child: Slider(
                key: const Key('provider_count_slider'),
                min: 1.0,
                max: 10.0,
                divisions: 9,
                value: _selectedProviderCount.toDouble().clamp(1.0, 10.0),
                onChanged: (double val) {
                  final int newCount = val.round();
                  if (newCount != _selectedProviderCount) {
                    _selectProviderCountFilter(newCount);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Floating button helper for map controls
  Widget _buildFloatingButton({
    Key? key,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF1C2926),
    bool isLoading = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        key: key,
        onTap: isLoading ? null : onTap,
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
            child: isLoading
                ? const SizedBox(
                    width: 17.0,
                    height: 17.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B53FE)),
                    ),
                  )
                : Icon(
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
    UserLocation userLoc,
  ) {
    final double cardWidth = containerWidth >= 390
        ? 350.0
        : (containerWidth - 40.0).clamp(280.0, 350.0);

    final tr = ref.watch(translationsProvider);

    final int count = _selectedProviderCount;
    final String providersLabel = tr.isArabic
        ? 'أقرب $_selectedProviderCount مزودين خدمة'
        : 'Nearest $_selectedProviderCount service providers';
    final String locationSubtitle = userLoc.isGpsDetected
        ? (userLoc.cityName.isNotEmpty && userLoc.cityName != 'Detecting Location...'
            ? '$providersLabel • ${userLoc.cityName}'
            : providersLabel)
        : (tr.isArabic
            ? '$providersLabel • خدمة الموقع مغلقة'
            : '$providersLabel • Location is OFF');

    return SizedBox(
      width: cardWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr.providersNearbyCount(count),
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  style: tr.font(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1C2926),
                    height: tr.isArabic ? 1.05 : 1.15,
                    letterSpacing: 0.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: tr.isArabic ? 0.0 : 2.0),
                Transform.translate(
                  offset: Offset(0, tr.isArabic ? -3.0 : 0.0),
                  child: Text(
                    locationSubtitle,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    style: tr.font(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF566663),
                      height: tr.isArabic ? 1.05 : 1.15,
                      letterSpacing: 0.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),

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
                color: const Color(0xFF8B53FE),
                borderRadius: BorderRadius.circular(60.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x338B53FE),
                    blurRadius: 6.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    tr.viewAll,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    style: tr.font(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.15,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(width: 8.0),
                  Transform.scale(
                    scaleX: (tr.isArabic || Directionality.of(context) == TextDirection.rtl) ? -1.0 : 1.0,
                    child: const CustomPaint(
                      size: Size(4.0, 8.0),
                      painter: _ChevronRightVectorPainter(
                        color: Colors.white,
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
  }

  /// Selected driver details card within bottom widget
  Widget _buildSelectedDriverCard(
    double containerWidth,
    List<ProviderModel> liveProviders,
  ) {
    final tr = ref.watch(translationsProvider);
    final userLocAsync = ref.read(userLocationProvider);
    final userLoc = userLocAsync.value ?? UserLocation.defaultLocation;
    final userPos = MapLatLng(userLoc.latitude, userLoc.longitude);

    final selectedRoute = (_driverRoutes ?? []).firstWhere(
      (r) => r.id == _selectedCarId,
      orElse: () => _driverRoutes!.first,
    );

    final double progress = (_carMotionController.value * selectedRoute.speedFactor * 2.0 + selectedRoute.startPhase);
    final live = selectedRoute.roadPath.evaluatePatrol(progress);
    final double dynamicDistKm = selectedRoute.liveDistanceKm(live.position, userPos);

    final double cardWidth = containerWidth >= 390
        ? 350.0
        : (containerWidth - 40.0).clamp(280.0, 350.0);

    final String driverName = selectedRoute.name;

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
                            tr.formatProviderName(driverName),
                            style: tr.font(
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
                            tr.online,
                            style: tr.font(
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
                        const SizedBox(width: 4.0),
                        Expanded(
                          child: Text(
                            '${tr.kmAway(dynamicDistKm.toStringAsFixed(1))} • ${tr.formatVehicleName(selectedRoute.vehicle)}',
                            style: tr.font(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF566663),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                      distance: '${dynamicDistKm.toStringAsFixed(1)} km',
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
                tr.confirmDriver(tr.formatProviderName(driverName).split(' ').first),
                style: tr.font(
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

/// Dynamic Slippy Map Layer supporting unlimited viewport dragging & Google/OSM tile rendering
class _DynamicMapTileLayer extends StatelessWidget {
  final double centerPixelX;
  final double centerPixelY;
  final double zoom;
  final double width;
  final double height;

  const _DynamicMapTileLayer({
    required this.centerPixelX,
    required this.centerPixelY,
    required this.zoom,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    const double tileSize = 256.0;
    final int z = zoom.toInt();

    final double leftPx = centerPixelX - (width / 2.0);
    final double topPx = centerPixelY - (height / 2.0);
    final double rightPx = leftPx + width;
    final double bottomPx = topPx + height;

    final int minTileX = (leftPx / tileSize).floor() - 1;
    final int maxTileX = (rightPx / tileSize).ceil() + 1;
    final int minTileY = (topPx / tileSize).floor() - 1;
    final int maxTileY = (bottomPx / tileSize).ceil() + 1;

    final int maxIndex = (1 << z) - 1;
    final List<Widget> tileWidgets = [];

    for (int tx = minTileX; tx <= maxTileX; tx++) {
      for (int ty = minTileY; ty <= maxTileY; ty++) {
        final int wrappedTileX = (tx % (maxIndex + 1) + (maxIndex + 1)) % (maxIndex + 1);
        if (ty < 0 || ty > maxIndex) continue;

        final double tileLeft = (tx * tileSize) - leftPx;
        final double tileTop = (ty * tileSize) - topPx;

        final int serverIdx = (wrappedTileX.abs() + ty.abs()) % 4;
        final String lang = Localizations.localeOf(context).languageCode;
        final String googleTileUrl =
            'https://mt$serverIdx.google.com/vt/lyrs=m&hl=$lang&x=$wrappedTileX&y=$ty&z=$z';
        final String osmTileUrl =
            'https://tile.openstreetmap.org/$z/$wrappedTileX/$ty.png';

        tileWidgets.add(
          Positioned(
            key: ValueKey('tile_${wrappedTileX}_${ty}_$z'),
            left: tileLeft,
            top: tileTop,
            width: tileSize,
            height: tileSize,
            child: Image.network(
              googleTileUrl,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              filterQuality: FilterQuality.low,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  osmTileUrl,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.low,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/BG image.png',
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    );
                  },
                );
              },
            ),
          ),
        );
      }
    }

    return ClipRect(
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/BG image.png',
                fit: BoxFit.cover,
              ),
            ),
            ...tileWidgets,
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF8B53FE).withValues(alpha: 0.03),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter that renders the light purple tracking line tracing and covering the route to the customer
class _RoadMarkingsPainter extends CustomPainter {
  final List<NearbyDriverRoute> routes;
  final double zoom;
  final double leftPx;
  final double topPx;
  final int? selectedId;
  final double animProgress;
  final MapLatLng userPos;

  const _RoadMarkingsPainter({
    required this.routes,
    required this.zoom,
    required this.leftPx,
    required this.topPx,
    this.selectedId,
    required this.animProgress,
    required this.userPos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (routes.isEmpty) return;

    // The car coming towards the customer (selected driver or primary incoming driver #1)
    final NearbyDriverRoute targetRoute = (selectedId != null)
        ? routes.firstWhere((r) => r.id == selectedId, orElse: () => routes.first)
        : routes.first;

    if (targetRoute.waypoints.length < 2) return;

    // 1. Build screen coordinates for all road waypoints leading directly to customer
    final List<Offset> screenPoints = [];
    for (int i = 0; i < targetRoute.waypoints.length; i++) {
      final wp = targetRoute.waypoints[i];
      final x = MercatorProjection.lngToX(wp.longitude, zoom) - leftPx;
      final y = MercatorProjection.latToY(wp.latitude, zoom) - topPx;
      screenPoints.add(Offset(x, y));
    }

    final fullPath = Path();
    fullPath.moveTo(screenPoints.first.dx, screenPoints.first.dy);
    for (int i = 1; i < screenPoints.length; i++) {
      fullPath.lineTo(screenPoints[i].dx, screenPoints[i].dy);
    }

    // Light purple color palette specified by user:
    // Core light purple: Color(0xFFB892FF)
    // Ambient casing/glow: Color(0x35B892FF)
    const Color lightPurple = Color(0xFFB892FF);
    final Color glowColor = lightPurple.withValues(alpha: 0.35);

    // A. Outer soft glowing light purple aura for the complete road corridor
    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(fullPath, glowPaint);

    // B. Complete road route corridor line (marked in light purple)
    final corridorPaint = Paint()
      ..color = lightPurple.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(fullPath, corridorPaint);

    // C. Live moving position of the car coming towards the customer
    final double p = (animProgress * targetRoute.speedFactor * 2.0 + targetRoute.startPhase);
    final double cycle = (p % 2.0 + 2.0) % 2.0;
    final bool isForward = cycle <= 1.0;
    final double t = isForward ? cycle : (2.0 - cycle);

    final live = targetRoute.roadPath.evaluatePatrol(p);
    final double carScreenX = MercatorProjection.lngToX(live.position.longitude, zoom) - leftPx;
    final double carScreenY = MercatorProjection.latToY(live.position.latitude, zoom) - topPx;
    final carOffset = Offset(carScreenX, carScreenY);

    // Calculate segment index where the car currently is
    final double targetDist = t * targetRoute.roadPath.totalDistance;
    double accumulated = 0.0;
    int carSegmentIndex = 0;
    for (int i = 0; i < targetRoute.roadPath.segmentDistances.length; i++) {
      final segDist = targetRoute.roadPath.segmentDistances[i];
      if (accumulated + segDist >= targetDist || i == targetRoute.roadPath.segmentDistances.length - 1) {
        carSegmentIndex = i;
        break;
      }
      accumulated += segDist;
    }

    // D. Covered path along street segments from origin up to live car position
    final coveredPath = Path();
    coveredPath.moveTo(screenPoints.first.dx, screenPoints.first.dy);
    for (int i = 1; i <= carSegmentIndex; i++) {
      coveredPath.lineTo(screenPoints[i].dx, screenPoints[i].dy);
    }
    coveredPath.lineTo(carOffset.dx, carOffset.dy);

    final coveredGlowPaint = Paint()
      ..color = lightPurple.withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(coveredPath, coveredGlowPaint);

    final coveredPaint = Paint()
      ..color = lightPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(coveredPath, coveredPaint);

    // E. Active remaining tracking path along street segments from car to customer pin
    final activePath = Path();
    activePath.moveTo(carOffset.dx, carOffset.dy);
    for (int i = carSegmentIndex + 1; i < screenPoints.length; i++) {
      activePath.lineTo(screenPoints[i].dx, screenPoints[i].dy);
    }

    final activeTrackingPaint = Paint()
      ..color = lightPurple.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(activePath, activeTrackingPaint);

    // F. Inner crisp white center road stripe along the complete route
    final lanePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(fullPath, lanePaint);

    // G. Origin / Route Start Milestone Pin
    final startOffset = screenPoints.first;
    final startPinGlow = Paint()
      ..color = lightPurple.withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(startOffset, 8.0, startPinGlow);
    final startPinCore = Paint()
      ..color = lightPurple
      ..style = PaintingStyle.fill;
    canvas.drawCircle(startOffset, 4.5, startPinCore);
    final startPinCenter = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(startOffset, 2.0, startPinCenter);

    // H. Animated tracking pulse dot flowing along the active path towards the customer
    final double pulseT = (animProgress * 2.5) % 1.0;
    final customerPoint = screenPoints.last;
    final pulseX = carOffset.dx + (customerPoint.dx - carOffset.dx) * pulseT;
    final pulseY = carOffset.dy + (customerPoint.dy - carOffset.dy) * pulseT;

    final dotGlowPaint = Paint()
      ..color = lightPurple.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(pulseX, pulseY), 5.5, dotGlowPaint);

    final dotCorePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(pulseX, pulseY), 2.5, dotCorePaint);
  }

  @override
  bool shouldRepaint(covariant _RoadMarkingsPainter oldDelegate) {
    return oldDelegate.animProgress != animProgress ||
        oldDelegate.leftPx != leftPx ||
        oldDelegate.topPx != topPx ||
        oldDelegate.zoom != zoom ||
        oldDelegate.selectedId != selectedId;
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

/// Vector chevron right matching Figma specifications
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
