import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/localization/app_locale.dart';
import '../../../providers/backend_provider.dart';
import '../../../providers/notifications_provider.dart';
import '../../../services/location_service.dart';
import '../../../services/task_service.dart';
import '../../home/presentation/widgets/bottom_nav_bar_widget.dart';
import '../../home/presentation/widgets/notification_bell_button.dart';
import '../../home/presentation/widgets/notification_popup_card.dart';
import '../../location/presentation/live_tracking_screen.dart';
import '../../location/presentation/widgets/real_map_background_widget.dart';
import '../../profile/presentation/notifications_screen.dart';
import '../../location/presentation/completed_service_details_screen.dart';

/// Requests Tab screen with branding header layout.
/// Hosts the request management view and floating bottom navigation bar.
class RequestsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNotificationTap;
  final ValueChanged<int>? onTabSelected;
  final bool showBottomNav;

  const RequestsScreen({
    super.key,
    this.onNotificationTap,
    this.onTabSelected,
    this.showBottomNav = true,
  });

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> {
  ScrollController? _scrollControllerInstance;
  ScrollController get _scrollController =>
      _scrollControllerInstance ??= ScrollController();

  TextEditingController? _searchControllerInstance;
  TextEditingController get _searchController =>
      _searchControllerInstance ??= TextEditingController();

  int? _selectedFilterIndex = 0; // 0: Active, 1: History
  int get _activeFilterIndex => _selectedFilterIndex ?? 0;

  late AppTranslations _tr;
  AppTranslations get tr => _tr;
  Timer? _statusSyncTimer;

  void _onTasksChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollControllerInstance ??= ScrollController();
    _searchControllerInstance ??= TextEditingController();
    TaskService.instance.activeTaskNotifier.addListener(_onTasksChanged);
    TaskService.instance.historyNotifier.addListener(_onTasksChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncCustomerRequestStatus());
    _statusSyncTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _syncCustomerRequestStatus();
    });
  }

  String? _cleanPhotoUrl(String? raw) {
    final v = raw?.trim() ?? '';
    if (v.isEmpty) return null;
    if (v.contains('unsplash.com') || v.contains('placeholder')) return null;
    return v;
  }

  String _providerInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'Z';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return parts[0].substring(0, 1).toUpperCase() + parts[1].substring(0, 1).toUpperCase();
  }

  double? _computeLiveDistanceMeters(ServiceTask task, UserLocation? userLoc) {
    final pLat = task.providerLatitude;
    final pLng = task.providerLongitude;
    final hasProv = pLat != null &&
        pLng != null &&
        pLat.isFinite &&
        pLng.isFinite &&
        (pLat.abs() > 0.001 || pLng.abs() > 0.001);
    if (userLoc != null && userLoc.hasValidDeviceGps && hasProv) {
      final m = Geolocator.distanceBetween(userLoc.latitude, userLoc.longitude, pLat, pLng);
      if (m.isFinite && m >= 0) return m;
    }
    return null;
  }

  String _formatDistance(double meters, bool isArabic) {
    if (meters < 1000.0) {
      return isArabic ? '${meters.round()} م' : '${meters.round()} m';
    }
    return isArabic
        ? '${(meters / 1000.0).toStringAsFixed(1)} كم'
        : '${(meters / 1000.0).toStringAsFixed(1)} km';
  }

  String _formatEta(double meters, bool isArabic) {
    if (meters < 100.0) return isArabic ? 'أقل من دقيقة' : '< 1 min';
    final mins = ((meters / 1000.0) / 30.0 * 60.0).ceil().clamp(1, 180);
    return isArabic ? '$mins د' : '$mins min';
  }

  Future<void> _syncCustomerRequestStatus() async {
    if (!mounted) return;
    final task = TaskService.instance.activeTask;
    final reqId = TaskService.extractBackendUuid(task?.id);
    if (task == null || reqId == null) return;

    final data = await ref.read(backendServiceProvider).getCustomerRequestStatus(reqId);
    if (!mounted || data == null) return;

    final pLat = (data['providerLatitude'] as num?)?.toDouble();
    final pLng = (data['providerLongitude'] as num?)?.toDouble();
    final ratingAvg = (data['providerRatingAvg'] as num?)?.toDouble();
    final ordersCount = (data['providerOrdersCount'] as num?)?.toInt() ?? 0;
    final vehicleType = data['providerVehicleType']?.toString().trim() ?? '';
    final vehicleModel = data['providerVehicleModel']?.toString().trim() ?? '';
    final plateNum = data['providerPlateNumber']?.toString().trim() ?? '';
    final photoUrl = _cleanPhotoUrl(data['providerPhotoUrl']?.toString());
    final resolvedVehicle = vehicleType.isNotEmpty ? vehicleType : vehicleModel;

    await TaskService.instance.updateActiveTaskProviderDetails(
      providerPublicId: data['providerPublicId']?.toString(),
      providerName: data['providerName']?.toString(),
      providerPhone: data['providerPhone']?.toString(),
      providerAvatar: photoUrl,
      providerRating: ratingAvg,
      providerTripsCount: ordersCount,
      providerLatitude: (pLat != null && pLat.abs() > 0.001) ? pLat : null,
      providerLongitude: (pLng != null && pLng.abs() > 0.001) ? pLng : null,
      serviceCategory: data['serviceCategory']?.toString(),
      vehicleName: resolvedVehicle,
      plateNumber: plateNum,
    );

    if (!mounted) return;
    final status = (data['status']?.toString() ?? task.status).toLowerCase();
    final cancelledBy = data['cancelledBy']?.toString();
    final step = (data['step'] is num)
        ? (data['step'] as num).toInt()
        : int.tryParse(data['step']?.toString() ?? '') ?? task.step;

    if (status != task.status || step != task.step) {
      if (status == 'completed') {
        await TaskService.instance.updateTaskStatus(status: 'completed', step: 4);
        await TaskService.instance.completeTask();
      } else if (status == 'cancelled') {
        await TaskService.instance.cancelTask();
      } else {
        await TaskService.instance.updateTaskStatus(status: status, step: step);
      }
      if (!mounted) return;
      ref.read(notificationsProvider.notifier).notifyCustomerRequestStatusChange(
            requestId: reqId,
            status: status,
            providerName: task.providerName,
            serviceCategory: task.serviceCategory,
            distance: task.distance,
            photoUrl: photoUrl ?? task.providerAvatar,
            cancelledBy: cancelledBy,
          );
    }
  }

  @override
  void dispose() {
    _statusSyncTimer?.cancel();
    TaskService.instance.activeTaskNotifier.removeListener(_onTasksChanged);
    TaskService.instance.historyNotifier.removeListener(_onTasksChanged);
    _scrollControllerInstance?.dispose();
    _searchControllerInstance?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tr = ref.watch(translationsProvider);
    final tr = _tr;
    final notifState = ref.watch(notificationsProvider);

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
            final mediaQuery = MediaQuery.of(context);
            final screenWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : mediaQuery.size.width;
            final screenHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : mediaQuery.size.height;

            // Desktop framing simulates mobile view (390 x 844)
            final bool isDesktopWeb = screenWidth > 500;
            final double containerWidth = isDesktopWeb ? 390.0 : screenWidth;
            final double containerHeight = isDesktopWeb
                ? math.min(844.0, (screenHeight - 32.0).clamp(520.0, 844.0))
                : screenHeight;
            final double horizontalPadding = containerWidth < 360 ? 16.0 : 20.0;

            final double topSafeArea = mediaQuery.padding.top;
            final double headerTopPadding = isDesktopWeb
                ? 44.0
                : (topSafeArea > 0 ? topSafeArea + 12.0 : 48.0);
            final double bottomNavClearance = isDesktopWeb
                ? 104.0
                : (mediaQuery.padding.bottom + 112.0);

            final activeTask = TaskService.instance.activeTask;
            final streamLoc = ref.watch(userLocationProvider).value;
            final activeLoc = (streamLoc != null && streamLoc.hasValidDeviceGps)
                ? streamLoc
                : LocationService.lastKnownValidLocation;
            final double? liveMeters =
                activeTask != null ? _computeLiveDistanceMeters(activeTask, activeLoc) : null;
            final String liveDistance = liveMeters != null
                ? _formatDistance(liveMeters, tr.isArabic)
                : (activeTask?.distance ?? '--');
            final String liveEta = liveMeters != null
                ? _formatEta(liveMeters, tr.isArabic)
                : (activeTask?.eta ?? '--');

            final Widget screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Fixed Header + Active/History Tabs, Scrollable Remaining Content
                  Positioned.fill(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // FIXED TOP SECTION: Header + Active / History Tabs
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            headerTopPadding,
                            horizontalPadding,
                            12.0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 1. Fixed Header Layout
                              SizedBox(
                                height: 40.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            tr.requestsTitle,
                                            style: tr.font(
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
                                            tr.requestsSubtitle,
                                            style: tr.font(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF566663),
                                              height: 1.2,
                                              letterSpacing: 0.0,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    NotificationBellButton(
                                      key: const Key('requests_header_notification_button'),
                                      hasNotification: notifState.hasCustomerUnread,
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        if (widget.onNotificationTap != null) {
                                          widget.onNotificationTap!();
                                        } else {
                                          if (notifState.customerNotification != null) {
                                            ref.read(notificationsProvider.notifier).toggleCustomerCard();
                                          } else {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => const NotificationsScreen(),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16.0),

                              // 2. Fixed Active & History Tabs Row
                              SizedBox(
                                height: 52.0,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 180),
                                          curve: Curves.easeInOut,
                                          height: 52.0,
                                          decoration: BoxDecoration(
                                            color: _activeFilterIndex == 0
                                                ? const Color(0xFF8B53FE)
                                                : const Color(0xFF2D2A3D),
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(12.0),
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(12.0),
                                              splashColor: (_activeFilterIndex == 0
                                                      ? Colors.white
                                                      : const Color(0xFF8B53FE))
                                                  .withValues(alpha: 0.18),
                                              highlightColor: (_activeFilterIndex == 0
                                                      ? Colors.white
                                                      : const Color(0xFF8B53FE))
                                                  .withValues(alpha: 0.08),
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                setState(() {
                                                  _selectedFilterIndex = 0;
                                                });
                                              },
                                              child: Center(
                                                child: Text(
                                                  tr.activeFilter,
                                                  style: tr.font(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(0xFFFFFFFF),
                                                    height: 1.15,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 180),
                                          curve: Curves.easeInOut,
                                          height: 52.0,
                                          decoration: BoxDecoration(
                                            color: _activeFilterIndex == 1
                                                ? const Color(0xFF8B53FE)
                                                : const Color(0xFF2D2A3D),
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(12.0),
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(12.0),
                                              splashColor: (_activeFilterIndex == 1
                                                      ? Colors.white
                                                      : const Color(0xFF8B53FE))
                                                  .withValues(alpha: 0.18),
                                              highlightColor: (_activeFilterIndex == 1
                                                      ? Colors.white
                                                      : const Color(0xFF8B53FE))
                                                  .withValues(alpha: 0.08),
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                setState(() {
                                                  _selectedFilterIndex = 1;
                                                });
                                              },
                                              child: Center(
                                                child: Text(
                                                  tr.historyFilter,
                                                  style: tr.font(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(0xFFFFFFFF),
                                                    height: 1.15,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // SCROLLABLE REMAINING CONTENT
                        Expanded(
                          child: Listener(
                            behavior: HitTestBehavior.translucent,
                            onPointerSignal: (pointerSignal) {
                              if (pointerSignal is PointerScrollEvent && _scrollController.hasClients) {
                                final double target = (_scrollController.offset + pointerSignal.scrollDelta.dy)
                                    .clamp(0.0, _scrollController.position.maxScrollExtent);
                                _scrollController.jumpTo(target);
                              }
                            },
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(
                                scrollbars: false,
                                dragDevices: {
                                  PointerDeviceKind.touch,
                                  PointerDeviceKind.mouse,
                                  PointerDeviceKind.trackpad,
                                  PointerDeviceKind.stylus,
                                  PointerDeviceKind.invertedStylus,
                                  PointerDeviceKind.unknown,
                                },
                              ),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                physics: const ClampingScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  4.0,
                                  horizontalPadding,
                                  bottomNavClearance,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // ACTIVE TAB CONTENT
                                    if (_activeFilterIndex == 0 && activeTask == null)
                                      _buildEmptyActiveState(containerWidth, horizontalPadding),

                                    if (_activeFilterIndex == 0 && activeTask != null) ...[
                                      // 3. Active Request Map + Real Provider Card
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.circular(16.0),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x1A000000),
                                              blurRadius: 12.0,
                                              offset: Offset(0, 1),
                                              spreadRadius: 0.0,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            // Card Status Header
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 12.0),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 32.0,
                                                    height: 32.0,
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFFF0EAFE),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Container(
                                                        width: 20.0,
                                                        height: 20.0,
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFFFFFFF),
                                                          shape: BoxShape.circle,
                                                          border: Border.all(
                                                            color: const Color(0xFF8B53FE),
                                                            width: 5.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 14.0),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          _getActiveStatusTitle(activeTask.step, tr, status: activeTask.status),
                                                          style: tr.font(
                                                            fontSize: 14.0,
                                                            fontWeight: FontWeight.w600,
                                                            color: const Color(0xFF1C2926),
                                                            height: 1.15,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(height: 2.0),
                                                        Text(
                                                          _getActiveStatusSubtitle(activeTask.step, tr, status: activeTask.status),
                                                          style: tr.font(
                                                            fontSize: 12.0,
                                                            fontWeight: FontWeight.w400,
                                                            color: const Color(0xFF566663),
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

                                            // Cleanly Aligned Embedded Live Map (padded & bordered inside card)
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              child: Container(
                                                height: 184.0,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(14.0),
                                                  border: Border.all(
                                                    color: const Color(0xFFE6EAE8),
                                                    width: 1.0,
                                                  ),
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: RealMapBackgroundWidget(
                                                        enableDrag: true,
                                                        zoom: 15.0,
                                                        borderRadius: BorderRadius.circular(14.0),
                                                        providerLatitude: activeTask.providerLatitude,
                                                        providerLongitude: activeTask.providerLongitude,
                                                        trackingStep: activeTask.step == 1
                                                            ? MapTrackingStep.onTheWay
                                                            : (activeTask.step >= 2
                                                                ? MapTrackingStep.arrived
                                                                : MapTrackingStep.requestSent),
                                                        driverName: activeTask.providerName,
                                                        serviceCategory: activeTask.serviceCategory,
                                                        vehicleName: activeTask.vehicleName.isNotEmpty
                                                            ? activeTask.vehicleName
                                                            : activeTask.serviceCategory,
                                                        etaText: liveEta,
                                                        distanceText: liveDistance,
                                                        showControls: false,
                                                      ),
                                                    ),
                                                    // Clean aligned Full View pill at top-right
                                                    Positioned(
                                                      top: 10.0,
                                                      right: 10.0,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          HapticFeedback.lightImpact();
                                                          Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                              builder: (_) => LiveTrackingScreen(
                                                                requestId: TaskService.extractBackendUuid(activeTask.id),
                                                                serviceCategory: activeTask.serviceCategory,
                                                                providerName: activeTask.providerName,
                                                                vehicleName: activeTask.vehicleName.isNotEmpty
                                                                    ? activeTask.vehicleName
                                                                    : activeTask.serviceCategory,
                                                                photoUrl: _cleanPhotoUrl(activeTask.providerAvatar),
                                                                providerLatitude: activeTask.providerLatitude,
                                                                providerLongitude: activeTask.providerLongitude,
                                                                distance: liveDistance,
                                                                duration: liveEta,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 10.0,
                                                            vertical: 6.0,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white.withValues(alpha: 0.96),
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
                                                              const SizedBox(width: 5.0),
                                                              Text(
                                                                tr.isArabic ? 'شاشة كاملة' : 'Full View',
                                                                style: tr.font(
                                                                  fontSize: 10.5,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: const Color(0xFF1C2926),
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

                                            // Real Service Provider Summary Row (NO '>' icon, 100% real data)
                                            Builder(
                                              builder: (context) {
                                                final realPhoto = _cleanPhotoUrl(activeTask.providerAvatar);
                                                final realCategory = tr.categoryName(activeTask.serviceCategory);
                                                final rawVehicle = activeTask.vehicleName.trim();
                                                final bool showVehicle = rawVehicle.isNotEmpty &&
                                                    rawVehicle.toLowerCase() != 'service vehicle';
                                                final rawPlate = activeTask.plateNumber.trim();
                                                final bool showPlate = rawPlate.isNotEmpty && rawPlate != '1122';
                                                final ratingText = activeTask.providerRating.toStringAsFixed(1);
                                                final tripsCount = activeTask.providerTripsCount;
                                                final showTrips = tripsCount > 0;
                                                final tripsLabel = tr.isArabic
                                                    ? '($tripsCount ${tripsCount == 1 ? 'رحلة' : 'رحلات'})'
                                                    : '($tripsCount ${tripsCount == 1 ? 'trip' : 'trips'})';

                                                return Padding(
                                                  padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 16.0),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      // Real provider photo or purple initials circle
                                                      Container(
                                                        width: 48.0,
                                                        height: 48.0,
                                                        decoration: const BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Color(0xFF8B53FE),
                                                        ),
                                                        clipBehavior: Clip.antiAlias,
                                                        child: realPhoto != null
                                                            ? Image.network(
                                                                realPhoto,
                                                                width: 48.0,
                                                                height: 48.0,
                                                                fit: BoxFit.cover,
                                                                errorBuilder: (_, _, _) => Center(
                                                                  child: Text(
                                                                    _providerInitials(activeTask.providerName),
                                                                    style: tr.font(
                                                                      fontSize: 16.0,
                                                                      fontWeight: FontWeight.w700,
                                                                      color: Colors.white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : Center(
                                                                child: Text(
                                                                  _providerInitials(activeTask.providerName),
                                                                  style: tr.font(
                                                                    fontSize: 16.0,
                                                                    fontWeight: FontWeight.w700,
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                              ),
                                                      ),
                                                      const SizedBox(width: 14.0),

                                                      // Real Provider Details Column
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            // 1. Real Provider Name (full, no ellipsis cut)
                                                            Text(
                                                              tr.formatProviderName(activeTask.providerName),
                                                              style: tr.font(
                                                                fontSize: 14.0,
                                                                fontWeight: FontWeight.w600,
                                                                color: const Color(0xFF1C2926),
                                                                height: 1.2,
                                                              ),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            const SizedBox(height: 4.0),

                                                            // 2. Real Rating & Trips Counter
                                                            Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                const Icon(
                                                                  Icons.star_rounded,
                                                                  size: 13.0,
                                                                  color: Color(0xFF8B53FE),
                                                                ),
                                                                const SizedBox(width: 4.0),
                                                                Text.rich(
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text: showTrips ? '$ratingText ' : ratingText,
                                                                        style: tr.font(
                                                                          fontSize: 11.5,
                                                                          fontWeight: FontWeight.w500,
                                                                          color: const Color(0xFF1C2926),
                                                                          height: 1.15,
                                                                        ),
                                                                      ),
                                                                      if (showTrips)
                                                                        TextSpan(
                                                                          text: tripsLabel,
                                                                          style: tr.font(
                                                                            fontSize: 11.0,
                                                                            fontWeight: FontWeight.w400,
                                                                            color: const Color(0xFF566663),
                                                                            height: 1.15,
                                                                          ),
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 4.0),

                                                            // 3. Real Service Category
                                                            Text(
                                                              realCategory,
                                                              style: tr.font(
                                                                fontSize: 11.5,
                                                                fontWeight: FontWeight.w500,
                                                                color: const Color(0xFF566663),
                                                                height: 1.2,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),

                                                            // 4. Real Vehicle Type & Plate (only when real data exists)
                                                            if (showVehicle || showPlate) ...[
                                                              const SizedBox(height: 4.0),
                                                              Wrap(
                                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                                spacing: 6.0,
                                                                runSpacing: 4.0,
                                                                children: [
                                                                  if (showVehicle)
                                                                    Row(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        const Icon(
                                                                          Icons.directions_car_filled_rounded,
                                                                          size: 12.0,
                                                                          color: Color(0xFF1C2926),
                                                                        ),
                                                                        const SizedBox(width: 4.0),
                                                                        Text(
                                                                          tr.formatVehicleName(rawVehicle),
                                                                          style: tr.font(
                                                                            fontSize: 11.0,
                                                                            fontWeight: FontWeight.w500,
                                                                            color: const Color(0xFF1C2926),
                                                                            height: 1.15,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  if (showVehicle && showPlate)
                                                                    Container(
                                                                      width: 1.0,
                                                                      height: 10.0,
                                                                      color: const Color(0xFFE5E7EB),
                                                                    ),
                                                                  if (showPlate)
                                                                    Row(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        Container(
                                                                          width: 12.0,
                                                                          height: 12.0,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(2.5),
                                                                            border: Border.all(
                                                                              color: const Color(0xFF566663),
                                                                              width: 0.9,
                                                                            ),
                                                                          ),
                                                                          alignment: Alignment.center,
                                                                          child: Text(
                                                                            '#',
                                                                            style: tr.font(
                                                                              fontSize: 7.5,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: const Color(0xFF566663),
                                                                              height: 1.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(width: 4.0),
                                                                        Text(
                                                                          rawPlate,
                                                                          style: tr.font(
                                                                            fontSize: 11.0,
                                                                            fontWeight: FontWeight.w500,
                                                                            color: const Color(0xFF566663),
                                                                            height: 1.15,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                ],
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 12.0),

                                      // 4. Status Progress Stepper Card
                                      Container(
                                        height: 88.0,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF2F5F4),
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Positioned(
                                              top: 25.5,
                                              left: 48.0,
                                              right: 48.0,
                                              height: 1.0,
                                              child: Container(
                                                color: const Color(0xFFEAEBE8),
                                              ),
                                            ),
                                            Positioned.fill(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 17.0),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: _buildStepperItem(
                                                        title: tr.requestSent,
                                                        time: activeTask.dateTime.contains(',')
                                                            ? activeTask.dateTime.split(',').last.trim()
                                                            : activeTask.dateTime,
                                                        state: _RequestStepState.completed,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: _buildStepperItem(
                                                        title: tr.accepted,
                                                        time: null,
                                                        state: activeTask.step >= 1
                                                            ? _RequestStepState.completed
                                                            : (activeTask.step == 0
                                                                ? _RequestStepState.active
                                                                : _RequestStepState.pending),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: _buildStepperItem(
                                                        title: tr.onTheWay,
                                                        time: null,
                                                        state: activeTask.step > 1
                                                            ? _RequestStepState.completed
                                                            : (activeTask.step == 1
                                                                ? _RequestStepState.active
                                                                : _RequestStepState.pending),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: _buildStepperItem(
                                                        title: tr.arrived,
                                                        time: null,
                                                        state: activeTask.step > 2
                                                            ? _RequestStepState.completed
                                                            : (activeTask.step == 2
                                                                ? _RequestStepState.active
                                                                : _RequestStepState.pending),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: _buildStepperItem(
                                                        title: tr.completed,
                                                        time: null,
                                                        state: activeTask.step >= 4
                                                            ? _RequestStepState.completed
                                                            : (activeTask.step == 3
                                                                ? _RequestStepState.active
                                                                : _RequestStepState.pending),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 12.0),

                                      // 5. Metric cards row: Real Distance Away & Estimated Time
                                      SizedBox(
                                        height: 64.0,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 64.0,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 12.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF2F5F4),
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
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
                                                    const SizedBox(width: 12.0),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          FittedBox(
                                                            fit: BoxFit.scaleDown,
                                                            alignment: AlignmentDirectional.centerStart,
                                                            child: Text(
                                                              liveDistance,
                                                              style: tr.font(
                                                                fontSize: 14.0,
                                                                fontWeight: FontWeight.w500,
                                                                color: const Color(0xFF1C2926),
                                                                height: 1.1,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(height: 2.0),
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
                                            const SizedBox(width: 12.0),
                                            Expanded(
                                              child: Container(
                                                height: 64.0,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 12.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF2F5F4),
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 32.0,
                                                      height: 32.0,
                                                      decoration: const BoxDecoration(
                                                        color: Color(0xFFF0EAFE),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Center(
                                                        child: CustomPaint(
                                                          size: Size(20.0, 20.0),
                                                          painter: _ClockIconPainter(
                                                            backgroundColor: Color(0xFF8B53FE),
                                                            handColor: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12.0),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          FittedBox(
                                                            fit: BoxFit.scaleDown,
                                                            alignment: AlignmentDirectional.centerStart,
                                                            child: Text(
                                                              liveEta,
                                                              style: tr.font(
                                                                fontSize: 14.0,
                                                                fontWeight: FontWeight.w500,
                                                                color: const Color(0xFF1C2926),
                                                                height: 1.1,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(height: 2.0),
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
                                      ),

                                      // 6. Action Button: Cancel Request (before arrival/completion)
                                      if (activeTask.step < 3) ...[
                                        const SizedBox(height: 14.0),
                                        SizedBox(
                                          height: 48.0,
                                          child: OutlinedButton.icon(
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: Text(tr.isArabic ? 'إلغاء الطلب' : 'Cancel Request'),
                                                  content: Text(
                                                    tr.isArabic
                                                        ? 'هل أنت متأكد من رغبتك في إلغاء هذا الطلب؟'
                                                        : 'Are you sure you want to cancel this request?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(ctx).pop(false),
                                                      child: Text(tr.isArabic ? 'تراجع' : 'No, Keep'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => Navigator.of(ctx).pop(true),
                                                      child: Text(
                                                        tr.isArabic ? 'نعم، إلغاء' : 'Yes, Cancel',
                                                        style: const TextStyle(color: Color(0xFFDC2626)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                final reqId = TaskService.extractBackendUuid(
                                                  TaskService.instance.activeTask?.id,
                                                );
                                                if (reqId != null && reqId.isNotEmpty) {
                                                  await ref
                                                      .read(backendServiceProvider)
                                                      .cancelCustomerRequest(reqId)
                                                      .catchError((_) => false);
                                                }
                                                await TaskService.instance.cancelTask();
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      backgroundColor: const Color(0xFF1C2926),
                                                      content: Text(
                                                        tr.isArabic ? 'تم إلغاء الطلب' : 'Request cancelled successfully',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            icon: const Icon(Icons.close_rounded, size: 18.0, color: Color(0xFFDC2626)),
                                            label: Text(
                                              tr.isArabic ? 'إلغاء الطلب' : 'Cancel Request',
                                              style: tr.font(
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFFDC2626),
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(color: Color(0xFFFFD1D1)),
                                              backgroundColor: const Color(0xFFFFF5F5),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],

                                    // HISTORY TAB LAYOUT (_activeFilterIndex == 1)
                                    if (_activeFilterIndex == 1) ...[
                                      SizedBox(
                                        height: 49.88,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 49.88,
                                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFFFFFF),
                                                  borderRadius: BorderRadius.circular(40.0),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color(0x1A000000),
                                                      blurRadius: 12.0,
                                                      offset: Offset(0, 1),
                                                      spreadRadius: 0.0,
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.search_rounded,
                                                      size: 20.0,
                                                      color: Color(0xFF1C2926),
                                                    ),
                                                    const SizedBox(width: 10.0),
                                                    Expanded(
                                                      child: TextField(
                                                        controller: _searchController,
                                                        onChanged: (val) {
                                                          setState(() {});
                                                        },
                                                        cursorColor: const Color(0xFF8B53FE),
                                                        style: tr.font(
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.w400,
                                                          color: const Color(0xFF1C2926),
                                                          height: 1.2,
                                                        ),
                                                        decoration: InputDecoration(
                                                          hintText: tr.searchRequests,
                                                          hintStyle: tr.font(
                                                            fontSize: 12.0,
                                                            fontWeight: FontWeight.w400,
                                                            color: const Color(0xFF566663),
                                                            height: 1.2,
                                                          ),
                                                          suffixIcon: _searchController.text.isNotEmpty
                                                              ? MouseRegion(
                                                                  cursor: SystemMouseCursors.click,
                                                                  child: GestureDetector(
                                                                    onTap: () {
                                                                      _searchController.clear();
                                                                      setState(() {});
                                                                    },
                                                                    child: const Icon(
                                                                      Icons.close_rounded,
                                                                      size: 16.0,
                                                                      color: Color(0xFF566663),
                                                                    ),
                                                                  ),
                                                                )
                                                              : null,
                                                          border: InputBorder.none,
                                                          isDense: true,
                                                          contentPadding: EdgeInsets.zero,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16.0),
                                            Material(
                                              color: Colors.transparent,
                                              shape: const CircleBorder(),
                                              child: InkWell(
                                                onTap: () {
                                                  HapticFeedback.lightImpact();
                                                },
                                                customBorder: const CircleBorder(),
                                                child: Container(
                                                  width: 49.88,
                                                  height: 49.88,
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFFFFFFFF),
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color(0x0F000000),
                                                        blurRadius: 8.0,
                                                        offset: Offset(0, 1),
                                                        spreadRadius: 0.0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Center(
                                                    child: CustomPaint(
                                                      size: Size(23.82, 14.29),
                                                      painter: _FilterLinesPainter(
                                                        color: Color(0xFF1C2926),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16.0),
                                      Column(
                                        children: [
                                          for (int i = 0; i < _filteredHistoryItems.length; i++) ...[
                                            if (i > 0) const SizedBox(height: 12.0),
                                            _buildHistoryCard(
                                              _filteredHistoryItems[i],
                                              containerWidth,
                                            ),
                                          ],
                                          if (_filteredHistoryItems.isEmpty)
                                            _buildEmptyHistoryState(containerWidth),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Floating Bottom Navigation Bar (Request tab active: index 1)
                  if (widget.showBottomNav)
                    Positioned(
                      left: (containerWidth - 292.0) / 2,
                      width: 292.0,
                      bottom: isDesktopWeb
                          ? 16.0
                          : (MediaQuery.of(context).padding.bottom + 12.0),
                      child: BottomNavBarWidget(
                        currentIndex: 1,
                        initialIndex: 1,
                        onTabSelected: (index) {
                          if (widget.onTabSelected != null) {
                            widget.onTabSelected!(index);
                          } else {
                            if (index == 0) {
                              Navigator.of(context).pushReplacementNamed('/home');
                            } else if (index == 2) {
                              Navigator.of(context).pushReplacementNamed('/profile');
                            }
                          }
                        },
                      ),
                    ),

                  // Notification Card Overlay after clicking bell icon (below header — bell stays visible)
                  if (notifState.isCustomerCardVisible &&
                      notifState.customerNotification != null) ...[
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          ref
                              .read(notificationsProvider.notifier)
                              .hideCustomerCard();
                        },
                        child: const ColoredBox(color: Colors.transparent),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 118.0,
                      left: horizontalPadding,
                      right: horizontalPadding,
                      child: NotificationPopupCard(
                        badgeText: tr.isArabic
                            ? (notifState.customerNotification?.badgeTextAr ?? '')
                            : (notifState.customerNotification?.badgeTextEn ?? ''),
                        title: tr.isArabic
                            ? (notifState.customerNotification?.titleAr ?? '')
                            : (notifState.customerNotification?.titleEn ?? ''),
                        location: tr.isArabic
                            ? (notifState.customerNotification?.locationAr ?? '')
                            : (notifState.customerNotification?.locationEn ?? ''),
                        distance: tr.isArabic
                            ? (notifState.customerNotification?.distanceAr ?? '')
                            : (notifState.customerNotification?.distanceEn ?? ''),
                        time: tr.isArabic
                            ? (notifState.customerNotification?.timeAr ?? '')
                            : (notifState.customerNotification?.timeEn ?? ''),
                        createdAt: notifState.customerNotification?.createdAt,
                        imageAsset: notifState.customerNotification?.imageAsset,
                        onTap: () {
                          ref.read(notificationsProvider.notifier).hideCustomerCard();
                          final task = TaskService.instance.activeTask;
                          if (task != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LiveTrackingScreen(
                                  serviceCategory: task.serviceCategory,
                                  providerName: task.providerName,
                                  distance: task.distance,
                                  duration: task.eta,
                                ),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            );
                          }
                        },
                        onDismiss: () {
                          ref
                              .read(notificationsProvider.notifier)
                              .dismissCustomerNotification();
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );

            if (isDesktopWeb) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFF0F1F5), // Clean modern outer backdrop matching home tab
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerSignal: (pointerSignal) {
                    if (pointerSignal is PointerScrollEvent && _scrollController.hasClients) {
                      final double target = (_scrollController.offset + pointerSignal.scrollDelta.dy)
                          .clamp(0.0, _scrollController.position.maxScrollExtent);
                      _scrollController.jumpTo(target);
                    }
                  },
                  child: Center(
                    child: Container(
                      width: containerWidth,
                      height: containerHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(42),
                        border: Border.all(
                          color: const Color(0xFF8B53FE).withValues(alpha: 0.25),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B53FE).withValues(alpha: 0.12),
                            blurRadius: 40,
                            spreadRadius: 6,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: screenContent,
                    ),
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

  Widget _buildStepperItem({
    required String title,
    String? time,
    required _RequestStepState state,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12.0), // top: 12px;
        SizedBox(
          height: 20.0,
          child: Center(
            child: _buildStepIcon(state),
          ),
        ),
        const SizedBox(height: 6.0), // gap: 6px to text row
        SizedBox(
          width: 64.0,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: tr.font(
                fontSize: 10.0,
                fontWeight: FontWeight.w500,
                color: state == _RequestStepState.pending
                    ? const Color(0xFF566663)
                    : const Color(0xFF8B53FE),
                height: 1.15,
                letterSpacing: 0.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
        if (time != null) ...[
          const SizedBox(height: 2.0),
          SizedBox(
            width: 64.0,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                time,
                textAlign: TextAlign.center,
                style: tr.font(
                  fontSize: 8.0,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF566663),
                  height: 1.15,
                  letterSpacing: 0.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStepIcon(_RequestStepState state) {
    switch (state) {
      case _RequestStepState.completed:
        return Container(
          width: 16.0,
          height: 16.0,
          decoration: BoxDecoration(
            color: const Color(0xFF8B53FE),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFFFFFF),
              width: 0.8,
            ),
          ),
          alignment: Alignment.center,
          child: const CustomPaint(
            size: Size(7.5, 5.0),
            painter: _CheckmarkPainter(
              color: Colors.white,
              strokeWidth: 0.8,
            ),
          ),
        );

      case _RequestStepState.active:
        return Container(
          width: 20.0,
          height: 20.0,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F5F4),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF8B53FE),
              width: 1.6,
            ),
          ),
          alignment: Alignment.center,
          child: Container(
            width: 10.0,
            height: 10.0,
            decoration: const BoxDecoration(
              color: Color(0xFF8B53FE),
              shape: BoxShape.circle,
            ),
          ),
        );

      case _RequestStepState.pending:
        return Container(
          width: 16.0,
          height: 16.0,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFEAEBE8),
              width: 1.0,
            ),
          ),
        );
    }
  }

  // -------------------------------------------------------------
  // ACTIVE & HISTORY TAB STATE & CARDS BUILDER
  // -------------------------------------------------------------
  Widget _buildEmptyActiveState(double containerWidth, double horizontalPadding) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12.0,
            offset: Offset(0, 1),
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72.0,
            height: 72.0,
            decoration: const BoxDecoration(
              color: Color(0xFFF0EAFE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 36.0,
              color: Color(0xFF8B53FE),
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            tr.isArabic ? 'لا توجد طلبات نشطة' : 'No Active Requests',
            textAlign: TextAlign.center,
            style: tr.font(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C2926),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            tr.isArabic
                ? 'ليس لديك أي طلب خدمة نشط حالياً. اطلب خدمة من الخريطة أو الشاشة الرئيسية لمتابعة حالتها هنا مباشرة.'
                : 'You have no active service requests right now. Book a service to track real-time provider arrival and progress here.',
            textAlign: TextAlign.center,
            style: tr.font(
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF566663),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20.0),
          SizedBox(
            height: 44.0,
            child: ElevatedButton.icon(
              onPressed: () {
                if (widget.onTabSelected != null) {
                  widget.onTabSelected!(0);
                }
              },
              icon: const Icon(Icons.explore_outlined, size: 18.0, color: Colors.white),
              label: Text(
                tr.isArabic ? 'استكشف الخدمات' : 'Explore Services',
                style: tr.font(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B53FE),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getActiveStatusTitle(int step, AppTranslations tr, {String? status}) {
    final normalized = (status ?? '').toLowerCase();
    if (step == 0 && (normalized == 'new' || normalized == 'pending')) {
      return tr.isArabic ? 'تم إرسال الطلب' : 'Request Sent';
    }
    switch (step) {
      case 0:
        return tr.isArabic ? 'تم قبول طلبك' : 'Request Accepted';
      case 1:
        return tr.providerOnTheWay;
      case 2:
        return tr.isArabic ? 'وصل المزود لموقعك' : 'Provider Arrived';
      case 3:
        return tr.isArabic ? 'جاري تنفيذ الخدمة' : 'Service In Progress';
      case 4:
      default:
        return tr.isArabic ? 'اكتملت الخدمة' : 'Service Completed';
    }
  }

  String _getActiveStatusSubtitle(int step, AppTranslations tr, {String? status}) {
    final normalized = (status ?? '').toLowerCase();
    if (step == 0 && (normalized == 'new' || normalized == 'pending')) {
      return tr.isArabic ? 'بانتظار قبول مزود الخدمة للطلب' : 'Waiting for provider to accept your request.';
    }
    switch (step) {
      case 0:
        return tr.isArabic ? 'المزود يستعد للتحرك' : 'Provider is preparing to depart.';
      case 1:
        return tr.providerArrivingSoon;
      case 2:
        return tr.isArabic ? 'المزود بانتظارك في الموقع' : 'Provider has reached your location.';
      case 3:
        return tr.isArabic ? 'الفني يباشر العمل على طلبك' : 'Technician is actively working on your request.';
      case 4:
      default:
        return tr.isArabic ? 'تمت الخدمة بنجاح' : 'Service completed successfully.';
    }
  }

  List<_HistoryRequestItem> get _filteredHistoryItems {
    final query = _searchController.text.trim().toLowerCase();
    final rawTasks = TaskService.instance.historyTasks;
    final mapped = rawTasks.map((t) {
      final isCancelled = t.status == 'cancelled';
      return _HistoryRequestItem(
        task: t,
        providerName: t.providerName,
        statusText: isCancelled ? (tr.isArabic ? 'ملغي' : 'Cancelled') : (tr.isArabic ? 'مكتمل' : 'Completed'),
        statusBgColor: isCancelled ? const Color(0xFFFFF0F0) : const Color(0xFFF0EAFE),
        statusTextColor: isCancelled ? const Color(0xFFDC2626) : const Color(0xFF8B53FE),
        rating: t.providerRating.toStringAsFixed(1),
        trips: t.providerTripsCount > 0
            ? (tr.isArabic
                ? '(${t.providerTripsCount} ${t.providerTripsCount == 1 ? 'رحلة' : 'رحلات'})'
                : '(${t.providerTripsCount} ${t.providerTripsCount == 1 ? 'trip' : 'trips'})')
            : '',
        serviceCategory: t.serviceCategory,
        vehicleName: t.vehicleName,
        vehicleIcon: Icons.local_shipping_outlined,
        plateNumber: t.plateNumber,
        dateTime: t.dateTime,
        avatarPath: t.providerAvatar ?? 'assets/images/driver_avatar.png',
        avatarFallbackColor: const Color(0xFFE2E8F0),
      );
    }).toList();

    if (query.isEmpty) return mapped;
    return mapped.where((item) {
      return item.providerName.toLowerCase().contains(query) ||
          item.serviceCategory.toLowerCase().contains(query) ||
          item.vehicleName.toLowerCase().contains(query) ||
          item.plateNumber.toLowerCase().contains(query) ||
          item.statusText.toLowerCase().contains(query) ||
          item.dateTime.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildEmptyHistoryState(double containerWidth) {
    final bool isSearch = _searchController.text.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000), // 0px 1px 12px 0px #0000001A
            blurRadius: 12.0,
            offset: Offset(0, 1),
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearch ? Icons.search_off_rounded : Icons.history_rounded,
              size: 36.0,
              color: const Color(0xFF8B53FE),
            ),
            const SizedBox(height: 10.0),
            Text(
              isSearch
                  ? tr.noRequestsFound
                  : (tr.isArabic ? 'لا توجد طلبات سابقة' : 'No Past Requests'),
              style: tr.font(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1C2926),
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              isSearch
                  ? tr.trySearchingDifferent
                  : (tr.isArabic
                      ? 'ستظهر هنا سجلات طلبات الخدمة المكتملة والسابقة.'
                      : 'Completed and past service requests will appear here.'),
              style: tr.font(
                fontSize: 11.0,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF566663),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openHistoryDetails(_HistoryRequestItem item) {
    HapticFeedback.lightImpact();
    if (item.task == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CompletedServiceDetailsScreen(task: item.task),
      ),
    );
  }

  Widget _buildHistoryCard(_HistoryRequestItem item, double containerWidth) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 110.0), // constraints: minHeight 110;
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // background: #FFFFFF;
        borderRadius: BorderRadius.circular(12.0), // border-radius: 12px;
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000), // box-shadow: 0px 1px 12px 0px #0000001A;
            blurRadius: 12.0,
            offset: Offset(0, 1),
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () => _openHistoryDetails(item),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // padding: 16px;
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // left side img: width: 48; height: 48;
                ClipOval(
                  child: SizedBox(
                    width: 48.0,
                    height: 48.0,
                    child: Image.asset(
                      item.avatarPath,
                      width: 48.0,
                      height: 48.0,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to driver_avatar or initials
                        return Image.asset(
                          'assets/images/driver_avatar.png',
                          width: 48.0,
                          height: 48.0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error2, stackTrace2) {
                            return Container(
                              width: 48.0,
                              height: 48.0,
                              decoration: BoxDecoration(
                                color: item.avatarFallbackColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  item.providerName.isNotEmpty
                                      ? item.providerName[0]
                                      : '?',
                                  style: tr.font(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1C2926),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16.0), // gap: 16px;

                // content layout: width: 254; min-height: 78; justify-content: space-between;
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 78.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // left content layout: width: 238; height: 78; gap: 12px;
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1st row branding: width: 238; height: 19; justify-content: space-between;
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // 1st row inner branding: content: Ahmad Transport
                                  // font-family: Inter; font-weight: 500; font-size: 12px; line-height: 22px; color: #1C2926;
                                  Flexible(
                                    child: Text(
                                      tr.formatProviderName(item.providerName),
                                      style: tr.font(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF1C2926),
                                        height: 1.15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),

                                  // 1st row right content: status badge
                                  // width: 64; height: 19; border-radius: 60px; padding: 6px; background: #F0F5F2;
                                  // content: Completed / Cancelled
                                  Container(
                                    height: 19.0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 3.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item.statusBgColor,
                                      borderRadius: BorderRadius.circular(60.0),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      (item.statusText == 'Completed' ? tr.completed : (item.statusText == 'Cancelled' ? tr.cancelled : item.statusText)),
                                      style: tr.font(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w400,
                                        color: item.statusTextColor,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // 2nd row layout: width: 171; height: 10; gap: 8px;
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // star branding: width: 10; height: 10; background: #1D8070;
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 11.0,
                                    color: Color(0xFF8B53FE),
                                  ),
                                  const SizedBox(width: 4.0), // gap: 4px;

                                  // content: 4.9 (120 trips) (Inter Regular 10px)
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: item.trips.isNotEmpty ? '${item.rating} ' : item.rating,
                                          style: tr.font(
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF1C2926),
                                            height: 1.15,
                                          ),
                                        ),
                                        if (item.trips.isNotEmpty)
                                          TextSpan(
                                            text: tr.formatTripsString(item.trips),
                                            style: tr.font(
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF566663),
                                              height: 1.15,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8.0), // gap: 8px;

                                  // content: Pickup & Delivery (Inter Regular 10px, #566663)
                                  Flexible(
                                    child: Text(
                                      tr.categoryName(item.serviceCategory, item.serviceCategory),
                                      style: tr.font(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF566663),
                                        height: 1.15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              // 3rd row layout: width: 160.5; height: 10; gap: 10px;
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // vector of car branding: width: 12; height: 10; background: #1C2926;
                                  Icon(
                                    item.vehicleIcon,
                                    size: 11.5,
                                    color: const Color(0xFF1C2926),
                                  ),
                                  const SizedBox(width: 4.0),

                                  // content: Toyota Hilux (Inter Medium 10px, #1C2926)
                                  Text(
                                    tr.formatVehicleName(item.vehicleName),
                                    style: tr.font(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1C2926),
                                      height: 1.15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(width: 6.0),
                                  // separator divider
                                  Container(
                                    width: 1.0,
                                    height: 8.0,
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                  const SizedBox(width: 6.0),

                                  // vector of # branding: width: 10; height: 10; background: #566663;
                                  Container(
                                    width: 10.0,
                                    height: 10.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFF566663),
                                        width: 0.8,
                                      ),
                                      borderRadius: BorderRadius.circular(2.0),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '#',
                                      style: tr.font(
                                        fontSize: 6.5,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF566663),
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4.0),

                                  // content: ABC-123 (Inter Regular 10px, #566663)
                                  Text(
                                    item.plateNumber,
                                    style: tr.font(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF566663),
                                      height: 1.15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),

                              // 4th row branding: content: 10 Sep 2026, 2:15 PM (Inter Regular 10px, #566663)
                              Text(
                                tr.formatDateTimeString(item.dateTime),
                                style: tr.font(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF566663),
                                  height: 1.15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // card right side > branding: width: 6; height: 12; angle: -180 deg; border: 0.8px solid #566663
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Icon(
                            (tr.isArabic || Directionality.of(context) == TextDirection.rtl)
                                ? Icons.chevron_left_rounded
                                : Icons.chevron_right_rounded,
                            size: 18.0,
                            color: const Color(0xFF566663),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _RequestStepState { completed, active, pending }

/// Data model for history tab request cards
class _HistoryRequestItem {
  final ServiceTask? task;
  final String providerName;
  final String statusText;
  final Color statusBgColor;
  final Color statusTextColor;
  final String rating;
  final String trips;
  final String serviceCategory;
  final String vehicleName;
  final IconData vehicleIcon;
  final String plateNumber;
  final String dateTime;
  final String avatarPath;
  final Color avatarFallbackColor;

  const _HistoryRequestItem({
    this.task,
    required this.providerName,
    required this.statusText,
    required this.statusBgColor,
    required this.statusTextColor,
    required this.rating,
    required this.trips,
    required this.serviceCategory,
    required this.vehicleName,
    required this.vehicleIcon,
    required this.plateNumber,
    required this.dateTime,
    required this.avatarPath,
    required this.avatarFallbackColor,
  });
}

/// Custom painter for checkmark vector: width: 7.5; height: 5; border: 0.8px solid #FFFFFF
class _CheckmarkPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _CheckmarkPainter({
    this.color = Colors.white,
    this.strokeWidth = 0.8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0, size.height * 0.45)
      ..lineTo(size.width * 0.38, size.height)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) => false;
}

/// Route vector line painter matching Figma route geometry
class _RouteVectorPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _RouteVectorPainter({
    this.color = const Color(0xFF8B53FE),
    this.strokeWidth = 4.0,
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
    path.moveTo(2.0, 4.0);
    path.cubicTo(
      size.width * 0.40,
      2.0,
      size.width * 0.60,
      size.height * 0.80,
      size.width - 2.0,
      size.height - 2.0,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RouteVectorPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}

/// Downward tooltip pointer arrow painter
class _TooltipArrowPainter extends CustomPainter {
  final Color color;
  const _TooltipArrowPainter({this.color = const Color(0xFF8B53FE)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TooltipArrowPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Detailed aerodynamic top-down car painter with purple roof (#A67AFE)
class _CarGraphicPainter extends CustomPainter {
  final Color roofColor;
  const _CarGraphicPainter({this.roofColor = const Color(0xFFA67AFE)});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Subtle soft shadow
    final shadowPaint = Paint()
      ..color = const Color(0x22000000)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.5, 1.2, w - 1.0, h - 0.8),
        Radius.circular(w * 0.28),
      ),
      shadowPaint,
    );

    // 2. Wheels / Tires (Dark rubber)
    final wheelPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    final double wheelW = w * 0.16;
    final double wheelH = h * 0.20;
    // Front wheels
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, h * 0.16, wheelW, wheelH), const Radius.circular(1.0)),
      wheelPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w - wheelW, h * 0.16, wheelW, wheelH), const Radius.circular(1.0)),
      wheelPaint,
    );
    // Rear wheels
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, h * 0.64, wheelW, wheelH), const Radius.circular(1.0)),
      wheelPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w - wheelW, h * 0.64, wheelW, wheelH), const Radius.circular(1.0)),
      wheelPaint,
    );

    // 3. Aerodynamic White Car Body
    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final bodyBorder = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final bodyPath = Path();
    final double bodyInset = w * 0.08;
    final double bw = w - bodyInset * 2.0;
    bodyPath.addRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(bodyInset, 0, bw, h),
        topLeft: Radius.circular(bw * 0.42),
        topRight: Radius.circular(bw * 0.42),
        bottomLeft: Radius.circular(bw * 0.35),
        bottomRight: Radius.circular(bw * 0.35),
      ),
    );
    canvas.drawPath(bodyPath, bodyPaint);
    canvas.drawPath(bodyPath, bodyBorder);

    // 4. Side Mirrors (Purple body accent)
    final mirrorPaint = Paint()
      ..color = roofColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(bodyInset * 0.5, h * 0.32), w * 0.08, mirrorPaint);
    canvas.drawCircle(Offset(w - bodyInset * 0.5, h * 0.32), w * 0.08, mirrorPaint);

    // 5. Dark Panoramic Glasshouse (Windshield & Rear glass)
    final glassPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    // Front windshield
    final frontGlass = Path()
      ..moveTo(w * 0.22, h * 0.26)
      ..lineTo(w * 0.78, h * 0.26)
      ..lineTo(w * 0.82, h * 0.38)
      ..lineTo(w * 0.18, h * 0.38)
      ..close();
    canvas.drawPath(frontGlass, glassPaint);

    // Rear windshield
    final rearGlass = Path()
      ..moveTo(w * 0.20, h * 0.68)
      ..lineTo(w * 0.80, h * 0.68)
      ..lineTo(w * 0.76, h * 0.80)
      ..lineTo(w * 0.24, h * 0.80)
      ..close();
    canvas.drawPath(rearGlass, glassPaint);

    // 6. Purple Roof (#A67AFE)
    final roofPaint = Paint()
      ..color = roofColor
      ..style = PaintingStyle.fill;
    final roofRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.20, h * 0.36, w * 0.80, h * 0.68),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(roofRRect, roofPaint);

    // 7. Antenna dot
    final dotPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.60), w * 0.05, dotPaint);

    // 8. Front Headlights (Warm white/amber)
    final headPaint = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.22, h * 0.06), w * 0.07, headPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.06), w * 0.07, headPaint);

    // 9. Rear Taillights (Red)
    final tailPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(w * 0.18, h * 0.94, w * 0.16, h * 0.04), tailPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.66, h * 0.94, w * 0.16, h * 0.04), tailPaint);
  }

  @override
  bool shouldRepaint(covariant _CarGraphicPainter oldDelegate) =>
      oldDelegate.roofColor != roofColor;
}

/// Brand 3D-styled Purple Location Pin (replaces green Group 5.png)
class _BrandPurpleLocationPinWidget extends StatelessWidget {
  final double size;
  const _BrandPurpleLocationPinWidget({this.size = 32.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: const _BrandPurpleLocationPinPainter(),
    );
  }
}

class _BrandPurpleLocationPinPainter extends CustomPainter {
  const _BrandPurpleLocationPinPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Oval shadow at bottom base of pin
    final shadowPaint = Paint()
      ..color = const Color(0x358B53FE)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.90),
        width: w * 0.70,
        height: h * 0.22,
      ),
      shadowPaint,
    );

    // 2. Base beacon ring at bottom
    final baseRingPaint = Paint()
      ..color = const Color(0xFF8B53FE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.88),
        width: w * 0.60,
        height: h * 0.18,
      ),
      baseRingPaint,
    );

    // 3. Teardrop pin body with rich purple gradient
    final Rect pinRect = Rect.fromLTWH(w * 0.14, 0.0, w * 0.72, h * 0.85);
    final pinGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFA67AFE), // Lighter vibrant purple highlight
        Color(0xFF8B53FE), // Deep brand purple
      ],
    );

    final pinPaint = Paint()
      ..shader = pinGradient.createShader(pinRect)
      ..style = PaintingStyle.fill;

    final pinBorderPaint = Paint()
      ..color = const Color(0xFF6E36E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final double cx = w * 0.5;
    final double radius = w * 0.32;
    final double cy = radius + h * 0.04;
    final double tipY = h * 0.86;

    final path = Path();
    path.addArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      math.pi * 0.78,
      math.pi * 1.44,
    );
    path.lineTo(cx, tipY);
    path.close();

    canvas.drawPath(path, pinPaint);
    canvas.drawPath(path, pinBorderPaint);

    // 4. Inner glossy white center dot/lens
    final innerCenter = Offset(cx, cy);
    final innerRadius = radius * 0.44;

    final innerLensPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Colors.white,
          Color(0xFFEFE6FF),
        ],
      ).createShader(Rect.fromCircle(center: innerCenter, radius: innerRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(innerCenter, innerRadius, innerLensPaint);

    final innerLensBorder = Paint()
      ..color = const Color(0x338B53FE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(innerCenter, innerRadius, innerLensBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Location pin icon painter matching Figma specifications:
class _LocationPinPainter extends CustomPainter {
  final Color color;
  const _LocationPinPainter({this.color = const Color(0xFF1C2926)});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
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
    canvas.drawCircle(Offset(cx, cy), 2.2, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _LocationPinPainter oldDelegate) =>
      color != oldDelegate.color;
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

    // 2. White clock hands (matching Figma: 12:00 -> center -> ~4:00)
    final handPaint = Paint()
      ..color = handColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(cx, cy - radius * 0.52);
    path.lineTo(cx, cy);
    path.lineTo(cx + radius * 0.42, cy + radius * 0.28);

    canvas.drawPath(path, handPaint);
  }

  @override
  bool shouldRepaint(covariant _ClockIconPainter oldDelegate) =>
      backgroundColor != oldDelegate.backgroundColor ||
      handColor != oldDelegate.handColor;
}

/// Custom painter for the 3-line filter vector: width: 23.82; height: 14.29; background: #1C2926;
class _FilterLinesPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _FilterLinesPainter({
    this.color = const Color(0xFF1C2926),
    this.strokeWidth = 2.2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2.0;

    // Line 1 (top): width: 23.82
    final topHalf = (size.width - strokeWidth) / 2.0;
    canvas.drawLine(
      Offset(cx - topHalf, strokeWidth / 2.0),
      Offset(cx + topHalf, strokeWidth / 2.0),
      paint,
    );

    // Line 2 (middle): width ~15.5
    final midHalf = topHalf * 0.65;
    canvas.drawLine(
      Offset(cx - midHalf, size.height / 2.0),
      Offset(cx + midHalf, size.height / 2.0),
      paint,
    );

    // Line 3 (bottom): width ~8.3
    final botHalf = topHalf * 0.35;
    canvas.drawLine(
      Offset(cx - botHalf, size.height - (strokeWidth / 2.0)),
      Offset(cx + botHalf, size.height - (strokeWidth / 2.0)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FilterLinesPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}


