import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../providers/backend_provider.dart';
import '../../../../services/location_service.dart';
import '../full_screen_tracking_map_screen.dart';
import 'google_maps_user_dot.dart';
import 'location_access_helper.dart';
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
  final double? providerLatitude;
  final double? providerLongitude;
  /// Customer pickup pin (used on provider maps).
  final double? customerLatitude;
  final double? customerLongitude;
  /// When true, device GPS is the provider vehicle heading to [customerLatitude/Longitude].
  final bool isProviderPerspective;
  final String? destinationName;
  final double? visibleTopHeightFraction;
  final double zoom;
  final bool enableDrag;
  final Widget? overlay;
  final BorderRadius? borderRadius;
  final Color? tintColor;
  final double blurSigma;
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
    this.providerLatitude,
    this.providerLongitude,
    this.customerLatitude,
    this.customerLongitude,
    this.isProviderPerspective = false,
    this.destinationName,
    this.visibleTopHeightFraction,
    this.zoom = 15.0,
    this.enableDrag = true,
    this.overlay,
    this.borderRadius,
    this.tintColor,
    this.blurSigma = 0.0,
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
  static bool _validGpsCoord(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (!lat.isFinite || !lng.isFinite) return false;
    return lat.abs() > 0.001 || lng.abs() > 0.001;
  }

  double _screenBearing(Offset from, Offset to) {
    return (math.atan2(to.dy - from.dy, to.dx - from.dx) * 180.0 / math.pi) + 90.0;
  }

  double _angleToward({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
    required Offset Function(double lat, double lng) toScreen,
  }) {
    final from = toScreen(fromLat, fromLng);
    final to = toScreen(toLat, toLng);
    return _screenBearing(from, to);
  }

  Widget _buildDestinationMarker(String label) {
    final text = label.trim().isNotEmpty ? label.trim() : 'Customer';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2926),
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
            text,
            style: const TextStyle(
              fontSize: 8.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 2.0),
        const Icon(Icons.location_on_rounded, size: 28.0, color: Color(0xFF8B53FE)),
      ],
    );
  }

  double _panOffsetX = 0.0;
  double _panOffsetY = 0.0;
  double? _internalZoom;
  double? _mapCenterLat;
  double? _mapCenterLng;
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
    if (widget.isProviderPerspective) return;
    HapticFeedback.lightImpact();
    if (widget.onCarTap != null) {
      widget.onCarTap!();
    } else if (widget.driverName != null && widget.driverName!.trim().isNotEmpty) {
      ProviderDetailCardWidget.showAsBottomSheet(
        context: context,
        providerName: widget.driverName!,
        serviceCategory: widget.serviceCategory ?? '',
        vehicleName: widget.vehicleName ?? widget.serviceCategory ?? '',
        distance: widget.distanceText ?? '',
        estimatedTime: widget.etaText ?? '',
        providerLatitude: widget.providerLatitude,
        providerLongitude: widget.providerLongitude,
      );
    }
  }

  /// Centers the map on the user's live GPS (Google Maps my-location behavior).
  void recenterToUser(UserLocation userLoc) {
    setState(() {
      _mapCenterLat = userLoc.latitude;
      _mapCenterLng = userLoc.longitude;
      _panOffsetX = 0.0;
      _panOffsetY = 0.0;
      _internalZoom = (_internalZoom ?? widget.zoom).clamp(14.0, 17.0);
    });
  }

  /// Back-compat alias used by full-screen map host.
  void recenter() {
    final userLoc = ref.read(userLocationProvider).value;
    if (userLoc != null && userLoc.hasValidDeviceGps) {
      recenterToUser(userLoc);
    } else {
      setState(() {
        _panOffsetX = 0.0;
        _panOffsetY = 0.0;
      });
    }
  }

  Future<void> _onMyLocationControlTap(UserLocation userLoc) async {
    HapticFeedback.lightImpact();
    if (userLoc.hasValidDeviceGps) {
      final traced = await ref.read(locationServiceProvider).traceExactGps();
      if (!mounted || !traced.hasValidDeviceGps) return;
      recenterToUser(traced);
      ref.invalidate(userLocationProvider);
      return;
    }
    final resolved = await LocationAccessHelper.resolveForMapAction(context, ref);
    if (!mounted || resolved == null || !resolved.hasValidDeviceGps) return;
    recenterToUser(resolved);
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final userLocAsync = ref.watch(userLocationProvider);
    final streamRaw = userLocAsync.value;
    final raw = (streamRaw != null && streamRaw.hasValidDeviceGps)
        ? streamRaw
        : LocationService.lastKnownValidLocation;
    final userLoc =
        (raw != null && raw.hasValidDeviceGps) ? raw : UserLocation.defaultLocation;

    final bool widgetHasValidCoords = widget.latitude != null &&
        widget.longitude != null &&
        !(widget.latitude == 0.0 && widget.longitude == 0.0);

    final double centerLat = _mapCenterLat ??
        (widgetHasValidCoords
            ? widget.latitude!
            : (userLoc.hasValidDeviceGps
                ? userLoc.latitude
                : UserLocation.fallbackMapLat));
    final double centerLng = _mapCenterLng ??
        (widgetHasValidCoords
            ? widget.longitude!
            : (userLoc.hasValidDeviceGps
                ? userLoc.longitude
                : UserLocation.fallbackMapLng));

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

        // If a bottom card covers the lower portion of the map, center the live GPS pin
        // inside the visible upper strip so the user's location and provider car are clearly visible!
        final double anchorY = widget.visibleTopHeightFraction != null
            ? (height * (widget.visibleTopHeightFraction!.clamp(0.25, 1.0) * 0.56))
            : (height / 2.0);

        final double leftPx = currentCenterPxX - (width / 2.0);
        final double topPx = currentCenterPxY - anchorY;
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
              anchorY;
          return Offset(pxX, pxY);
        }

        // Real live customer GPS & real provider GPS (zero fake coordinates)
        final double userLat = userLoc.hasValidDeviceGps ? userLoc.latitude : centerLat;
        final double userLng = userLoc.hasValidDeviceGps ? userLoc.longitude : centerLng;
        final bool hasRealProviderCoords =
            widget.providerLatitude != null &&
            widget.providerLongitude != null &&
            widget.providerLatitude!.isFinite &&
            widget.providerLongitude!.isFinite &&
            (widget.providerLatitude!.abs() > 0.001 || widget.providerLongitude!.abs() > 0.001);

        final double providerLat = hasRealProviderCoords
            ? widget.providerLatitude!
            : (widget.isProviderPerspective && userLoc.hasValidDeviceGps
                ? userLat
                : (userLat + 0.0025));
        final double providerLng = hasRealProviderCoords
            ? widget.providerLongitude!
            : (widget.isProviderPerspective && userLoc.hasValidDeviceGps
                ? userLng
                : (userLng - 0.0025));

        final double? realDistanceKm = widget.isProviderPerspective
            ? (_validGpsCoord(widget.customerLatitude, widget.customerLongitude) &&
                    userLoc.hasValidDeviceGps
                ? Geolocator.distanceBetween(
                      userLat,
                      userLng,
                      widget.customerLatitude!,
                      widget.customerLongitude!,
                    ) /
                    1000.0
                : null)
            : (userLoc.hasValidDeviceGps && hasRealProviderCoords
                ? (Geolocator.distanceBetween(userLat, userLng, providerLat, providerLng) /
                    1000.0)
                : null);

        final List<Offset> gpsWaypoints = [
          Offset(providerLat, providerLng),
          Offset((providerLat * 0.65) + (userLat * 0.35), (providerLng * 0.55) + (userLng * 0.45)),
          Offset((providerLat * 0.3) + (userLat * 0.7), (providerLng * 0.3) + (userLng * 0.7)),
          Offset(userLat, userLng),
        ];

        final List<Offset> screenWaypoints = gpsWaypoints
            .map((pt) => toScreen(pt.dx, pt.dy))
            .toList();

        final Offset userScreenPos = toScreen(userLat, userLng);
        final Offset rawProviderScreenPos = toScreen(providerLat, providerLng);
        // When customer & provider are very close (< 28px apart), slightly offset the provider car
        // vertically so both the "You" badge and the provider distance badge stay clearly legible.
        final double screenGap = (rawProviderScreenPos - userScreenPos).distance;
        final Offset providerScreenPos = (hasRealProviderCoords && userLoc.hasValidDeviceGps && screenGap < 28.0)
            ? Offset(rawProviderScreenPos.dx + 14.0, rawProviderScreenPos.dy - 26.0)
            : rawProviderScreenPos;

        Widget baseMapLayer = Stack(
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
          ],
        );

        if (widget.blurSigma > 0) {
          baseMapLayer = ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: widget.blurSigma,
              sigmaY: widget.blurSigma,
              tileMode: TileMode.decal,
            ),
            child: baseMapLayer,
          );
        }

        return Stack(
          children: [
            Positioned.fill(child: baseMapLayer),

            // Step-based Functional Map Tracking Layers
            if (widget.trackingStep == MapTrackingStep.onTheWay ||
                widget.trackingStep == MapTrackingStep.arrived) ...[
              Positioned.fill(
                child: Builder(
                  builder: (context) {
                  final bool providerView = widget.isProviderPerspective;
                  final bool arrived =
                      widget.trackingStep == MapTrackingStep.arrived;
                  final double? pinLat = _validGpsCoord(
                    widget.customerLatitude,
                    widget.customerLongitude,
                  )
                      ? widget.customerLatitude
                      : (providerView && widgetHasValidCoords
                          ? widget.latitude
                          : null);
                  final double? pinLng = _validGpsCoord(
                    widget.customerLatitude,
                    widget.customerLongitude,
                  )
                      ? widget.customerLongitude
                      : (providerView && widgetHasValidCoords
                          ? widget.longitude
                          : null);
                  final bool hasCustomerPin =
                      _validGpsCoord(pinLat, pinLng);
                  final bool hasDest = providerView
                      ? (hasCustomerPin ||
                          (arrived && userLoc.hasValidDeviceGps))
                      : userLoc.hasValidDeviceGps;
                  final bool hasVehicle = providerView
                      ? (userLoc.hasValidDeviceGps || hasCustomerPin)
                      : hasRealProviderCoords;

                  final bool providerCanRender =
                      providerView && (hasCustomerPin || userLoc.hasValidDeviceGps);

                  if (providerView) {
                    if (!providerCanRender) {
                      return const SizedBox.shrink();
                    }
                  } else if (!hasDest || !hasVehicle) {
                    if (userLoc.hasValidDeviceGps) {
                      return Positioned(
                        left: userScreenPos.dx - 24.0,
                        top: userScreenPos.dy - 24.0,
                        child: _buildUserLocationMarker(tr),
                      );
                    }
                    return const SizedBox.shrink();
                  }

                  final double destLat = providerView
                      ? (hasCustomerPin ? pinLat! : userLat)
                      : userLat;
                  final double destLng = providerView
                      ? (hasCustomerPin ? pinLng! : userLng)
                      : userLng;
                  final double vehicleLat = providerView
                      ? (userLoc.hasValidDeviceGps ? userLat : destLat)
                      : providerLat;
                  final double vehicleLng = providerView
                      ? (userLoc.hasValidDeviceGps ? userLng : destLng)
                      : providerLng;
                  // Customer view: provider car snaps to customer pin when arrived.
                  // Provider view: keep "You" at real GPS + separate customer destination pin.
                  final double carLat = (arrived && !providerView) ? destLat : vehicleLat;
                  final double carLng = (arrived && !providerView) ? destLng : vehicleLng;

                  final List<Offset> liveGpsRoute = [
                    Offset(vehicleLat, vehicleLng),
                    Offset(
                      (vehicleLat * 0.65) + (destLat * 0.35),
                      (vehicleLng * 0.55) + (destLng * 0.45),
                    ),
                    Offset(
                      (vehicleLat * 0.35) + (destLat * 0.65),
                      (vehicleLng * 0.35) + (destLng * 0.65),
                    ),
                    Offset(destLat, destLng),
                  ];
                  final liveScreenRoute =
                      liveGpsRoute.map((pt) => toScreen(pt.dx, pt.dy)).toList();
                  Offset carScreen = toScreen(carLat, carLng);
                  final Offset destScreen = toScreen(destLat, destLng);
                  if (providerView && hasCustomerPin) {
                    final double screenGap = (carScreen - destScreen).distance;
                    if (screenGap < 36.0) {
                      carScreen = Offset(
                        carScreen.dx - 20.0,
                        carScreen.dy + 24.0,
                      );
                    }
                  }
                  final double carAngle = _angleToward(
                    fromLat: vehicleLat,
                    fromLng: vehicleLng,
                    toLat: destLat,
                    toLng: destLng,
                    toScreen: toScreen,
                  );

                  final String carBadge = providerView
                      ? tr.youBadge
                      : ((widget.driverName != null &&
                              widget.driverName!.trim().isNotEmpty)
                          ? widget.driverName!.trim().split(' ').first
                          : 'Provider');

                  final String destLabel = (widget.destinationName?.trim().isNotEmpty ==
                          true)
                      ? widget.destinationName!.trim().split(' ').first
                      : (providerView ? 'Customer' : tr.youBadge);

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomPaint(
                        size: Size(width, height),
                        painter: _LiveRoutePolylinePainter(
                          waypoints: liveScreenRoute,
                          color: const Color(0xFF8B53FE),
                          strokeWidth: 4.5,
                        ),
                      ),
                      Positioned(
                        left: carScreen.dx - 45.0,
                        top: carScreen.dy - 50.0,
                        width: 90.0,
                        height: 74.0,
                        child: TopDownCarWidget(
                          carId: widget.driverName ?? 'vehicle',
                          width: 17.0,
                          height: 29.0,
                          angle: carAngle,
                          driverName: carBadge,
                          distanceKm: arrived ? null : realDistanceKm,
                          showBadge: true,
                          bodyColor: const Color(0xFFA67AFE),
                          onTap: widget.isProviderPerspective ? null : _handleCarTap,
                        ),
                      ),
                      if (!providerView && userLoc.hasValidDeviceGps)
                        Positioned(
                          left: userScreenPos.dx - 24.0,
                          top: userScreenPos.dy - 24.0,
                          child: _buildUserLocationMarker(tr),
                        ),
                      if (providerView)
                        Positioned(
                          left: destScreen.dx - 24.0,
                          top: destScreen.dy - 40.0,
                          child: _buildDestinationMarker(destLabel),
                        ),
                    ],
                  );
                  },
                ),
              ),
            ] else if (widget.trackingStep == MapTrackingStep.none) ...[
              // Always show real live customer GPS marker on background maps when GPS is active
              if (userLoc.hasValidDeviceGps)
                Positioned(
                  left: userScreenPos.dx - 24.0,
                  top: userScreenPos.dy - 24.0,
                  child: _buildUserLocationMarker(tr),
                ),
              // Show real provider car marker at their exact live GPS coordinates when available
              if (hasRealProviderCoords)
                Positioned(
                  left: providerScreenPos.dx - 45.0,
                  top: providerScreenPos.dy - 50.0,
                  width: 90.0,
                  height: 74.0,
                  child: TopDownCarWidget(
                    carId: widget.driverName ?? 'provider',
                    width: 17.0,
                    height: 29.0,
                    angle: 35.0,
                    driverName: (widget.driverName != null && widget.driverName!.trim().isNotEmpty)
                        ? widget.driverName!.trim().split(' ').first
                        : 'Provider',
                    distanceKm: realDistanceKm,
                    showBadge: true,
                    bodyColor: const Color(0xFFA67AFE),
                    onTap: widget.isProviderPerspective ? null : _handleCarTap,
                  ),
                ),
            ] else if (widget.trackingStep == MapTrackingStep.requestSent) ...[
              // Radar ripple waves around user's real GPS pin
              if (userLoc.hasValidDeviceGps)
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
              if (userLoc.hasValidDeviceGps)
                Positioned(
                  left: userScreenPos.dx - 24.0,
                  top: userScreenPos.dy - 24.0,
                  child: _buildUserLocationMarker(tr),
                ),
              if (hasRealProviderCoords)
                Positioned(
                  left: providerScreenPos.dx - 45.0,
                  top: providerScreenPos.dy - 50.0,
                  width: 90.0,
                  height: 74.0,
                  child: TopDownCarWidget(
                    carId: widget.driverName ?? 'provider',
                    width: 17.0,
                    height: 29.0,
                    angle: 35.0,
                    driverName: (widget.driverName != null && widget.driverName!.trim().isNotEmpty)
                        ? widget.driverName!.trim().split(' ').first
                        : 'Provider',
                    distanceKm: realDistanceKm,
                    showBadge: true,
                    bodyColor: const Color(0xFFA67AFE),
                    onTap: widget.isProviderPerspective ? null : _handleCarTap,
                  ),
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
                      onTap: () => _onMyLocationControlTap(userLoc),
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
        const GoogleMapsUserDot(size: 18.0, showAccuracyRing: true),
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
