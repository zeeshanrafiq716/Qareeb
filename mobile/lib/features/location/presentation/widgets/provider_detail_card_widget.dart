import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../core/utils/contact_launcher.dart';
import '../../../../providers/backend_provider.dart';
import '../../../../services/location_service.dart';
import '../../../../services/task_service.dart';
import '../live_tracking_screen.dart';
import '../send_location_screen.dart';
import '../send_request_screen.dart';

/// Map bottom sheet when a customer taps a provider car.
/// Real name/photo/contact only — no placeholder portraits, reviews, or order counters.
class ProviderDetailCardWidget extends ConsumerStatefulWidget {
  final String providerName;
  final String serviceCategory;
  final String vehicleName;
  final String distance;
  final String estimatedTime;
  final double rating;
  final int tripsCount;
  final String? avatarUrl;
  final String? phoneNumber;
  final String? providerPublicId;
  final bool verified;
  final bool isAvailable;
  final double? providerLatitude;
  final double? providerLongitude;
  final bool showCloseIcon;
  final VoidCallback? onClose;
  final VoidCallback? onSendMyLocation;
  final VoidCallback? onSendRequest;

  const ProviderDetailCardWidget({
    super.key,
    this.providerName = '',
    this.serviceCategory = '',
    this.vehicleName = '',
    this.distance = '',
    this.estimatedTime = '',
    this.rating = 0,
    this.tripsCount = 0,
    this.avatarUrl,
    this.phoneNumber,
    this.providerPublicId,
    this.verified = false,
    this.isAvailable = true,
    this.providerLatitude,
    this.providerLongitude,
    this.showCloseIcon = true,
    this.onClose,
    this.onSendMyLocation,
    this.onSendRequest,
  });

  static Future<T?> showAsBottomSheet<T>({
    required BuildContext context,
    String providerName = '',
    String serviceCategory = '',
    String vehicleName = '',
    String distance = '',
    String estimatedTime = '',
    double rating = 0,
    int tripsCount = 0,
    String? avatarUrl,
    String? phoneNumber,
    String? providerPublicId,
    bool verified = false,
    bool isAvailable = true,
    double? providerLatitude,
    double? providerLongitude,
    VoidCallback? onSendMyLocation,
    VoidCallback? onSendRequest,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (ctx) => ProviderDetailCardWidget(
        providerName: providerName,
        serviceCategory: serviceCategory,
        vehicleName: vehicleName,
        distance: distance,
        estimatedTime: estimatedTime,
        rating: rating,
        tripsCount: tripsCount,
        avatarUrl: avatarUrl,
        phoneNumber: phoneNumber,
        providerPublicId: providerPublicId,
        verified: verified,
        isAvailable: isAvailable,
        providerLatitude: providerLatitude,
        providerLongitude: providerLongitude,
        showCloseIcon: true,
        onClose: () => Navigator.of(ctx).pop(),
        onSendMyLocation: onSendMyLocation,
        onSendRequest: onSendRequest,
      ),
    );
  }

  @override
  ConsumerState<ProviderDetailCardWidget> createState() =>
      _ProviderDetailCardWidgetState();
}

String _formatDistanceMeters(double distanceM, bool isArabic) {
  final safeM = distanceM.clamp(0.0, 999000.0);
  if (safeM < 1000.0) {
    final m = safeM.round();
    return isArabic ? '$m م' : '$m m';
  }
  final km = (safeM / 1000.0).toStringAsFixed(1);
  return isArabic ? '$km كم' : '$km km';
}

String _formatEtaMinutes(int minutes, bool isArabic, {double? distanceM}) {
  if (distanceM != null && distanceM < 80.0) {
    return isArabic ? 'أقل من د' : '< 1 min';
  }
  final mins = minutes.clamp(1, 999);
  return isArabic ? '$mins د' : '$mins min';
}

int _estimateMinutesFromMeters(double distanceM) {
  if (distanceM < 80.0) return 1;
  // Realistic urban driving speed ~30 km/h (500 m/min)
  return (distanceM / 500.0).ceil().clamp(1, 999);
}

class _ProviderDetailCardWidgetState extends ConsumerState<ProviderDetailCardWidget> {
  static const Color _brand = Color(0xFF8B53FE);
  static const Color _brandSoft = Color(0xFFF8F5FE);
  static const Color _brandBorder = Color(0xFFE4D8FC);
  static const Color _ink = Color(0xFF1C2926);
  static const Color _muted = Color(0xFF566663);

  String? _phone;
  String? _photoUrl;
  bool _verified = false;
  bool _busy = false;
  bool _isOnline = true;
  late String _liveDistance;
  late String _liveEta;
  double? _providerLat;
  double? _providerLng;
  Timer? _liveMetricsTimer;

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
    _photoUrl = _cleanPhoto(widget.avatarUrl);
    _verified = widget.verified;
    _isOnline = widget.isAvailable;
    _liveDistance = '';
    _liveEta = '';
    _providerLat = widget.providerLatitude;
    _providerLng = widget.providerLongitude;
    TaskService.instance.activeTaskNotifier.addListener(_onActiveTaskChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hydrateFromProfile();
      _refreshLiveMetrics();
    });
    _liveMetricsTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) _refreshLiveMetrics();
    });
  }

  @override
  void dispose() {
    TaskService.instance.activeTaskNotifier.removeListener(_onActiveTaskChanged);
    _liveMetricsTimer?.cancel();
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

  void _applyProfileMap(Map<String, dynamic> profile, {required bool isArabic}) {
    final contact = profile['contact'];
    String? phone = _phone;
    if (contact is Map && contact['phone'] != null) {
      phone = contact['phone'].toString();
    }
    phone ??= profile['phone']?.toString();

    final lat = (profile['latitude'] as num?)?.toDouble();
    final lng = (profile['longitude'] as num?)?.toDouble();
    if (lat != null && lng != null && lat != 0 && lng != 0) {
      _providerLat = lat;
      _providerLng = lng;
    }

    String? nextDistance;
    String? nextEta;
    final distanceM = (profile['distanceMeters'] as num?)?.toDouble();
    if (distanceM != null && distanceM >= 0) {
      nextDistance = _formatDistanceMeters(distanceM, isArabic);
      nextEta = _formatEtaMinutes(
        _estimateMinutesFromMeters(distanceM),
        isArabic,
        distanceM: distanceM,
      );
    }

    final availability = profile['availability'];
    final badges = profile['badges'];
    final online = profile['isOnline'] == true ||
        (availability is Map && availability['isOnline'] == true) ||
        (badges is Map && badges['available'] == true);

    setState(() {
      _phone = _cleanOptional(phone);
      _photoUrl = _cleanPhoto(profile['photoUrl']?.toString()) ?? _photoUrl;
      _verified = profile['verified'] == true ||
          (badges is Map && badges['verified'] == true) ||
          _verified;
      _isOnline = online;
      if (nextDistance != null) _liveDistance = nextDistance;
      if (nextEta != null) _liveEta = nextEta;
    });
  }

  Future<void> _fetchRealDriveEta({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final tr = ref.read(translationsProvider);
    final straightM = ref.read(locationServiceProvider).calculateDistanceKm(
          originLat,
          originLng,
          destLat,
          destLng,
        ) * 1000.0;
    final route = await ref.read(googleMapsServiceProvider).computeRoute(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
        );
    if (!mounted || route.isFallback) return;
    // Ignore anomalous road-snap detours that inflate short distances > 3.5x
    if (straightM > 0 && route.distanceMeters > straightM * 3.5) return;
    setState(() {
      if (route.distanceMeters >= 0) {
        _liveDistance = _formatDistanceMeters(route.distanceMeters.toDouble(), tr.isArabic);
      }
      _liveEta = _formatEtaMinutes(
        route.durationMinutes,
        tr.isArabic,
        distanceM: route.distanceMeters.toDouble(),
      );
    });
  }

  Future<void> _hydrateFromProfile() async {
    await _refreshLiveMetrics(contactOnly: true);
  }

  Future<void> _refreshLiveMetrics({bool contactOnly = false}) async {
    final tr = ref.read(translationsProvider);
    final rawLoc = ref.read(userLocationProvider).value;
    final loc = (rawLoc != null && rawLoc.hasValidDeviceGps)
        ? rawLoc
        : LocationService.lastKnownValidLocation;
    final publicId = widget.providerPublicId?.trim() ?? '';

    // Compute immediate real Haversine distance (in metres/km) & real ETA when both GPS coords exist
    if (loc != null &&
        loc.hasValidDeviceGps &&
        _providerLat != null &&
        _providerLng != null &&
        !(_providerLat == 0 && _providerLng == 0)) {
      final km = ref.read(locationServiceProvider).calculateDistanceKm(
            loc.latitude,
            loc.longitude,
            _providerLat!,
            _providerLng!,
          );
      final distanceM = km * 1000.0;
      final formattedDist = _formatDistanceMeters(distanceM, tr.isArabic);
      final estEta = _formatEtaMinutes(
        _estimateMinutesFromMeters(distanceM),
        tr.isArabic,
        distanceM: distanceM,
      );
      if (mounted && (_liveDistance != formattedDist || _liveEta != estEta)) {
        setState(() {
          _liveDistance = formattedDist;
          _liveEta = estEta;
        });
      }
    }

    if (publicId.isEmpty) return;

    final profile = await ref.read(backendServiceProvider).getPublicProviderProfile(
          publicId,
          latitude: (loc != null && loc.hasValidDeviceGps) ? loc.latitude : null,
          longitude: (loc != null && loc.hasValidDeviceGps) ? loc.longitude : null,
        );
    if (!mounted || profile == null) return;

    _applyProfileMap(profile, isArabic: tr.isArabic);

    // Re-sync live distance & ETA from fresh provider coordinates
    if (loc != null &&
        loc.hasValidDeviceGps &&
        _providerLat != null &&
        _providerLng != null &&
        !(_providerLat == 0 && _providerLng == 0)) {
      final km = ref.read(locationServiceProvider).calculateDistanceKm(
            loc.latitude,
            loc.longitude,
            _providerLat!,
            _providerLng!,
          );
      final distanceM = km * 1000.0;
      final formattedDist = _formatDistanceMeters(distanceM, tr.isArabic);
      final estEta = _formatEtaMinutes(
        _estimateMinutesFromMeters(distanceM),
        tr.isArabic,
        distanceM: distanceM,
      );
      if (mounted && (_liveDistance != formattedDist || _liveEta != estEta)) {
        setState(() {
          _liveDistance = formattedDist;
          _liveEta = estEta;
        });
      }
    }

    if (contactOnly || loc == null || !loc.hasValidDeviceGps) return;

    final destLat = _providerLat;
    final destLng = _providerLng;
    if (destLat == null || destLng == null) return;

    // For short distances (< 300 m), keep exact GPS distance so Google Routes road-snapping
    // does not inflate nearby distances (e.g. turning 5 m into a 1.2 km U-turn loop).
    final straightMeters = ref.read(locationServiceProvider).calculateDistanceKm(
          loc.latitude,
          loc.longitude,
          destLat,
          destLng,
        ) * 1000.0;
    if (straightMeters < 300.0) return;

    await _fetchRealDriveEta(
      originLat: loc.latitude,
      originLng: loc.longitude,
      destLat: destLat,
      destLng: destLng,
    );
  }

  Future<String?> _ensurePhone() async {
    final existing = _cleanOptional(_phone);
    if (existing != null) return existing;
    await _hydrateFromProfile();
    return _cleanOptional(_phone);
  }

  Future<void> _track(String event) async {
    final id = widget.providerPublicId;
    if (id == null || id.isEmpty) return;
    final rawLoc = ref.read(userLocationProvider).value;
    final loc = (rawLoc != null && rawLoc.hasValidDeviceGps)
        ? rawLoc
        : LocationService.lastKnownValidLocation;
    try {
      await ref.read(backendServiceProvider).trackCustomerEvent(
            event: event,
            providerPublicId: id,
            latitude: (loc != null && loc.hasValidDeviceGps) ? loc.latitude : null,
            longitude: (loc != null && loc.hasValidDeviceGps) ? loc.longitude : null,
          );
    } catch (_) {}
  }

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: error ? const Color(0xFFEF4444) : _brand,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onWhatsApp() async {
    final tr = ref.read(translationsProvider);
    setState(() => _busy = true);
    final phone = await _ensurePhone();
    if (!mounted) return;
    setState(() => _busy = false);
    if (phone == null) {
      _toast(tr.isArabic ? 'رقم واتساب غير متوفر' : 'WhatsApp number is not available', error: true);
      return;
    }
    // Ensure backend receives whatsapp_click and triggers provider notification BEFORE switching apps
    await _track('whatsapp_click').timeout(
      const Duration(milliseconds: 900),
      onTimeout: () {},
    );
    final ok = await ContactLauncher.whatsApp(phone);
    if (!ok) {
      _toast(tr.isArabic ? 'تعذر فتح واتساب' : 'Could not open WhatsApp', error: true);
    }
  }

  Future<void> _onCall() async {
    final tr = ref.read(translationsProvider);
    setState(() => _busy = true);
    final phone = await _ensurePhone();
    if (!mounted) return;
    setState(() => _busy = false);
    if (phone == null) {
      _toast(tr.isArabic ? 'رقم الهاتف غير متوفر' : 'Phone number is not available', error: true);
      return;
    }
    // Ensure backend receives call_click and triggers provider notification BEFORE opening dialer
    await _track('call_click').timeout(
      const Duration(milliseconds: 900),
      onTimeout: () {},
    );
    final ok = await ContactLauncher.call(phone);
    if (!ok) {
      _toast(tr.isArabic ? 'تعذر بدء الاتصال' : 'Could not start the call', error: true);
    }
  }

  Future<void> _onSendLocation() async {
    HapticFeedback.lightImpact();
    if (widget.onSendMyLocation != null) {
      widget.onSendMyLocation!();
      return;
    }
    _track('share_location_click');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SendLocationScreen(
          serviceCategory: widget.serviceCategory.isNotEmpty
              ? widget.serviceCategory
              : 'Service',
          providerName: widget.providerName.isNotEmpty
              ? widget.providerName
              : 'Provider',
          providerPublicId: widget.providerPublicId,
          providerPhone: _phone ?? widget.phoneNumber,
          distance: _liveDistance.isNotEmpty ? _liveDistance : '--',
          eta: _liveEta.isNotEmpty ? _liveEta : null,
          vehicleName: widget.vehicleName,
          providerLatitude: _providerLat,
          providerLongitude: _providerLng,
        ),
      ),
    );
  }

  Future<void> _onSendRequest() async {
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
              distance: _liveDistance.isNotEmpty ? _liveDistance : existing.distance,
              duration: _liveEta.isNotEmpty ? _liveEta : existing.eta,
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
            providerPhone: _phone ?? widget.phoneNumber ?? existing.providerPhone,
            photoUrl: _photoUrl ?? existing.providerAvatar,
            vehicleName: widget.vehicleName.isNotEmpty
                ? widget.vehicleName
                : existing.vehicleName,
            distance: _liveDistance.isNotEmpty ? _liveDistance : existing.distance,
            eta: _liveEta.isNotEmpty ? _liveEta : existing.eta,
            verified: _verified,
            providerLatitude: _providerLat ?? existing.providerLatitude,
            providerLongitude: _providerLng ?? existing.providerLongitude,
          ),
        ),
      );
      return;
    }

    if (widget.onSendRequest != null) {
      widget.onSendRequest!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SendRequestScreen(
          serviceCategory: widget.serviceCategory.isNotEmpty
              ? widget.serviceCategory
              : 'Service',
          providerName: widget.providerName.isNotEmpty
              ? widget.providerName
              : 'Provider',
          providerPublicId: widget.providerPublicId,
          providerPhone: _phone ?? widget.phoneNumber,
          photoUrl: _photoUrl,
          vehicleName: widget.vehicleName,
          distance: _liveDistance.isNotEmpty ? _liveDistance : '--',
          eta: _liveEta.isNotEmpty ? _liveEta : null,
          verified: _verified,
          providerLatitude: _providerLat,
          providerLongitude: _providerLng,
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'Q';
    String first(String s) => s.substring(0, 1).toUpperCase();
    if (parts.length == 1) return first(parts.first);
    return first(parts[0]) + first(parts[1]);
  }

  Widget _brandStatCard({
    required Widget icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: _brandSoft,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: _brandBorder, width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 36.0,
              height: 36.0,
              decoration: const BoxDecoration(color: _brand, shape: BoxShape.circle),
              child: Center(child: icon),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                      height: 1.15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w500,
                      color: _muted,
                      height: 1.15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _trustChip({
    required Widget icon,
    required String title,
    required String subtitle,
    double paddingLeft = 0,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: paddingLeft),
        child: Row(
        children: [
          Container(
            width: 28.0,
            height: 28.0,
            decoration: const BoxDecoration(color: _brand, shape: BoxShape.circle),
            child: Center(child: icon),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w500,
                    color: _muted,
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = math.min(screenWidth, 440.0);
    final displayName = widget.providerName.trim().isEmpty
        ? (tr.isArabic ? 'مزود خدمة' : 'Provider')
        : tr.formatProviderName(widget.providerName);
    final category = widget.serviceCategory.trim().isNotEmpty
        ? tr.categoryName(widget.serviceCategory)
        : (widget.vehicleName.trim().isNotEmpty ? widget.vehicleName : '');
    final showRating = widget.tripsCount > 0 && widget.rating > 0;
    final hasPhone = (_phone != null && _phone!.isNotEmpty) ||
        (widget.phoneNumber != null && widget.phoneNumber!.trim().isNotEmpty);
    final canContact =
        hasPhone || (widget.providerPublicId != null && widget.providerPublicId!.trim().isNotEmpty);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        key: const Key('selected_driver_card'),
        width: cardWidth,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.78),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.0),
            topRight: Radius.circular(28.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x1F000000),
              offset: Offset(0, -3),
              blurRadius: 14.0,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 12.0,
              left: (cardWidth - 40.0) / 2.0,
              width: 40.0,
              height: 4.0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 48.0, 20.0, math.max(16.0, bottomInset + 12.0)),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48.0,
                          height: 48.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _brand,
                            border: Border.all(color: _brandBorder, width: 2.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _photoUrl != null
                              ? Image.network(
                                  _photoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Text(
                                      _initials(displayName),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    _initials(displayName),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: tr.font(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                  color: _ink,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                softWrap: true,
                              ),
                              if (category.isNotEmpty || widget.isAvailable) ...[
                                const SizedBox(height: 4.0),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: [
                                    if (category.isNotEmpty)
                                      Text(
                                        category,
                                        style: tr.font(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500,
                                          color: _muted,
                                        ),
                                      ),
                                    if (widget.isAvailable)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                                        decoration: BoxDecoration(
                                          color: _brandSoft,
                                          borderRadius: BorderRadius.circular(60.0),
                                          border: Border.all(color: _brandBorder),
                                        ),
                                        child: Text(
                                          tr.isArabic ? 'متاح' : 'Available',
                                          style: tr.font(
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w600,
                                            color: _brand,
                                            height: 1.0,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                              if (showRating) ...[
                                const SizedBox(height: 4.0),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 13.0, color: _brand),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      tr.isArabic
                                          ? '${widget.rating.toStringAsFixed(1)} (${widget.tripsCount} تقييم)'
                                          : '${widget.rating.toStringAsFixed(1)} (${widget.tripsCount})',
                                      style: tr.font(
                                        fontSize: 11.0,
                                        fontWeight: FontWeight.w500,
                                        color: _muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _roundAction(
                              key: const Key('provider_detail_card_whatsapp_btn'),
                              color: const Color(0xFF25D366),
                              enabled: canContact && !_busy,
                              onTap: _onWhatsApp,
                              child: const CustomPaint(
                                size: Size(18.0, 18.0),
                                painter: _CardWhatsAppIconPainter(),
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            _roundAction(
                              key: const Key('provider_detail_card_call_btn'),
                              color: _ink,
                              enabled: canContact && !_busy,
                              onTap: _onCall,
                              child: const Icon(Icons.phone_rounded, size: 17.0, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        _brandStatCard(
                          icon: const Icon(Icons.place_rounded, size: 18.0, color: Colors.white),
                          value: _liveDistance.isNotEmpty ? _liveDistance : '—',
                          label: tr.distanceAway,
                        ),
                        const SizedBox(width: 10.0),
                        _brandStatCard(
                          icon: const Icon(Icons.schedule_rounded, size: 18.0, color: Colors.white),
                          value: _liveEta.isNotEmpty ? _liveEta : '—',
                          label: tr.estimatedTime,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: _brandSoft,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(color: _brandBorder, width: 1.0),
                      ),
                      child: Row(
                        children: [
                          _trustChip(
                            icon: const Icon(Icons.verified_rounded, size: 15.0, color: Colors.white),
                            title: _verified
                                ? (tr.isArabic ? 'موثّق' : 'Verified')
                                : (tr.isArabic ? 'مزود' : 'Provider'),
                            subtitle: tr.isArabic ? 'زيشو' : 'Zesho',
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            width: 1.0,
                            height: 28.0,
                            color: _brandBorder,
                          ),
                          _trustChip(
                            icon: Icon(
                              _isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                              size: 15.0,
                              color: Colors.white,
                            ),
                            title: _isOnline
                                ? (tr.isArabic ? 'متصل' : 'Online')
                                : (tr.isArabic ? 'غير متصل' : 'Offline'),
                            subtitle: tr.isArabic ? 'مباشر' : 'Live',
                            paddingLeft: 10.0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    GestureDetector(
                      key: const Key('provider_detail_card_send_loc_btn'),
                      onTap: _busy ? null : _onSendLocation,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: double.infinity,
                        height: 50.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(color: _brand, width: 1.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.my_location_rounded, size: 18.0, color: _brand),
                            const SizedBox(width: 8.0),
                            Text(
                              tr.sendMyLocation,
                              style: tr.font(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w700,
                                color: _brand,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    GestureDetector(
                      key: const Key('provider_detail_card_send_req_btn'),
                      onTap: _busy ? null : _onSendRequest,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: double.infinity,
                        height: 52.0,
                        decoration: BoxDecoration(
                          color: _brand,
                          borderRadius: BorderRadius.circular(14.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x338B53FE),
                              blurRadius: 10.0,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_busy)
                              const SizedBox(
                                width: 18.0,
                                height: 18.0,
                                child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white),
                              )
                            else ...[
                              Text(
                                _matchingActiveTask != null
                                    ? (tr.isArabic ? 'عرض الطلب' : 'View Request')
                                    : (tr.isArabic ? 'إرسال الطلب' : 'Send Request'),
                                style: tr.font(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Icon(
                                tr.isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                                size: 18.0,
                                color: Colors.white,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.showCloseIcon)
              PositionedDirectional(
                top: 10.0,
                end: 16.0,
                child: GestureDetector(
                  key: const Key('provider_detail_card_close_button'),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (widget.onClose != null) {
                      widget.onClose!();
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                  child: Container(
                    width: 34.0,
                    height: 34.0,
                    decoration: BoxDecoration(
                      color: _brandSoft,
                      shape: BoxShape.circle,
                      border: Border.all(color: _brandBorder),
                    ),
                    child: const Icon(Icons.close_rounded, size: 18.0, color: _ink),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _roundAction({
    required Key key,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: GestureDetector(
        key: key,
        onTap: enabled ? onTap : null,
        child: Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _CardWhatsAppIconPainter extends CustomPainter {
  const _CardWhatsAppIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);
    final path = Path()..fillType = PathFillType.evenOdd;
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
