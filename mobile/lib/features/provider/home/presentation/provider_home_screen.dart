import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/home/presentation/widgets/bottom_nav_bar_widget.dart';
import 'package:mobile/features/home/presentation/widgets/notification_popup_card.dart';
import 'package:mobile/features/profile/presentation/notifications_screen.dart';
import 'package:mobile/features/profile/presentation/profile_screen.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';
import 'package:mobile/features/provider/auth/presentation/provider_onboarding_guard.dart';
import 'package:mobile/features/provider/auth/presentation/provider_phone_change_watcher.dart';
import 'package:mobile/features/provider/auth/presentation/admin_approval_screen.dart';
import 'package:mobile/features/provider/auth/presentation/phone_verification_screen.dart';
import 'package:mobile/features/provider/auth/presentation/provider_blocked_screen.dart';
import 'package:mobile/features/provider/dashboard/presentation/provider_dashboard_screen.dart';
import 'package:mobile/features/provider/home/presentation/widgets/provider_home_header.dart';
import 'package:mobile/features/provider/home/presentation/widgets/provider_online_status_text.dart';
import 'package:mobile/features/provider/home/presentation/widgets/provider_online_toggle.dart';
import 'package:mobile/features/provider/home/provider_online_session.dart';
import 'package:mobile/features/provider/home/presentation/widgets/provider_stats_cards.dart';
import 'package:mobile/features/provider/home/presentation/widgets/provider_vehicle_card.dart';
import 'package:mobile/features/provider/requests/presentation/provider_requests_screen.dart';
import 'package:mobile/providers/backend_provider.dart';
import 'package:mobile/providers/notifications_provider.dart';
import 'package:mobile/services/backend_service.dart';
import 'package:mobile/services/location_service.dart';
import 'package:mobile/services/task_service.dart';

/// Provider Home Screen
/// Implements exact base branding specifications & artboard dimensions:
///
/// HOME SCREEN total height and width:
///   width: 392;
///   height: 844;
///   angle: 0 deg;
///   opacity: 1;
///
/// home screen branding:
///   background: linear-gradient(0deg, #FFFFFF, #FFFFFF),
///   linear-gradient(180.52deg, #8B53FE -66.75%, rgba(139, 83, 254, 0.37284) -0.59%, rgba(139, 83, 254, 0) 29.8%);
class ProviderHomeScreen extends ConsumerStatefulWidget {
  final Widget? body;
  final int initialTabIndex;

  const ProviderHomeScreen({
    super.key,
    this.body,
    this.initialTabIndex = 0,
  });

  static const double designWidth = 392.0;
  static const double designHeight = 844.0;

  @override
  ConsumerState<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends ConsumerState<ProviderHomeScreen> {
  static const double designWidth = 392.0;
  static const double designHeight = 844.0;

  int _currentTabIndex = 0;
  bool _isOnline = false;

  Timer? _gpsTrackingTimer;
  Timer? _statsRefreshTimer;
  Timer? _notificationsPollTimer;
  String? _lastProviderNotificationId;
  bool _hasCompletedInitialNotifPoll = false;
  StreamSubscription<UserLocation>? _locationSubscription;
  bool _isUpdatingLocation = false;
  DateTime? _lastSentLocationAt;
  UserLocation? _lastSentLocation;
  bool _isNavigatingAway = false;

  ScrollController? _scrollControllerInstance;
  ScrollController get _scrollController =>
      _scrollControllerInstance ??= ScrollController();

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTabIndex;
    final reg = ProviderRegistrationStore.instance.data;
    _isOnline = reg.isOnline && ProviderOnboardingGuard.canGoOnline(reg);
    if (reg.isOnline && !_isOnline) {
      ProviderRegistrationStore.instance.update(
        (data) => data.copyWith(isOnline: false),
      );
    }
    ProviderOnlineSession.loadPersisted().then((_) async {
      if (!mounted) return;
      if (_isOnline) {
        if (!ProviderOnlineSession.hasActiveSession) {
          await ProviderOnlineSession.goOnline();
        }
      } else {
        await ProviderOnlineSession.goOffline();
      }
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isOnline) {
        _startGpsTrackingAndPresence();
      }
      _syncProviderAccountStatus();
      ProviderPhoneChangeWatcher.start(context);
    });
    // High-frequency stats polling and account status synchronization (every 2.5s)
    // Instantly reacts if admin blocks, suspends, or deletes provider
    _statsRefreshTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (mounted) {
        ref.invalidate(providerQuickStatsProvider);
        _syncProviderAccountStatus();
      }
    });
    _notificationsPollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _pollProviderNotifications();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _pollProviderNotifications());
  }

  String _formatCustomerLocationFromNotification(Map<String, dynamic> latest) {
    final lat = latest['customerLatitude'];
    final lng = latest['customerLongitude'];
    if (lat != null && lng != null) {
      final la = lat is num ? lat.toDouble() : double.tryParse(lat.toString());
      final lo = lng is num ? lng.toDouble() : double.tryParse(lng.toString());
      if (la != null && lo != null) {
        return 'https://maps.google.com/?q=$la,$lo';
      }
    }
    return 'Customer via Zesho';
  }

  Future<void> _pollProviderNotifications() async {
    if (!mounted || _isNavigatingAway) return;
    try {
      final items = await ref.read(backendServiceProvider).fetchProviderNotifications(limit: 20);
      if (!mounted) return;
      final isFirstPoll = !_hasCompletedInitialNotifPoll;
      _hasCompletedInitialNotifPoll = true;
      final nowUtc = DateTime.now().toUtc();
      // Keep notifications available in the popup for 24 hours; ignore older ones
      final recentItems = items.where((item) {
        final rawTs = item['createdAt']?.toString();
        final ts = rawTs != null ? DateTime.tryParse(rawTs) : null;
        if (ts == null) return true;
        return nowUtc.difference(ts.toUtc()).abs() <= const Duration(hours: 24);
      }).toList();

      final tr = ref.read(translationsProvider);

      // Sync ALL incoming send_request_click and request_cancelled notifications into Provider Requests tab
      for (final item in recentItems.reversed) {
        final ev = item['eventType']?.toString() ?? '';
        if (ev == 'request_cancelled') {
          final meta = item['metadata'] is Map ? item['metadata'] as Map : const {};
          final cancelledReqId = meta['requestId']?.toString().trim() ?? '';
          if (cancelledReqId.isNotEmpty) {
            await TaskService.instance.cancelRequestById('REQ-$cancelledReqId');
          }
          continue;
        }
        if (ev != 'send_request_click') continue;
        final itemId = item['id']?.toString() ?? '';
        if (itemId.isEmpty) continue;
        final meta = item['metadata'] is Map ? item['metadata'] as Map : const {};
        final cat = meta['serviceCategory']?.toString().trim() ?? '';
        final custName = meta['customerName']?.toString().trim() ?? '';
        final custAddr = meta['customerAddress']?.toString().trim() ?? '';
        final dist = meta['distance']?.toString().trim() ?? '';
        final reqStatus = meta['requestStatus']?.toString().trim() ?? 'new';
        final reqStep = (meta['step'] is num)
            ? (meta['step'] as num).toInt()
            : int.tryParse(meta['step']?.toString() ?? '') ?? 0;
        final tsRaw = item['createdAt']?.toString();
        await TaskService.instance.upsertIncomingRequestFromProviderNotification(
          notificationId: itemId,
          serviceCategory: cat.isNotEmpty
              ? cat
              : (tr.isArabic ? 'طلب خدمة' : 'Service request'),
          customerLocation: custAddr.isNotEmpty
              ? custAddr
              : _formatCustomerLocationFromNotification(item),
          distance: dist,
          customerName: custName.isNotEmpty
              ? custName
              : (tr.isArabic ? 'عميل' : 'Customer'),
          status: reqStatus,
          step: reqStep,
          createdAt: tsRaw != null ? DateTime.tryParse(tsRaw) : null,
        );
      }

      if (recentItems.isEmpty) {
        if (ref.read(notificationsProvider).providerNotification != null) {
          ref.read(notificationsProvider.notifier).setProviderNotification(null);
        }
        return;
      }

      final latest = recentItems.first;
      final id = latest['id']?.toString() ?? '';
      if (id.isEmpty || id == _lastProviderNotificationId) return;
      _lastProviderNotificationId = id;

      final isUnread = latest['isRead'] != true;
      final createdAtRaw = latest['createdAt']?.toString();
      final createdAt = createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null;
      final isJustArrived = createdAt == null ||
          nowUtc.difference(createdAt.toUtc()).abs() <= const Duration(minutes: 2);
      final shouldPopup = isUnread && (!isFirstPoll || isJustArrived);

      final String timeEn = _formatRelativeTime(createdAt, isArabic: false);
      final String timeAr = _formatRelativeTime(createdAt, isArabic: true);

      final metadata = latest['metadata'] is Map ? latest['metadata'] as Map : const {};
      final rawPhoto = (metadata['customerPhotoUrl'] ??
              metadata['photoUrl'] ??
              latest['customerPhotoUrl'])
          ?.toString()
          .trim();
      final String? profilePhotoUrl =
          (rawPhoto != null && rawPhoto.isNotEmpty) ? rawPhoto : null;

      final eventType = latest['eventType']?.toString() ?? '';
      String badgeEn = 'New activity';
      String badgeAr = 'نشاط جديد';
      String fallbackTitleEn = 'Customer activity';
      String fallbackTitleAr = 'نشاط عميل';
      String fallbackBodyEn = 'A customer contacted you via Zesho';
      String fallbackBodyAr = 'تواصل معك عميل عبر زيشو';

      switch (eventType) {
        case 'call_click':
          badgeEn = 'Incoming call';
          badgeAr = 'مكالمة واردة';
          fallbackTitleEn = 'Customer tapped Call';
          fallbackTitleAr = 'عميل ضغط على اتصال';
          fallbackBodyEn = 'A customer tapped Call on your Zesho profile';
          fallbackBodyAr = 'ضغط عميل على اتصال في ملفك على زيشو';
          break;
        case 'whatsapp_click':
          badgeEn = 'WhatsApp';
          badgeAr = 'واتساب';
          fallbackTitleEn = 'Customer tapped WhatsApp';
          fallbackTitleAr = 'عميل تواصل عبر واتساب';
          fallbackBodyEn = 'A customer opened WhatsApp to reach you';
          fallbackBodyAr = 'فتح عميل واتساب للتواصل معك';
          break;
        case 'share_location_click':
          badgeEn = 'Location shared';
          badgeAr = 'موقع مشترك';
          fallbackTitleEn = 'Customer shared location';
          fallbackTitleAr = 'شارك العميل موقعه';
          fallbackBodyEn = 'A customer shared their live location with you';
          fallbackBodyAr = 'شارك عميل موقعه المباشر معك';
          break;
        case 'send_request_click':
          badgeEn = 'New Request';
          badgeAr = 'طلب جديد';
          final reqCat = metadata['serviceCategory']?.toString().trim() ?? '';
          final reqCust = metadata['customerName']?.toString().trim() ?? '';
          fallbackTitleEn = reqCat.isNotEmpty ? 'New Request • $reqCat' : 'New service request';
          fallbackTitleAr = reqCat.isNotEmpty ? 'طلب جديد • $reqCat' : 'طلب خدمة جديد';
          fallbackBodyEn = reqCust.isNotEmpty
              ? '$reqCust sent you a service request'
              : 'A customer sent you a service request';
          fallbackBodyAr = reqCust.isNotEmpty
              ? 'أرسل $reqCust طلب خدمة لك'
              : 'أرسل لك عميل طلب خدمة';
          break;
        case 'request_cancelled':
          badgeEn = 'Request Cancelled';
          badgeAr = 'تم إلغاء الطلب';
          final cancelCat = metadata['serviceCategory']?.toString().trim() ?? '';
          final cancelCust = metadata['customerName']?.toString().trim() ?? '';
          fallbackTitleEn = cancelCat.isNotEmpty ? 'Request Cancelled • $cancelCat' : 'Request cancelled';
          fallbackTitleAr = cancelCat.isNotEmpty ? 'تم إلغاء الطلب • $cancelCat' : 'تم إلغاء الطلب';
          fallbackBodyEn = cancelCust.isNotEmpty
              ? '$cancelCust cancelled the service request'
              : 'A customer cancelled their service request';
          fallbackBodyAr = cancelCust.isNotEmpty
              ? 'ألغى $cancelCust طلب الخدمة'
              : 'ألغى العميل طلب الخدمة';
          break;
      }

      final serverTitle = latest['title']?.toString().trim() ?? '';
      final serverBody = latest['body']?.toString().trim() ?? '';
      final titleEn = serverTitle.isNotEmpty ? serverTitle : fallbackTitleEn;
      final titleAr = fallbackTitleAr;
      final bodyEn = serverBody.isNotEmpty ? serverBody : fallbackBodyEn;
      final bodyAr = fallbackBodyAr;

      if (shouldPopup) {
        HapticFeedback.heavyImpact();
      }

      ref.read(notificationsProvider.notifier).setProviderNotification(
            AppNotificationItem(
              id: id,
              badgeTextEn: badgeEn,
              badgeTextAr: badgeAr,
              titleEn: titleEn,
              titleAr: titleAr,
              locationEn: bodyEn,
              locationAr: bodyAr,
              distanceEn: '',
              distanceAr: '',
              timeEn: timeEn,
              timeAr: timeAr,
              createdAt: createdAt ?? DateTime.now().toUtc(),
              imageAsset: profilePhotoUrl,
              isRead: !isUnread,
            ),
            showCard: shouldPopup,
            autoHideDuration: const Duration(seconds: 4),
          );
    } catch (_) {}
  }

  String _formatRelativeTime(DateTime? createdAt, {required bool isArabic}) {
    if (createdAt == null) return isArabic ? 'الآن' : 'Just now';
    final rawDiff = DateTime.now().toUtc().difference(createdAt.toUtc());
    final diff = rawDiff.isNegative ? Duration.zero : rawDiff;
    if (diff.inSeconds < 5) return isArabic ? 'الآن' : 'Just now';
    if (diff.inSeconds < 60) {
      return isArabic ? 'منذ ${diff.inSeconds} ث' : '${diff.inSeconds}s ago';
    }
    if (diff.inMinutes < 60) {
      return isArabic ? 'منذ ${diff.inMinutes} د' : '${diff.inMinutes}m ago';
    }
    return isArabic ? 'منذ ${diff.inHours} س' : '${diff.inHours}h ago';
  }

  Future<void> _syncProviderAccountStatus() async {
    if (_isNavigatingAway) return;
    try {
      final accountState =
          await ref.read(backendServiceProvider).checkProviderAccountState();
      if (!mounted || _isNavigatingAway) return;

      if (accountState.status == ProviderAccountStatus.deleted) {
        _isNavigatingAway = true;
        _statsRefreshTimer?.cancel();
        _stopGpsTrackingAndPresence(callBackend: false);
        await ProviderRegistrationStore.instance.clear();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.isArabic
                  ? 'تم حذف حساب مزود الخدمة الخاص بك من قبل الإدارة'
                  : 'Your provider account has been deleted by administration.',
            ),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PhoneVerificationScreen()),
          (route) => false,
        );
      } else if (accountState.status == ProviderAccountStatus.blocked) {
        _isNavigatingAway = true;
        _statsRefreshTimer?.cancel();
        _stopGpsTrackingAndPresence(callBackend: true);
        ProviderRegistrationStore.instance.update(
          (d) => d.copyWith(status: 'BLOCKED', isOnline: false),
        );
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => ProviderBlockedScreen(
              reason: accountState.statusReason,
            ),
          ),
          (route) => false,
        );
      } else if (accountState.status == ProviderAccountStatus.suspended) {
        _isNavigatingAway = true;
        _statsRefreshTimer?.cancel();
        _stopGpsTrackingAndPresence(callBackend: true);
        ProviderRegistrationStore.instance.update(
          (d) => d.copyWith(status: 'SUSPENDED', isOnline: false),
        );
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const AdminApprovalScreen(
              isSuspended: true,
            ),
          ),
          (route) => false,
        );
      } else if (accountState.profile != null && accountState.profile!.isNotEmpty) {
        ProviderRegistrationStore.instance.updateFromBackendProfile(accountState.profile!);
        if (mounted) {
          ref.read(providerRegistrationProvider.notifier).syncWithStore();
          setState(() {});
        }
      }
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant ProviderHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      _currentTabIndex = widget.initialTabIndex;
    }
  }

  @override
  void dispose() {
    ProviderPhoneChangeWatcher.stop();
    _notificationsPollTimer?.cancel();
    _statsRefreshTimer?.cancel();
    _stopGpsTrackingAndPresence(callBackend: false);
    _scrollControllerInstance?.dispose();
    super.dispose();
  }

  void _setOnlineStatus(bool online) {
    if (_isOnline == online) return;
    if (online) {
      final data = ProviderRegistrationStore.instance.data;
      if (!ProviderOnboardingGuard.canGoOnline(data)) {
        ProviderOnboardingGuard.showMustCompleteOnboarding(context, data);
        setState(() => _isOnline = false);
        return;
      }
    }
    setState(() {
      _isOnline = online;
    });
    ProviderRegistrationStore.instance.update(
      (data) => data.copyWith(isOnline: online),
    );
    if (online) {
      ProviderOnlineSession.goOnline();
      _startGpsTrackingAndPresence();
    } else {
      ProviderOnlineSession.goOffline();
      _stopGpsTrackingAndPresence(callBackend: true);
    }
  }

  Future<void> _startGpsTrackingAndPresence() async {
    try {
      // 1. Immediately notify backend that provider is Online
      await ref.read(backendServiceProvider).updateProviderPresence(true);
    } catch (_) {}

    // 2. Immediately acquire and send exact GPS location
    _acquireAndSendGpsLocation();

    // 3. Keep online presence alive every 25s WITHOUT overwriting exact GPS with noisy indoor jitter
    _gpsTrackingTimer?.cancel();
    _gpsTrackingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      ref.read(backendServiceProvider).updateProviderPresence(true).catchError((_) => false);
      if (_lastSentLocation == null) {
        _acquireAndSendGpsLocation();
      }
    });

    // 4. Listen to stabilized location stream: only push to backend when provider genuinely moves
    _locationSubscription?.cancel();
    _locationSubscription = ref.read(locationServiceProvider).watchLocation().listen((loc) {
      if (loc.hasValidDeviceGps) {
        _sendLocationToBackend(loc);
      }
    });
  }

  void _stopGpsTrackingAndPresence({bool callBackend = true}) {
    _gpsTrackingTimer?.cancel();
    _gpsTrackingTimer = null;
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _lastSentLocationAt = null;
    _lastSentLocation = null;
    if (callBackend) {
      try {
        ref.read(backendServiceProvider).updateProviderPresence(false);
      } catch (_) {}
    }
  }

  Future<void> _acquireAndSendGpsLocation() async {
    if (_isUpdatingLocation) return;
    _isUpdatingLocation = true;
    try {
      final loc = await ref.read(locationServiceProvider).getCurrentLocation();
      await _sendLocationToBackend(loc, force: _lastSentLocation == null);
    } catch (_) {
    } finally {
      _isUpdatingLocation = false;
    }
  }

  Future<void> _sendLocationToBackend(UserLocation loc, {bool force = false}) async {
    if (!loc.hasValidDeviceGps) return;
    final now = DateTime.now();
    final prev = _lastSentLocation;
    if (!force && prev != null && _lastSentLocationAt != null) {
      final movedMeters = ref.read(locationServiceProvider).calculateDistanceKm(
            prev.latitude,
            prev.longitude,
            loc.latitude,
            loc.longitude,
          ) * 1000.0;
      final prevAcc = prev.accuracy ?? 999.0;
      final curAcc = loc.accuracy ?? 999.0;
      final accuracySharpened = curAcc <= 12.0 && (curAcc + 6.0) < prevAcc;
      // Do not overwrite backend coordinates with stationary GPS jitter (< 12 m)
      if (movedMeters < 12.0 && !accuracySharpened) {
        return;
      }
    }
    _lastSentLocationAt = now;
    _lastSentLocation = loc;
    try {
      await ref.read(backendServiceProvider).updateProviderLocation(
        latitude: loc.latitude,
        longitude: loc.longitude,
        address: loc.address,
        city: loc.cityName,
      );
      ProviderRegistrationStore.instance.update(
        (data) => data.copyWith(
          latitude: loc.latitude,
          longitude: loc.longitude,
        ),
      );
    } catch (_) {}
  }

  void _onTabSelected(int index) {
    if (_currentTabIndex == index) return;
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationsProvider);
    final n = notifState.providerNotification;
    final topPad = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        IndexedStack(
          index: _currentTabIndex,
          children: [
            _buildHomeTab(context),
            ProviderRequestsScreen(
              onBackTap: () => _onTabSelected(0),
              onTabSelected: _onTabSelected,
            ),
            ProfileScreen(
              isProvider: true,
              onBackTap: () => _onTabSelected(0),
              onTabSelected: _onTabSelected,
            ),
          ],
        ),
        if (_currentTabIndex != 0 && notifState.isProviderCardVisible && n != null)
          Positioned(
            top: (topPad > 0 ? topPad + 12.0 : 54.0),
            left: 16.0,
            right: 16.0,
            child: NotificationPopupCard(
              badgeText: context.isArabic ? n.badgeTextAr : n.badgeTextEn,
              title: context.isArabic ? n.titleAr : n.titleEn,
              location: context.isArabic ? n.locationAr : n.locationEn,
              distance: context.isArabic ? n.distanceAr : n.distanceEn,
              time: context.isArabic ? n.timeAr : n.timeEn,
              createdAt: n.createdAt,
              imageAsset: n.imageAsset,
              onTap: () {
                ref.read(notificationsProvider.notifier).hideProviderCard();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(isProvider: true),
                  ),
                );
              },
              onDismiss: () {
                ref.read(notificationsProvider.notifier).hideProviderCard();
              },
            ),
          ),
      ],
    );
  }

  Widget _buildHomeTab(BuildContext context) {
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
            final bool isDesktopWeb = constraints.maxWidth > 500;
            final double containerWidth = isDesktopWeb
                ? designWidth
                : (constraints.maxWidth > designWidth ? designWidth : constraints.maxWidth);
            final double containerHeight = isDesktopWeb ? designHeight : constraints.maxHeight;

            final double topSafeArea = MediaQuery.of(context).padding.top;
            final double headerTop = topSafeArea > 0 ? (topSafeArea + 18.0) : 56.0;

            // HOME SCREEN total layout:
            // width: 392; height: 844; angle: 0 deg; opacity: 1;
            final Widget screenContent = Opacity(
              opacity: 1.0, // opacity: 1
              child: Transform.rotate(
                angle: 0.0, // angle: 0 deg
                child: Container(
                  width: containerWidth, // width: 392
                  height: containerHeight, // height: 844
                  color: Colors.white, // background: linear-gradient(0deg, #FFFFFF, #FFFFFF)
                  child: Stack(
                    children: [
                      // Top Purple Glow Gradient from user branding specifications:
                      // linear-gradient(180.52deg, #8B53FE -66.75%, rgba(139, 83, 254, 0.37284) -0.59%, rgba(139, 83, 254, 0) 29.8%)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: containerHeight * 0.298,
                        child: const IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(0.009, -1.0),
                                end: Alignment(-0.009, 1.0),
                                stops: [0.0, 1.0],
                                colors: [
                                  Color(0x5F8B53FE), // rgba(139, 83, 254, 0.37284) at top (-0.59%)
                                  Color(0x008B53FE), // rgba(139, 83, 254, 0) at 29.8%
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 1. Pinned Header Layout:
                      // width: 390; height: 36; justify-content: space-between; padding: 20px;
                      Positioned(
                        top: headerTop,
                        left: 0,
                        right: 0,
                        child: ProviderHomeHeader(
                          showLanguageToggle: true,
                          onProfileTap: () => _onTabSelected(2),
                        ),
                      ),

                      // 2. Fixed, non-scrollable Home layout with full touch support
                      Positioned.fill(
                        top: headerTop + ProviderHomeHeader.designHeight + 24.0,
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            scrollbars: false,
                          ),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              right: 20.0,
                              bottom: 12.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Stats Cards (width: double.infinity; height: 68)
                                ProviderStatsCards(
                                  onViewsTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const ProviderDashboardScreen(
                                          initialCardIndex: 0,
                                        ),
                                      ),
                                    );
                                  },
                                  onContactsTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const ProviderDashboardScreen(
                                          initialCardIndex: 1,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 12.0),

                                // Main Screen Text Layout (Online Status Text: height: 33)
                                ProviderOnlineStatusText(isOnline: _isOnline),

                                const SizedBox(height: 10.0),

                                // Online / Offline Toggle & Live Presence (height: 154)
                                ProviderOnlineToggle(
                                  isOnline: _isOnline,
                                  onChanged: (val) {
                                    _setOnlineStatus(val);
                                  },
                                ),

                                const SizedBox(height: 12.0),

                                // Next Card: Vehicle Info Card (height: 150)
                                ProviderVehicleCard(),

                                if (widget.body != null) ...[
                                  const SizedBox(height: 12.0),
                                  widget.body!,
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),

                      // 3. Floating Bottom Navigation Bar (exact width: 292, centered, matches customer side)
                      Positioned(
                        left: (containerWidth - 292.0) / 2,
                        width: 292.0,
                        bottom: isDesktopWeb ? 20.0 : (MediaQuery.of(context).padding.bottom + 12.0),
                        child: BottomNavBarWidget(
                          currentIndex: _currentTabIndex,
                          initialIndex: _currentTabIndex,
                          onTabSelected: _onTabSelected,
                        ),
                      ),

                      // 4. Notification Card Overlay after clicking bell icon
                      //    Exact layout: width: 350; height: 96; top: 106px; left: 21px;
                      if (notifState.isProviderCardVisible &&
                          notifState.providerNotification != null) ...[
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              ref
                                  .read(notificationsProvider.notifier)
                                  .hideProviderCard();
                            },
                          ),
                        ),
                        Positioned(
                          top: 106.0,
                          left: 20.0,
                          right: 20.0,
                          child: NotificationPopupCard(
                            badgeText: context.isArabic
                                ? (notifState.providerNotification?.badgeTextAr ?? '')
                                : (notifState.providerNotification?.badgeTextEn ?? ''),
                            title: context.isArabic
                                ? (notifState.providerNotification?.titleAr ?? '')
                                : (notifState.providerNotification?.titleEn ?? ''),
                            location: context.isArabic
                                ? (notifState.providerNotification?.locationAr ?? '')
                                : (notifState.providerNotification?.locationEn ?? ''),
                            distance: context.isArabic
                                ? (notifState.providerNotification?.distanceAr ?? '')
                                : (notifState.providerNotification?.distanceEn ?? ''),
                            time: context.isArabic
                                ? (notifState.providerNotification?.timeAr ?? '')
                                : (notifState.providerNotification?.timeEn ?? ''),
                            createdAt: notifState.providerNotification?.createdAt,
                            imageAsset: notifState.providerNotification?.imageAsset,
                            onTap: () {
                              ref
                                  .read(notificationsProvider.notifier)
                                  .hideProviderCard();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsScreen(isProvider: true),
                                ),
                              );
                            },
                            onDismiss: () {
                              ref
                                  .read(notificationsProvider.notifier)
                                  .hideProviderCard();
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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
