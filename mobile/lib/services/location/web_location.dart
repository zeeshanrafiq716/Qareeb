import 'web_location_stub.dart'
    if (dart.library.html) 'web_location_real.dart';

/// Request real GPS coordinates cross-platform
Future<Map<String, double>?> getBrowserCoordinates() => getPlatformCoordinates();

/// Real-time continuous GPS tracking stream cross-platform
Stream<Map<String, double>> watchBrowserCoordinates() => watchPlatformCoordinates();
