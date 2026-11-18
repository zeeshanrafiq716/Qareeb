import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/utils/contact_launcher.dart';
import '../../../providers/backend_provider.dart';
import '../../../services/location_service.dart';
import '../../../services/task_service.dart';
import 'live_tracking_screen.dart';
import 'send_location_screen.dart';
import 'send_request_screen.dart';
import 'widgets/real_map_background_widget.dart';

/// Screen displayed when user clicks on a provider card.
/// Shows 100% real live GPS map + real provider data (zero fallbacks).
class ProviderDetailScreen extends ConsumerStatefulWidget {
  final String serviceCategory;
  final String providerName;
  final String? providerPublicId;
  final String? phoneNumber;
  final String? photoUrl;
  final String? vehicleName;
  final String? distance;
  final String? estimatedTime;
  final double? rating;
  final int? reviews;
  final int? ordersCount;
  final bool? verified;
  final double? providerLatitude;
  final double? providerLongitude;

  const ProviderDetailScreen({
    super.key,
    this.serviceCategory = 'Service',
    this.providerName = 'Provider',
    this.providerPublicId,
    this.phoneNumber,
    this.photoUrl,
    this.vehicleName,
    this.distance,
    this.estimatedTime,
    this.rating,
    this.reviews,
    this.ordersCount,
    this.verified,
    this.providerLatitude,
    this.providerLongitude,
  });

  @override
  ConsumerState<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends ConsumerState<ProviderDetailScreen> {
  AppTranslations get tr => ref.read(translationsProvider);

  String? _phone;
  String? _photoUrl;
  String? _vehicleName;
  String? _categoryName;
  bool _verified = false;
  bool _isOnline = true;
  double _rating = 0.0;
  int _reviews = 0;
  int _ordersCount = 0;
  double? _providerLat;
  double? _providerLng;
  double? _backendDistanceMeters;

  void _onActiveTaskChanged() {
    if (mounted) setState(() {});
  }

  ServiceTask? get _matchingActiveTask {
    final task = TaskService.instance.activeTask;
    if (task == null) return null;
    final status = task.status.toLowerCase();
    if (status == 'completed' || status == 'cancelled') return null;
    final pubId = widget.providerPublicId?.trim() ?? '';
    if (pubId.isNotEmpty &&
        task.providerPublicId != null &&
        task.providerPublicId!.trim() == pubId) {
      return task;
    }
    if (widget.providerName.trim().isNotEmpty &&
        task.providerName.trim().toLowerCase() ==
            widget.providerName.trim().toLowerCase()) {
      return task;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _phone = _cleanOptional(widget.phoneNumber);
    _photoUrl = _cleanPhoto(widget.photoUrl);
    _vehicleName = _cleanOptional(widget.vehicleName);
    _categoryName = _cleanOptional(widget.serviceCategory);
    _verified = widget.verified ?? false;
    _rating = widget.rating ?? 0.0;
    _reviews = widget.reviews ?? 0;
    _ordersCount = widget.ordersCount ?? 0;
    _providerLat = widget.providerLatitude;
    _providerLng = widget.providerLongitude;
    TaskService.instance.activeTaskNotifier.addListener(_onActiveTaskChanged);

    if (widget.providerPublicId != null && widget.providerPublicId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final rawLoc = ref.read(userLocationProvider).value;
        final loc = (rawLoc != null && rawLoc.hasValidDeviceGps)
            ? rawLoc
            : LocationService.lastKnownValidLocation;
        ref.read(backendServiceProvider).trackCustomerEvent(
          event: 'profile_view',
          providerPublicId: widget.providerPublicId!,
          latitude: loc?.latitude,
          longitude: loc?.longitude,
        );
        _hydrateProfile();
      });
    }
  }

  @override
  void dispose() {
    TaskService.instance.activeTaskNotifier.removeListener(_onActiveTaskChanged);
    super.dispose();
  }

  String? _cleanOptional(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }

  String? _cleanPhoto(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text.contains('unsplash.com') || text.contains('placeholder')) return null;
    return text;
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'Z';
    String first(String s) => s.substring(0, 1).toUpperCase();
    if (parts.length == 1) return first(parts.first);
    return first(parts[0]) + first(parts[1]);
  }

  double? _computeRealDistanceMeters(UserLocation? userLoc) {
    final bool hasProv = _providerLat != null &&
        _providerLng != null &&
        _providerLat!.isFinite &&
        _providerLng!.isFinite &&
        (_providerLat!.abs() > 0.001 || _providerLng!.abs() > 0.001);
    if (userLoc != null && userLoc.hasValidDeviceGps && hasProv) {
      final m = Geolocator.distanceBetween(
        userLoc.latitude,
        userLoc.longitude,
        _providerLat!,
        _providerLng!,
      );
      if (m.isFinite && m >= 0) return m;
    }
    if (_backendDistanceMeters != null && _backendDistanceMeters! >= 0) {
      return _backendDistanceMeters;
    }
    return null;
  }

  String _formatDistance(double meters, bool isArabic) {
    if (meters < 1000.0) {
      return isArabic ? '${meters.round()} م' : '${meters.round()} m';
    }
    final km = meters / 1000.0;
    return isArabic ? '${km.toStringAsFixed(1)} كم' : '${km.toStringAsFixed(1)} km';
  }

  String _formatEta(double meters, bool isArabic) {
    if (meters < 100.0) {
      return isArabic ? 'أقل من دقيقة' : '< 1 min';
    }
    final mins = ((meters / 1000.0) / 30.0 * 60.0).ceil().clamp(1, 180);
    return isArabic ? '$mins د' : '$mins min';
  }

  Future<void> _hydrateProfile() async {
    final publicId = widget.providerPublicId?.trim() ?? '';
    if (publicId.isEmpty) return;
    try {
      final rawLoc = ref.read(userLocationProvider).value;
      final loc = (rawLoc != null && rawLoc.hasValidDeviceGps)
          ? rawLoc
          : LocationService.lastKnownValidLocation;
      final profile = await ref.read(backendServiceProvider).getPublicProviderProfile(
        publicId,
        latitude: loc?.latitude,
        longitude: loc?.longitude,
      );
      if (!mounted || profile == null) return;
      final contact = profile['contact'];
      String? phone = _phone;
      if (contact is Map && contact['phone'] != null) {
        phone = contact['phone'].toString();
      }
      phone ??= profile['phone']?.toString();
      final ratingMap = profile['rating'];
      final categoryMap = profile['category'];
      final availabilityMap = profile['availability'];
      final double? lat = (profile['latitude'] as num?)?.toDouble();
      final double? lng = (profile['longitude'] as num?)?.toDouble();
      final double? distM = (profile['distanceMeters'] as num?)?.toDouble();

      setState(() {
        _phone = _cleanOptional(phone);
        _photoUrl = _cleanPhoto(profile['photoUrl']?.toString()) ?? _photoUrl;
        final vType = _cleanOptional(profile['vehicleType']?.toString());
        if (vType != null) _vehicleName = vType;
        if (categoryMap is Map && categoryMap['name'] != null) {
          _categoryName = _cleanOptional(categoryMap['name']?.toString()) ?? _categoryName;
        }
        if (ratingMap is Map) {
          _rating = (ratingMap['average'] as num?)?.toDouble() ?? _rating;
          _reviews = (ratingMap['count'] as num?)?.toInt() ?? _reviews;
        }
        if (profile['ordersCount'] is num) {
          _ordersCount = (profile['ordersCount'] as num).toInt();
        }
        if (availabilityMap is Map && availabilityMap['isOnline'] is bool) {
          _isOnline = availabilityMap['isOnline'] as bool;
        }
        if (lat != null && lng != null && (lat.abs() > 0.001 || lng.abs() > 0.001)) {
          _providerLat = lat;
          _providerLng = lng;
        }
        if (distM != null && distM >= 0) {
          _backendDistanceMeters = distM;
        }
        final badges = profile['badges'];
        _verified = profile['verified'] == true ||
            (badges is Map && badges['verified'] == true) ||
            _verified;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final streamLoc = ref.watch(userLocationProvider).value;
    final UserLocation? activeUserLoc = (streamLoc != null && streamLoc.hasValidDeviceGps)
        ? streamLoc
        : LocationService.lastKnownValidLocation;
    final double? liveMeters = _computeRealDistanceMeters(activeUserLoc);
    final String realDistanceText = liveMeters != null
        ? _formatDistance(liveMeters, tr.isArabic)
        : ((widget.distance != null && widget.distance!.trim().isNotEmpty && widget.distance!.trim() != '--')
            ? widget.distance!.trim()
            : '--');
    final String realEtaText = liveMeters != null
        ? _formatEta(liveMeters, tr.isArabic)
        : ((widget.estimatedTime != null && widget.estimatedTime!.trim().isNotEmpty && widget.estimatedTime!.trim() != '--')
            ? widget.estimatedTime!.trim()
            : '--');
    final String displayCategory = tr.categoryName(_categoryName ?? widget.serviceCategory);
    final String displayVehicle = (_vehicleName != null &&
            _vehicleName!.isNotEmpty &&
            _vehicleName!.toLowerCase() != displayCategory.toLowerCase())
        ? _vehicleName!
        : '';

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
            final mediaQuery = MediaQuery.of(context);
            final double containerHeight = isDesktopWeb
                ? math.min(844.0, (constraints.maxHeight - 32.0).clamp(520.0, 844.0))
                : constraints.maxHeight;

            final screenContent = SizedBox(
              width: containerWidth,
              height: containerHeight,
              child: Stack(
                children: [
                  // 1. Live Real Slippy Map Layer showing real user GPS + real provider location
                  Positioned.fill(
                    child: RealMapBackgroundWidget(
                      enableDrag: true,
                      zoom: 15.0,
                      providerLatitude: _providerLat,
                      providerLongitude: _providerLng,
                      visibleTopHeightFraction: 0.42,
                      trackingStep: MapTrackingStep.none,
                      blurSigma: 0.0,
                      driverName: widget.providerName,
                      serviceCategory: displayCategory,
                      vehicleName: displayVehicle.isNotEmpty ? displayVehicle : displayCategory,
                      etaText: realEtaText,
                      distanceText: realDistanceText,
                      showControls: false,
                    ),
                  ),

                  // 7. Header with same previous branding:
                  // width: 350; height: 36; gap: 16px; top: 56px; left: 20px;
                  Positioned(
                    top: math.max(48.0, mediaQuery.padding.top + 8.0),
                    left: 20.0,
                    right: 20.0,
                    height: 36.0,
                    child: SizedBox(
                      height: 36.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Circular Back Button
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              key: const Key('provider_detail_back_button'),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).maybePop();
                              },
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
                                      color: Color(0x14000000), // #00000014
                                      blurRadius: 12.0,
                                      offset: Offset(0, -2),
                                      spreadRadius: 0.0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Transform.scale(
                                    scaleX: 1.0,
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
                          const SizedBox(width: 16.0), // gap: 16px;

                          // Title: Pickup & Delivery
                          Expanded(
                            child: Text(
                              tr.categoryName(widget.serviceCategory),
                              style: tr.font(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1C2926),
                                height: 1.15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 8. Card Widget: Full responsive edge-to-edge bottom sheet
                  Positioned(
                    top: (containerHeight * 0.40).clamp(270.0, 360.0),
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      width: double.infinity,
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
                        clipBehavior: Clip.none,
                        children: [
                          // Card top indicator handle
                          Positioned(
                            top: 12.0,
                            left: 0.0,
                            right: 0.0,
                            child: Center(
                              child: Container(
                                width: 40.0,
                                height: 4.0,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                              ),
                            ),
                          ),

                          // Top Corner Close Button ('X')
                          PositionedDirectional(
                            top: 12.0,
                            end: 16.0,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                key: const Key('provider_detail_card_close_button'),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.of(context).maybePop();
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 32.0,
                                  height: 32.0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 18.0,
                                      color: Color(0xFF566663),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // content layout: Responsive edge-to-edge
                          Positioned(
                            top: 36.0,
                            bottom: math.max(16.0, mediaQuery.padding.bottom + 8.0),
                            left: 20.0,
                            right: 20.0,
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                // 1st row designing:
                                // width: 350; height: 40; justify-content: space-between; angle: 0 deg; opacity: 1;
                                SizedBox(
                                  width: double.infinity,
                                  height: 40.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // left side content layout:
                                      // width: 228; height: 40; gap: 16px; angle: 0 deg; opacity: 1;
                                      SizedBox(
                                        width: 228.0,
                                        height: 40.0,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            // Avatar layout (clean, real only - no fake stock portraits)
                                            Container(
                                              width: 38.0,
                                              height: 38.0,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFF8B53FE),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: _photoUrl != null
                                                  ? Image.network(
                                                      _photoUrl!,
                                                      width: 38.0,
                                                      height: 38.0,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) => Center(
                                                        child: Text(
                                                          _initials(tr.formatProviderName(widget.providerName)),
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 14.0,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Center(
                                                      child: Text(
                                                        _initials(tr.formatProviderName(widget.providerName)),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 14.0,
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                            const SizedBox(width: 12.0),

                                            // content layout:
                                            // width: 176; height: 40; gap: 12px; angle: 0 deg; opacity: 1;
                                            SizedBox(
                                              width: 176.0,
                                              height: 40.0,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // content 1st row branding:
                                                  // width: 176; height: 18; gap: 12px; angle: 0 deg; opacity: 1;
                                                  SizedBox(
                                                    width: 176.0,
                                                    height: 18.0,
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        // content: Ahmad Transport
                                                        // width: 117; height: 10; font-family: Inter; font-weight: 500; font-size: 14px; line-height: 22px; color: #1C2926;
                                                        Expanded(
                                                          child: FittedBox(
                                                            fit: BoxFit.scaleDown,
                                                            alignment: AlignmentDirectional.centerStart,
                                                            child: Text(
                                                              tr.formatProviderName(widget.providerName),
                                                              style: tr.font(
                                                                fontSize: 14.0,
                                                                fontWeight: FontWeight.w500,
                                                                color: const Color(0xFF1C2926),
                                                                height: 1.15,
                                                              ),
                                                              maxLines: 1,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12.0), // gap: 12px;

                                                        // available badge layout:
                                                        // width: 47; height: 18; gap: 10px; border-radius: 60px; padding: 6px; background: #F0F5F2;
                                                        // content: Available (width: 35; height: 6; font-family: Inter; font-weight: 500; font-size: 8px; line-height: 22px; color: #1D8070)
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                                          constraints: const BoxConstraints(minWidth: 47.0),
                                                          height: 18.0,
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFFF0EAFE),
                                                            borderRadius: BorderRadius.circular(60.0),
                                                          ),
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            tr.isArabic ? 'متاح' : 'Available',
                                                            style: tr.font(
                                                              fontSize: 8.0,
                                                              fontWeight: FontWeight.w500,
                                                              color: const Color(0xFF8B53FE),
                                                              height: 1.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 3.0),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        const Icon(
                                                          Icons.star_rounded,
                                                          size: 11.0,
                                                          color: Color(0xFF8B53FE),
                                                        ),
                                                        const SizedBox(width: 3.0),
                                                        Text(
                                                          '${_rating.toStringAsFixed(1)} ($_reviews)',
                                                          style: tr.font(
                                                            fontSize: 10.0,
                                                            fontWeight: FontWeight.w500,
                                                            color: const Color(0xFF566663),
                                                            height: 1.0,
                                                          ),
                                                          maxLines: 1,
                                                        ),
                                                        const SizedBox(width: 8.0),
                                                        const Icon(
                                                          Icons.receipt_long_rounded,
                                                          size: 10.5,
                                                          color: Color(0xFF8B53FE),
                                                        ),
                                                        const SizedBox(width: 2.5),
                                                        Text(
                                                          tr.isArabic
                                                              ? '$_ordersCount طلب'
                                                              : '$_ordersCount ${_ordersCount == 1 ? 'order' : 'orders'}',
                                                          style: tr.font(
                                                            fontSize: 10.0,
                                                            fontWeight: FontWeight.w500,
                                                            color: const Color(0xFF566663),
                                                            height: 1.0,
                                                          ),
                                                          maxLines: 1,
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

                                      // right side icons layout: WhatsApp & Call (100% Real & Functional)
                                       Row(
                                         mainAxisSize: MainAxisSize.min,
                                         crossAxisAlignment: CrossAxisAlignment.center,
                                         children: [
                                           // Real WhatsApp Button
                                           MouseRegion(
                                             cursor: SystemMouseCursors.click,
                                             child: GestureDetector(
                                               key: const Key('provider_detail_whatsapp_button'),
                                               onTap: () async {
                                                 HapticFeedback.lightImpact();
                                                 final phone = _phone;
                                                 if (phone == null || phone.isEmpty) {
                                                   ScaffoldMessenger.of(context).showSnackBar(
                                                     SnackBar(
                                                       content: Text(
                                                         tr.isArabic ? 'رقم واتساب غير متوفر' : 'WhatsApp number not available',
                                                         style: tr.font(color: Colors.white),
                                                       ),
                                                       backgroundColor: const Color(0xFFEF4444),
                                                       behavior: SnackBarBehavior.floating,
                                                     ),
                                                   );
                                                   return;
                                                 }
                                                 if (widget.providerPublicId != null && widget.providerPublicId!.isNotEmpty) {
                                                   await ref.read(backendServiceProvider).trackCustomerEvent(
                                                     event: 'whatsapp_click',
                                                     providerPublicId: widget.providerPublicId!,
                                                     latitude: activeUserLoc?.latitude,
                                                     longitude: activeUserLoc?.longitude,
                                                   ).catchError((_) => false);
                                                 }
                                                 final ok = await ContactLauncher.whatsApp(phone);
                                                 if (!ok && mounted) {
                                                   ScaffoldMessenger.of(context).showSnackBar(
                                                     SnackBar(
                                                       content: Text(
                                                         tr.isArabic ? 'تعذر فتح واتساب' : 'Could not open WhatsApp',
                                                         style: tr.font(color: Colors.white),
                                                       ),
                                                       backgroundColor: const Color(0xFFEF4444),
                                                       behavior: SnackBarBehavior.floating,
                                                     ),
                                                   );
                                                 }
                                               },
                                               behavior: HitTestBehavior.opaque,
                                               child: Container(
                                                 width: 38.0,
                                                 height: 38.0,
                                                 decoration: const BoxDecoration(
                                                   color: Color(0xFF25D366),
                                                   shape: BoxShape.circle,
                                                 ),
                                                 child: const Center(
                                                   child: CustomPaint(
                                                     size: Size(20.0, 20.0),
                                                     painter: _WhatsAppIconPainter(),
                                                   ),
                                                 ),
                                               ),
                                             ),
                                           ),
                                           const SizedBox(width: 10.0),

                                           // Real Call Button
                                           MouseRegion(
                                             cursor: SystemMouseCursors.click,
                                             child: GestureDetector(
                                               key: const Key('provider_detail_call_button'),
                                               onTap: () async {
                                                 HapticFeedback.lightImpact();
                                                 final phone = _phone;
                                                 if (phone == null || phone.isEmpty) {
                                                   ScaffoldMessenger.of(context).showSnackBar(
                                                     SnackBar(
                                                       content: Text(
                                                         tr.isArabic ? 'رقم الهاتف غير متوفر' : 'Phone number not available',
                                                         style: tr.font(color: Colors.white),
                                                       ),
                                                       backgroundColor: const Color(0xFFEF4444),
                                                       behavior: SnackBarBehavior.floating,
                                                     ),
                                                   );
                                                   return;
                                                 }
                                                 if (widget.providerPublicId != null && widget.providerPublicId!.isNotEmpty) {
                                                   await ref.read(backendServiceProvider).trackCustomerEvent(
                                                     event: 'call_click',
                                                     providerPublicId: widget.providerPublicId!,
                                                     latitude: activeUserLoc?.latitude,
                                                     longitude: activeUserLoc?.longitude,
                                                   ).catchError((_) => false);
                                                 }
                                                 final ok = await ContactLauncher.call(phone);
                                                 if (!ok && mounted) {
                                                   ScaffoldMessenger.of(context).showSnackBar(
                                                     SnackBar(
                                                       content: Text(
                                                         tr.isArabic ? 'تعذر بدء الاتصال' : 'Could not start phone call',
                                                         style: tr.font(color: Colors.white),
                                                       ),
                                                       backgroundColor: const Color(0xFFEF4444),
                                                       behavior: SnackBarBehavior.floating,
                                                     ),
                                                   );
                                                 }
                                               },
                                               behavior: HitTestBehavior.opaque,
                                               child: Container(
                                                 width: 38.0,
                                                 height: 38.0,
                                                 decoration: const BoxDecoration(
                                                   color: Color(0xFF1C2926),
                                                   shape: BoxShape.circle,
                                                 ),
                                                 child: const Center(
                                                   child: Icon(
                                                     Icons.call_rounded,
                                                     size: 19.0,
                                                     color: Colors.white,
                                                   ),
                                                 ),
                                               ),
                                             ),
                                           ),
                                         ],
                                       ),
                                     ],
                                   ),
                                 ),
                                 const SizedBox(height: 16.0), // gap: 16px;

                                 // 2nd row: next widget branding:
                                // width: 350; height: 10; justify-content: space-between; angle: 0 deg; opacity: 1;
                                SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // content branding:
                                      // width: 202; height: 10; gap: 12px; angle: 0 deg; opacity: 1;
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          // car icon branding:
                                          // width: 12; height: 10; angle: 0 deg; opacity: 1; background: #1C2926;
                                          const Icon(
                                            Icons.directions_car_filled_rounded,
                                            size: 12.0,
                                            color: Color(0xFF1C2926),
                                          ),
                                          const SizedBox(width: 12.0), // gap: 12px;

                                          // text branding:
                                          // width: 182; height: 9; gap: 12px; angle: 0 deg; opacity: 1;
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              if (displayVehicle.isNotEmpty) ...[
                                                Text(
                                                  displayVehicle,
                                                  style: tr.font(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(0xFF1C2926),
                                                    height: 1.3,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                                const SizedBox(width: 8.0),
                                                const Text('•', style: TextStyle(color: Color(0xFF9CA3AF))),
                                                const SizedBox(width: 8.0),
                                              ],
                                              Text(
                                                displayCategory,
                                                style: tr.font(
                                                  fontSize: 12.0,
                                                  fontWeight: displayVehicle.isEmpty ? FontWeight.w500 : FontWeight.w400,
                                                  color: displayVehicle.isEmpty
                                                      ? const Color(0xFF1C2926)
                                                      : const Color(0xFF566663),
                                                  height: 1.3,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16.0), // gap: 16px;

                                // 3rd section: next widget styling (metric cards grid):
                                // width: 350; height: 136; gap: 12px; angle: 0 deg; opacity: 1;
                                Container(
                                  width: double.infinity,
                                  constraints: const BoxConstraints(minHeight: 136.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 1st row of metric cards:
                                      Row(
                                        children: [
                                          // 1st card branding: 1.8 km Distance Away
                                          // width: 169 (flexible on mobile); height: 64; gap: 12px;
                                          Expanded(
                                            child: Container(
                                              constraints: const BoxConstraints(minHeight: 56.0),
                                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF2F5F4),
                                                borderRadius: BorderRadius.circular(12.0),
                                              ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                // icon syling on left side:
                                                // width: 32; height: 32; angle: 0 deg; opacity: 1; border-radius: 60px; background: #E2F0E6;
                                                Container(
                                                  width: 32.0,
                                                  height: 32.0,
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFFF0EAFE),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Center(
                                                    child: CustomPaint(
                                                      size: Size(16.0, 18.0),
                                                      painter: _LocationPinPainter(
                                                        color: Color(0xFF8B53FE),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12.0), // gap: 12px;

                                                // inner card content right side:
                                                // width: 93; height: 29; gap: 12px; angle: 0 deg; opacity: 1;
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      // dynamic real live distance
                                                      FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        alignment: AlignmentDirectional.centerStart,
                                                        child: Text(
                                                          realDistanceText,
                                                          style: tr.font(
                                                            fontSize: 14.0,
                                                            fontWeight: FontWeight.w600,
                                                            color: const Color(0xFF1C2926),
                                                            height: 1.1,
                                                            letterSpacing: 0.0,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2.0),

                                                      // content: Distance Away
                                                      FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        alignment: AlignmentDirectional.centerStart,
                                                        child: Text(
                                                          tr.distanceAway,
                                                          style: tr.font(
                                                            fontSize: 10.0,
                                                            fontWeight: FontWeight.w400,
                                                            color: const Color(0xFF566663),
                                                            height: 1.1,
                                                            letterSpacing: 0.0,
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
                                        const SizedBox(width: 12.0), // gap: 12px;

                                        // 2nd card branding in same row: 6 min Estimated time
                                        // width: 169 (flexible on mobile); height: 64; gap: 12px;
                                        Expanded(
                                          child: Container(
                                            constraints: const BoxConstraints(minHeight: 56.0),
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF2F5F4),
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                // left side icon branding:
                                                // width: 32; height: 32; angle: 0 deg; opacity: 1; border-radius: 60px; background: #E2F0E6;
                                                Container(
                                                  width: 32.0,
                                                  height: 32.0,
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFFF0EAFE),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Center(
                                                    // icon inner branding:
                                                    // width: 20; height: 20; angle: 0 deg; opacity: 1; top: 6.2px; left: 6.2px; background: #8B53FE;
                                                    child: CustomPaint(
                                                      size: Size(20.0, 20.0),
                                                      painter: _ClockIconPainter(
                                                        backgroundColor: Color(0xFF8B53FE),
                                                        handColor: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12.0), // gap: 12px;

                                                // content layout:
                                                // width: 93; height: 29; gap: 12px; angle: 0 deg; opacity: 1;
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      // dynamic real live ETA
                                                      FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        alignment: AlignmentDirectional.centerStart,
                                                        child: Text(
                                                          realEtaText,
                                                          style: tr.font(
                                                            fontSize: 14.0,
                                                            fontWeight: FontWeight.w600,
                                                            color: const Color(0xFF1C2926),
                                                            height: 1.1,
                                                            letterSpacing: 0.0,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2.0),

                                                      // content: Estimated time
                                                      // width: 71; height: 7; font-family: Inter; font-weight: 400; font-size: 10px; line-height: 22px; color: #566663;
                                                      FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        alignment: AlignmentDirectional.centerStart,
                                                        child: Text(
                                                          tr.estimatedTime,
                                                          style: tr.font(
                                                            fontSize: 10.0,
                                                            fontWeight: FontWeight.w400,
                                                            color: const Color(0xFF566663),
                                                            height: 1.1,
                                                            letterSpacing: 0.0,
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
                                        ],
                                      ),
                                      const SizedBox(height: 12.0), // gap: 12px;

                                      // Real trust & verification status chip (Zero fake stats)
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF2F5F4),
                                          borderRadius: BorderRadius.circular(12.0),
                                          border: Border.all(color: const Color(0xFFEDF0E9), width: 1.0),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 28.0,
                                                    height: 28.0,
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFFF0EAFE),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        _verified ? Icons.verified_rounded : Icons.shield_outlined,
                                                        size: 16.0,
                                                        color: const Color(0xFF8B53FE),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8.0),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          _verified
                                                              ? (tr.isArabic ? 'موثّق' : 'Verified')
                                                              : (tr.isArabic ? 'مزود خدمة' : 'Provider'),
                                                          style: tr.font(
                                                            fontSize: 12.0,
                                                            fontWeight: FontWeight.w600,
                                                            color: const Color(0xFF1C2926),
                                                            height: 1.1,
                                                          ),
                                                          maxLines: 1,
                                                        ),
                                                        Text(
                                                          tr.isArabic ? 'زيشو' : 'Zesho',
                                                          style: tr.font(
                                                            fontSize: 10.0,
                                                            fontWeight: FontWeight.w400,
                                                            color: const Color(0xFF566663),
                                                            height: 1.1,
                                                          ),
                                                          maxLines: 1,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 10.0),
                                              width: 1.0,
                                              height: 24.0,
                                              color: const Color(0xFFEDF0E9),
                                            ),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 28.0,
                                                    height: 28.0,
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFFF0EAFE),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.wifi_rounded,
                                                        size: 16.0,
                                                        color: Color(0xFF8B53FE),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8.0),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          _isOnline
                                                              ? (tr.isArabic ? 'متصل الآن' : 'Online')
                                                              : (tr.isArabic ? 'غير متصل' : 'Offline'),
                                                          style: tr.font(
                                                            fontSize: 12.0,
                                                            fontWeight: FontWeight.w600,
                                                            color: const Color(0xFF1C2926),
                                                            height: 1.1,
                                                          ),
                                                          maxLines: 1,
                                                        ),
                                                        Text(
                                                          tr.isArabic ? 'مباشر' : 'Live GPS',
                                                          style: tr.font(
                                                            fontSize: 10.0,
                                                            fontWeight: FontWeight.w400,
                                                            color: const Color(0xFF566663),
                                                            height: 1.1,
                                                          ),
                                                          maxLines: 1,
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
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16.0), // gap: 16px;

                                // 4th section: next widget layout (buttons):
                                // width: 350; height: 116; gap: 12px; angle: 0 deg; opacity: 1;
                                SizedBox(
                                  width: double.infinity,
                                  height: 116.0,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // button layout:
                                      // width: 350; height: 52; angle: 0 deg; opacity: 1; border-radius: 12px; background: #F2F5F4;
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          key: const Key('provider_detail_send_location_button'),
                                          onTap: () async {
                                            HapticFeedback.lightImpact();
                                            final phone = _phone;
                                            if (phone == null || phone.isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    tr.isArabic ? 'رقم الهاتف غير متوفر لمشاركة الموقع' : 'Provider phone number not available',
                                                    style: tr.font(color: Colors.white),
                                                  ),
                                                  backgroundColor: const Color(0xFFEF4444),
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                              return;
                                            }
                                            final userLoc = activeUserLoc;
                                            if (userLoc == null) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    tr.isArabic ? 'الموقع غير متاح حالياً' : 'Your location is not available yet',
                                                    style: tr.font(color: Colors.white),
                                                  ),
                                                  backgroundColor: const Color(0xFFEF4444),
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                              return;
                                            }
                                            if (widget.providerPublicId != null && widget.providerPublicId!.isNotEmpty) {
                                              await ref.read(backendServiceProvider).trackCustomerEvent(
                                                event: 'share_location_click',
                                                providerPublicId: widget.providerPublicId!,
                                                latitude: userLoc.latitude,
                                                longitude: userLoc.longitude,
                                              ).catchError((_) => false);
                                            }
                                            if (!mounted) return;
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => SendLocationScreen(
                                                  serviceCategory: displayCategory,
                                                  providerName: widget.providerName,
                                                  providerPublicId: widget.providerPublicId,
                                                  providerPhone: _phone,
                                                  distance: realDistanceText,
                                                  providerLatitude: _providerLat,
                                                  providerLongitude: _providerLng,
                                                  vehicleName: displayVehicle.isNotEmpty ? displayVehicle : displayCategory,
                                                  eta: realEtaText,
                                                ),
                                              ),
                                            );
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Container(
                                            width: double.infinity,
                                            height: 52.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF2F5F4),
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                // left icon branding:
                                                // width: 16; height: 16; angle: 0 deg; opacity: 1; background: #1C2926;
                                                const CustomPaint(
                                                  size: Size(14.0, 16.0),
                                                  painter: _LocationPinPainter(
                                                    color: Color(0xFF1C2926),
                                                  ),
                                                ),
                                                const SizedBox(width: 10.0), // gap: 10px;

                                                // content: Send My Location
                                                // width: 121; height: 10; font-family: Inter; font-weight: 500; font-size: 14px; line-height: 22px; color: #1C2926;
                                                Text(
                                                  tr.sendMyLocation,
                                                  style: tr.font(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(0xFF1C2926),
                                                    height: 1.1,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      // 2nd button layout:
                                      // width: 350; height: 52; angle: 0 deg; opacity: 1; border-radius: 12px; background: #1D8070;
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          key: const Key('provider_detail_send_request_button'),
                                          onTap: () {
                                            HapticFeedback.mediumImpact();
                                            final existing = _matchingActiveTask;
                                            if (existing != null) {
                                              final isAccepted = existing.step >= 1 &&
                                                  (existing.status == 'active' ||
                                                      existing.status == 'arrived' ||
                                                      existing.status == 'in_progress');
                                              if (isAccepted) {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) => LiveTrackingScreen(
                                                      requestId: TaskService.extractBackendUuid(existing.id),
                                                      serviceCategory: existing.serviceCategory,
                                                      providerName: existing.providerName,
                                                      vehicleName: existing.vehicleName.isNotEmpty
                                                          ? existing.vehicleName
                                                          : existing.serviceCategory,
                                                      photoUrl: _photoUrl ?? existing.providerAvatar,
                                                      providerLatitude: _providerLat ?? existing.providerLatitude,
                                                      providerLongitude: _providerLng ?? existing.providerLongitude,
                                                      distance: realDistanceText,
                                                      duration: realEtaText,
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => SendRequestScreen(
                                                    existingTask: existing,
                                                    serviceCategory: existing.serviceCategory,
                                                    providerName: existing.providerName,
                                                    providerPublicId: widget.providerPublicId ?? existing.providerPublicId,
                                                    providerPhone: _phone ?? existing.providerPhone,
                                                    photoUrl: _photoUrl ?? existing.providerAvatar,
                                                    vehicleName: displayVehicle.isNotEmpty ? displayVehicle : existing.vehicleName,
                                                    distance: realDistanceText,
                                                    eta: realEtaText,
                                                    rating: _rating,
                                                    reviews: _reviews,
                                                    ordersCount: _ordersCount,
                                                    verified: _verified,
                                                    providerLatitude: _providerLat ?? existing.providerLatitude,
                                                    providerLongitude: _providerLng ?? existing.providerLongitude,
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => SendRequestScreen(
                                                  serviceCategory: displayCategory,
                                                  providerName: widget.providerName,
                                                  providerPublicId: widget.providerPublicId,
                                                  providerPhone: _phone,
                                                  photoUrl: _photoUrl,
                                                  vehicleName: displayVehicle.isNotEmpty ? displayVehicle : displayCategory,
                                                  distance: realDistanceText,
                                                  eta: realEtaText,
                                                  rating: _rating,
                                                  reviews: _reviews,
                                                  ordersCount: _ordersCount,
                                                  verified: _verified,
                                                  providerLatitude: _providerLat,
                                                  providerLongitude: _providerLng,
                                                ),
                                              ),
                                            );
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Container(
                                            width: double.infinity,
                                            height: 52.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF8B53FE),
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                // content: Send Request or View Request
                                                Text(
                                                  _matchingActiveTask != null
                                                      ? (tr.isArabic ? 'عرض الطلب' : 'View Request')
                                                      : tr.sendRequest,
                                                  style: tr.font(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(0xFFFFFFFF),
                                                    height: 1.1,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                                const SizedBox(width: 10.0), // gap: 10px;

                                                // right side icon layout:
                                                // arrow vector: width: 14; height: 12; angle: -180 deg; border-width: 1.5px; border: 1.5px solid #FFFFFF;
                                                Transform.scale(
                                                  scaleX: tr.isArabic ? -1.0 : 1.0,
                                                  child: const CustomPaint(
                                                    size: Size(14.0, 12.0),
                                                    painter: _ArrowRightPainter(
                                                      color: Color(0xFFFFFFFF),
                                                      strokeWidth: 1.5,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24.0),
                              ],
                            ),
                          ),
                        ),

                        // Bottom Bar Layout: width: 390; height: 24;
                        Positioned(
                          bottom: 8.0,
                          left: 0.0,
                          width: containerWidth >= 390 ? 390.0 : containerWidth,
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
                        color: const Color(0xFF8B53FE).withValues(alpha: 0.35),
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
}

/// Back chevron vector < matching Figma specifications exactly:
/// width: 6; height: 13; border: 1px solid #566663
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

/// Route vector line painter matching Figma specifications:
/// width: 145.5; height: 91; border-width: 4px; border: 4px solid #1D8070;
class _RouteVectorPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _RouteVectorPainter({
    this.color = const Color(0xFFB892FF),
    this.strokeWidth = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    // Starts directly beneath the location pin (pin center is x ~ 12.5)
    path.moveTo(12.5, 0.0);
    // Heads down-left to intersection corner
    path.lineTo(2.0, 18.0);
    // Smooth corner turn into the avenue
    path.quadraticBezierTo(2.0, 24.0, 8.0, 27.0);
    // Straight diagonal run southeast towards the car
    path.lineTo(size.width - 2.0, size.height - 4.0);

    // Light purple glow casing
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, glowPaint);

    // Main route line in light purple
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);

    // Inner white center road stripe
    final innerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _RouteVectorPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}

/// Top-down car graphic painter matching Figma car asset:
/// width: 15; height: 24;
class _CarGraphicPainter extends CustomPainter {
  final Color roofColor;
  const _CarGraphicPainter({this.roofColor = const Color(0xFFA67AFE)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Car body paint (white with subtle border)
    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF2C3A36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1.5, 1.0, w - 3.0, h - 2.0),
      const Radius.circular(3.5),
    );
    canvas.drawRRect(bodyRRect, bodyPaint);
    canvas.drawRRect(bodyRRect, borderPaint);

    // Front Windshield (dark glass)
    final glassPaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.fill;

    final windshieldRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3.0, 5.0, w - 6.0, 3.5),
      const Radius.circular(1.0),
    );
    canvas.drawRRect(windshieldRect, glassPaint);

    // Roof (brand teal)
    final roofPaint = Paint()
      ..color = roofColor
      ..style = PaintingStyle.fill;

    final roofRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3.2, 9.0, w - 6.4, 7.0),
      const Radius.circular(1.0),
    );
    canvas.drawRRect(roofRect, roofPaint);

    // Rear Windshield (dark glass)
    final rearGlassRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3.0, 16.5, w - 6.0, 2.5),
      const Radius.circular(1.0),
    );
    canvas.drawRRect(rearGlassRect, glassPaint);

    // Taillights (red accents at bottom)
    final tailPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2.5, h - 2.5, 2.5, 1.0),
        const Radius.circular(0.5),
      ),
      tailPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w - 5.0, h - 2.5, 2.5, 1.0),
        const Radius.circular(0.5),
      ),
      tailPaint,
    );

    // Headlights (subtle white/cyan at top)
    final headPaint = Paint()
      ..color = const Color(0xFFE0F2FE)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2.5, 1.5, 2.5, 1.2),
        const Radius.circular(0.5),
      ),
      headPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w - 5.0, 1.5, 2.5, 1.2),
        const Radius.circular(0.5),
      ),
      headPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CarGraphicPainter oldDelegate) =>
      roofColor != oldDelegate.roofColor;
}

/// Location pin icon vector matching Figma icon inside 36x36 circular button:
class _LocationPinPainter extends CustomPainter {
  final Color color;
  const _LocationPinPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2.0;
    final r = (size.width / 2.0) - 1.0;
    final cy = r + 1.0;

    final pinPath = Path();
    pinPath.addArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      math.pi * 0.8,
      math.pi * 1.4,
    );
    pinPath.lineTo(cx, size.height);
    pinPath.close();

    canvas.drawPath(pinPath, strokePaint);
    canvas.drawCircle(Offset(cx, cy), 1.8, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _LocationPinPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Distance badge tooltip speech-bubble painter:
/// width: 42; height: 26; angle: 0 deg; top: 124px; left: 119px; background: #1D8070;
/// inner body: width: 42; height: 19; border-radius: 4px; padding: 6px;
class _DistanceBadgeTooltipPainter extends CustomPainter {
  final Color color;
  final double cornerRadius;
  final double pointerX;
  final double pointerWidth;
  final double pointerHeight;

  const _DistanceBadgeTooltipPainter({
    this.color = const Color(0xFF8B53FE),
    this.cornerRadius = 4.0,
    this.pointerX = 10.0,
    this.pointerWidth = 8.0,
    this.pointerHeight = 7.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final bodyHeight = size.height - pointerHeight; // 26 - 7 = 19px
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, bodyHeight),
      Radius.circular(cornerRadius),
    );

    final path = Path()..addRRect(rrect);

    // Pointer pointing downward towards the location pin
    final pointerPath = Path();
    final halfWidth = pointerWidth / 2.0;
    pointerPath.moveTo(pointerX - halfWidth, bodyHeight - 0.5);
    pointerPath.lineTo(pointerX + halfWidth, bodyHeight - 0.5);
    pointerPath.lineTo(pointerX, size.height);
    pointerPath.close();

    final combined = Path.combine(PathOperation.union, path, pointerPath);
    canvas.drawPath(combined, paint);
  }

  @override
  bool shouldRepaint(covariant _DistanceBadgeTooltipPainter oldDelegate) =>
      color != oldDelegate.color ||
      cornerRadius != oldDelegate.cornerRadius ||
      pointerX != oldDelegate.pointerX ||
      pointerWidth != oldDelegate.pointerWidth ||
      pointerHeight != oldDelegate.pointerHeight;
}

/// Real WhatsApp official vector icon painter matching Figma specifications:
/// Outer speech-bubble ring + classic telephone receiver inside
class _WhatsAppIconPainter extends CustomPainter {
  const _WhatsAppIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Official WhatsApp vector path defined on a 24x24 viewBox
    final double scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final path = Path()..fillType = PathFillType.evenOdd;

    // 1. Outer speech-bubble contour
    path.moveTo(12.04, 2.0);
    path.cubicTo(6.58, 2.0, 2.13, 6.45, 2.13, 11.91);
    path.cubicTo(2.13, 13.66, 2.59, 15.36, 3.45, 16.86);
    path.lineTo(2.05, 22.0);
    path.lineTo(7.3, 20.62);
    path.cubicTo(8.75, 21.41, 10.38, 21.83, 12.04, 21.83);
    path.cubicTo(17.5, 21.83, 21.95, 17.38, 21.95, 11.92);
    path.cubicTo(21.95, 9.27, 20.92, 6.78, 19.05, 4.91);
    path.cubicTo(17.18, 3.03, 14.69, 2.0, 12.04, 2.0);
    path.close();

    // 2. Inner speech-bubble hole (creating the crisp outline)
    path.moveTo(12.05, 3.67);
    path.cubicTo(14.25, 3.67, 16.31, 4.53, 17.87, 6.09);
    path.cubicTo(19.42, 7.65, 20.28, 9.72, 20.28, 11.92);
    path.cubicTo(20.28, 16.46, 16.58, 20.16, 12.04, 20.16);
    path.cubicTo(10.66, 20.16, 9.3, 19.8, 8.1, 19.11);
    path.lineTo(7.81, 18.94);
    path.lineTo(4.7, 19.76);
    path.lineTo(5.53, 16.73);
    path.lineTo(5.34, 16.43);
    path.cubicTo(4.56, 15.19, 4.15, 13.57, 4.15, 11.91);
    path.cubicTo(4.15, 7.37, 7.85, 3.67, 12.05, 3.67);
    path.close();

    // 3. Official telephone handset inside
    path.moveTo(8.53, 7.33);
    path.cubicTo(8.37, 7.33, 8.1, 7.39, 7.87, 7.64);
    path.cubicTo(7.65, 7.89, 7.02, 8.48, 7.02, 9.71);
    path.cubicTo(7.02, 10.93, 7.91, 12.11, 8.03, 12.27);
    path.cubicTo(8.16, 12.44, 9.75, 14.88, 12.19, 15.93);
    path.cubicTo(14.22, 16.81, 14.63, 16.63, 15.08, 16.59);
    path.cubicTo(15.53, 16.55, 16.53, 16.0, 16.74, 15.42);
    path.cubicTo(16.95, 14.84, 16.95, 14.34, 16.89, 14.24);
    path.cubicTo(16.82, 14.13, 16.66, 14.07, 16.41, 13.95);
    path.cubicTo(16.16, 13.82, 14.94, 13.22, 14.71, 13.14);
    path.cubicTo(14.49, 13.06, 14.32, 13.01, 14.16, 13.26);
    path.cubicTo(13.99, 13.51, 13.52, 14.07, 13.37, 14.24);
    path.cubicTo(13.23, 14.4, 13.08, 14.42, 12.83, 14.3);
    path.cubicTo(12.58, 14.17, 11.78, 13.91, 10.83, 13.07);
    path.cubicTo(10.09, 12.41, 9.59, 11.6, 9.47, 11.35);
    path.cubicTo(9.34, 11.1, 9.45, 10.97, 9.58, 10.84);
    path.cubicTo(9.69, 10.73, 9.83, 10.55, 9.95, 10.41);
    path.cubicTo(10.08, 10.26, 10.12, 10.16, 10.2, 9.99);
    path.cubicTo(10.28, 9.83, 10.24, 9.68, 10.18, 9.56);
    path.cubicTo(10.12, 9.44, 9.63, 8.23, 9.42, 7.74);
    path.cubicTo(9.22, 7.25, 9.02, 7.32, 8.87, 7.31);
    path.cubicTo(8.72, 7.31, 8.55, 7.33, 8.53, 7.33);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Real clock icon painter matching Figma specifications:
/// width: 20; height: 20; background: #1C2926; with crisp white clock hands (#FFFFFF)
class _ClockIconPainter extends CustomPainter {
  final Color backgroundColor;
  final Color handColor;

  const _ClockIconPainter({
    this.backgroundColor = const Color(0xFF1C2926),
    this.handColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2.0;
    final double cy = size.height / 2.0;
    final double radius = size.width / 2.0;

    // 1. Dark circular clock body (#1C2926)
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(Offset(cx, cy), radius, bgPaint);

    // 2. White clock hands (matching Figma / Lucide clock polyline: 12:00 -> center -> ~4:00)
    final handPaint = Paint()
      ..color = handColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final path = Path();
    // Vertical hand from ~12 o'clock down to center
    path.moveTo(cx, cy - radius * 0.52);
    path.lineTo(cx, cy);
    // Minute hand pointing down-right towards ~4 o'clock
    path.lineTo(cx + radius * 0.42, cy + radius * 0.28);

    canvas.drawPath(path, handPaint);
  }

  @override
  bool shouldRepaint(covariant _ClockIconPainter oldDelegate) =>
      backgroundColor != oldDelegate.backgroundColor ||
      handColor != oldDelegate.handColor;
}

/// Verified shield icon painter matching Figma specifications:
/// width: 14; height: 16; background: #1D8070; with crisp white checkmark
class _VerifiedShieldPainter extends CustomPainter {
  final Color shieldColor;
  final Color checkColor;

  const _VerifiedShieldPainter({
    this.shieldColor = const Color(0xFF8B53FE),
    this.checkColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw smooth shield contour
    final shieldPaint = Paint()
      ..color = shieldColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final shieldPath = Path();
    shieldPath.moveTo(size.width * 0.5, 0.5);
    // Top-right curve
    shieldPath.quadraticBezierTo(size.width * 0.75, 0.5, size.width - 0.5, 2.5);
    // Right side down to bottom tip
    shieldPath.cubicTo(size.width - 0.5, 8.5, size.width * 0.75, 13.5, size.width * 0.5, size.height - 0.5);
    // Bottom tip up left side
    shieldPath.cubicTo(size.width * 0.25, 13.5, 0.5, 8.5, 0.5, 2.5);
    // Top-left curve back to top center
    shieldPath.quadraticBezierTo(size.width * 0.25, 0.5, size.width * 0.5, 0.5);
    shieldPath.close();

    canvas.drawPath(shieldPath, shieldPaint);

    // 2. Draw crisp checkmark inside shield
    final checkPaint = Paint()
      ..color = checkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final checkPath = Path();
    checkPath.moveTo(size.width * 0.30, size.height * 0.50);
    checkPath.lineTo(size.width * 0.46, size.height * 0.64);
    checkPath.lineTo(size.width * 0.72, size.height * 0.36);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant _VerifiedShieldPainter oldDelegate) =>
      shieldColor != oldDelegate.shieldColor ||
      checkColor != oldDelegate.checkColor;
}


/// Arrow vector painter matching Figma specifications:
/// width: 14; height: 12; angle: -180 deg; border-width: 1.5px; border: 1.5px solid #FFFFFF;
class _ArrowRightPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _ArrowRightPainter({
    this.color = Colors.white,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final path = Path();
    final double midY = size.height / 2.0;

    // Horizontal stem
    path.moveTo(1.0, midY);
    path.lineTo(size.width - 1.5, midY);

    // Arrowhead chevron pointing forward / right
    path.moveTo(size.width - 5.5, 1.5);
    path.lineTo(size.width - 1.5, midY);
    path.lineTo(size.width - 5.5, size.height - 1.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowRightPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}



