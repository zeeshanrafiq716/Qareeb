import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const String appName = 'Qareeb';
  static const String appVersion = '1.0.0';
  static const String googleMapsApiKey = 'AIzaSyDpF68t3tu43hMcN969pPsub6QCzEwLBLE';

  /// Resolves the default backend base URL depending on platform:
  /// - Android Emulator: 10.0.2.2:3000
  /// - Web / Windows / macOS / iOS Simulator: localhost:3000
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000';
      default:
        return 'http://localhost:3000';
    }
  }

  /// Can be overridden at runtime or via environment variables
  static String baseUrl = defaultBaseUrl;

  /// Default timeout in milliseconds
  static const int connectTimeoutMs = 6000;
  static const int receiveTimeoutMs = 6000;
}
