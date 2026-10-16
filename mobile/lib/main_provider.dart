import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/provider/auth/presentation/phone_verification_screen.dart';
import 'features/provider/splash/presentation/provider_splash_screen.dart';
import 'features/provider/theme/provider_colors.dart';

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
class QareebProviderApp extends StatelessWidget {
  const QareebProviderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QAREEB Partner',
      debugShowCheckedModeBanner: false,
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
      },
    );
  }
}
