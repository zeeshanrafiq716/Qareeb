import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../providers/backend_provider.dart';
import '../../../../services/location_service.dart';
import '../full_screen_tracking_map_screen.dart';
import 'map_tracking_step.dart';
import 'provider_detail_card_widget.dart';
import 'top_down_car_widget.dart';

export 'map_tracking_step.dart';

/// Standard Web Mercator (EPSG:3857) projection matching Google Maps & OpenStreetMap
class MapMercatorProjection {
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

/// Dynamic real-world interactive slippy map background with live Google / OSM tiles
/// and step-aware real tracking overlays (User GPS Pin, Road Route, Animated Car, Radar).
class RealMapBackgroundWidget extends ConsumerStatefulWidget {
  final double? latitude;
  final double? longitude;
  final double zoom;
  final bool enableDrag;
  final Widget? overlay;
  final BorderRadius? borderRadius;
  final Color? tintColor;
  final MapTrackingStep trackingStep;
  final String? driverName;
  final String? serviceCategory;
  final String? vehicleName;
  final String? etaText;
  final String? distanceText;
  final bool showControls;
  final VoidCallback? onFullView;
  final VoidCallback? onCarTap;

  const RealMapBackgroundWidget({
    super.key,
    this.latitude,
    this.longitude,
    this.zoom = 15.0,
    this.enableDrag = true,
    this.overlay,
    this.borderRadius,
    this.tintColor,
    this.trackingStep = MapTrackingStep.none,
    this.driverName,
    this.serviceCategory,
    this.vehicleName,
    this.etaText,
    this.distanceText,
    this.showControls = false,
    this.onFullView,
    this.onCarTap,
  });

  @override
  ConsumerState<RealMapBackgroundWidget> createState() =>
      RealMapBackgroundWidgetState();
}

class RealMapBackgroundWidgetState extends ConsumerState<RealMapBackgroundWidget>
    with TickerProviderStateMixin {
  double _panOffsetX = 0.0;
  double _panOffsetY = 0.0;
  double? _internalZoom;
  double _baseScale = 1.0;
  bool _isDragging = false;

  double get currentZoom => (_internalZoom ?? widget.zoom).clamp(10.0, 19.0);

  void zoomIn() {
    HapticFeedback.lightImpact();
    setState(() {
      _internalZoom = (currentZoom + 1.0).clamp(10.0, 19.0);
    });
  }

  void zoomOut() {
    HapticFeedback.lightImpact();
    setState(() {
      _internalZoom = (currentZoom - 1.0).clamp(10.0, 19.0);
    });
  }

  late final AnimationController _carAnimationController;
  late final AnimationController _pulseAnimationController;

  @override
  void initState() {
    super.initState();
    _carAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _carAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  /// Handles tap on car in map to open Provider Details Card
  void _handleCarTap() {
    HapticFeedback.lightImpact();
    if (widget.onCarTap != null) {
      widget.onCarTap!();
    } else {
      final tr = ref.read(translationsProvider);
      ProviderDetailCardWidget.showAsBottomSheet(
        context: context,
        providerName: widget.driverName ?? 'Usman Ali',
        serviceCategory: widget.serviceCategory ?? 'Fire Brigade',
        vehicleName: widget.vehicleName ?? 'Toyota Hilux',
        distance: widget.distanceText ?? '1.8 km',
        estimatedTime: widget.etaText ?? (tr.isArabic ? '6 د' : '6 min'),
      );
    }
  }

  /// Recenter the map to user location
  void recenter() {
    setState(() {
      _panOffsetX = 0.0;
      _panOffsetY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final userLocAsync = ref.watch(userLocationProvider);
    final userLoc = userLocAsync.value ?? UserLocation.defaultLocation;

    final double centerLat = widget.latitude ?? userLoc.latitude;
    final double centerLng = widget.longitude ?? userLoc.longitude;

    final double activeZoom = currentZoom;
    final double baseCenterPxX =
        MapMercatorProjection.lngToX(centerLng, activeZoom);
    final double baseCenterPxY =
        MapMercatorProjection.latToY(centerLat, activeZoom);

    final double currentCenterPxX = baseCenterPxX - _panOffsetX;
    final double currentCenterPxY = baseCenterPxY - _panOffsetY;

    Widget mapContent = LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        if (width <= 0 || height <= 0) return const SizedBox();

        const double tileSize = 256.0;
        final int z = activeZoom.toInt();

        final double leftPx = currentCenterPxX - (width / 2.0);
        final double topPx = currentCenterPxY - (height / 2.0);
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
            final int wrappedTileX =
                (tx % (maxIndex + 1) + (maxIndex + 1)) % (maxIndex + 1);
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
                key: ValueKey('map_tile_${wrappedTileX}_${ty}_$z'),
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

        // Coordinate to Screen Pixel converter (stays locked to GPS coords when panning)
        Offset toScreen(double lat, double lng) {
          final double pxX = MapMercatorProjection.lngToX(lng, activeZoom) -
              currentCenterPxX +
              (width / 2.0);
          final double pxY = MapMercatorProjection.latToY(lat, activeZoom) -
              currentCenterPxY +
              (height / 2.0);
          return Offset(pxX, pxY);
        }

        // Realistic road path coordinates connecting provider to user
        // Coordinates offset ~1.5 - 2 km along real neighborhood grid
        final double userLat = centerLat;
        final double userLng = centerLng;
        final double providerLat = userLat + 0.0055;
        final double providerLng = userLng - 0.0070;

        final List<Offset> gpsWaypoints = [
          Offset(providerLat, providerLng),
          Offset(providerLat - 0.0016, providerLng + 0.0024),
          Offset(providerLat - 0.0036, providerLng + 0.0038),
          Offset(userLat + 0.0012, userLng - 0.0016),
          Offset(userLat, userLng),
        ];

        final List<Offset> screenWaypoints = gpsWaypoints
            .map((pt) => toScreen(pt.dx, pt.dy))
            .toList();

        final Offset userScreenPos = toScreen(userLat, userLng);

        return Stack(
          children: [
            // Baseline background image while tiles load
            Positioned.fill(
              child: Image.asset(
                'assets/images/BG image.png',
                fit: BoxFit.cover,
              ),
            ),
            // Live vector/raster tiles
            ...tileWidgets,
            // Subtle theme tint
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.tintColor ??
                      const Color(0xFF8B53FE).withValues(alpha: 0.04),
                ),
              ),
            ),

            // Step-based Functional Map Tracking Layers
            if (widget.trackingStep == MapTrackingStep.onTheWay ||
                widget.trackingStep == MapTrackingStep.arrived) ...[
              // 1. Live Road Route Polyline
              CustomPaint(
                size: Size(width, height),
                painter: _LiveRoutePolylinePainter(
                  waypoints: screenWaypoints,
                  color: const Color(0xFF8B53FE),
                  strokeWidth: 4.5,
                ),
              ),

              // 2. Animated Driving Car / Arrived Car
              AnimatedBuilder(
                animation: _carAnimationController,
                builder: (context, _) {
                  Offset carPos;
                  double carAngle;

                  if (widget.trackingStep == MapTrackingStep.arrived) {
                    // Car is parked right beside user's pin
                    final Offset arrivedOffset = toScreen(userLat + 0.0004, userLng + 0.0004);
                    carPos = arrivedOffset;
                    carAngle = -45.0;
                  } else {
                    // Car animates along the road path towards user
                    final double progress = _carAnimationController.value.clamp(0.0, 0.95);
                    final computed = _interpolateAlongPath(screenWaypoints, progress);
                    carPos = computed.position;
                    carAngle = computed.angle;
                  }

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Interactive Car with Speech Bubble ("• Usman \n ▶ 1.8 km")
                      // Tap on car or speech bubble opens the Provider Details Card
                      Positioned(
                        left: carPos.dx - 45.0,
                        top: carPos.dy - 50.0,
                        width: 90.0,
                        height: 74.0,
                        child: TopDownCarWidget(
                          width: 17.0,
                          height: 29.0,
                          angle: carAngle,
                          driverName: (widget.driverName ?? 'Usman').split(' ').first,
                          distanceKm: widget.trackingStep == MapTrackingStep.arrived ? null : 1.8,
                          showBadge: true,
                          bodyColor: const Color(0xFFA67AFE),
                          onTap: _handleCarTap,
                        ),
                      ),
                    ],
                  );
                },
              ),

              // 3. User Marker Pin with Glowing Concentric Halos & "You" Bubble
              Positioned(
                left: userScreenPos.dx - 24.0,
                top: userScreenPos.dy - 24.0,
                child: _buildUserLocationMarker(tr),
              ),
            ] else if (widget.trackingStep == MapTrackingStep.requestSent) ...[
              // Radar ripple waves around user's GPS pin (only when GPS is detected)
              if (userLoc.isGpsDetected)
                AnimatedBuilder(
                  animation: _pulseAnimationController,
                  builder: (context, _) {
                    final double pulseVal = _pulseAnimationController.value;
                    return Positioned(
                      left: userScreenPos.dx - (40.0 * (1.0 + pulseVal * 0.8)),
                      top: userScreenPos.dy - (40.0 * (1.0 + pulseVal * 0.8)),
                      width: 80.0 * (1.0 + pulseVal * 0.8),
                      height: 80.0 * (1.0 + pulseVal * 0.8),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF8B53FE)
                              .withValues(alpha: (0.25 * (1.0 - pulseVal)).clamp(0.0, 1.0)),
                        ),
                      ),
                    );
                  },
                ),
              Positioned(
                left: userScreenPos.dx - 24.0,
                top: userScreenPos.dy - 24.0,
                child: _buildUserLocationMarker(tr),
              ),
            ],

            // Custom overlay if provided
            if (widget.overlay != null) widget.overlay!,

            // Floating Controls: Recenter Crosshair Button & Full View Button
            if (widget.showControls) ...[
              // Full View Button at Top-Right
              Positioned(
                top: 10.0,
                right: 10.0,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (widget.onFullView != null) {
                      widget.onFullView!();
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FullScreenTrackingMapScreen(
                            trackingStep: widget.trackingStep,
                            driverName: widget.driverName ?? 'Ahmad Transport',
                            etaText: widget.etaText ?? (tr.isArabic ? '8 د' : '8 min away'),
                            distanceText: widget.distanceText ?? '1.8 km',
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F000000),
                          blurRadius: 8.0,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.open_in_full_rounded,
                          size: 13.0,
                          color: Color(0xFF8B53FE),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          tr.isArabic ? 'شاشة كاملة' : 'Full View',
                          style: tr.font(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1C2926),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Floating Controls at Bottom-Right: Zoom In, Zoom Out, GPS Recenter
              Positioned(
                bottom: 10.0,
                right: 10.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Zoom In Button (+)
                    GestureDetector(
                      onTap: zoomIn,
                      child: Container(
                        width: 32.0,
                        height: 32.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 8.0,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add_rounded,
                            size: 18.0,
                            color: Color(0xFF1C2926),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    // Zoom Out Button (-)
                    GestureDetector(
                      onTap: zoomOut,
                      child: Container(
                        width: 32.0,
                        height: 32.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 8.0,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.remove_rounded,
                            size: 18.0,
                            color: Color(0xFF1C2926),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    // GPS Recenter Button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (!userLoc.isGpsDetected) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.location_off_rounded,
                                    size: 16.0,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      tr.isArabic
                                          ? 'خدمة الموقع غير مفعلة في جهازك'
                                          : 'Device location is OFF. Please turn ON location in device settings.',
                                      style: tr.font(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFFE11D48),
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        recenter();
                      },
                      child: Container(
                        width: 32.0,
                        height: 32.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 8.0,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            userLoc.isGpsDetected ? Icons.my_location_rounded : Icons.location_off_rounded,
                            size: 16.0,
                            color: userLoc.isGpsDetected ? const Color(0xFF1C2926) : const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );

    if (widget.enableDrag) {
      mapContent = Listener(
        onPointerSignal: (pointerSignal) {
          if (pointerSignal is PointerScrollEvent) {
            if (pointerSignal.scrollDelta.dy < 0) {
              zoomIn();
            } else if (pointerSignal.scrollDelta.dy > 0) {
              zoomOut();
            }
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: zoomIn,
          onScaleStart: (details) {
            _baseScale = 1.0;
            setState(() => _isDragging = true);
          },
          onScaleUpdate: (details) {
            setState(() {
              _panOffsetX += details.focalPointDelta.dx;
              _panOffsetY += details.focalPointDelta.dy;

              if (details.scale != 1.0) {
                final double ratio = details.scale / _baseScale;
                if (ratio > 1.25 && currentZoom < 19.0) {
                  _internalZoom = (currentZoom + 1.0).clamp(10.0, 19.0);
                  _baseScale = details.scale;
                } else if (ratio < 0.8 && currentZoom > 10.0) {
                  _internalZoom = (currentZoom - 1.0).clamp(10.0, 19.0);
                  _baseScale = details.scale;
                }
              }
            });
          },
          onScaleEnd: (details) {
            setState(() => _isDragging = false);
          },
          child: MouseRegion(
            cursor: _isDragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab,
            child: mapContent,
          ),
        ),
      );
    }

    if (widget.borderRadius != null) {
      mapContent = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: mapContent,
      );
    }

    return mapContent;
  }

  /// Builds the floating ETA badge above the car
  Widget _buildFloatingEtaBubble({required String text}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: const Color(0xFF8B53FE),
            borderRadius: BorderRadius.circular(6.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 9.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        CustomPaint(
          size: const Size(6.0, 4.0),
          painter: _BubbleTrianglePainter(color: const Color(0xFF8B53FE)),
        ),
      ],
    );
  }

  /// Builds the User Location Pin with halo and "You" badge
  Widget _buildUserLocationMarker(AppTranslations tr) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "You" badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: const Color(0xFF8B53FE),
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 4.0,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            tr.youBadge,
            style: const TextStyle(
              fontSize: 8.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 1.0),
        // Pin with pulsing halo
        Container(
          width: 38.0,
          height: 38.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF0EAFE),
            border: Border.all(
              color: const Color(0x808B53FE),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x338B53FE),
                blurRadius: 8.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.location_on_rounded,
              size: 24.0,
              color: Color(0xFF8B53FE),
            ),
          ),
        ),
      ],
    );
  }

  /// Interpolates position and angle along a list of 2D screen waypoints
  _PathInterpolation _interpolateAlongPath(List<Offset> waypoints, double t) {
    if (waypoints.isEmpty) return _PathInterpolation(Offset.zero, 0.0);
    if (waypoints.length == 1) return _PathInterpolation(waypoints.first, 0.0);

    // Compute total distance
    double totalDist = 0.0;
    final List<double> segmentDists = [];
    for (int i = 0; i < waypoints.length - 1; i++) {
      final d = (waypoints[i + 1] - waypoints[i]).distance;
      segmentDists.add(d);
      totalDist += d;
    }

    if (totalDist <= 0.0) return _PathInterpolation(waypoints.first, 0.0);

    final double targetDist = totalDist * t;
    double accumulated = 0.0;

    for (int i = 0; i < segmentDists.length; i++) {
      final double segDist = segmentDists[i];
      if (accumulated + segDist >= targetDist || i == segmentDists.length - 1) {
        final double segT = segDist > 0 ? (targetDist - accumulated) / segDist : 0.0;
        final p1 = waypoints[i];
        final p2 = waypoints[i + 1];
        final pos = Offset.lerp(p1, p2, segT.clamp(0.0, 1.0)) ?? p1;
        final double angle =
            (math.atan2(p2.dy - p1.dy, p2.dx - p1.dx) * 180.0 / math.pi) + 90.0;
        return _PathInterpolation(pos, angle);
      }
      accumulated += segDist;
    }

    return _PathInterpolation(waypoints.last, 0.0);
  }
}

class _PathInterpolation {
  final Offset position;
  final double angle;
  _PathInterpolation(this.position, this.angle);
}

/// Custom painter for live curved road polyline
class _LiveRoutePolylinePainter extends CustomPainter {
  final List<Offset> waypoints;
  final Color color;
  final double strokeWidth;

  _LiveRoutePolylinePainter({
    required this.waypoints,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waypoints.length < 2) return;

    // Glowing border / track underlay
    final Paint trackPaint = Paint()
      ..color = const Color(0xFFDACBFE).withValues(alpha: 0.6)
      ..strokeWidth = strokeWidth + 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Main route stroke
    final Paint routePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    path.moveTo(waypoints.first.dx, waypoints.first.dy);

    for (int i = 0; i < waypoints.length - 1; i++) {
      final p0 = waypoints[i];
      final p1 = waypoints[i + 1];
      final mid = Offset((p0.dx + p1.dx) / 2.0, (p0.dy + p1.dy) / 2.0);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    path.lineTo(waypoints.last.dx, waypoints.last.dy);

    canvas.drawPath(path, trackPaint);
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant _LiveRoutePolylinePainter oldDelegate) {
    return oldDelegate.waypoints != waypoints ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Downward pointing triangle for tooltip bubble
class _BubbleTrianglePainter extends CustomPainter {
  final Color color;
  _BubbleTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2.0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
