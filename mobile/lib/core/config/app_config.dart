class AppConfig {
  AppConfig._();

  static const String appName = 'Qareeb';
  static const String appVersion = '1.0.0';
  static const String googleMapsApiKey = 'AIzaSyDpF68t3tu43hMcN969pPsub6QCzEwLBLE';

  /// Live Production Backend Server URL
  static const String productionBaseUrl = 'https://zesho.tech';

  /// Resolves the default backend base URL:
  static String get defaultBaseUrl {
    return productionBaseUrl;
  }

  /// Can be overridden at runtime or via environment variables
  static String baseUrl = defaultBaseUrl;

  /// Default timeout in milliseconds
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 10000;
}
