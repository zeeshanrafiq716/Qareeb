// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';

/// Requests fresh, exact real GPS coordinates from browser Geolocation API.
/// Triggers browser permission dialog: "Allow location access".
/// Features robust fallback:
/// 1. Tries high accuracy (satellite / Wi-Fi trilateration)
/// 2. If high accuracy fails / times out (common on desktop PC without GPS),
///    falls back seamlessly to standard accuracy.
Future<Map<String, double>?> getPlatformCoordinates() async {
  try {
    final geo = html.window.navigator.geolocation;

    // Helper to extract coordinates from Geoposition
    Map<String, double>? extract(html.Geoposition pos) {
      final coords = pos.coords;
      if (coords != null && coords.latitude != null && coords.longitude != null) {
        return {
          'latitude': coords.latitude!.toDouble(),
          'longitude': coords.longitude!.toDouble(),
          if (coords.accuracy != null) 'accuracy': coords.accuracy!.toDouble(),
        };
      }
      return null;
    }

    // 1. Try high accuracy first (5-second timeout)
    try {
      final pos = await geo.getCurrentPosition(
        enableHighAccuracy: true,
        timeout: const Duration(seconds: 5),
        maximumAge: Duration.zero,
      );
      final res = extract(pos);
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
      final res = extract(pos);
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
          final coords = pos.coords;
          if (coords != null && coords.latitude != null && coords.longitude != null) {
            controller.add({
              'latitude': coords.latitude!.toDouble(),
              'longitude': coords.longitude!.toDouble(),
              if (coords.accuracy != null) 'accuracy': coords.accuracy!.toDouble(),
            });
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
