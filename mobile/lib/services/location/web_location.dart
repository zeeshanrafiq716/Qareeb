import 'web_location_stub.dart'
    if (dart.library.html) 'web_location_real.dart';

/// Request a fresh device GPS reading. Never an IP or cached network fix.
Future<Map<String, dynamic>?> getBrowserCoordinates({Duration? timeout}) =>
    getPlatformCoordinates(timeout: timeout);

/// Real-time GPS tracking stream.
Stream<Map<String, dynamic>> watchBrowserCoordinates() => watchPlatformCoordinates();
