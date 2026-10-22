import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final AppNotificationItem customerNotification;
  final AppNotificationItem providerNotification;

  const NotificationsState({
    this.hasCustomerUnread = true,
    this.hasProviderUnread = true,
    this.isCustomerCardVisible = false,
    this.isProviderCardVisible = false,
    required this.customerNotification,
    required this.providerNotification,
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
  @override
  NotificationsState build() {
    return const NotificationsState(
      hasCustomerUnread: true,
      hasProviderUnread: true,
      isCustomerCardVisible: false,
      isProviderCardVisible: false,
      customerNotification: AppNotificationItem(
        id: 'cust_notif_1',
        badgeTextEn: 'Service Update',
        badgeTextAr: 'تحديث الخدمة',
        titleEn: 'Battery Jump Start',
        titleAr: 'شحن بطارية',
        locationEn: 'King Abdullah Rd, Riyadh',
        locationAr: 'طريق الملك عبدالله، الرياض',
        distanceEn: '4.1 km  away',
        distanceAr: 'على بعد 4.1 كم',
        timeEn: 'Just now',
        timeAr: 'الآن',
        imageAsset: null,
        isRead: false,
      ),
      providerNotification: AppNotificationItem(
        id: 'prov_notif_1',
        badgeTextEn: 'New Request',
        badgeTextAr: 'طلب جديد',
        titleEn: 'Battery Jump Start',
        titleAr: 'شحن بطارية',
        locationEn: 'King Abdullah Rd, Riyadh',
        locationAr: 'طريق الملك عبدالله، الرياض',
        distanceEn: '4.1 km  away',
        distanceAr: 'على بعد 4.1 كم',
        timeEn: 'Just now',
        timeAr: 'الآن',
        imageAsset: null,
        isRead: false,
      ),
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
