import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'features/provider/theme/provider_colors.dart';
import 'features/provider/theme/provider_text_styles.dart';
import 'core/localization/app_locale.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Gracefully handle font network loading errors
  PlatformDispatcher.instance.onError = (error, stack) {
    final errorStr = error.toString();
    if (errorStr.contains('Failed to load font') ||
        errorStr.contains('ClientException') ||
        errorStr.contains('fonts.gstatic.com') ||
        errorStr.contains('Noto fonts')) {
      debugPrint('Font network fallback: $error');
      return true;
    }
    return false;
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    final errorStr = details.exception.toString();
    if (errorStr.contains('Failed to load font') ||
        errorStr.contains('ClientException') ||
        errorStr.contains('fonts.gstatic.com') ||
        errorStr.contains('Noto fonts')) {
      return;
    }
    FlutterError.presentError(details);
  };

  // Portrait orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: QareebProviderApp(),
    ),
  );
}

/// Standalone Provider App Entry Point
/// Isolates provider navigation and themes completely from customer app.
class QareebProviderApp extends ConsumerWidget {
  const QareebProviderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final isArabic = locale.languageCode == 'ar';
    ProviderTextStyles.isArabic = isArabic;

    return MaterialApp(
      title: 'QAREEB Partner',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) {
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox(),
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ProviderColors.background,
        primaryColor: ProviderColors.mintAccent,
        colorScheme: const ColorScheme.dark(
          primary: ProviderColors.mintAccent,
          secondary: ProviderColors.mintGlow,
          surface: Color(0xFF253330),
          onPrimary: ProviderColors.background,
          onSurface: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ProviderSplashScreen(),
        '/splash': (context) => const ProviderSplashScreen(),
        '/verification': (context) => const PhoneVerificationScreen(),
        '/phone-verification': (context) => const PhoneVerificationScreen(),
        '/otp': (context) => const OtpVerificationScreen(),
        '/otp-verification': (context) => const OtpVerificationScreen(),
        '/verified': (context) => const PhoneVerifiedScreen(),
        '/phone-verified': (context) => const PhoneVerifiedScreen(),
        '/profile-details': (context) => const ProviderProfileDetailsScreen(),
        '/provider-profile-details': (context) => const ProviderProfileDetailsScreen(),
        '/vehicle-service-details': (context) => const VehicleServiceDetailsScreen(),
        '/provider/vehicle-service-details': (context) => const VehicleServiceDetailsScreen(),
        '/upload-documents': (context) => const UploadDocumentsScreen(),
        '/provider/upload-documents': (context) => const UploadDocumentsScreen(),
        '/location-permission': (context) => const ProviderLocationPermissionScreen(),
        '/provider/location-permission': (context) => const ProviderLocationPermissionScreen(),
        '/allow-location': (context) => const ProviderLocationPermissionScreen(),
        '/admin-approval': (context) => const AdminApprovalScreen(),
        '/provider/admin-approval': (context) => const AdminApprovalScreen(),
        '/home': (context) => const ProviderHomeScreen(),
        '/provider/home': (context) => const ProviderHomeScreen(),
        '/provider-home': (context) => const ProviderHomeScreen(),
      },
    );
  }
}
