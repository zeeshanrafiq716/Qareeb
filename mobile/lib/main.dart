import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/app_locale.dart';
import 'core/theme/app_theme.dart';
import 'features/customer/auth/data/customer_auth_store.dart';
import 'features/customer/auth/presentation/customer_otp_verification_screen.dart';
import 'features/customer/auth/presentation/customer_signup_screen.dart';
import 'features/emergency/presentation/emergency_services_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/profile/presentation/customer_feedback_support_screen.dart';
import 'features/profile/presentation/customer_personal_info_screen.dart';
import 'features/profile/presentation/notifications_screen.dart';
import 'features/profile/presentation/privacy_security_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/profile/presentation/provider_help_support_screen.dart';
import 'features/provider/auth/data/provider_registration_state.dart';
import 'features/provider/auth/presentation/admin_approval_screen.dart';
import 'features/provider/auth/presentation/otp_verification_screen.dart';
import 'features/provider/auth/presentation/phone_verification_screen.dart';
import 'features/provider/auth/presentation/phone_verified_screen.dart';
import 'features/provider/auth/presentation/provider_blocked_screen.dart';
import 'features/provider/auth/presentation/provider_location_permission_screen.dart';
import 'features/provider/auth/presentation/provider_profile_details_screen.dart';
import 'features/provider/auth/presentation/upload_documents_screen.dart';
import 'features/provider/auth/presentation/vehicle_service_details_screen.dart';
import 'features/provider/home/presentation/provider_home_screen.dart';
import 'features/provider/splash/presentation/provider_splash_screen.dart';
import 'features/provider/theme/provider_text_styles.dart';
import 'features/requests/presentation/requests_screen.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'services/task_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize real task service
  await TaskService.instance.init();

  // Pre-load active mode from persistence before app boots up
  // Ensures provider side directly launches ProviderSplashScreen, never flashing customer splash
  await ProviderRegistrationStore.instance.loadFromPrefs();
  await CustomerAuthStore.instance.loadFromPrefs();
  final initialMode = await ProviderRegistrationStore.instance.getActiveAppMode();

  // Gracefully handle font loading & hero transition errors so offline/CORS/HotRestart issues never crash the app
  PlatformDispatcher.instance.onError = (error, stack) {
    final errorStr = error.toString();
    if (errorStr.contains('Failed to load font') ||
        errorStr.contains('ClientException') ||
        errorStr.contains('fonts.gstatic.com') ||
        errorStr.contains('Noto fonts') ||
        errorStr.contains('heroes that share the same tag') ||
        errorStr.contains('Hero')) {
      debugPrint('Suppressed Hero/Font transition warning: $error');
      return true; // handled, do not crash app
    }
    return false;
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    final errorStr = details.exception.toString();
    if (errorStr.contains('Failed to load font') ||
        errorStr.contains('ClientException') ||
        errorStr.contains('fonts.gstatic.com') ||
        errorStr.contains('Noto fonts') ||
        errorStr.contains('heroes that share the same tag') ||
        errorStr.contains('Hero')) {
      debugPrint('Suppressed Hero/Font transition error: ${details.exception}');
      return;
    }
    FlutterError.presentError(details);
  };

  // Fix orientation to portrait for native mobile experience
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      child: QareebApp(initialMode: initialMode),
    ),
  );
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => const ClampingScrollPhysics();

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class QareebApp extends ConsumerWidget {
  final String initialMode;

  const QareebApp({
    super.key,
    this.initialMode = 'customer',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final isArabic = locale.languageCode == 'ar';
    ProviderTextStyles.isArabic = isArabic;

    return MaterialApp(
      title: 'ZESHO',
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.darkTheme,
      scrollBehavior: const AppScrollBehavior(),
      builder: (context, child) {
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox(),
        );
      },
      home: initialMode == 'provider'
          ? const ProviderSplashScreen()
          : const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/customer/signup': (context) => const CustomerSignupScreen(),
        '/customer/otp': (context) => const CustomerOtpVerificationScreen(),
        '/customer/personal-info': (context) => const CustomerPersonalInfoScreen(),
        '/requests': (context) => const RequestsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/privacy-security': (context) => const PrivacySecurityScreen(),
        '/help-support': (context) => const CustomerFeedbackSupportScreen(),
        '/emergency': (context) => const EmergencyServicesScreen(),
        '/provider': (context) => const ProviderSplashScreen(),
        '/provider/splash': (context) => const ProviderSplashScreen(),
        '/provider/help-support': (context) => const ProviderHelpSupportScreen(),
        '/provider/verification': (context) => const PhoneVerificationScreen(),
        '/provider/otp': (context) => const OtpVerificationScreen(),
        '/provider/verified': (context) => const PhoneVerifiedScreen(),
        '/provider/profile-details': (context) => const ProviderProfileDetailsScreen(),
        '/provider/vehicle-service-details': (context) => const VehicleServiceDetailsScreen(),
        '/provider/upload-documents': (context) => const UploadDocumentsScreen(),
        '/provider/location-permission': (context) => const ProviderLocationPermissionScreen(),
        '/provider/admin-approval': (context) => const AdminApprovalScreen(),
        '/provider/blocked': (context) => const ProviderBlockedScreen(),
        '/provider/home': (context) => const ProviderHomeScreen(),
      },
    );
  }
}
