import 'package:flutter/foundation.dart';
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
    this.imageAsset,
    this.isRead = false,
  });

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

  const NotificationsState({
    this.hasCustomerUnread = false,
    this.hasProviderUnread = false,
    this.isCustomerCardVisible = false,
    this.isProviderCardVisible = false,
    this.customerNotification,
    this.providerNotification,
  });

  NotificationsState copyWith({
    bool? hasCustomerUnread,
    bool? hasProviderUnread,
    bool? isCustomerCardVisible,
    bool? isProviderCardVisible,
    AppNotificationItem? customerNotification,
    AppNotificationItem? providerNotification,
  }) {
    return NotificationsState(
      hasCustomerUnread: hasCustomerUnread ?? this.hasCustomerUnread,
      hasProviderUnread: hasProviderUnread ?? this.hasProviderUnread,
      isCustomerCardVisible: isCustomerCardVisible ?? this.isCustomerCardVisible,
      isProviderCardVisible: isProviderCardVisible ?? this.isProviderCardVisible,
      customerNotification: customerNotification ?? this.customerNotification,
      providerNotification: providerNotification ?? this.providerNotification,
    );
  }
}

/// Reactive Notifier managing notifications state for Customer and Provider
class NotificationsNotifier extends Notifier<NotificationsState> {
  VoidCallback? _taskListener;

  @override
  NotificationsState build() {
    _initTaskSync();
    return _buildStateFromTask(TaskService.instance.activeTask);
  }

  void _initTaskSync() {
    _taskListener = () {
      final task = TaskService.instance.activeTask;
      final updatedState = _buildStateFromTask(task, markUnread: true);
      state = updatedState;
    };
    TaskService.instance.activeTaskNotifier.addListener(_taskListener!);
    ref.onDispose(() {
      if (_taskListener != null) {
        TaskService.instance.activeTaskNotifier.removeListener(_taskListener!);
      }
    });
  }

  NotificationsState _buildStateFromTask(ServiceTask? task, {bool markUnread = false}) {
    if (task == null) {
      return NotificationsState(
        hasCustomerUnread: false,
        hasProviderUnread: false,
        isCustomerCardVisible: false,
        isProviderCardVisible: false,
        customerNotification: null,
        providerNotification: null,
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
      imageAsset: task.providerAvatar ?? 'assets/images/driver_avatar.png',
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
      imageAsset: 'assets/images/driver_avatar.png',
    );

    return NotificationsState(
      hasCustomerUnread: markUnread ? true : state.hasCustomerUnread,
      hasProviderUnread: markUnread ? true : state.hasProviderUnread,
      isCustomerCardVisible: state.isCustomerCardVisible,
      isProviderCardVisible: state.isProviderCardVisible,
      customerNotification: custNotif,
      providerNotification: provNotif,
    );
  }

  void setCustomerNotification(AppNotificationItem? notif) {
    state = state.copyWith(
      customerNotification: notif,
      hasCustomerUnread: notif != null,
    );
  }

  void setProviderNotification(AppNotificationItem? notif) {
    state = state.copyWith(
      providerNotification: notif,
      hasProviderUnread: notif != null,
    );
  }

  void toggleCustomerCard() {
    final nextVisible = !state.isCustomerCardVisible;
    state = state.copyWith(
      isCustomerCardVisible: nextVisible,
      hasCustomerUnread: nextVisible ? false : state.hasCustomerUnread,
    );
  }

  void hideCustomerCard() {
    if (state.isCustomerCardVisible) {
      state = state.copyWith(isCustomerCardVisible: false);
    }
  }

  void toggleProviderCard() {
    final nextVisible = !state.isProviderCardVisible;
    state = state.copyWith(
      isProviderCardVisible: nextVisible,
      hasProviderUnread: nextVisible ? false : state.hasProviderUnread,
    );
  }

  void hideProviderCard() {
    if (state.isProviderCardVisible) {
      state = state.copyWith(isProviderCardVisible: false);
    }
  }

  void dismissCustomerNotification() {
    state = state.copyWith(
      isCustomerCardVisible: false,
      hasCustomerUnread: false,
    );
  }

  void dismissProviderNotification() {
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
