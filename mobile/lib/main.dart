import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/app_locale.dart';
import 'core/theme/app_theme.dart';
import 'features/emergency/presentation/emergency_services_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/provider/auth/presentation/admin_approval_screen.dart';
import 'features/provider/auth/presentation/otp_verification_screen.dart';
import 'features/provider/auth/presentation/phone_verification_screen.dart';
import 'features/provider/auth/presentation/phone_verified_screen.dart';
import 'features/provider/auth/presentation/provider_location_permission_screen.dart';
import 'features/provider/auth/presentation/provider_profile_details_screen.dart';
import 'features/provider/auth/presentation/upload_documents_screen.dart';
import 'features/provider/auth/presentation/vehicle_service_details_screen.dart';
import 'features/provider/home/presentation/provider_home_screen.dart';
import 'features/provider/splash/presentation/provider_splash_screen.dart';
import 'features/provider/theme/provider_text_styles.dart';
import 'features/requests/presentation/requests_screen.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Gracefully handle font loading network errors so offline/CORS issues never crash the app
  PlatformDispatcher.instance.onError = (error, stack) {
    final errorStr = error.toString();
    if (errorStr.contains('Failed to load font') ||
        errorStr.contains('ClientException') ||
        errorStr.contains('fonts.gstatic.com') ||
        errorStr.contains('Noto fonts')) {
      debugPrint('Font network loading failed, falling back to system font: $error');
      return true; // handled, do not crash app
    }
    return false;
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    final errorStr = details.exception.toString();
    if (errorStr.contains('Failed to load font') ||
        errorStr.contains('ClientException') ||
        errorStr.contains('fonts.gstatic.com') ||
        errorStr.contains('Noto fonts')) {
      debugPrint('Suppressed Flutter font loading error: ${details.exception}');
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
      child: QareebApp(),
    ),
  );
}

class QareebApp extends ConsumerWidget {
  const QareebApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final isArabic = locale.languageCode == 'ar';
    ProviderTextStyles.isArabic = isArabic;

    return MaterialApp(
      title: 'QAREEB',
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.darkTheme,
      builder: (context, child) {
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox(),
        );
      },
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/requests': (context) => const RequestsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/emergency': (context) => const EmergencyServicesScreen(),
        '/provider': (context) => const ProviderSplashScreen(),
        '/provider/splash': (context) => const ProviderSplashScreen(),
        '/provider/verification': (context) => const PhoneVerificationScreen(),
        '/provider/otp': (context) => const OtpVerificationScreen(),
        '/provider/verified': (context) => const PhoneVerifiedScreen(),
        '/provider/profile-details': (context) => const ProviderProfileDetailsScreen(),
        '/provider/vehicle-service-details': (context) => const VehicleServiceDetailsScreen(),
        '/provider/upload-documents': (context) => const UploadDocumentsScreen(),
        '/provider/location-permission': (context) => const ProviderLocationPermissionScreen(),
        '/provider/admin-approval': (context) => const AdminApprovalScreen(),
        '/provider/home': (context) => const ProviderHomeScreen(),
      },
    );
  }
}
