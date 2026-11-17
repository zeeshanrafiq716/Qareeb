import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale.dart';
import '../../../models/provider_model.dart';
import '../../../providers/backend_provider.dart';
import '../../../services/location_service.dart';
import 'find_provider_screen.dart';
import 'widgets/google_maps_user_dot.dart';
import 'widgets/location_access_helper.dart';
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

/// Model representing a nearby driver on the map with real GPS tracking
class NearbyDriverRoute {
  final String id;
  final String name;
  final String vehicle;
  final String? phone;
  final String? publicId;
  final String? photoUrl;
  final bool verified;
  final double rating;
  final int reviews;
  final double initialDistanceKm;
  final Color roofColor;
  final double speedFactor;
  final double startPhase;
  final MapLatLng currentPos;
  final MapLatLng? previousPos;
  final double heading;
  final List<MapLatLng> waypoints;
  late final RoadPath roadPath;

  NearbyDriverRoute({
    required this.id,
    required this.name,
    this.vehicle = 'Sedan • AC',
    this.phone,
    this.publicId,
    this.photoUrl,
    this.verified = false,
    this.rating = 0.0,
    this.reviews = 0,
    required this.initialDistanceKm,
    this.roofColor = const Color(0xFFA67AFE),
    this.speedFactor = 1.0,
    this.startPhase = 0.0,
    required this.currentPos,
    this.previousPos,
    this.heading = 0.0,
    required this.waypoints,
  }) {
    roadPath = RoadPath(waypoints);
  }

  /// Calculates dynamic live distance in km from user position using Haversine
  double liveDistanceKm(MapLatLng carPos, MapLatLng userPos) {
    final dMeters = RoadPath.haversineDistance(carPos, userPos);
    return double.parse((dMeters / 1000.0).clamp(0.1, 99.0).toStringAsFixed(1));
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

  String? _selectedCarId;
  static final Set<String> _clickedCarIds = <String>{};
  Set<String> get _safeClickedCarIds => _clickedCarIds;
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
  double _mapScaleBase = 1.0;

  List<NearbyDriverRoute>? _driverRoutes;
  List<ProviderMarkerModel> _gpsProviders = const [];
  final Map<String, MapLatLng> _lastKnownPositions = {};
  final Map<String, double> _driverHeadings = {};
  Timer? _providerLocationPollTimer;

  @override
  void initState() {
    super.initState();

    // 1. Radar wave pulse
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    // 2. Continuous animation ticker for pulse dots and map markers
    _carMotionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    // 3. Smooth map recentering animation controller
    _recenterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // 4. Real-time background provider tracking poll: refresh providers every 4s
    _providerLocationPollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final loc = _exactTracedLocation ?? ref.read(userLocationProvider).value;
      if (loc != null && loc.hasValidDeviceGps) {
        unawaited(_refreshNearbyCars(loc));
      } else {
        ref.invalidate(nearbyProvidersProvider);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _promptLocationIfNeededOnMapOpen());
  }

  Future<void> _promptLocationIfNeededOnMapOpen() async {
    if (!mounted) return;
    final live = ref.read(userLocationProvider).value;
    if (live != null && live.isGpsDetected) return;

    final issue = await LocationAccessHelper.diagnose(ref.read(locationServiceProvider));
    if (!mounted || issue == LocationAccessIssue.unavailable) return;

    await LocationAccessHelper.showEnableLocationDialog(
      context,
      ref,
      issue: issue,
      serviceName: widget.serviceName,
    );
    if (!mounted) return;
    ref.invalidate(userLocationProvider);
    ref.invalidate(nearbyProvidersProvider);
  }

  @override
  void dispose() {
    _providerLocationPollTimer?.cancel();
    _radarController.dispose();
    _carMotionController.dispose();
    _recenterController.dispose();
    _zoomAnimationController?.dispose();
    super.dispose();
  }

  /// Builds dynamic routes for real providers returned by the backend.
  /// Uses real provider GPS coordinates without artificial patrol loops.
  List<NearbyDriverRoute> _buildDriverRoutesFromProviders(
    List<ProviderMarkerModel> providers,
    double centerLat,
    double centerLng,
  ) {
    // Only map providers who have valid GPS coordinates within the vicinity
    final validProviders = providers
        .where((p) => p.latitude != 0.0 && p.longitude != 0.0)
        .toList();
    if (validProviders.isEmpty) return <NearbyDriverRoute>[];

    final colors = [
      const Color(0xFF8B53FE),
      const Color(0xFF7C3AED),
      const Color(0xFF6D28D9),
      const Color(0xFF9333EA),
      const Color(0xFFA855F7),
      const Color(0xFF7E22CE),
      const Color(0xFF8B5CF6),
      const Color(0xFF6B21A8),
    ];

    final userPos = MapLatLng(centerLat, centerLng);

    return validProviders.asMap().entries.map((entry) {
      final index = entry.key;
      final p = entry.value;
      final Color roofCol = colors[index % colors.length];
      final String provId = p.publicId.isNotEmpty
          ? p.publicId
          : (p.id != 0 ? '${p.id}' : (p.name.isNotEmpty ? 'driver_${p.name}' : 'driver_$index'));

      final newPos = MapLatLng(p.latitude, p.longitude);

      final oldPos = _lastKnownPositions[provId];
      double heading = _driverHeadings[provId] ?? p.carAngle;

      if (oldPos != null &&
          (oldPos.latitude != newPos.latitude || oldPos.longitude != newPos.longitude)) {
        final dM = RoadPath.haversineDistance(oldPos, newPos);
        if (dM > 1.0) {
          heading = RoadPath.calculateBearing(oldPos, newPos);
          _driverHeadings[provId] = heading;
        }
      }
      _lastKnownPositions[provId] = newPos;

      // Real distance calculated directly between provider GPS and customer GPS
      final double realDistMeters = RoadPath.haversineDistance(newPos, userPos);
      final double distKm = realDistMeters > 0
          ? double.parse((realDistMeters / 1000.0).toStringAsFixed(1))
          : (p.distanceKm > 0 ? p.distanceKm : 0.0);

      return NearbyDriverRoute(
        id: provId,
        name: p.name,
        phone: p.phone,
        publicId: p.publicId,
        photoUrl: p.photoUrl,
        verified: p.verificationStatus == 'approved' || p.verificationStatus == 'verified',
        vehicle: '${p.categoryName.isNotEmpty ? p.categoryName : 'Vehicle'} • AC',
        rating: p.ratingAvg,
        reviews: p.ratingCount,
        initialDistanceKm: distKm,
        roofColor: roofCol,
        speedFactor: 1.0,
        startPhase: 0.0,
        currentPos: newPos,
        previousPos: oldPos ?? newPos,
        heading: heading,
        waypoints: [newPos, userPos],
      );
    }).toList();
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

  bool _looksLikeCoordinates(String value) {
    final text = value.trim();
    return RegExp(r'^-?\d{1,3}\.\d+').hasMatch(text);
  }

  String _placeLabel(UserLocation loc) {
    final city = loc.cityName.trim();
    if (city.isNotEmpty &&
        city != 'Detecting Location...' &&
        city != 'Location is OFF' &&
        !_looksLikeCoordinates(city)) {
      return city;
    }
    final address = loc.address.trim();
    if (address.isNotEmpty &&
        !address.startsWith('GPS') &&
        !address.startsWith('Exact GPS') &&
        !_looksLikeCoordinates(address)) {
      return address;
    }
    return loc.coordinatesDisplay;
  }

  Future<UserLocation> _withPlaceName(UserLocation loc) async {
    if (!_looksLikeCoordinates(loc.cityName) &&
        loc.cityName.trim().isNotEmpty &&
        loc.cityName != 'Location is OFF' &&
        loc.cityName != 'Detecting Location...') {
      return loc;
    }
    try {
      final addr = await ref.read(googleMapsServiceProvider).reverseGeocode(
            loc.latitude,
            loc.longitude,
            lang: 'en',
          );
      final city = addr.cityName.trim();
      if (city.isNotEmpty && !_looksLikeCoordinates(city)) {
        return loc.copyWith(
          cityName: city,
          address: addr.formattedAddress.isNotEmpty ? addr.formattedAddress : city,
        );
      }
    } catch (_) {}
    return loc;
  }

  Future<void> _refreshNearbyCars(UserLocation loc) async {
    if (!loc.hasValidDeviceGps) return;
    try {
      final list = await ref.read(backendServiceProvider).getNearbyProviders(
            latitude: loc.latitude,
            longitude: loc.longitude,
            radiusKm: 25,
          );
      if (!mounted) return;
      setState(() => _gpsProviders = list);
    } catch (_) {}
  }

  void _showLocationMessage(UserLocation loc) {
    if (!mounted) return;
    final tr = ref.read(translationsProvider);
    final place = _placeLabel(loc);
    final coords = loc.coordinatesDisplay;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF8B53FE),
        behavior: SnackBarBehavior.floating,
        content: Text(
          tr.isArabic
              ? 'موقعك: $place\n$coords'
              : 'Your location: $place\n$coords',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _applyUserLocationToMap(UserLocation resolved) {
    final double targetZoom =
        _calculateZoomForCount(_selectedProviderCount).clamp(10.0, 18.0);
    setState(() {
      _exactTracedLocation = resolved;
      if (_zoom < targetZoom - 0.25) {
        _zoom = targetZoom;
      }
    });
    ref.invalidate(userLocationProvider);
    ref.invalidate(nearbyProvidersProvider);
    _recenterMap(resolved.latitude, resolved.longitude);
  }

  /// My location — refresh GPS, recenter, and reload nearby providers on the map.
  Future<void> _onMyLocationButtonTap() async {
    if (_isTracingGps) return;
    HapticFeedback.mediumImpact();
    setState(() => _isTracingGps = true);
    try {
      final UserLocation? resolved = await LocationAccessHelper.resolveForMapAction(
        context,
        ref,
        serviceName: widget.serviceName,
      );

      if (!mounted || resolved == null || !resolved.hasValidDeviceGps) return;
      final named = await _withPlaceName(resolved);
      if (!mounted) return;
      _applyUserLocationToMap(named);
      await _refreshNearbyCars(named);
      _showLocationMessage(named);
    } finally {
      if (mounted) setState(() => _isTracingGps = false);
    }
  }

  void _zoomIn() {
    HapticFeedback.selectionClick();
    if (_zoom >= 18.0) return;
    setState(() {
      final curLng = MercatorProjection.xToLng(_centerPixelX!, _zoom);
      final curLat = MercatorProjection.yToLat(_centerPixelY!, _zoom);
      _zoom = (_zoom + 1.0).clamp(10.0, 18.0);
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
      _zoom = (_zoom - 1.0).clamp(10.0, 18.0);
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
    final distances = List<double>.from(
      _driverRoutes!.map((d) => RoadPath.haversineDistance(d.currentPos, userPos)),
    )..sort();

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
              final double sliderTop = isDesktopWeb ? 20.0 : (safeTop + 10.0);
              const double sliderHeight = 62.0;
              final double headerTop = sliderTop + sliderHeight + 12.0;
              const double headerHeight = 36.0;
              final double safeBottom = MediaQuery.of(context).padding.bottom;
              final double beaconTop = headerTop + headerHeight + 10.0;
              final double bottomCardHeight = isDesktopWeb
                  ? 108.0
                  : math.max(96.0, safeBottom + 78.0);
              final double bottomCardTop = containerHeight - bottomCardHeight;
              final double beaconHeight = (bottomCardTop - beaconTop - 10.0).clamp(280.0, 540.0);

              final double effectiveBeaconTop = _isFullViewMode ? 0.0 : beaconTop;
              final double effectiveBeaconLeft = _isFullViewMode ? 0.0 : beaconLeft;
              final double effectiveBeaconWidth = _isFullViewMode ? containerWidth : beaconWidth;
              final double effectiveBeaconHeight = _isFullViewMode ? containerHeight : beaconHeight;
              final double mapControlsBottom = _isFullViewMode
                  ? math.max(20.0, safeBottom + 18.0)
                  : 16.0;

              final userLocAsync = ref.watch(userLocationProvider);
              final UserLocation? rawUserLoc =
                  _exactTracedLocation ?? userLocAsync.value;
              final userLoc = (rawUserLoc != null && rawUserLoc.hasValidDeviceGps)
                  ? rawUserLoc
                  : UserLocation.defaultLocation;
              final userPos = userLoc.hasValidDeviceGps
                  ? MapLatLng(userLoc.latitude, userLoc.longitude)
                  : const MapLatLng(0, 0);
              final double targetCircleRadiusMeters = _calculateRadiusForCount(_selectedProviderCount, userPos);

              // Build routes strictly from real live providers
              final providersAsync = ref.watch(nearbyProvidersProvider);
              final streamed = providersAsync.value ?? const <ProviderMarkerModel>[];
              final liveProviders = _gpsProviders.isNotEmpty ? _gpsProviders : streamed;
              final routeUser = (rawUserLoc != null && rawUserLoc.hasValidDeviceGps)
                  ? rawUserLoc
                  : null;
              if (routeUser != null) {
                final allRoutes = List<NearbyDriverRoute>.from(
                  _buildDriverRoutesFromProviders(
                    liveProviders,
                    routeUser.latitude,
                    routeUser.longitude,
                  ),
                );
                allRoutes.sort((a, b) => a.initialDistanceKm.compareTo(b.initialDistanceKm));
                _driverRoutes = allRoutes.take(_selectedProviderCount).toList();
              } else {
                _driverRoutes = <NearbyDriverRoute>[];
              }

              // Initialize map center only from real GPS (not placeholder 0,0)
              if (userLoc.hasValidDeviceGps) {
                _centerPixelX ??= MercatorProjection.lngToX(userLoc.longitude, _zoom);
                _centerPixelY ??= MercatorProjection.latToY(userLoc.latitude, _zoom);
              } else {
                _centerPixelX ??= MercatorProjection.lngToX(0, _zoom);
                _centerPixelY ??= MercatorProjection.latToY(0, _zoom);
              }

              final double mapLat = userLoc.hasValidDeviceGps ? userLoc.latitude : 0;
              final double metersPerPixel = (156543.03392 * math.cos(mapLat * math.pi / 180.0)) / (1 << _zoom.toInt());

              final double leftPx = _centerPixelX! - (effectiveBeaconWidth / 2.0);
              final double topPx = _centerPixelY! - (effectiveBeaconHeight / 2.0);

            // User GPS position in on-screen pixels
            final double userScreenX = MercatorProjection.lngToX(userLoc.longitude, _zoom) - leftPx;
            final double userScreenY = MercatorProjection.latToY(userLoc.latitude, _zoom) - topPx;

            // Real providers synced with map layer

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
                      child: Listener(
                        onPointerSignal: (pointerSignal) {
                          if (pointerSignal is PointerScrollEvent) {
                            if (pointerSignal.scrollDelta.dy < 0) {
                              _zoomIn();
                            } else if (pointerSignal.scrollDelta.dy > 0) {
                              _zoomOut();
                            }
                          }
                        },
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onDoubleTap: _zoomIn,
                          onScaleStart: (details) {
                            _mapScaleBase = 1.0;
                            setState(() {
                              _isDraggingMap = true;
                            });
                          },
                          // FLUID LEFT-TO-RIGHT & MULTI-DIRECTIONAL DRAGGING + PINCH ZOOM
                          onScaleUpdate: (details) {
                            setState(() {
                              _centerPixelX = _centerPixelX! - details.focalPointDelta.dx;
                              _centerPixelY = _centerPixelY! - details.focalPointDelta.dy;

                              if (details.scale != 1.0) {
                                final double ratio = details.scale / _mapScaleBase;
                                if (ratio > 1.25 && _zoom < 18.0) {
                                  _zoomIn();
                                  _mapScaleBase = details.scale;
                                } else if (ratio < 0.8 && _zoom > 10.0) {
                                  _zoomOut();
                                  _mapScaleBase = details.scale;
                                }
                              }
                            });
                          },
                          onScaleEnd: (details) {
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
                              // A. Real Slippy Map Layer (Google Road Tiles / OSM) with Infinite Viewport Loading
                              _DynamicMapTileLayer(
                                centerPixelX: _centerPixelX!,
                                centerPixelY: _centerPixelY!,
                                zoom: _zoom,
                                width: effectiveBeaconWidth,
                                height: effectiveBeaconHeight,
                              ),

                              // B. Light Purple Route Line Tracking & Covering Road to Customer
                              if (_driverRoutes != null && _driverRoutes!.isNotEmpty)
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
                                left: userScreenX - 24.0,
                                top: userScreenY - 24.0,
                                child: Tooltip(
                                  message: userLoc.hasValidDeviceGps
                                      ? (tr.isArabic
                                          ? 'موقعك: ${_placeLabel(userLoc)}'
                                          : 'Your location: ${_placeLabel(userLoc)}')
                                      : (tr.isArabic
                                          ? 'اضغط زر الموقع لتفعيل الخدمة'
                                          : 'Tap the location button to turn on Location'),
                                  child: userLoc.isGpsDetected
                                      ? const GoogleMapsUserDot(
                                          key: Key('user_gps_center_marker'),
                                          size: 18.0,
                                        )
                                      : GestureDetector(
                                          onTap: _onMyLocationButtonTap,
                                          child: Container(
                                            key: const Key('user_gps_center_marker'),
                                            width: 30.0,
                                            height: 30.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color(0xFF9AA0A6),
                                              border: Border.all(color: Colors.white, width: 2.6),
                                            ),
                                            child: const Icon(
                                              Icons.location_off_rounded,
                                              size: 14.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                ),
                              ),

                              // F. REAL CAR TRACKING ACCORDING TO SERVICE PROVIDER GPS MOVEMENT
                              () {
                                final routes = _driverRoutes ?? [];
                                if (routes.isEmpty) return const SizedBox.shrink();

                                // Sort drivers so clicked & active drivers are drawn last (highest z-index on map)
                                final sortedRoutes = List<NearbyDriverRoute>.from(routes);
                                final clicked = _safeClickedCarIds;
                                if (_selectedCarId != null || clicked.isNotEmpty) {
                                  sortedRoutes.sort((a, b) {
                                    if (a.id == _selectedCarId) return 2;
                                    if (b.id == _selectedCarId) return -2;
                                    final aClicked = clicked.contains(a.id);
                                    final bClicked = clicked.contains(b.id);
                                    if (aClicked && !bClicked) return 1;
                                    if (!aClicked && bClicked) return -1;
                                    return 0;
                                  });
                                }

                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    for (final driver in sortedRoutes)
                                      TweenAnimationBuilder<Offset>(
                                        key: ValueKey('driver_car_anim_${driver.id}'),
                                        tween: Tween<Offset>(
                                          begin: Offset(
                                            (driver.previousPos ?? driver.currentPos).longitude,
                                            (driver.previousPos ?? driver.currentPos).latitude,
                                          ),
                                          end: Offset(
                                            driver.currentPos.longitude,
                                            driver.currentPos.latitude,
                                          ),
                                        ),
                                        duration: const Duration(milliseconds: 1500),
                                        curve: Curves.easeInOutCubic,
                                        builder: (context, animGps, _) {
                                          final currentGps = MapLatLng(animGps.dy, animGps.dx);
                                          final double carX = MercatorProjection.lngToX(currentGps.longitude, _zoom) - leftPx;
                                          final double carY = MercatorProjection.latToY(currentGps.latitude, _zoom) - topPx;

                                          final bool isSelected = _selectedCarId == driver.id;
                                          final bool isWhite = _safeClickedCarIds.contains(driver.id) ||
                                              (driver.publicId != null && _safeClickedCarIds.contains(driver.publicId!)) ||
                                              _safeClickedCarIds.contains(driver.name) ||
                                              TopDownCarWidget.isClicked(driver.id) ||
                                              (driver.publicId != null && TopDownCarWidget.isClicked(driver.publicId!)) ||
                                              TopDownCarWidget.isClicked(driver.name);
                                          final double realDistKm = driver.liveDistanceKm(currentGps, userPos);
                                          final bool isInsideRadius = (realDistKm * 1000.0) <= targetCircleRadiusMeters;

                                          // Render luxury executive car with Compact Speech Bubble Badge!
                                          return Positioned(
                                            left: carX - 33.0, // center horizontally on car (width = 66.0)
                                            top: carY - 45.0,  // center vertically on car (height = 68.0)
                                            width: 66.0,
                                            height: 68.0,
                                            child: TopDownCarWidget(
                                              key: ValueKey('driver_car_${driver.id}'),
                                              carId: driver.id,
                                              width: 18.0,
                                              height: 35.0,
                                              angle: driver.heading, // dynamic road bearing or heading
                                              opacity: isInsideRadius ? 1.0 : 0.72,
                                              driverName: driver.name.split(' ').first,
                                              distanceKm: realDistKm,
                                              bodyColor: driver.roofColor,
                                              showBadge: true,
                                              isSelected: isSelected,
                                              isWhite: isWhite,
                                              isInsideRadius: isInsideRadius,
                                              onTap: () {
                                                HapticFeedback.selectionClick();
                                                TopDownCarWidget.markAsClicked(driver.id);
                                                if (driver.publicId != null) {
                                                  TopDownCarWidget.markAsClicked(driver.publicId!);
                                                }
                                                TopDownCarWidget.markAsClicked(driver.name);
                                                _clickedCarIds.add(driver.id);
                                                if (driver.publicId != null) {
                                                  _clickedCarIds.add(driver.publicId!);
                                                }
                                                _clickedCarIds.add(driver.name);
                                                setState(() {
                                                  _selectedCarId = driver.id;
                                                });
                                                ProviderDetailCardWidget.showAsBottomSheet(
                                                  context: context,
                                                  providerName: driver.name,
                                                  serviceCategory: tr.categoryName(widget.serviceName, widget.serviceName),
                                                  vehicleName: driver.vehicle,
                                                  distance: '',
                                                  estimatedTime: '',
                                                  rating: driver.rating,
                                                  tripsCount: driver.reviews,
                                                  phoneNumber: driver.phone,
                                                  providerPublicId: driver.publicId,
                                                  avatarUrl: driver.photoUrl,
                                                  verified: driver.verified,
                                                  isAvailable: true,
                                                  providerLatitude: driver.currentPos.latitude,
                                                  providerLongitude: driver.currentPos.longitude,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                );
                              }(),



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
                                bottom: mapControlsBottom,
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
                                      onTap: _onMyLocationButtonTap,
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
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            20.0,
                            14.0,
                            20.0,
                            math.max(10.0, safeBottom + 6.0),
                          ),
                          child: _buildProvidersInnerCard(
                            containerWidth,
                            liveProviders,
                            userLoc,
                          ),
                        ),
                      ),
                    ),

                  // 5. FULL VIEW TOP: Back + nearest-providers filter (no title / "Full Map" pill)
                  if (_isFullViewMode)
                    Positioned(
                      top: isDesktopWeb ? 20.0 : (safeTop + 10.0),
                      left: containerWidth >= 390 ? 20.0 : 12.0,
                      right: containerWidth >= 390 ? 20.0 : 12.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: GestureDetector(
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
                          ),
                          const SizedBox(height: 12.0),
                          _buildTopProviderSliderCard(),
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
      padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 6.0),
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

    final String heading = tr.isArabic ? 'قائمة المزودين' : 'Provider List';
    final String baseSubtitle = tr.isArabic
        ? 'اختر مزود خدمة بالقرب منك'
        : 'Choose a provider near you';
    final String place = userLoc.hasValidDeviceGps ? _placeLabel(userLoc) : '';
    final String locationSubtitle = userLoc.hasValidDeviceGps
        ? '$baseSubtitle • $place'
        : (tr.isArabic
            ? '$baseSubtitle • خدمة الموقع مغلقة'
            : '$baseSubtitle • Location is OFF');

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
                  heading,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  style: tr.font(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C2926),
                    height: tr.isArabic ? 1.05 : 1.12,
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
                      fontSize: 11.0,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF566663),
                      height: tr.isArabic ? 1.05 : 1.12,
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
              height: 36.0,
              decoration: BoxDecoration(
                color: const Color(0xFF8B53FE),
                borderRadius: BorderRadius.circular(60.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x338B53FE),
                    blurRadius: 5.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
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
        final String topoSub = ['a', 'b', 'c'][(wrappedTileX.abs() + ty.abs()) % 3];
        final String googleTileUrl =
            'https://mt$serverIdx.google.com/vt/lyrs=p&hl=$lang&x=$wrappedTileX&y=$ty&z=$z';
        final String osmTileUrl =
            'https://$topoSub.tile.opentopomap.org/$z/$wrappedTileX/$ty.png';

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
  final String? selectedId;
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
    // Only paint tracking line when a specific provider is selected/tracked
    if (routes.isEmpty || selectedId == null) return;

    final NearbyDriverRoute targetRoute = routes.firstWhere(
      (r) => r.id == selectedId,
      orElse: () => routes.first,
    );

    final double carScreenX =
        MercatorProjection.lngToX(targetRoute.currentPos.longitude, zoom) - leftPx;
    final double carScreenY =
        MercatorProjection.latToY(targetRoute.currentPos.latitude, zoom) - topPx;
    final carOffset = Offset(carScreenX, carScreenY);

    final double userScreenX =
        MercatorProjection.lngToX(userPos.longitude, zoom) - leftPx;
    final double userScreenY =
        MercatorProjection.latToY(userPos.latitude, zoom) - topPx;
    final customerPoint = Offset(userScreenX, userScreenY);

    final fullPath = Path();
    fullPath.moveTo(carOffset.dx, carOffset.dy);
    fullPath.lineTo(customerPoint.dx, customerPoint.dy);

    const Color lightPurple = Color(0xFFB892FF);
    final Color glowColor = lightPurple.withValues(alpha: 0.35);

    // A. Outer soft glowing light purple aura for the direct tracking route
    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(fullPath, glowPaint);

    // B. Direct road route corridor line (marked in light purple)
    final corridorPaint = Paint()
      ..color = lightPurple.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(fullPath, corridorPaint);

    // C. Inner crisp white center road stripe along the complete route
    final lanePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(fullPath, lanePaint);

    // D. Origin milestone dot at provider position
    final startPinGlow = Paint()
      ..color = lightPurple.withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(carOffset, 7.0, startPinGlow);
    final startPinCore = Paint()
      ..color = lightPurple
      ..style = PaintingStyle.fill;
    canvas.drawCircle(carOffset, 4.0, startPinCore);
    final startPinCenter = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(carOffset, 2.0, startPinCenter);

    // E. Animated tracking pulse dot flowing along the active path towards the customer
    final double pulseT = (animProgress * 2.5) % 1.0;
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
