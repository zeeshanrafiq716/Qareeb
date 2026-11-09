import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/task_service.dart';
import 'package:mobile/providers/notifications_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TaskService.instance.init();
    await TaskService.instance.clearAll();
  });

  test('Notification state synchronizes dynamically with TaskService', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial state: no active task, no unread notifications
    var notifState = container.read(notificationsProvider);
    expect(notifState.hasCustomerUnread, isFalse);
    expect(notifState.customerNotification, isNull);

    // Create a real customer request
    await TaskService.instance.createCustomerRequest(
      providerName: 'Fahad Towing',
      serviceCategory: 'Tow Truck',
      distance: '2.5 km',
      eta: '10 min',
      vehicleName: 'Flatbed Truck',
      customerName: 'Saleh',
      customerLocation: 'Olaya, Riyadh',
    );

    // Check notification auto-updated
    notifState = container.read(notificationsProvider);
    expect(notifState.hasCustomerUnread, isTrue);
    expect(notifState.customerNotification, isNotNull);
    expect(notifState.customerNotification!.badgeTextEn, 'On The Way');
    expect(notifState.customerNotification!.titleEn, contains('Fahad Towing'));
    expect(notifState.customerNotification!.distanceEn, contains('2.5 km'));

    // Toggle customer card opens the popup and marks as read
    container.read(notificationsProvider.notifier).toggleCustomerCard();
    notifState = container.read(notificationsProvider);
    expect(notifState.isCustomerCardVisible, isTrue);
    expect(notifState.hasCustomerUnread, isFalse);

    // Dismissing customer notification hides the card
    container.read(notificationsProvider.notifier).dismissCustomerNotification();
    notifState = container.read(notificationsProvider);
    expect(notifState.isCustomerCardVisible, isFalse);
  });
}

