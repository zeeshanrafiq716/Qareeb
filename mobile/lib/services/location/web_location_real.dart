// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;
import 'dart:async';

/// Helper to safely extract coordinates from Geoposition (native JS object)
/// avoiding LegacyJavaScriptObject to Coordinates? type-cast error in DDC/dart2js.
Map<String, double>? _extractCoordinates(dynamic pos) {
  try {
    if (pos == null) return null;
    final jsPos = js.JsObject.fromBrowserObject(pos);
    final dynamic coords = jsPos['coords'];
    if (coords == null) return null;

    final dynamic rawLat = coords['latitude'];
    final dynamic rawLng = coords['longitude'];
    final dynamic rawAcc = coords['accuracy'];

    if (rawLat != null && rawLng != null) {
      final lat = (rawLat as num).toDouble();
      final lng = (rawLng as num).toDouble();
      final acc = rawAcc != null ? (rawAcc as num).toDouble() : null;
      final map = <String, double>{
        'latitude': lat,
        'longitude': lng,
      };
      if (acc != null) {
        map['accuracy'] = acc;
      }
      return map;
    }
  } catch (_) {}
  return null;
}

/// Requests fresh, exact real GPS coordinates from browser Geolocation API.
/// Triggers browser permission dialog: "Allow location access".
/// Features robust fallback:
/// 1. Tries high accuracy (satellite / Wi-Fi trilateration)
/// 2. If high accuracy fails / times out (common on desktop PC without GPS),
///    falls back seamlessly to standard accuracy.
Future<Map<String, double>?> getPlatformCoordinates() async {
  try {
    final geo = html.window.navigator.geolocation;

    // 1. Try high accuracy first (5-second timeout)
    try {
      final pos = await geo.getCurrentPosition(
        enableHighAccuracy: true,
        timeout: const Duration(seconds: 5),
        maximumAge: Duration.zero,
      );
      final res = _extractCoordinates(pos);
      if (res != null) return res;
    } catch (_) {
      // High accuracy failed or timed out on desktop PC, fallback below
    }

    // 2. Fallback to standard accuracy (works reliably on Chrome desktop & Windows)
    try {
      final pos = await geo.getCurrentPosition(
        enableHighAccuracy: false,
        timeout: const Duration(seconds: 8),
        maximumAge: const Duration(minutes: 2),
      );
      final res = _extractCoordinates(pos);
      if (res != null) return res;
    } catch (_) {
      // Standard accuracy failed or permission denied
    }

    return null;
  } catch (_) {
    return null;
  }
}

/// Continuous real-time GPS tracking stream from browser.
/// Listens to position updates and automatically handles high/standard accuracy.
Stream<Map<String, double>> watchPlatformCoordinates() {
  final controller = StreamController<Map<String, double>>.broadcast();
  try {
    final geo = html.window.navigator.geolocation;
    StreamSubscription? sub;

    void startWatching({required bool highAccuracy}) {
      sub?.cancel();
      sub = geo.watchPosition(
        enableHighAccuracy: highAccuracy,
        maximumAge: highAccuracy ? Duration.zero : const Duration(seconds: 15),
      ).listen(
        (pos) {
          final res = _extractCoordinates(pos);
          if (res != null) {
            controller.add(res);
          }
        },
        onError: (err) {
          if (highAccuracy) {
            // If high accuracy errors out on PC, gracefully fall back to standard accuracy
            startWatching(highAccuracy: false);
          }
        },
      );
    }

    startWatching(highAccuracy: true);

    controller.onCancel = () {
      sub?.cancel();
    };
  } catch (_) {}

  return controller.stream;
}
