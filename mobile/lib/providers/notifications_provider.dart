import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/task_service.dart';

/// Single Notification Model matching exact Figma specifications
class AppNotificationItem {
  final String id;
  final String badgeTextEn;
  final String badgeTextAr;
  final String titleEn;
  final String titleAr;
  final String locationEn;
  final String locationAr;
  final String distanceEn;
  final String distanceAr;
  final String timeEn;
  final String timeAr;
  final DateTime? createdAt;
  final String? imageAsset;
  final bool isRead;

  const AppNotificationItem({
    required this.id,
    required this.badgeTextEn,
    required this.badgeTextAr,
    required this.titleEn,
    required this.titleAr,
    required this.locationEn,
    required this.locationAr,
    required this.distanceEn,
    required this.distanceAr,
    required this.timeEn,
    required this.timeAr,
    this.createdAt,
    this.imageAsset,
    this.isRead = false,
  });

  bool get isExpired {
    final ts = createdAt;
    if (ts == null) return false;
    final diff = DateTime.now().toUtc().difference(ts.toUtc());
    return !diff.isNegative && diff > const Duration(hours: 24);
  }

  AppNotificationItem copyWith({
    String? id,
    String? badgeTextEn,
    String? badgeTextAr,
    String? titleEn,
    String? titleAr,
    String? locationEn,
    String? locationAr,
    String? distanceEn,
    String? distanceAr,
    String? timeEn,
    String? timeAr,
    DateTime? createdAt,
    String? imageAsset,
    bool? isRead,
  }) {
    return AppNotificationItem(
      id: id ?? this.id,
      badgeTextEn: badgeTextEn ?? this.badgeTextEn,
      badgeTextAr: badgeTextAr ?? this.badgeTextAr,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      locationEn: locationEn ?? this.locationEn,
      locationAr: locationAr ?? this.locationAr,
      distanceEn: distanceEn ?? this.distanceEn,
      distanceAr: distanceAr ?? this.distanceAr,
      timeEn: timeEn ?? this.timeEn,
      timeAr: timeAr ?? this.timeAr,
      createdAt: createdAt ?? this.createdAt,
      imageAsset: imageAsset ?? this.imageAsset,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// State for Notifications across Customer and Provider
class NotificationsState {
  final bool hasCustomerUnread;
  final bool hasProviderUnread;
  final bool isCustomerCardVisible;
  final bool isProviderCardVisible;
  final AppNotificationItem? customerNotification;
  final AppNotificationItem? providerNotification;
  final List<AppNotificationItem> customerHistory;

  const NotificationsState({
    this.hasCustomerUnread = false,
    this.hasProviderUnread = false,
    this.isCustomerCardVisible = false,
    this.isProviderCardVisible = false,
    this.customerNotification,
    this.providerNotification,
    this.customerHistory = const [],
  });

  NotificationsState copyWith({
    bool? hasCustomerUnread,
    bool? hasProviderUnread,
    bool? isCustomerCardVisible,
    bool? isProviderCardVisible,
    AppNotificationItem? customerNotification,
    bool clearCustomerNotification = false,
    AppNotificationItem? providerNotification,
    bool clearProviderNotification = false,
    List<AppNotificationItem>? customerHistory,
  }) {
    return NotificationsState(
      hasCustomerUnread: hasCustomerUnread ?? this.hasCustomerUnread,
      hasProviderUnread: hasProviderUnread ?? this.hasProviderUnread,
      isCustomerCardVisible: isCustomerCardVisible ?? this.isCustomerCardVisible,
      isProviderCardVisible: isProviderCardVisible ?? this.isProviderCardVisible,
      customerNotification: clearCustomerNotification
          ? null
          : (customerNotification ?? this.customerNotification),
      providerNotification: clearProviderNotification
          ? null
          : (providerNotification ?? this.providerNotification),
      customerHistory: customerHistory ?? this.customerHistory,
    );
  }
}

/// Reactive Notifier managing notifications state for Customer and Provider
class NotificationsNotifier extends Notifier<NotificationsState> {
  VoidCallback? _taskListener;
  Timer? _providerAutoHideTimer;
  Timer? _customerAutoHideTimer;
  bool _isInitialized = false;
  final Set<String> _notifiedCustomerKeys = <String>{};

  @override
  NotificationsState build() {
    _isInitialized = false;
    _initTaskSync();
    ref.onDispose(() {
      _isInitialized = false;
      _providerAutoHideTimer?.cancel();
      _customerAutoHideTimer?.cancel();
    });
    final initial = _buildStateFromTask(
      TaskService.instance.activeTask,
      previousState: const NotificationsState(),
    );
    _isInitialized = true;
    return initial;
  }

  void _initTaskSync() {
    _taskListener = () {
      if (!_isInitialized) return;
      final task = TaskService.instance.activeTask;
      final updatedState = _buildStateFromTask(
        task,
        previousState: state,
        markUnread: true,
      );
      state = updatedState;
    };
    TaskService.instance.activeTaskNotifier.addListener(_taskListener!);
    ref.onDispose(() {
      if (_taskListener != null) {
        TaskService.instance.activeTaskNotifier.removeListener(_taskListener!);
      }
    });
  }

  NotificationsState _buildStateFromTask(
    ServiceTask? task, {
    required NotificationsState previousState,
    bool markUnread = false,
  }) {
    if (task == null) {
      final keepProviderNotif = previousState.providerNotification != null &&
          !previousState.providerNotification!.isExpired;
      return NotificationsState(
        hasCustomerUnread: previousState.hasCustomerUnread,
        hasProviderUnread: keepProviderNotif ? previousState.hasProviderUnread : false,
        isCustomerCardVisible: previousState.isCustomerCardVisible,
        isProviderCardVisible: keepProviderNotif ? previousState.isProviderCardVisible : false,
        customerNotification: previousState.customerNotification?.isExpired == true
            ? null
            : previousState.customerNotification,
        providerNotification: keepProviderNotif ? previousState.providerNotification : null,
        customerHistory: previousState.customerHistory.where((n) => !n.isExpired).toList(),
      );
    }

    String badgeEn = 'On The Way';
    String badgeAr = 'في الطريق';
    String customerTitleEn = '${task.serviceCategory} • ${task.providerName}';
    String customerTitleAr = '${task.serviceCategory} • ${task.providerName}';
    String providerTitleEn = '${task.serviceCategory} • ${task.customerName}';
    String providerTitleAr = '${task.serviceCategory} • ${task.customerName}';

    switch (task.step) {
      case 0:
        badgeEn = 'Request Sent';
        badgeAr = 'تم إرسال الطلب';
        customerTitleEn = 'Request sent to ${task.providerName}';
        customerTitleAr = 'تم إرسال الطلب إلى ${task.providerName}';
        break;
      case 1:
        badgeEn = 'On The Way';
        badgeAr = 'في الطريق';
        customerTitleEn = '${task.providerName} is on the way';
        customerTitleAr = '${task.providerName} في الطريق إليك';
        break;
      case 2:
        badgeEn = 'Provider Arrived';
        badgeAr = 'وصل المزود';
        customerTitleEn = '${task.providerName} has arrived';
        customerTitleAr = 'وصل ${task.providerName} إلى موقعك';
        break;
      case 3:
        badgeEn = 'In Progress';
        badgeAr = 'جاري التنفيذ';
        customerTitleEn = '${task.serviceCategory} in progress';
        customerTitleAr = '${task.serviceCategory} قيد التنفيذ';
        break;
      case 4:
      default:
        badgeEn = 'Completed';
        badgeAr = 'مكتمل';
        customerTitleEn = 'Service completed successfully';
        customerTitleAr = 'تمت الخدمة بنجاح';
        break;
    }

    final custNotif = AppNotificationItem(
      id: task.id,
      badgeTextEn: badgeEn,
      badgeTextAr: badgeAr,
      titleEn: customerTitleEn,
      titleAr: customerTitleAr,
      locationEn: task.customerLocation,
      locationAr: task.customerLocation,
      distanceEn: '${task.distance} away',
      distanceAr: '${task.distance} على بعد',
      timeEn: task.eta.isNotEmpty ? 'ETA ${task.eta}' : 'Just now',
      timeAr: task.eta.isNotEmpty ? 'الوصول ${task.eta}' : 'الآن',
      createdAt: task.createdAt,
      imageAsset: task.providerAvatar,
    );

    final provNotif = AppNotificationItem(
      id: task.id,
      badgeTextEn: task.step == 0 ? 'New Request' : badgeEn,
      badgeTextAr: task.step == 0 ? 'طلب جديد' : badgeAr,
      titleEn: providerTitleEn,
      titleAr: providerTitleAr,
      locationEn: task.customerLocation,
      locationAr: task.customerLocation,
      distanceEn: '${task.distance} away',
      distanceAr: '${task.distance} على بعد',
      timeEn: 'Just now',
      timeAr: 'الآن',
      createdAt: task.createdAt,
      imageAsset: null,
    );

    return NotificationsState(
      hasCustomerUnread: markUnread ? true : previousState.hasCustomerUnread,
      hasProviderUnread: markUnread ? true : previousState.hasProviderUnread,
      isCustomerCardVisible: previousState.isCustomerCardVisible,
      isProviderCardVisible: previousState.isProviderCardVisible,
      customerNotification: custNotif,
      providerNotification: provNotif,
      customerHistory: previousState.customerHistory.where((n) => !n.isExpired).toList(),
    );
  }

  /// Unified deduplicated customer notification dispatcher for EVERY request step:
  /// Accept ('active'), Reach/Arrive ('arrived'), Start ('in_progress'), Complete ('completed'), Decline/Cancel ('cancelled').
  void notifyCustomerRequestStatusChange({
    required String requestId,
    required String status,
    required String providerName,
    required String serviceCategory,
    String distance = '',
    String? photoUrl,
    String? cancelledBy,
  }) {
    final normalized = status.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'new') return;
    if (normalized == 'cancelled' && cancelledBy?.toLowerCase() == 'customer') return;

    final dedupKey = '${requestId.trim()}_$normalized';
    if (_notifiedCustomerKeys.contains(dedupKey)) return;
    _notifiedCustomerKeys.add(dedupKey);

    final safeProvider = providerName.trim().isNotEmpty ? providerName.trim() : 'Provider';
    final safeCategory = serviceCategory.trim().isNotEmpty ? serviceCategory.trim() : 'Service';
    final safeDist = (distance.trim().isNotEmpty && distance.trim() != '--' && distance.trim() != '—')
        ? distance.trim()
        : '';

    String badgeEn = 'Request Update';
    String badgeAr = 'تحديث الطلب';
    String titleEn = '$safeProvider updated your request';
    String titleAr = 'قام $safeProvider بتحديث طلبك';
    String bodyEn = safeCategory;
    String bodyAr = safeCategory;

    switch (normalized) {
      case 'active':
        badgeEn = 'Request Accepted';
        badgeAr = 'تم قبول الطلب';
        titleEn = '$safeProvider accepted your request';
        titleAr = 'قبل $safeProvider طلبك';
        bodyEn = '$safeCategory • Provider is on the way';
        bodyAr = '$safeCategory • مزود الخدمة في الطريق إليك';
        break;
      case 'arrived':
        badgeEn = 'Provider Arrived';
        badgeAr = 'وصل المزود';
        titleEn = '$safeProvider reached your location';
        titleAr = 'وصل $safeProvider إلى موقعك';
        bodyEn = '$safeCategory • Ready to assist';
        bodyAr = '$safeCategory • جاهز لخدمتك';
        break;
      case 'in_progress':
        badgeEn = 'In Progress';
        badgeAr = 'جاري التنفيذ';
        titleEn = '$safeCategory started';
        titleAr = 'بدأ تنفيذ $safeCategory';
        bodyEn = '$safeProvider is working on your service';
        bodyAr = 'يقوم $safeProvider بتنفيذ خدمتك الآن';
        break;
      case 'completed':
        badgeEn = 'Service Completed';
        badgeAr = 'تمت الخدمة';
        titleEn = '$safeCategory completed';
        titleAr = 'تمت خدمة $safeCategory بنجاح';
        bodyEn = 'Completed by $safeProvider';
        bodyAr = 'أتمها $safeProvider بنجاح';
        break;
      case 'cancelled':
        badgeEn = 'Request Declined';
        badgeAr = 'تم رفض الطلب';
        titleEn = '$safeProvider declined your request';
        titleAr = 'اعتذر $safeProvider عن طلبك';
        bodyEn = safeCategory;
        bodyAr = safeCategory;
        break;
    }

    HapticFeedback.heavyImpact();
    setCustomerNotification(
      AppNotificationItem(
        id: dedupKey,
        badgeTextEn: badgeEn,
        badgeTextAr: badgeAr,
        titleEn: titleEn,
        titleAr: titleAr,
        locationEn: bodyEn,
        locationAr: bodyAr,
        distanceEn: safeDist,
        distanceAr: safeDist,
        timeEn: 'Just now',
        timeAr: 'الآن',
        createdAt: DateTime.now().toUtc(),
        imageAsset: photoUrl,
      ),
      showCard: true,
      autoHideDuration: const Duration(seconds: 4),
    );
  }

  void setCustomerNotification(
    AppNotificationItem? notif, {
    bool showCard = false,
    Duration autoHideDuration = const Duration(seconds: 4),
  }) {
    _customerAutoHideTimer?.cancel();
    if (notif == null || notif.isExpired) {
      state = state.copyWith(
        clearCustomerNotification: true,
        hasCustomerUnread: false,
        isCustomerCardVisible: false,
      );
      return;
    }
    final nextHistory = <AppNotificationItem>[
      notif,
      ...state.customerHistory.where((n) => !n.isExpired && n.id != notif.id),
    ].take(30).toList();

    state = state.copyWith(
      customerNotification: notif,
      customerHistory: nextHistory,
      hasCustomerUnread: true,
      isCustomerCardVisible: showCard ? true : state.isCustomerCardVisible,
    );
    if (showCard) {
      _customerAutoHideTimer = Timer(autoHideDuration, () {
        if (state.isCustomerCardVisible) {
          state = state.copyWith(isCustomerCardVisible: false);
        }
      });
    }
  }

  void setProviderNotification(
    AppNotificationItem? notif, {
    bool showCard = false,
    Duration autoHideDuration = const Duration(seconds: 4),
  }) {
    if (notif == null || notif.isExpired) {
      _providerAutoHideTimer?.cancel();
      state = state.copyWith(
        clearProviderNotification: true,
        hasProviderUnread: false,
        isProviderCardVisible: false,
      );
      return;
    }
    state = state.copyWith(
      providerNotification: notif,
      hasProviderUnread: !notif.isRead,
      isProviderCardVisible: showCard ? true : state.isProviderCardVisible,
    );
    if (showCard) {
      _providerAutoHideTimer?.cancel();
      _providerAutoHideTimer = Timer(autoHideDuration, () {
        if (state.isProviderCardVisible) {
          state = state.copyWith(isProviderCardVisible: false);
        }
      });
    }
  }

  void toggleCustomerCard() {
    _customerAutoHideTimer?.cancel();
    if (state.customerNotification?.isExpired == true) {
      state = state.copyWith(
        clearCustomerNotification: true,
        isCustomerCardVisible: false,
        hasCustomerUnread: false,
      );
      return;
    }
    final nextVisible = !state.isCustomerCardVisible;
    state = state.copyWith(
      isCustomerCardVisible: nextVisible,
      hasCustomerUnread: nextVisible ? false : state.hasCustomerUnread,
    );
  }

  void hideCustomerCard() {
    _customerAutoHideTimer?.cancel();
    if (state.isCustomerCardVisible) {
      state = state.copyWith(isCustomerCardVisible: false);
    }
  }

  void toggleProviderCard() {
    _providerAutoHideTimer?.cancel();
    if (state.providerNotification?.isExpired == true) {
      state = state.copyWith(
        clearProviderNotification: true,
        isProviderCardVisible: false,
        hasProviderUnread: false,
      );
      return;
    }
    final nextVisible = !state.isProviderCardVisible;
    state = state.copyWith(
      isProviderCardVisible: nextVisible,
      hasProviderUnread: nextVisible ? false : state.hasProviderUnread,
    );
  }

  void hideProviderCard() {
    _providerAutoHideTimer?.cancel();
    if (state.isProviderCardVisible) {
      state = state.copyWith(isProviderCardVisible: false);
    }
  }

  void dismissCustomerNotification() {
    _customerAutoHideTimer?.cancel();
    state = state.copyWith(
      isCustomerCardVisible: false,
      hasCustomerUnread: false,
    );
  }

  void dismissProviderNotification() {
    _providerAutoHideTimer?.cancel();
    state = state.copyWith(
      isProviderCardVisible: false,
      hasProviderUnread: false,
    );
  }

  void triggerNotification({required bool isProvider}) {
    if (isProvider) {
      state = state.copyWith(hasProviderUnread: true);
    } else {
      state = state.copyWith(hasCustomerUnread: true);
    }
  }
}

/// Global provider for notifications
final notificationsProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);
