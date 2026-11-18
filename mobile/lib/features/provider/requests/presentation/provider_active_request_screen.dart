import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/core/utils/app_snackbar.dart';
import 'package:mobile/core/utils/contact_launcher.dart';
import 'package:mobile/core/utils/geo_distance.dart';
import 'package:mobile/models/category_model.dart';
import 'package:mobile/providers/backend_provider.dart';
import 'package:mobile/services/location_service.dart';
import 'package:mobile/providers/notifications_provider.dart';
import 'package:mobile/services/task_service.dart';
import 'package:mobile/features/home/presentation/widgets/notification_popup_card.dart';
import 'package:mobile/features/location/presentation/widgets/real_map_background_widget.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_scroll_behavior.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_header_back_button.dart';
import 'package:mobile/features/provider/requests/presentation/provider_service_completed_screen.dart';
import 'package:mobile/features/provider/requests/provider_request_sync.dart';
import 'package:mobile/features/provider/requests/presentation/widgets/provider_request_metric_cards_row.dart';
import 'package:mobile/features/provider/requests/presentation/widgets/provider_request_sheet_typography.dart';

/// Provider Active Request Screen
/// Displays active request details with:
/// - Top header with Back button, "Active Request" title, and "On the way" status card
/// - Map with destination pin, route line, car, landmark, and GPS button
/// - Bottom card with same branding as service details screen:
///   1. Service image + title + client info
///   2. Customer Location card
///   3. Distance & Estimated time twin cards
///   4. Customer card with WhatsApp, Call, vehicle & plate
///   5. 5-step status stepper (Accepted -> On the way -> Arrived -> In Progress -> Completed)
///   6. Customer Note card
///   7. "I've Arrived ->" primary action button
///   8. Bottom home indicator bar
class ProviderActiveRequestScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String serviceTypeEn;
  final String serviceTypeAr;
  final String locationEn;
  final String locationAr;
  final String distanceEn;
  final String distanceAr;
  final String timeEn;
  final String timeAr;
  final String customerNameEn;
  final String customerNameAr;
  final String? customerPhone;
  final String vehicleModelEn;
  final String vehicleModelAr;
  final String plateNumber;
  final String customerNoteEn;
  final String customerNoteAr;
  final String? imageAsset;
  final String? customerPhotoUrl;

  const ProviderActiveRequestScreen({
    super.key,
    required this.requestId,
    this.serviceTypeEn = 'Service',
    this.serviceTypeAr = 'خدمة',
    this.locationEn = '',
    this.locationAr = '',
    this.distanceEn = '',
    this.distanceAr = '',
    this.timeEn = '--',
    this.timeAr = '--',
    this.customerNameEn = 'Customer',
    this.customerNameAr = 'عميل',
    this.customerPhone,
    this.vehicleModelEn = '',
    this.vehicleModelAr = '',
    this.plateNumber = '',
    this.customerNoteEn = '',
    this.customerNoteAr = '',
    this.imageAsset,
    this.customerPhotoUrl,
  });

  @override
  ConsumerState<ProviderActiveRequestScreen> createState() =>
      _ProviderActiveRequestScreenState();
}

class _ProviderActiveRequestScreenState
    extends ConsumerState<ProviderActiveRequestScreen> {
  static const double designWidth = 390.0;
  static const double designHeight = 844.0;

  // Active step index: 0 = Accepted, 1 = On the way, 2 = Arrived, 3 = In Progress, 4 = Completed
  int _currentStep = 1;
  // Sheet expandable state for smooth user-friendly scrolling
  bool _isSheetExpanded = false;

  final ScrollController _scrollController = ScrollController();
  Timer? _backendSyncTimer;

  void _onTaskChanged() {
    if (!mounted) return;
    final task = _resolveTask();
    if (task != null) {
      setState(() {
        _currentStep = math.max(_currentStep, task.step).clamp(0, 4);
      });
    } else {
      setState(() {});
    }
  }

  ServiceTask? _resolveTask() {
    for (final t in TaskService.instance.providerRequests) {
      if (t.id == widget.requestId) return t;
    }
    final active = TaskService.instance.activeTask;
    if (active?.id == widget.requestId) return active;
    return null;
  }

  String get _customerPhone {
    final fromTask = _resolveTask()?.customerPhone.trim() ?? '';
    if (fromTask.isNotEmpty) return fromTask;
    return widget.customerPhone?.trim() ?? '';
  }

  Future<void> _trackProviderContact(String channel) async {
    final taskId = _resolveTask()?.id ?? widget.requestId;
    final reqId = TaskService.extractBackendUuid(taskId);
    if (reqId == null) return;
    await ref.read(backendServiceProvider).recordProviderContactCustomer(
          requestId: reqId,
          channel: channel,
        );
  }

  Future<void> _contactCustomerWhatsApp(bool isArabic) async {
    final phone = _customerPhone;
    if (phone.isEmpty) {
      showAppSnackBar(
        context,
        isArabic ? 'رقم العميل غير متوفر' : 'Customer phone not available',
      );
      return;
    }
    HapticFeedback.lightImpact();
    await _trackProviderContact('whatsapp');
    final ok = await ContactLauncher.whatsApp(phone);
    if (!ok && mounted) {
      showAppSnackBar(
        context,
        isArabic ? 'تعذر فتح واتساب' : 'Could not open WhatsApp',
      );
    }
  }

  Future<void> _contactCustomerCall(bool isArabic) async {
    final phone = _customerPhone;
    if (phone.isEmpty) {
      showAppSnackBar(
        context,
        isArabic ? 'رقم العميل غير متوفر' : 'Customer phone not available',
      );
      return;
    }
    HapticFeedback.lightImpact();
    await _trackProviderContact('call');
    final ok = await ContactLauncher.call(phone);
    if (!ok && mounted) {
      showAppSnackBar(
        context,
        isArabic ? 'تعذر بدء الاتصال' : 'Could not start call',
      );
    }
  }

  String _categoryAsset(String category) {
    final slug = category.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final model = CategoryModel(
      id: slug,
      name: category.trim().isNotEmpty ? category.trim() : 'Service',
      slug: slug,
    );
    return model.displayAssetImage ?? 'assets/images/tow_truck.png';
  }

  String _resolvePhotoUrl(String? raw) {
    final v = raw?.trim() ?? '';
    if (v.isEmpty) return '';
    if (v.startsWith('http')) return v;
    if (v.startsWith('/')) return '${AppConfig.baseUrl}$v';
    return v;
  }

  (double?, double?) _resolveCustomerCoords(ServiceTask? task, bool isArabic) {
    if (GeoDistance.coordsValid(task?.customerLatitude, task?.customerLongitude)) {
      return (task!.customerLatitude, task.customerLongitude);
    }
    final fromTask = GeoDistance.parseLatLngFromSharedLocation(task?.customerLocation);
    if (GeoDistance.coordsValid(fromTask.$1, fromTask.$2)) return fromTask;
    final fromWidget = GeoDistance.parseLatLngFromSharedLocation(
      isArabic ? widget.locationAr : widget.locationEn,
    );
    return fromWidget;
  }

  String _customerInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'C';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
  }

  String _liveDistanceText(ServiceTask? task, bool isArabic, {required int activeStep}) {
    if (GeoDistance.isAtCustomerSite(step: activeStep, status: task?.status)) {
      return GeoDistance.zeroDistanceLabel(isArabic: isArabic);
    }
    final providerLoc =
        ref.read(userLocationProvider).value ?? LocationService.lastKnownValidLocation;
    final valid = providerLoc != null && providerLoc.hasValidDeviceGps;
    return GeoDistance.resolveProviderToCustomerLabel(
      providerLat: valid ? providerLoc.latitude : null,
      providerLng: valid ? providerLoc.longitude : null,
      providerGpsValid: valid,
      customerLat: task?.customerLatitude,
      customerLng: task?.customerLongitude,
      isArabic: isArabic,
      fallbackLabel: isArabic ? widget.distanceAr : widget.distanceEn,
    );
  }

  String _etaText(ServiceTask? task, bool isArabic, {required int activeStep}) {
    if (GeoDistance.isAtCustomerSite(step: activeStep, status: task?.status)) {
      return isArabic ? 'وصلت' : 'Arrived';
    }
    final meters = _distanceMeters(task);
    if (meters != null && meters >= 0) {
      return GeoDistance.formatEta(meters, isArabic: isArabic);
    }
    final eta = task?.eta.trim() ?? '';
    if (eta.isNotEmpty && eta != '--') return eta;
    final fromWidget = (isArabic ? widget.timeAr : widget.timeEn).trim();
    if (fromWidget.isNotEmpty && fromWidget != '--' && !RegExp(r'\d{4}').hasMatch(fromWidget)) {
      return fromWidget;
    }
    return '--';
  }

  double? _distanceMeters(ServiceTask? task) {
    final providerLoc =
        ref.read(userLocationProvider).value ?? LocationService.lastKnownValidLocation;
    if (!GeoDistance.coordsValid(task?.customerLatitude, task?.customerLongitude)) {
      return null;
    }
    if (providerLoc == null || !providerLoc.hasValidDeviceGps) return null;
    return GeoDistance.metersBetween(
      providerLoc.latitude,
      providerLoc.longitude,
      task!.customerLatitude,
      task.customerLongitude,
    );
  }

  @override
  void initState() {
    super.initState();
    final task = _resolveTask() ?? TaskService.instance.activeTask;
    if (task != null) {
      _currentStep = task.step.clamp(0, 4);
    }
    TaskService.instance.activeTaskNotifier.addListener(_onTaskChanged);
    TaskService.instance.providerRequestsNotifier.addListener(_onTaskChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        syncProviderRequestsFromBackend(ref);
      }
    });
    _backendSyncTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      syncProviderRequestsFromBackend(ref);
    });
  }

  @override
  void dispose() {
    _backendSyncTimer?.cancel();
    TaskService.instance.activeTaskNotifier.removeListener(_onTaskChanged);
    TaskService.instance.providerRequestsNotifier.removeListener(_onTaskChanged);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    ref.watch(userLocationProvider);
    ref.listen(userLocationProvider, (previous, next) {
      if (mounted) setState(() {});
    });
    final task = _resolveTask();
    final int activeStep =
        math.max(task?.step ?? 0, _currentStep).clamp(0, 4);
    final cleanDistance = _liveDistanceText(task, isArabic, activeStep: activeStep);
    final etaLabel = _etaText(task, isArabic, activeStep: activeStep);
    final categoryImage = widget.imageAsset ?? _categoryAsset(isArabic ? widget.serviceTypeAr : widget.serviceTypeEn);
    final customerName = (task?.customerName.trim().isNotEmpty == true)
        ? task!.customerName.trim()
        : (isArabic ? widget.customerNameAr : widget.customerNameEn).trim();
    final rawPhoto = task?.customerPhotoUrl ?? widget.customerPhotoUrl;
    final customerPhoto = (rawPhoto != null &&
            (rawPhoto.contains('ahmed_khan') || rawPhoto.contains('img.png')))
        ? ''
        : _resolvePhotoUrl(rawPhoto);
    final noteFromTask = task?.customerNote.trim() ?? '';
    final noteFromWidget =
        (isArabic ? widget.customerNoteAr : widget.customerNoteEn).trim();
    final customerNote = noteFromTask.isNotEmpty ? noteFromTask : noteFromWidget;
    final bool isLegacySeedNote = customerNote.toLowerCase().contains('battery is dead') ||
        customerNote.toLowerCase().contains('jump start');
    final showCustomerNote = customerNote.isNotEmpty && !isLegacySeedNote;
    final vehicle = (isArabic ? widget.vehicleModelAr : widget.vehicleModelEn).trim();
    final lowVehicle = vehicle.toLowerCase();
    final bool showVehicle = vehicle.isNotEmpty &&
        lowVehicle != 'toyota corolla' &&
        lowVehicle != 'تويوتا كورولا' &&
        lowVehicle != 'service vehicle';

    String statusPillSubtitle(bool ar) {
      if (activeStep >= 2) {
        return ar ? 'عند موقع العميل' : 'At customer site';
      }
      final hasEta = etaLabel.isNotEmpty && etaLabel != '--' && etaLabel != '—';
      final hasDist =
          cleanDistance.isNotEmpty && cleanDistance != '--' && cleanDistance != '—';
      if (hasEta && hasDist) {
        return '$etaLabel · $cleanDistance';
      }
      if (hasEta) return etaLabel;
      if (hasDist) return cleanDistance;
      return ar ? 'تحديث المسافة' : 'Updating distance';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktopWeb = constraints.maxWidth > 500;
            final double containerWidth = isDesktopWeb
                ? designWidth
                : (constraints.maxWidth > designWidth
                    ? designWidth
                    : constraints.maxWidth);
            final double containerHeight =
                isDesktopWeb ? designHeight : constraints.maxHeight;

            final double topSafeArea =
                MediaQuery.maybeOf(context)?.padding.top ?? 0.0;
            final double bottomSafeArea =
                MediaQuery.maybeOf(context)?.padding.bottom ?? 0.0;
            final double headerTop =
                topSafeArea > 0 ? (topSafeArea + 8.0) : 52.0;

            final providerLoc =
                ref.read(userLocationProvider).value ??
                    LocationService.lastKnownValidLocation;
            final (cLat, cLng) = _resolveCustomerCoords(task, isArabic);
            final hasCustomerPin = GeoDistance.coordsValid(cLat, cLng);
            final hasProviderGps =
                providerLoc != null && providerLoc.hasValidDeviceGps;
            double? mapCenterLat;
            double? mapCenterLng;
            if (activeStep >= 2 && hasCustomerPin) {
              mapCenterLat = cLat;
              mapCenterLng = cLng;
            } else if (hasCustomerPin && hasProviderGps) {
              mapCenterLat = (cLat! + providerLoc.latitude) / 2;
              mapCenterLng = (cLng! + providerLoc.longitude) / 2;
            } else if (hasCustomerPin) {
              mapCenterLat = cLat;
              mapCenterLng = cLng;
            } else if (hasProviderGps) {
              mapCenterLat = providerLoc.latitude;
              mapCenterLng = providerLoc.longitude;
            }

            final Widget screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Map Section Background (top 0 to 480px)
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    width: containerWidth,
                    height: 500.0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 1a. Live Real Slippy Map Layer
                        Positioned.fill(
                          child: RealMapBackgroundWidget(
                            enableDrag: true,
                            zoom: activeStep >= 2 ? 16.0 : 15.0,
                            trackingStep: activeStep >= 2
                                ? MapTrackingStep.arrived
                                : (activeStep >= 1
                                    ? MapTrackingStep.onTheWay
                                    : MapTrackingStep.requestSent),
                            isProviderPerspective: true,
                            latitude: mapCenterLat,
                            longitude: mapCenterLng,
                            customerLatitude: cLat,
                            customerLongitude: cLng,
                            destinationName: customerName,
                            driverName: customerName,
                            etaText: etaLabel,
                            distanceText: cleanDistance,
                            visibleTopHeightFraction: 0.58,
                            showControls: true,
                          ),
                        ),

                        // 1b. Header fade only — keep map pins/car visible below
                        Positioned(
                          top: 0.0,
                          left: 0.0,
                          right: 0.0,
                          height: 132.0,
                          child: const IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFFFFFFF),
                                    Color(0xA3FFFFFF),
                                    Color(0x00FFFFFF),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 1j. Floating GPS / Re-center Target Button
                        Positioned(
                          top: 210.0,
                          right: 20.0,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isArabic
                                        ? 'تم إعادة توسيط الخريطة'
                                        : 'Map re-centered to your location',
                                    style: GoogleFonts.inter(color: Colors.white),
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              width: 42.0,
                              height: 42.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                  width: 1.0,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x1F000000),
                                    blurRadius: 12.0,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.my_location_rounded,
                                  size: 22.0,
                                  color: Color(0xFF1C2926),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Header Bar: Circular Back Button `<` + Title: "Active Request" + Top Right "On the way" Card
                  Positioned(
                    top: headerTop,
                    left: 20.0,
                    right: 20.0,
                    height: 46.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ProviderHeaderBackButton(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).maybePop();
                          },
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            isArabic ? 'طلب نشط' : 'Active Request',
                            style: isArabic
                                ? GoogleFonts.cairo(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1C2926),
                                    height: 1.2,
                                  )
                                : GoogleFonts.inter(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1C2926),
                                    height: 1.2,
                                  ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        _buildHeaderStatusPill(
                          isArabic: isArabic,
                          activeStep: activeStep,
                          subtitle: statusPillSubtitle(isArabic),
                        ),
                      ],
                    ),
                  ),

                  // 3. Bottom Sheet Card (Smooth user-friendly expandable & scrollable sheet)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    top: _isSheetExpanded
                        ? (topSafeArea > 0 ? (topSafeArea + 50.0) : 88.0)
                        : 258.0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: containerWidth,
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
                      child: Column(
                        children: [
                          // Interactive Drag Handle Bar (Tap or drag up/down to expand/collapse)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _isSheetExpanded = !_isSheetExpanded;
                              });
                            },
                            onVerticalDragEnd: (details) {
                              if (details.primaryVelocity != null) {
                                if (details.primaryVelocity! < -80) {
                                  // Dragged / flicked up -> expand
                                  HapticFeedback.lightImpact();
                                  setState(() => _isSheetExpanded = true);
                                } else if (details.primaryVelocity! > 80) {
                                  // Dragged / flicked down -> collapse
                                  HapticFeedback.lightImpact();
                                  setState(() => _isSheetExpanded = false);
                                }
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(top: 10.0, bottom: 6.0),
                              color: Colors.transparent,
                              child: Center(
                                child: Container(
                                  width: 44.0,
                                  height: 4.0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0DFE4),
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Scrollable Bottom Card Content Area (Smooth bouncing physics, equal gaps)
                          Expanded(
                            child: ScrollConfiguration(
                              behavior: const ProviderCardScrollBehavior(),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                physics: const ClampingScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  20.0,
                                  6.0,
                                  20.0,
                                  bottomSafeArea > 0 ? (bottomSafeArea + 24.0) : 24.0,
                                ),
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 3a. Row 1: Service Image + Service Title + Client Name & Location
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        child: Image.asset(
                                          categoryImage,
                                          width: ProviderRequestSheetTypography.serviceThumb,
                                          height: ProviderRequestSheetTypography.serviceThumb,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            width: ProviderRequestSheetTypography.serviceThumb,
                                            height: ProviderRequestSheetTypography.serviceThumb,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3F2F5),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: const Icon(
                                              Icons.car_repair_rounded,
                                              color: Color(0xFF8B53FE),
                                              size: 30.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isArabic
                                                  ? widget.serviceTypeAr
                                                  : widget.serviceTypeEn,
                                              style: ProviderRequestSheetTypography.title(isArabic),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: ProviderRequestSheetTypography.labelGap),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    customerName,
                                                    style: ProviderRequestSheetTypography.subtext(
                                                      isArabic,
                                                      weight: FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8.0),
                                                Container(
                                                  width: 4.0,
                                                  height: 4.0,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFF616166),
                                                  ),
                                                ),
                                                const SizedBox(width: 8.0),
                                                Flexible(
                                                  child: Text(
                                                    isArabic
                                                        ? widget.locationAr
                                                        : widget.locationEn,
                                                    style: ProviderRequestSheetTypography.subtext(isArabic),
                                                    maxLines: 2,
                                                    softWrap: true,
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: ProviderRequestSheetTypography.sectionGap),

                                  // 3b. 1st Card: Customer Location Card
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 16.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F2F5),
                                      borderRadius:
                                          BorderRadius.circular(12.0),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: ProviderRequestSheetTypography.iconBox,
                                          height: ProviderRequestSheetTypography.iconBox,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE7E6EB),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.location_on_rounded,
                                              size: ProviderRequestSheetTypography.iconGlyph,
                                              color: Color(0xFF252527),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isArabic
                                                    ? 'موقع العميل'
                                                    : 'Customer Location',
                                                style: ProviderRequestSheetTypography.label(isArabic),
                                                maxLines: 2,
                                                softWrap: true,
                                                overflow: TextOverflow.clip,
                                              ),
                                              const SizedBox(height: ProviderRequestSheetTypography.labelGap),
                                              Text(
                                                isArabic
                                                    ? widget.locationAr
                                                    : widget.locationEn,
                                                style: ProviderRequestSheetTypography.body(isArabic),
                                                maxLines: 2,
                                                softWrap: true,
                                                overflow: TextOverflow.clip,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: ProviderRequestSheetTypography.sectionGap),

                                  ProviderRequestMetricCardsRow(
                                    isArabic: isArabic,
                                    distanceValue: cleanDistance,
                                    etaValue: etaLabel,
                                  ),

                                  const SizedBox(height: ProviderRequestSheetTypography.sectionGap),

                                  // 3d. Customer Card: Avatar, Name, WhatsApp, Call, Vehicle
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F2F5),
                                      borderRadius:
                                          BorderRadius.circular(16.0),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Avatar + Customer info
                                            Row(
                                              children: [
                                                ClipOval(
                                                  child: customerPhoto.isNotEmpty
                                                      ? Image.network(
                                                          customerPhoto,
                                                          width: ProviderRequestSheetTypography.avatar,
                                                          height: ProviderRequestSheetTypography.avatar,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (_, _, _) => Container(
                                                            width: ProviderRequestSheetTypography.avatar,
                                                            height: ProviderRequestSheetTypography.avatar,
                                                            color: const Color(0xFF8B53FE),
                                                            alignment: Alignment.center,
                                                            child: Text(
                                                              _customerInitials(customerName),
                                                              style: GoogleFonts.inter(
                                                                fontSize: ProviderRequestSheetTypography.valueMd,
                                                                fontWeight: FontWeight.w700,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Container(
                                                          width: ProviderRequestSheetTypography.avatar,
                                                          height: ProviderRequestSheetTypography.avatar,
                                                          color: const Color(0xFF8B53FE),
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            _customerInitials(customerName),
                                                            style: GoogleFonts.inter(
                                                              fontSize: ProviderRequestSheetTypography.valueMd,
                                                              fontWeight: FontWeight.w700,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                ),
                                                const SizedBox(width: 12.0),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      isArabic
                                                          ? 'العميل'
                                                          : 'Customer',
                                                      style: ProviderRequestSheetTypography.label(isArabic),
                                                    ),
                                                    const SizedBox(
                                                        height: ProviderRequestSheetTypography.labelGap),
                                                    Text(
                                                      customerName,
                                                      style: ProviderRequestSheetTypography.body(isArabic),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),

                                            if (_customerPhone.isNotEmpty)
                                            Row(
                                              children: [
                                                // WhatsApp Button
                                                GestureDetector(
                                                  onTap: () =>
                                                      _contactCustomerWhatsApp(isArabic),
                                                  child: Container(
                                                    width: 38.0,
                                                    height: 38.0,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xFF25D366),
                                                    ),
                                                    child: const Center(
                                                      child: SizedBox(
                                                        width: 20.0,
                                                        height: 20.0,
                                                        child: CustomPaint(
                                                          painter:
                                                              _ActiveOfficialWhatsAppLogoPainter(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10.0),
                                                // Call Button
                                                GestureDetector(
                                                  onTap: () =>
                                                      _contactCustomerCall(isArabic),
                                                  child: Container(
                                                    width: 38.0,
                                                    height: 38.0,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xFF252527),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.phone_rounded,
                                                        size: 18.0,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        if (showVehicle) ...[
                                        const SizedBox(height: ProviderRequestSheetTypography.sectionGap),

                                        // Vehicle Row (only when real data exists)
                                        Row(
                                          children: [
                                            Icon(
                                                Icons.directions_car_rounded,
                                                size: ProviderRequestSheetTypography.iconGlyph,
                                                color: Color(0xFF252527)),
                                            const SizedBox(width: 8.0),
                                            Text(
                                              isArabic
                                                  ? widget.vehicleModelAr
                                                  : widget.vehicleModelEn,
                                              style: ProviderRequestSheetTypography.body(isArabic),
                                            ),
                                            const SizedBox(width: 12.0),
                                            Container(
                                                width: 1.0,
                                                height: 14.0,
                                                color:
                                                    const Color(0xFFE0DFE4)),
                                            const SizedBox(width: 12.0),
                                            // Plate Icon Badge
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.5,
                                                      vertical: 2.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: const Color(
                                                        0xFF9E9EA4),
                                                    width: 1.0),
                                                borderRadius:
                                                    BorderRadius.circular(3.5),
                                              ),
                                              child: Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  Container(
                                                      width: 1.0,
                                                      height: 7.5,
                                                      color: const Color(
                                                          0xFF75757A)),
                                                  const SizedBox(width: 2.0),
                                                  Container(
                                                      width: 1.0,
                                                      height: 7.5,
                                                      color: const Color(
                                                          0xFF75757A)),
                                                  const SizedBox(width: 2.0),
                                                  Container(
                                                      width: 1.0,
                                                      height: 7.5,
                                                      color: const Color(
                                                          0xFF75757A)),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 6.0),
                                            Text(
                                              widget.plateNumber,
                                              style: GoogleFonts.inter(
                                                fontSize: ProviderRequestSheetTypography.labelSm,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    const Color(0xFF5E5E63),
                                              ),
                                            ),
                                          ],
                                        ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: ProviderRequestSheetTypography.sectionGap),

                                  // 3e. Service Status Stepper (5 Steps: Accepted -> On the way -> Arrived -> In Progress -> Completed)
                                  _buildStatusStepper(isArabic),

                                  if (showCustomerNote) ...[
                                  const SizedBox(height: ProviderRequestSheetTypography.sectionGap),

                                  // 3f. Customer Note Card (only when customer left a note)
                                  Container(
                                    width: 350.0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 15.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F2F5),
                                      borderRadius:
                                          BorderRadius.circular(12.0),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const _ActiveCustomerNoteIcon(),
                                        const SizedBox(width: 11.0),
                                        Expanded(
                                          child: SizedBox(
                                            width: 283.0,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  isArabic
                                                      ? 'ملاحظة العميل'
                                                      : 'Customer Note',
                                                  style: ProviderRequestSheetTypography.label(isArabic),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: ProviderRequestSheetTypography.labelGap),
                                                Text(
                                                  customerNote,
                                                  style: ProviderRequestSheetTypography.subtext(isArabic),
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.visible,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ],
                                  const SizedBox(height: 16.0),

                                  // 3g. Primary Action Button: "I've Arrived ->" (Exact previous button branding)
                                  GestureDetector(
                              onTap: () async {
                                HapticFeedback.mediumImpact();
                                if (_currentStep < 3) {
                                  setState(() {
                                    _currentStep++;
                                  });
                                  final String newStatus = _currentStep == 2 ? 'arrived' : 'in_progress';
                                  final zeroDist =
                                      GeoDistance.zeroDistanceLabel(isArabic: isArabic);
                                  final arrivedEta = isArabic ? 'وصلت' : 'Arrived';
                                  final inProgressEta =
                                      isArabic ? 'قيد التنفيذ' : 'In progress';
                                  await ref
                                      .read(backendServiceProvider)
                                      .updateProviderRequestStatus(
                                        requestId: widget.requestId,
                                        status: newStatus,
                                        step: _currentStep,
                                      )
                                      .catchError((_) => false);
                                  await TaskService.instance.updateRequestStatusById(
                                    taskId: widget.requestId,
                                    status: newStatus,
                                    step: _currentStep,
                                    distance: _currentStep >= 2 ? zeroDist : null,
                                    eta: _currentStep == 2
                                        ? arrivedEta
                                        : (_currentStep >= 3 ? inProgressEta : null),
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color(0xFF8B53FE),
                                      content: Text(
                                        _getSuccessMessage(isArabic),
                                        style: GoogleFonts.inter(color: Colors.white),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  // Complete Service (_currentStep == 3) or Service Completed (_currentStep == 4)
                                  setState(() {
                                    _currentStep = 4;
                                  });
                                  await ref
                                      .read(backendServiceProvider)
                                      .updateProviderRequestStatus(
                                        requestId: widget.requestId,
                                        status: 'completed',
                                        step: 4,
                                      )
                                      .catchError((_) => false);
                                  await TaskService.instance
                                      .completeRequestById(widget.requestId);
                                  if (!context.mounted) return;
                                  final task = TaskService.instance.getTaskById(widget.requestId) ?? TaskService.instance.activeTask;
                                  final nowLocal = DateTime.now();
                                  final taskCreated = task?.createdAt ?? nowLocal;
                                  final elapsedMinutes = nowLocal.difference(taskCreated).inMinutes;
                                  final durationEn = elapsedMinutes <= 0
                                      ? '< 1 minute'
                                      : (elapsedMinutes == 1 ? '1 minute' : '$elapsedMinutes minutes');
                                  final durationAr = elapsedMinutes <= 0
                                      ? 'أقل من دقيقة'
                                      : (elapsedMinutes == 1 ? 'دقيقة واحدة' : '$elapsedMinutes دقيقة');
                                  final completedDateStr =
                                      '${nowLocal.day.toString().padLeft(2, '0')}/${nowLocal.month.toString().padLeft(2, '0')}/${nowLocal.year} '
                                      '${nowLocal.hour.toString().padLeft(2, '0')}:${nowLocal.minute.toString().padLeft(2, '0')}';
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProviderServiceCompletedScreen(
                                        requestId: widget.requestId,
                                        serviceTypeEn: widget.serviceTypeEn,
                                        serviceTypeAr: widget.serviceTypeAr,
                                        imageAsset: categoryImage,
                                        customerPhotoUrl: customerPhoto,
                                        serviceLocationEn: widget.locationEn,
                                        serviceLocationAr: widget.locationAr,
                                        serviceDateEn: completedDateStr,
                                        serviceDateAr: completedDateStr,
                                        serviceDurationEn: durationEn,
                                        serviceDurationAr: durationAr,
                                        customerNameEn: widget.customerNameEn,
                                        customerNameAr: widget.customerNameAr,
                                        vehicleModelEn: widget.vehicleModelEn,
                                        vehicleModelAr: widget.vehicleModelAr,
                                        plateNumber: widget.plateNumber,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: 52.0,
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B53FE),
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x338B53FE),
                                      blurRadius: 10.0,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _getActionButtonText(isArabic),
                                      style: isArabic
                                          ? GoogleFonts.cairo(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              height: 22.0 / 14.0,
                                              letterSpacing: 0.0,
                                            )
                                          : GoogleFonts.inter(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              height: 22.0 / 14.0,
                                              letterSpacing: 0.0,
                                            ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 8.0),
                                    Icon(
                                      isArabic
                                          ? Icons.arrow_back_rounded
                                          : Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 18.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 3g-2. Cancel Request Button (Branding: #FFEBEB bg, #FF383C text, 52h, 12r)
                            if (activeStep < 2) ...[
                              const SizedBox(height: 12.0),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _showCancelDialog(isArabic);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: double.infinity,
                                  height: 52.0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                    horizontal: 53.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEB),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    isArabic ? 'إلغاء الطلب' : 'Cancel Request',
                                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFFFF383C),
                                      height: 22.0 / 14.0,
                                      letterSpacing: 0.0,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16.0),

                            // 3h. Bottom Home Indicator Bar (In-scroll, with safe-area padding)
                            Center(
                              child: Container(
                                width: 134.0,
                                height: 5.0,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C1C1E),
                                  borderRadius: BorderRadius.circular(100.0),
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
                  ),

                  // 4. Live Provider Notification Banner Overlay (e.g. if customer cancels mid-trip)
                  Builder(
                    builder: (context) {
                      final notifState = ref.watch(notificationsProvider);
                      final n = notifState.providerNotification;
                      if (!notifState.isProviderCardVisible || n == null) {
                        return const SizedBox.shrink();
                      }
                      return Positioned(
                        top: headerTop + 50.0,
                        left: 16.0,
                        right: 16.0,
                        child: NotificationPopupCard(
                          badgeText: isArabic ? n.badgeTextAr : n.badgeTextEn,
                          title: isArabic ? n.titleAr : n.titleEn,
                          location: isArabic ? n.locationAr : n.locationEn,
                          distance: isArabic ? n.distanceAr : n.distanceEn,
                          time: isArabic ? n.timeAr : n.timeEn,
                          createdAt: n.createdAt,
                          imageAsset: n.imageAsset,
                          onTap: () => ref.read(notificationsProvider.notifier).hideProviderCard(),
                          onDismiss: () => ref.read(notificationsProvider.notifier).hideProviderCard(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );

            if (isDesktopWeb) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFF0F1F5),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Container(
                    width: designWidth,
                    height: designHeight,
                    margin: const EdgeInsets.symmetric(vertical: 24.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(44),
                      border: Border.all(
                        color: const Color(0xFF8B53FE).withValues(alpha: 0.35),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 36,
                          spreadRadius: 6,
                        ),
                        BoxShadow(
                          color: const Color(0xFF8B53FE).withValues(alpha: 0.10),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(42),
                      child: screenContent,
                    ),
                  ),
                ),
              );
            }

            return Center(
              child: SizedBox(
                width: containerWidth,
                height: containerHeight,
                child: screenContent,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderStatusPill({
    required bool isArabic,
    required int activeStep,
    required String subtitle,
  }) {
    TextStyle textStyle(bool ar, double size, FontWeight w, Color color) =>
        (ar ? GoogleFonts.cairo : GoogleFonts.inter)(
        fontSize: size,
        fontWeight: w,
        color: color,
          height: 1.15,
        );

    if (activeStep >= 2) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF4EEFF),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: const Color(0xFF8B53FE), width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.place_rounded,
              size: 17.0,
              color: Color(0xFF8B53FE),
            ),
            const SizedBox(width: 6.0),
            Text(
              isArabic ? 'تم الوصول' : 'Arrived',
              style: textStyle(isArabic, 12.0, FontWeight.w700, const Color(0xFF8B53FE)),
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 0.8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 26.0,
              height: 26.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF8B53FE),
              ),
              child: const Icon(
                Icons.near_me_rounded,
                color: Colors.white,
                size: 14.0,
              ),
            ),
            const SizedBox(width: 6.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getStepStatusText(isArabic, activeStep),
                    style: textStyle(
                      isArabic,
                      11.0,
                      FontWeight.w700,
                      const Color(0xFF8B53FE),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: textStyle(
                      isArabic,
                      10.5,
                      FontWeight.w400,
                      const Color(0xFF75757A),
                    ),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.fade,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepStatusText(bool isArabic, int step) {
    switch (step) {
      case 0:
        return isArabic ? 'تم القبول' : 'Accepted';
      case 1:
        return isArabic ? 'في الطريق' : 'On the way';
      case 2:
        return isArabic ? 'تم الوصول' : 'Arrived';
      case 3:
        return isArabic ? 'جاري العمل' : 'In Progress';
      case 4:
        return isArabic ? 'مكتمل' : 'Completed';
      default:
        return isArabic ? 'في الطريق' : 'On the way';
    }
  }

  String _getActionButtonText(bool isArabic) {
    switch (_currentStep) {
      case 0:
      case 1:
        return isArabic ? 'لقد وصلت' : "I've Arrived";
      case 2:
        return isArabic ? 'بدء الخدمة' : 'Start Service';
      case 3:
        return isArabic ? 'إكمال الخدمة' : 'Complete Service';
      case 4:
      default:
        return isArabic ? 'تم الانتهاء بنجاح' : 'Service Completed';
    }
  }

  String _getSuccessMessage(bool isArabic) {
    switch (_currentStep) {
      case 2:
        return isArabic ? 'تم تأكيد الوصول للعميل!' : 'Arrival confirmed!';
      case 3:
        return isArabic ? 'تم بدء تنفيذ الخدمة!' : 'Service started!';
      case 4:
        return isArabic
            ? 'تم إكمال الخدمة بنجاح!'
            : 'Service successfully completed!';
      default:
        return isArabic
            ? 'تم تحديث حالة الطلب!'
            : 'Request status updated!';
    }
  }

  Future<void> _showCancelDialog(bool isArabic) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            isArabic ? 'إلغاء الطلب' : 'Cancel Request',
            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF252527),
            ),
          ),
          content: Text(
            isArabic
                ? 'هل أنت متأكد من رغبتك في إلغاء هذا الطلب؟ لا يمكن التراجع عن هذا الإجراء.'
                : 'Are you sure you want to cancel this service request? This action cannot be undone.',
            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF616166),
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      isArabic ? 'تراجع' : 'Keep',
                      style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF616166),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF383C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      isArabic ? 'نعم، إلغاء' : 'Yes, Cancel',
                      style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (confirmed == true) {
      await ref
          .read(backendServiceProvider)
          .updateProviderRequestStatus(
            requestId: widget.requestId,
            status: 'cancelled',
            step: 0,
          )
          .catchError((_) => false);
      await TaskService.instance.cancelRequestById(widget.requestId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFFF383C),
          content: Text(
            isArabic ? 'تم إلغاء الطلب بنجاح' : 'Request has been cancelled',
            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
              color: Colors.white,
            ),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).maybePop();
    }
  }

  /// 5-Step Stepper Widget matching exact Figma design from user screenshot:
  /// Accepted (done) -> On the way (active) -> Arrived -> In Progress -> Completed
  Widget _buildStatusStepper(bool isArabic) {
    final steps = [
      {'key': 'accepted', 'en': 'Accepted', 'ar': 'تم القبول'},
      {'key': 'on_way', 'en': 'On the way', 'ar': 'في الطريق'},
      {'key': 'arrived', 'en': 'Arrived', 'ar': 'تم الوصول'},
      {'key': 'in_progress', 'en': 'In Progress', 'ar': 'جاري العمل'},
      {'key': 'completed', 'en': 'Completed', 'ar': 'مكتمل'},
    ];

    return Column(
      children: [
        // Stepper Nodes and Connecting Lines Row
        SizedBox(
          height: 30.0,
          child: Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isEven) {
                final stepIdx = index ~/ 2;
                final bool isDone = stepIdx < _currentStep;
                final bool isActive = stepIdx == _currentStep;

                if (isDone) {
                  // Step Completed: Purple circle with white checkmark
                  return Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF8B53FE),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 15.0,
                        color: Colors.white,
                      ),
                    ),
                  );
                } else if (isActive) {
                  // Step Active: Concentric purple ring
                  return Container(
                    width: 26.0,
                    height: 26.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFF8B53FE),
                        width: 2.2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x338B53FE),
                          blurRadius: 6.0,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 12.0,
                        height: 12.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF8B53FE),
                        ),
                      ),
                    ),
                  );
                } else {
                  // Step Pending: Light grey outlined circle
                  return Container(
                    width: 22.0,
                    height: 22.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                    ),
                  );
                }
              } else {
                // Connecting line between steps
                final lineIdx = index ~/ 2;
                final bool isLineDone = lineIdx < _currentStep;
                return Expanded(
                  child: Container(
                    height: 2.0,
                    margin: const EdgeInsets.symmetric(horizontal: 2.0),
                    color: isLineDone
                        ? const Color(0xFF8B53FE)
                        : const Color(0xFFE5E7EB),
                  ),
                );
              }
            }),
          ),
        ),

        const SizedBox(height: ProviderRequestSheetTypography.labelGap),

        // Stepper Labels Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (stepIdx) {
            final bool isDone = stepIdx < _currentStep;
            final bool isActive = stepIdx == _currentStep;
            final String label = (isArabic
                    ? steps[stepIdx]['ar']
                    : steps[stepIdx]['en']) ??
                '';

            Color textColor;
            FontWeight fontWeight;
            if (isActive) {
              textColor = const Color(0xFF8B53FE);
              fontWeight = FontWeight.w600;
            } else if (isDone) {
              textColor = const Color(0xFF252527);
              fontWeight = FontWeight.w500;
            } else {
              textColor = const Color(0xFF8E8E93);
              fontWeight = FontWeight.w400;
            }

            return SizedBox(
              width: 60.0,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: ProviderRequestSheetTypography.stepLabelStyle(
                  isArabic,
                  fontWeight: fontWeight,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Official WhatsApp Logo Painter (Authentic PathFillType.evenOdd vector)
class _ActiveOfficialWhatsAppLogoPainter extends CustomPainter {
  const _ActiveOfficialWhatsAppLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

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

    // 2. Inner speech-bubble hole (crisp outline cut)
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
  bool shouldRepaint(covariant _ActiveOfficialWhatsAppLogoPainter oldDelegate) =>
      false;
}

/// Customer Note notepad icon
class _ActiveCustomerNoteIcon extends StatelessWidget {
  const _ActiveCustomerNoteIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24.0,
      height: 26.0,
      child: CustomPaint(
        painter: _ActiveCustomerNoteIconPainter(),
      ),
    );
  }
}

class _ActiveCustomerNoteIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final darkPaint = Paint()
      ..color = const Color(0xFF252527)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final lightPaint = Paint()
      ..color = const Color(0xFFF3F2F5)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.0, 4.0, size.width, size.height - 4.0),
        const Radius.circular(6.0),
      ),
      darkPaint,
    );

    // Left binder clip
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(4.5, 0.0, 3.5, 6.0),
        const Radius.circular(1.75),
      ),
      darkPaint,
    );

    // Right binder clip
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(16.0, 0.0, 3.5, 6.0),
        const Radius.circular(1.75),
      ),
      darkPaint,
    );

    // Note line 1
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(5.0, 10.5, 8.5, 2.2),
        const Radius.circular(1.1),
      ),
      lightPaint,
    );

    // Note line 2
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(5.0, 15.5, 14.0, 2.2),
        const Radius.circular(1.1),
      ),
      lightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ActiveCustomerNoteIconPainter oldDelegate) =>
      false;
}
