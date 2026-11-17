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
import 'features/splash/presentation/app_mode_selection_screen.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'services/task_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
    const ProviderScope(
      child: QareebAppRoot(),
    ),
  );
}

/// Boots persisted state after the first frame so cold starts never sit on a gray native window.
class QareebAppRoot extends StatefulWidget {
  const QareebAppRoot({super.key});

  @override
  State<QareebAppRoot> createState() => _QareebAppRootState();
}

class _QareebAppRootState extends State<QareebAppRoot> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await TaskService.instance.init();
      await ProviderRegistrationStore.instance.loadFromPrefs();
      await CustomerAuthStore.instance.loadFromPrefs();
      if (!mounted) return;
      setState(() => _ready = true);
    } catch (e) {
      debugPrint('Bootstrap error: $e');
      if (!mounted) return;
      setState(() => _ready = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _BootstrapPlaceholder(),
      );
    }
    return const QareebApp();
  }
}

class _BootstrapPlaceholder extends StatelessWidget {
  const _BootstrapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFF8B53FE),
          ),
        ),
      ),
    );
  }
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
  const QareebApp({super.key});

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
      home: const AppModeSelectionScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/app-mode': (context) => const AppModeSelectionScreen(),
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
