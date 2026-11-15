import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const String appName = 'Zesho';
  static const String appVersion = '1.0.0';
  static const String googleMapsApiKey = 'AIzaSyDpF68t3tu43hMcN969pPsub6QCzEwLBLE';

  /// Live Production Backend Server URL
  static const String productionBaseUrl = 'https://zesho.tech';

  /// Resolves the default backend base URL:
  /// - Web / Chrome debug: http://localhost:3000
  /// - Android Emulator: http://10.0.2.2:3000
  /// - Physical device / Production: https://zesho.tech
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    if (kDebugMode && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return productionBaseUrl;
  }

  static String? _customBaseUrl;

  /// Dynamically resolves the active base URL:
  /// - Web / Chrome debug: http://localhost:3000
  /// - Android Emulator: http://10.0.2.2:3000
  /// - Physical device / Production: https://zesho.tech
  static String get baseUrl => _customBaseUrl ?? defaultBaseUrl;

  static set baseUrl(String value) {
    _customBaseUrl = value;
  }

  /// Default timeout in milliseconds
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 10000;
}
