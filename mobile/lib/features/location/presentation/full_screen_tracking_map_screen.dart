import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_locale.dart';
import '../../../providers/backend_provider.dart';
import '../../../services/location_service.dart';
import 'widgets/real_map_background_widget.dart';

/// Full Screen Interactive Tracking Map Screen
/// Displays full interactive map with slippy tiles, live route, car animation,
/// zoom controls, recenter button, and provider summary.
class FullScreenTrackingMapScreen extends ConsumerStatefulWidget {
  final MapTrackingStep trackingStep;
  final String driverName;
  final String etaText;
  final String distanceText;
  final String vehicleName;
  final String plateNumber;
  final double rating;
  final String trips;
  final String avatarPath;

  const FullScreenTrackingMapScreen({
    super.key,
    this.trackingStep = MapTrackingStep.onTheWay,
    this.driverName = 'Ahmad Transport',
    this.etaText = '8 min away',
    this.distanceText = '1.8 km',
    this.vehicleName = 'Toyota Hilux',
    this.plateNumber = 'ABC-123',
    this.rating = 4.9,
    this.trips = '120 trips',
    this.avatarPath = 'assets/images/driver_avatar.png',
  });

  @override
  ConsumerState<FullScreenTrackingMapScreen> createState() =>
      _FullScreenTrackingMapScreenState();
}

class _FullScreenTrackingMapScreenState
    extends ConsumerState<FullScreenTrackingMapScreen> {
  double _zoom = 15.0;
  final GlobalKey<RealMapBackgroundWidgetState> _mapKey =
      GlobalKey<RealMapBackgroundWidgetState>();

  void _zoomIn() {
    HapticFeedback.lightImpact();
    setState(() {
      _zoom = (_zoom + 1.0).clamp(12.0, 18.0);
    });
  }

  void _zoomOut() {
    HapticFeedback.lightImpact();
    setState(() {
      _zoom = (_zoom - 1.0).clamp(12.0, 18.0);
    });
  }

  void _recenter() {
    HapticFeedback.lightImpact();
    final userLoc = ref.read(userLocationProvider).value ?? UserLocation.defaultLocation;
    if (!userLoc.isGpsDetected) {
      final tr = ref.read(translationsProvider);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.location_off_rounded, size: 16.0, color: Colors.white),
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
    _mapKey.currentState?.recenter();
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final isRtl = tr.isArabic || Directionality.of(context) == TextDirection.rtl;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Full Screen Interactive Slippy Map
          Positioned.fill(
            child: RealMapBackgroundWidget(
              key: _mapKey,
              enableDrag: true,
              zoom: _zoom,
              trackingStep: widget.trackingStep,
              driverName: widget.driverName,
              vehicleName: widget.vehicleName,
              etaText: widget.etaText,
              distanceText: widget.distanceText,
              showControls: false, // We supply custom floating controls on full screen
            ),
          ),

          // 2. Top Header Bar (Back button, Title, Filter button)
          Positioned(
            top: topPadding + 12.0,
            left: 16.0,
            right: 16.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 10.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                        size: 26.0,
                        color: const Color(0xFF1C2926),
                      ),
                    ),
                  ),
                ),

                // Title Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 10.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.0,
                        height: 8.0,
                        decoration: const BoxDecoration(
                          color: Color(0xFF8B53FE),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        tr.isArabic ? 'خريطة التتبع المباشر' : 'Live Tracking Map',
                        style: tr.font(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C2926),
                        ),
                      ),
                    ],
                  ),
                ),

                // Recenter Icon Button in Header
                GestureDetector(
                  onTap: _recenter,
                  child: Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 10.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.my_location_rounded,
                        size: 20.0,
                        color: Color(0xFF8B53FE),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating Zoom Controls (+ and -) on right side
          Positioned(
            right: isRtl ? null : 16.0,
            left: isRtl ? 16.0 : null,
            bottom: bottomPadding + 140.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _zoomIn,
                  child: Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 8.0,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.add_rounded, size: 22.0, color: Color(0xFF1C2926)),
                    ),
                  ),
                ),
                Container(
                  width: 44.0,
                  height: 1.0,
                  color: const Color(0xFFF3F4F6),
                ),
                GestureDetector(
                  onTap: _zoomOut,
                  child: Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(10.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 8.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.remove_rounded, size: 22.0, color: Color(0xFF1C2926)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Floating Provider Card at Bottom
          Positioned(
            left: 16.0,
            right: 16.0,
            bottom: bottomPadding + 16.0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 16.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Avatar
                      ClipOval(
                        child: Image.asset(
                          widget.avatarPath,
                          width: 48.0,
                          height: 48.0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 48.0,
                            height: 48.0,
                            color: const Color(0xFFFFB6C1),
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14.0),
                      // Driver Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.driverName,
                              style: tr.font(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1C2926),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2.0),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 13.0, color: Color(0xFF8B53FE)),
                                const SizedBox(width: 3.0),
                                Text(
                                  '${widget.rating} (${widget.trips})',
                                  style: tr.font(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF566663),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              '${widget.vehicleName} • ${widget.plateNumber}',
                              style: tr.font(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1C2926),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // ETA / Distance Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EAFE),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.distanceText,
                              style: tr.font(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF8B53FE),
                              ),
                            ),
                            Text(
                              widget.etaText,
                              style: tr.font(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF8B53FE),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
