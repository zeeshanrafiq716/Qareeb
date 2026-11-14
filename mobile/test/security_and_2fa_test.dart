import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/security/biometric_helper.dart';
import 'package:mobile/core/security/device_session_service.dart';
import 'package:mobile/services/backend_service.dart';
import 'package:mobile/features/customer/auth/data/customer_auth_store.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('2FA State & Preference Persistence Tests', () {
    test('Customer 2FA initial state and toggle persistence', () async {
      final prefs = await SharedPreferences.getInstance();

      // Initial state is null / false
      expect(prefs.getBool('customer_2fa_enabled'), isNull);

      // Enable 2FA with Authenticator method
      await prefs.setBool('customer_2fa_enabled', true);
      await prefs.setString('customer_2fa_method', 'authenticator');
      await prefs.setString('customer_2fa_enrolled_at', DateTime.now().toIso8601String());

      expect(prefs.getBool('customer_2fa_enabled'), isTrue);
      expect(prefs.getString('customer_2fa_method'), equals('authenticator'));

      // Disable 2FA
      await prefs.setBool('customer_2fa_enabled', false);
      expect(prefs.getBool('customer_2fa_enabled'), isFalse);
    });

    test('Provider 2FA initial state and toggle persistence', () async {
      final prefs = await SharedPreferences.getInstance();

      // Initial state is null / false
      expect(prefs.getBool('provider_2fa_enabled'), isNull);

      // Enable Provider 2FA with SMS method
      await prefs.setBool('provider_2fa_enabled', true);
      await prefs.setString('provider_2fa_method', 'sms');
      await prefs.setString('provider_2fa_enrolled_at', DateTime.now().toIso8601String());

      expect(prefs.getBool('provider_2fa_enabled'), isTrue);
      expect(prefs.getString('provider_2fa_method'), equals('sms'));

      // Disable Provider 2FA
      await prefs.setBool('provider_2fa_enabled', false);
      expect(prefs.getBool('provider_2fa_enabled'), isFalse);
    });
  });

  group('Biometric Authentication & Device Session Management Tests', () {
    test('BiometricHelper availability check returns without throwing', () async {
      final available = await BiometricHelper.isBiometricsAvailable();
      expect(available, isA<bool>());
    });

    test('DeviceSessionService manages active sessions and sign-outs', () async {
      final currentDevice = await DeviceSessionService.resolveCurrentDevice();
      expect(currentDevice.id, isNotEmpty);
      expect(currentDevice.name, isNotEmpty);
      expect(currentDevice.isCurrent, isTrue);

      final sessions = await DeviceSessionService.getActiveSessions();
      expect(sessions, isNotEmpty);
      expect(sessions.first.isCurrent, isTrue);

      // We should have seeded secondary sessions
      final otherCountBefore = sessions.where((s) => !s.isCurrent).length;
      expect(otherCountBefore, greaterThan(0));

      // Sign out individual remote session
      final remoteDevice = sessions.firstWhere((s) => !s.isCurrent);
      final didSignOutOne = await DeviceSessionService.signOutDevice(remoteDevice.id);
      expect(didSignOutOne, isTrue);

      final sessionsAfterOne = await DeviceSessionService.getActiveSessions();
      expect(sessionsAfterOne.any((s) => s.id == remoteDevice.id), isFalse);

      // Sign out all remaining other devices
      final removed = await DeviceSessionService.signOutOtherDevices();
      expect(removed, greaterThanOrEqualTo(0));

      final finalSessions = await DeviceSessionService.getActiveSessions();
      // Only current device remains
      expect(finalSessions.length, equals(1));
      expect(finalSessions.first.isCurrent, isTrue);
    });
  });

  group('Apple & Google Compliance: Account Deletion Tests', () {
    test('Customer account deletion wipes local store & preferences', () async {
      final store = CustomerAuthStore.instance;

      // Simulate customer signed up
      await store.signUp(fullName: 'Ahmed Ali', phone: '0501234567');
      expect(store.fullName, equals('Ahmed Ali'));
      expect(store.phone, equals('0501234567'));
      expect(store.hasCompletedSignup, isTrue);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('customer_2fa_enabled', true);
      await prefs.setString('customer_2fa_method', 'sms');

      // Execute account deletion wipe
      await store.clear();
      await prefs.remove('customer_2fa_enabled');
      await prefs.remove('customer_2fa_method');

      expect(store.fullName, isEmpty);
      expect(store.phone, isEmpty);
      expect(store.hasCompletedSignup, isFalse);
      expect(prefs.getBool('customer_2fa_enabled'), isNull);
    });

    test('Provider account deletion wipes local store & preferences', () async {
      final store = ProviderRegistrationStore.instance;

      // Simulate provider registered
      store.update((c) => c.copyWith(phone: '0509876543'));
      expect(store.data.phone, equals('0509876543'));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('provider_2fa_enabled', true);
      await prefs.setString('provider_2fa_method', 'authenticator');

      // Execute account deletion wipe
      await store.clear();
      await prefs.remove('provider_2fa_enabled');
      await prefs.remove('provider_2fa_method');

      expect(store.data.phone, isEmpty);
      expect(prefs.getBool('provider_2fa_enabled'), isNull);
    });

    test('ApiClient exposes delete method and BackendService handles de-registration', () async {
      final client = ApiClient(baseUrl: 'http://127.0.0.1:3000');
      final service = BackendService(client);

      // When backend is not reachable, deleteProviderAccount returns false gracefully without throwing
      final result = await service.deleteProviderAccount();
      expect(result, isFalse);
    });
  });
}
