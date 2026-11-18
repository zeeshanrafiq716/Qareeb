import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/core/utils/contact_launcher.dart';
import 'package:mobile/core/utils/geo_distance.dart';
import 'package:mobile/providers/backend_provider.dart';
import 'package:mobile/services/location_service.dart';
import 'package:mobile/providers/notifications_provider.dart';
import 'package:mobile/services/task_service.dart';
import 'package:mobile/features/home/presentation/widgets/notification_popup_card.dart';
import 'package:mobile/features/provider/requests/presentation/provider_active_request_screen.dart';
import 'package:mobile/features/location/presentation/widgets/real_map_background_widget.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_animated_language_toggle.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_scroll_behavior.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_header_back_button.dart';
import 'package:mobile/features/provider/requests/presentation/widgets/provider_request_metric_cards_row.dart';
import 'package:mobile/features/provider/requests/presentation/widgets/provider_request_sheet_typography.dart';

/// Provider Request Details Screen
/// Exact Figma specification matching user screenshot:
///
/// header:
///   - Circular back button `<`
///   - Title: "Request Details"
///   - Language toggle on right side as in previous screens
///
/// complete screen layout:
///   width: 390;
///   height: 843;
///   top: 1px;
///   angle: 0 deg;
///   opacity: 1;
///   background: linear-gradient(180deg, #FFFFFF 2.14%, rgba(255, 255, 255, 0.839534) 17.05%, rgba(255, 255, 255, 0) 26.93%);
///
/// map layout:
///   - Route line from location pin to car
///   - Tooltip badge with distance (e.g. 2.4 km) pointing down to pin
///   - Pin with glowing halo rings
///   - Top-down vector car
///   - White speech-bubble tooltip badge above car: "You"
///   - Landmark: "النخيل مول / Al Nakheel Mall"
///   - Floating GPS / location re-center target button
///
/// bottom card layout:
///   - Customer side layout & branding
///   - Handle, customer profile, WhatsApp & Call shortcuts, service details, and Accept/Decline action buttons
class ProviderRequestDetailsScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String serviceTypeEn;
  final String serviceTypeAr;
  final String locationEn;
  final String locationAr;
  final String distanceEn;
  final String distanceAr;
  final String etaEn;
  final String etaAr;
  final String timeEn;
  final String timeAr;
  final String badgeEn;
  final String badgeAr;
  final String imageAsset;
  final String status;
  final String customerName;
  final String? customerPhotoUrl;
  final String? customerPhone;
  final String vehicleModelEn;
  final String vehicleModelAr;
  final String plateNumber;
  final String customerNoteEn;
  final String customerNoteAr;

  const ProviderRequestDetailsScreen({
    super.key,
    this.requestId = '',
    this.serviceTypeEn = 'Service Request',
    this.serviceTypeAr = 'طلب خدمة',
    this.locationEn = '',
    this.locationAr = '',
    this.distanceEn = '--',
    this.distanceAr = '--',
    this.etaEn = '',
    this.etaAr = '',
    this.timeEn = '',
    this.timeAr = '',
    this.badgeEn = 'New Request',
    this.badgeAr = 'طلب جديد',
    this.imageAsset = 'assets/images/tow_truck.png',
    this.status = 'new',
    this.customerName = 'Customer',
    this.customerPhotoUrl,
    this.customerPhone,
    this.vehicleModelEn = '',
    this.vehicleModelAr = '',
    this.plateNumber = '',
    this.customerNoteEn = '',
    this.customerNoteAr = '',
  });

  static const double designWidth = 390.0;
  static const double designHeight = 843.0;

  @override
  ConsumerState<ProviderRequestDetailsScreen> createState() =>
      _ProviderRequestDetailsScreenState();
}

class _ProviderRequestDetailsScreenState
    extends ConsumerState<ProviderRequestDetailsScreen> {
  static const double designWidth = 390.0;
  static const double designHeight = 843.0;

  bool _isSheetExpanded = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _showAcceptDeclineActions {
    final status = widget.status.toLowerCase().trim();
    return status != 'completed' && status != 'cancelled';
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'C';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return parts[0].substring(0, 1).toUpperCase() + parts[1].substring(0, 1).toUpperCase();
  }

  String? _cleanPhoto(String? raw) {
    final v = raw?.trim() ?? '';
    if (v.isEmpty) return null;
    if (v.contains('ahmed_khan') || v.endsWith('img.png') || v.contains('unsplash.com')) {
      return null;
    }
    return v;
  }

  Future<void> _trackProviderContact(String channel) async {
    final reqId = TaskService.extractBackendUuid(widget.requestId);
    if (reqId == null) return;
    await ref.read(backendServiceProvider).recordProviderContactCustomer(
          requestId: reqId,
          channel: channel,
        );
  }

  String _resolveEtaText(String cleanDistance, bool isArabic) {
    final rawEta = (isArabic ? widget.etaAr : widget.etaEn).trim();
    if (rawEta.isNotEmpty && rawEta != '--' && rawEta != '—') {
      return rawEta;
    }
    final mMatch = RegExp(r'^(\d+(?:\.\d+)?)\s*(m|م)$', caseSensitive: false).firstMatch(cleanDistance);
    if (mMatch != null) {
      final meters = double.tryParse(mMatch.group(1) ?? '') ?? 0;
      if (meters < 100) return isArabic ? 'أقل من دقيقة' : '< 1 min';
      final mins = ((meters / 1000.0) / 30.0 * 60.0).ceil().clamp(1, 180);
      return isArabic ? '$mins د' : '$mins min';
    }
    final kmMatch = RegExp(r'^(\d+(?:\.\d+)?)\s*(km|كم)$', caseSensitive: false).firstMatch(cleanDistance);
    if (kmMatch != null) {
      final km = double.tryParse(kmMatch.group(1) ?? '') ?? 0;
      if (km < 0.1) return isArabic ? 'أقل من دقيقة' : '< 1 min';
      final mins = (km / 30.0 * 60.0).ceil().clamp(1, 180);
      return isArabic ? '$mins د' : '$mins min';
    }
    return '--';
  }

  bool _isSeedVehicle(String v) {
    final low = v.trim().toLowerCase();
    return low.isEmpty || low == 'toyota corolla' || low == 'service vehicle' || low == 'تويوتا كورولا';
  }

  bool _isSeedPlate(String p) {
    final low = p.trim().toLowerCase();
    return low.isEmpty || low == 'ksa 1234' || low == '1122';
  }

  bool _isSeedNote(String n) {
    final low = n.trim().toLowerCase();
    return low.isEmpty || low.contains('battery is dead') || low.contains('البطارية فارغة');
  }

  String _customerLocationLabel(bool isArabic) {
    final task = _resolveTask();
    final fromWidget = (isArabic ? widget.locationAr : widget.locationEn).trim();
    return GeoDistance.customerLocationLabel(
      fromWidget.isNotEmpty ? fromWidget : task?.customerLocation,
      isArabic: isArabic,
      alternate: task?.customerLocation,
    );
  }

  ServiceTask? _resolveTask() {
    final id = widget.requestId.trim();
    if (id.isEmpty) return null;
    for (final t in TaskService.instance.providerRequests) {
      if (t.id == id) return t;
    }
    for (final t in TaskService.instance.historyTasks) {
      if (t.id == id) return t;
    }
    if (TaskService.instance.activeTask?.id == id) {
      return TaskService.instance.activeTask;
    }
    return null;
  }

  double? _liveDistanceMeters(ServiceTask? task, UserLocation? providerLoc) {
    if (providerLoc == null || !providerLoc.hasValidDeviceGps || task == null) {
      return null;
    }
    return GeoDistance.metersBetween(
      providerLoc.latitude,
      providerLoc.longitude,
      task.customerLatitude,
      task.customerLongitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;
    final task = _resolveTask();
    final userLoc = ref.watch(userLocationProvider).value ?? LocationService.lastKnownValidLocation;
    final providerGpsValid = userLoc != null && userLoc.hasValidDeviceGps;
    final distanceDisplay = GeoDistance.resolveProviderToCustomerLabel(
      providerLat: providerGpsValid ? userLoc.latitude : null,
      providerLng: providerGpsValid ? userLoc.longitude : null,
      providerGpsValid: providerGpsValid,
      customerLat: task?.customerLatitude,
      customerLng: task?.customerLongitude,
      isArabic: isArabic,
      fallbackLabel: isArabic ? widget.distanceAr : widget.distanceEn,
    );
    final liveMeters = _liveDistanceMeters(task, userLoc);
    final etaDisplay = liveMeters != null
        ? GeoDistance.formatEta(liveMeters, isArabic: isArabic)
        : _resolveEtaText(distanceDisplay, isArabic);

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

            final Widget screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Map Section Background (top 0 to ~ 515px)
                  Positioned(
                    top: 1.0,
                    left: 0.0,
                    width: containerWidth,
                    height: 520.0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 1a. Live Real Slippy Map Layer
                        Positioned.fill(
                          child: RealMapBackgroundWidget(
                            enableDrag: true,
                            zoom: 15.0,
                            trackingStep: MapTrackingStep.none,
                            showControls: false,
                          ),
                        ),

                        // 1b. Complete Screen Gradient Overlay Layer:
                        // background: linear-gradient(180deg, #FFFFFF 2.14%, rgba(255, 255, 255, 0.839534) 17.05%, rgba(255, 255, 255, 0) 26.93%);
                        Positioned.fill(
                          child: const IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: [0.0214, 0.1705, 0.2693, 1.0],
                                  colors: [
                                    Color(0xFFFFFFFF), // #FFFFFF 2.14%
                                    Color(0xD6FFFFFF), // rgba(255, 255, 255, 0.839534) 17.05%
                                    Color(0x00FFFFFF), // rgba(255, 255, 255, 0) 26.93%
                                    Color(0x00FFFFFF),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),


                        // 1i. Floating Location / GPS Re-Center Target Button:
                        Positioned(
                          top: 232.0,
                          right: 20.0 + ((containerWidth - 390.0) / 2.0),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
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

                  // 2. Header: Circular Chevron Back Button + Title + Language Toggle on Right
                  Positioned(
                    top: headerTop,
                    left: 20.0,
                    right: 20.0,
                    height: 38.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Circular Back Button `<`
                        ProviderHeaderBackButton(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).maybePop();
                          },
                        ),

                        const SizedBox(width: 12.0),

                        // Title: Request Details
                        Expanded(
                          child: Text(
                            isArabic ? 'تفاصيل الطلب' : 'Request Details',
                            style: isArabic
                                ? GoogleFonts.cairo(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1C2926),
                                    height: 1.2,
                                  )
                                : GoogleFonts.inter(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1C2926),
                                    height: 1.2,
                                  ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 8.0),

                        // Animated Language Toggle on right side of header
                        const ProviderAnimatedLanguageToggle.compact(),
                      ],
                    ),
                  ),

                  // 3. User-friendly Expandable & Scrollable Bottom Card
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    top: _isSheetExpanded
                        ? (topSafeArea > 0 ? (topSafeArea + 50.0) : 88.0)
                        : 291.0,
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
                            color: Color(0x14000000), // 0px -2px 12px 0px #00000014
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
                                  HapticFeedback.lightImpact();
                                  setState(() => _isSheetExpanded = true);
                                } else if (details.primaryVelocity! > 80) {
                                  HapticFeedback.lightImpact();
                                  setState(() => _isSheetExpanded = false);
                                }
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
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

                          // Complete Card Content Area (Scrollable with AlwaysScrollableScrollPhysics)
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
                                  bottomSafeArea > 0 ? (bottomSafeArea + 40.0) : 36.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 3a. Row 1: Service Image + Service Title + Client Name & Location
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          widget.imageAsset.isNotEmpty
                                              ? widget.imageAsset
                                              : 'assets/images/tow_truck.png',
                                          width: ProviderRequestSheetTypography.serviceThumb,
                                          height: ProviderRequestSheetTypography.serviceThumb,
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                          errorBuilder: (context, error, stackTrace) {
                                            return SizedBox(
                                              width: ProviderRequestSheetTypography.serviceThumb,
                                              height: ProviderRequestSheetTypography.serviceThumb,
                                              child: Icon(
                                                Icons.car_repair_rounded,
                                                color: const Color(0xFF8B53FE).withValues(alpha: 0.85),
                                                size: 30.0,
                                              ),
                                            );
                                          },
                                        ),

                                        const SizedBox(width: 14.0),

                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isArabic ? widget.serviceTypeAr : widget.serviceTypeEn,
                                                style: ProviderRequestSheetTypography.title(isArabic),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: ProviderRequestSheetTypography.labelGap),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      widget.customerName.trim().isNotEmpty
                                                          ? (isArabic
                                                              ? 'من ${widget.customerName.trim()}'
                                                              : 'From ${widget.customerName.trim()}')
                                                          : (isArabic ? 'عميل' : 'Customer'),
                                                      style: ProviderRequestSheetTypography.subtext(isArabic),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8.0),
                                                  Container(
                                                    width: 4.0,
                                                    height: 4.0,
                                                    decoration: const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xFF616166),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8.0),
                                                  Flexible(
                                                    child: Text(
                                                      _customerLocationLabel(isArabic),
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

                                    // 3b. Customer Location Card
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F2F5),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: ProviderRequestSheetTypography.iconBox,
                                            height: ProviderRequestSheetTypography.iconBox,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE7E6EB),
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.location_on_rounded,
                                                size: ProviderRequestSheetTypography.iconGlyph,
                                                color: const Color(0xFF252527),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12.0),
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  isArabic ? 'موقع العميل' : 'Customer Location',
                                                  style: ProviderRequestSheetTypography.label(isArabic),
                                                  maxLines: 2,
                                                  softWrap: true,
                                                  overflow: TextOverflow.clip,
                                                ),
                                                const SizedBox(height: ProviderRequestSheetTypography.labelGap),
                                                Text(
                                                  _customerLocationLabel(isArabic),
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
                                      distanceValue: distanceDisplay,
                                      etaValue: etaDisplay,
                                    ),

                                    const SizedBox(height: ProviderRequestSheetTypography.sectionGap),

                                    // 3d. Customer Card (100% Real Data — Zero Seed Fallbacks)
                                    Builder(
                                      builder: (context) {
                                        final realCustomerName = widget.customerName.trim().isNotEmpty
                                            ? widget.customerName.trim()
                                            : (isArabic ? 'عميل' : 'Customer');
                                        final realPhoto = _cleanPhoto(widget.customerPhotoUrl);
                                        final taskPhone = TaskService.instance
                                                .getTaskById(widget.requestId)
                                                ?.customerPhone
                                                .trim() ??
                                            '';
                                        final realPhone = (widget.customerPhone?.trim().isNotEmpty == true)
                                            ? widget.customerPhone!.trim()
                                            : taskPhone;
                                        final realVehicle = (isArabic ? widget.vehicleModelAr : widget.vehicleModelEn).trim();
                                        final showVehicle = !_isSeedVehicle(realVehicle);
                                        final realPlate = widget.plateNumber.trim();
                                        final showPlate = !_isSeedPlate(realPlate);

                                        return Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3F2F5),
                                            borderRadius: BorderRadius.circular(16.0),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  // Real Avatar or Purple Initials + Real Customer Name
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: ProviderRequestSheetTypography.avatar,
                                                          height: ProviderRequestSheetTypography.avatar,
                                                          decoration: const BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: Color(0xFF8B53FE),
                                                          ),
                                                          clipBehavior: Clip.antiAlias,
                                                          child: realPhoto != null
                                                              ? Image.network(
                                                                  realPhoto,
                                                                  width: ProviderRequestSheetTypography.avatar,
                                                                  height: ProviderRequestSheetTypography.avatar,
                                                                  fit: BoxFit.cover,
                                                                  errorBuilder: (_, _, _) => Center(
                                                                    child: Text(
                                                                      _initials(realCustomerName),
                                                                      style: GoogleFonts.inter(
                                                                        fontSize: ProviderRequestSheetTypography.valueMd,
                                                                        fontWeight: FontWeight.w700,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              : Center(
                                                                  child: Text(
                                                                    _initials(realCustomerName),
                                                                    style: GoogleFonts.inter(
                                                                      fontSize: ProviderRequestSheetTypography.valueMd,
                                                                      fontWeight: FontWeight.w700,
                                                                      color: Colors.white,
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
                                                                isArabic ? 'العميل' : 'Customer',
                                                                style: ProviderRequestSheetTypography.label(isArabic),
                                                              ),
                                                              const SizedBox(
                                                                  height: ProviderRequestSheetTypography.labelGap),
                                                              Text(
                                                                realCustomerName,
                                                                style: ProviderRequestSheetTypography.body(isArabic),
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  if (realPhone.isNotEmpty) ...[
                                                    const SizedBox(width: 8.0),
                                                    Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () async {
                                                            HapticFeedback.lightImpact();
                                                            await _trackProviderContact('whatsapp');
                                                            final ok = await ContactLauncher.whatsApp(realPhone);
                                                            if (!ok && context.mounted) {
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    isArabic ? 'تعذر فتح واتساب' : 'Could not open WhatsApp',
                                                                    style: GoogleFonts.inter(color: Colors.white),
                                                                  ),
                                                                  backgroundColor: const Color(0xFF1C2926),
                                                                  behavior: SnackBarBehavior.floating,
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          child: Container(
                                                            width: 38.0,
                                                            height: 38.0,
                                                            decoration: const BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: Color(0xFF25D366),
                                                            ),
                                                            child: const Center(
                                                              child: SizedBox(
                                                                width: 20.0,
                                                                height: 20.0,
                                                                child: CustomPaint(
                                                                  painter: _OfficialWhatsAppLogoPainter(),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 10.0),
                                                        GestureDetector(
                                                          onTap: () async {
                                                            HapticFeedback.lightImpact();
                                                            await _trackProviderContact('call');
                                                            final ok = await ContactLauncher.call(realPhone);
                                                            if (!ok && context.mounted) {
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    isArabic ? 'تعذر بدء الاتصال' : 'Could not start call',
                                                                    style: GoogleFonts.inter(color: Colors.white),
                                                                  ),
                                                                  backgroundColor: const Color(0xFF1C2926),
                                                                  behavior: SnackBarBehavior.floating,
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          child: Container(
                                                            width: 38.0,
                                                            height: 38.0,
                                                            decoration: const BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: Color(0xFF252527),
                                                            ),
                                                            child: const Center(
                                                              child: Icon(Icons.phone_rounded, size: 18.0, color: Colors.white),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),

                                              if (showVehicle || showPlate) ...[
                                                const SizedBox(height: 14.0),
                                                Row(
                                                  children: [
                                                    if (showVehicle) ...[
                                                      const Icon(Icons.directions_car_rounded, size: 18.0, color: Color(0xFF252527)),
                                                      const SizedBox(width: 8.0),
                                                      Flexible(
                                                        child: Text(
                                                          realVehicle,
                                                          style: isArabic
                                                              ? GoogleFonts.cairo(
                                                                  fontSize: 13.0,
                                                                  fontWeight: FontWeight.w500,
                                                                  color: const Color(0xFF252527),
                                                                )
                                                              : GoogleFonts.inter(
                                                                  fontSize: 13.0,
                                                                  fontWeight: FontWeight.w500,
                                                                  color: const Color(0xFF252527),
                                                                ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                    if (showVehicle && showPlate) ...[
                                                      const SizedBox(width: 12.0),
                                                      Container(width: 1.0, height: 14.0, color: const Color(0xFFE0DFE4)),
                                                      const SizedBox(width: 12.0),
                                                    ],
                                                    if (showPlate) ...[
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2.0),
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: const Color(0xFF9E9EA4), width: 1.0),
                                                          borderRadius: BorderRadius.circular(3.5),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Container(width: 1.0, height: 7.5, color: const Color(0xFF75757A)),
                                                            const SizedBox(width: 2.0),
                                                            Container(width: 1.0, height: 7.5, color: const Color(0xFF75757A)),
                                                            const SizedBox(width: 2.0),
                                                            Container(width: 1.0, height: 7.5, color: const Color(0xFF75757A)),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6.0),
                                                      Text(
                                                        realPlate,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.w500,
                                                          color: const Color(0xFF5E5E63),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        );
                                      },
                                    ),

                                    // 3e. Customer Note Card (only displayed when a real customer note exists)
                                    Builder(
                                      builder: (context) {
                                        final note = (isArabic ? widget.customerNoteAr : widget.customerNoteEn).trim();
                                        if (_isSeedNote(note)) return const SizedBox.shrink();
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: ProviderRequestSheetTypography.sectionGap),
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3F2F5),
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                const _CustomerNoteIcon(),
                                                const SizedBox(width: 11.0),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        isArabic ? 'ملاحظة العميل' : 'Customer Note',
                                                        style: ProviderRequestSheetTypography.label(isArabic),
                                                        maxLines: 2,
                                                        softWrap: true,
                                                        overflow: TextOverflow.clip,
                                                      ),
                                                      const SizedBox(
                                                          height: ProviderRequestSheetTypography.labelGap),
                                                      Text(
                                                        note,
                                                        style: ProviderRequestSheetTypography.subtext(isArabic),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    if (_showAcceptDeclineActions) ...[
                                      const SizedBox(height: 16.0),

                                      // 3f. Action Buttons: Decline & Accept Request (not for completed/cancelled)
                                      Row(
                                        children: [
                                          // Decline button
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                HapticFeedback.lightImpact();
                                                await ref
                                                    .read(backendServiceProvider)
                                                    .updateProviderRequestStatus(
                                                      requestId: widget.requestId,
                                                      status: 'cancelled',
                                                      step: 0,
                                                    )
                                                    .catchError((_) => false);
                                                await TaskService.instance
                                                    .cancelRequestById(widget.requestId);
                                                if (context.mounted) {
                                                  Navigator.of(context).maybePop(false);
                                                }
                                              },
                                              child: Container(
                                                height: 52.0,
                                                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFFEBEB),
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  isArabic ? 'رفض' : 'Decline',
                                                  style: isArabic
                                                      ? GoogleFonts.cairo(
                                                          fontSize: 14.0,
                                                          fontWeight: FontWeight.w500,
                                                          color: const Color(0xFFFF383C),
                                                          height: 1.2,
                                                          letterSpacing: 0.0,
                                                        )
                                                      : GoogleFonts.inter(
                                                          fontSize: 14.0,
                                                          fontWeight: FontWeight.w500,
                                                          color: const Color(0xFFFF383C),
                                                          height: 1.2,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 12.0),

                                          // Accept button -> syncs 'active' status to backend so customer updates live AND moves task to Active tab
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                HapticFeedback.mediumImpact();
                                                await ref
                                                    .read(backendServiceProvider)
                                                    .updateProviderRequestStatus(
                                                      requestId: widget.requestId,
                                                      status: 'active',
                                                      step: 1,
                                                    )
                                                    .catchError((_) => false);
                                                await TaskService.instance
                                                    .acceptRequestById(widget.requestId);
                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: const Color(0xFF8B53FE),
                                                    content: Text(
                                                      isArabic
                                                          ? 'تم قبول الطلب بنجاح!'
                                                          : 'Request Accepted Successfully!',
                                                      style: GoogleFonts.inter(color: Colors.white),
                                                    ),
                                                    duration: const Duration(seconds: 2),
                                                  ),
                                                );
                                                final custName = widget.customerName.trim().isNotEmpty
                                                    ? widget.customerName.trim()
                                                    : (TaskService.instance.activeTask?.customerName ?? 'Customer');
                                                final taskPhone = TaskService.instance
                                                        .getTaskById(widget.requestId)
                                                        ?.customerPhone
                                                        .trim() ??
                                                    '';
                                                final custPhone = (widget.customerPhone?.trim().isNotEmpty == true)
                                                    ? widget.customerPhone!.trim()
                                                    : taskPhone;
                                                Navigator.of(context).pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (_) => ProviderActiveRequestScreen(
                                                      requestId: widget.requestId,
                                                      serviceTypeEn: widget.serviceTypeEn,
                                                      serviceTypeAr: widget.serviceTypeAr,
                                                      locationEn: widget.locationEn,
                                                      locationAr: widget.locationAr,
                                                      distanceEn: widget.distanceEn,
                                                      distanceAr: widget.distanceAr,
                                                      timeEn: widget.timeEn,
                                                      timeAr: widget.timeAr,
                                                      customerNameEn: custName,
                                                      customerNameAr: custName,
                                                      customerPhone: custPhone.isNotEmpty ? custPhone : null,
                                                      imageAsset: widget.imageAsset,
                                                      customerPhotoUrl: widget.customerPhotoUrl,
                                                      customerNoteEn: widget.customerNoteEn,
                                                      customerNoteAr: widget.customerNoteAr,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: 52.0,
                                                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
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
                                                child: Text(
                                                  isArabic ? 'قبول الطلب' : 'Accept Request',
                                                  style: isArabic
                                                      ? GoogleFonts.cairo(
                                                          fontSize: 14.0,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.white,
                                                          height: 1.2,
                                                          letterSpacing: 0.0,
                                                        )
                                                      : GoogleFonts.inter(
                                                          fontSize: 14.0,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.white,
                                                          height: 1.2,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 16.0),
                                    ],

                                    if (!_showAcceptDeclineActions)
                                      const SizedBox(
                                          height: ProviderRequestSheetTypography.sectionGap),

                                    // 3g. Bottom Home Indicator Bar (with dynamic safe-area)
                                    const SizedBox(height: 12.0),
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
                                    SizedBox(height: bottomSafeArea > 0 ? 8.0 : 12.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Live Provider Notification Banner Overlay
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
}

/// Street route painter connecting pin to car matching user screenshot
class _StreetRoutePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _StreetRoutePainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // Starting at top under pin (x: 18, y: 0)
    path.moveTo(18.0, 0.0);
    // Going down along street
    path.lineTo(6.0, size.height * 0.52);
    // Curve corner smoothly
    path.quadraticBezierTo(2.0, size.height * 0.65, 16.0, size.height * 0.78);
    // Follow street down-right straight to the vehicle
    path.lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StreetRoutePainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}

/// Speech bubble tooltip painter with downward pointer
class _TooltipSpeechBubblePainter extends CustomPainter {
  final Color color;
  final double cornerRadius;
  final double pointerWidth;
  final double pointerHeight;
  final Color? shadowColor;

  const _TooltipSpeechBubblePainter({
    required this.color,
    this.cornerRadius = 6.0,
    this.pointerWidth = 8.0,
    this.pointerHeight = 6.0,
    this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bodyHeight = size.height - pointerHeight;
    final centerX = size.width / 2.0;

    final path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, bodyHeight),
        Radius.circular(cornerRadius),
      ),
    );

    // Downward pointer triangle
    path.moveTo(centerX - pointerWidth / 2.0, bodyHeight);
    path.lineTo(centerX, size.height);
    path.lineTo(centerX + pointerWidth / 2.0, bodyHeight);
    path.close();

    if (shadowColor != null) {
      canvas.drawShadow(path, shadowColor!, 4.0, true);
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TooltipSpeechBubblePainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Custom notepad/calendar icon with binder rings and cutouts matching user screenshot
class _CustomerNoteIcon extends StatelessWidget {
  const _CustomerNoteIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24.0,
      height: 26.0,
      child: CustomPaint(
        painter: _CustomerNoteIconPainter(),
      ),
    );
  }
}

class _CustomerNoteIconPainter extends CustomPainter {
  const _CustomerNoteIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bodyPaint = Paint()
      ..color = const Color(0xFF252527)
      ..style = PaintingStyle.fill;

    final Paint cutoutPaint = Paint()
      ..color = const Color(0xFFF3F2F5)
      ..style = PaintingStyle.fill;

    // Body: rounded rectangle starting at y = 4 to leave room for top binder rings
    final RRect bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 4.0, size.width, size.height - 4.0),
      const Radius.circular(6.0),
    );
    canvas.drawRRect(bodyRRect, bodyPaint);

    // Two binder rings on top
    final RRect ring1 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(4.5, 0.0, 3.5, 6.0),
      const Radius.circular(1.75),
    );
    final RRect ring2 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(16.0, 0.0, 3.5, 6.0),
      const Radius.circular(1.75),
    );
    canvas.drawRRect(ring1, bodyPaint);
    canvas.drawRRect(ring2, bodyPaint);

    // Two horizontal cutouts inside notepad body
    // Top shorter slit
    final RRect line1 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(5.0, 10.5, 8.5, 2.2),
      const Radius.circular(1.1),
    );
    // Bottom longer slit
    final RRect line2 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(5.0, 15.5, 14.0, 2.2),
      const Radius.circular(1.1),
    );
    canvas.drawRRect(line1, cutoutPaint);
    canvas.drawRRect(line2, cutoutPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Real Official WhatsApp Vector Logo Painter
class _OfficialWhatsAppLogoPainter extends CustomPainter {
  const _OfficialWhatsAppLogoPainter();

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


