// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;
import 'dart:async';

/// Helper to safely extract coordinates from Geoposition.
/// IP and network lookups are never used.
Map<String, dynamic>? _extractCoordinates(dynamic pos) {
  if (pos == null) return null;

  try {
    if (pos is html.Geoposition) {
      final coords = pos.coords;
      if (coords != null) {
        final lat = coords.latitude?.toDouble();
        final lng = coords.longitude?.toDouble();
        if (lat != null && lng != null) {
          return <String, dynamic>{
            'latitude': lat,
            'longitude': lng,
            if (coords.accuracy != null) 'accuracy': coords.accuracy!.toDouble(),
          };
        }
      }
    }
  } catch (_) {}

  try {
    final dynamic coords = (pos as dynamic).coords;
    if (coords != null) {
      final dynamic rawLat = coords.latitude;
      final dynamic rawLng = coords.longitude;
      if (rawLat != null && rawLng != null) {
        return {
          'latitude': (rawLat as num).toDouble(),
          'longitude': (rawLng as num).toDouble(),
          if (coords.accuracy != null) 'accuracy': (coords.accuracy as num).toDouble(),
        };
      }
    }
  } catch (_) {}

  try {
    final jsPos = js.JsObject.fromBrowserObject(pos);
    final dynamic coords = jsPos['coords'];
    if (coords != null) {
      final dynamic rawLat = coords['latitude'];
      final dynamic rawLng = coords['longitude'];
      final dynamic rawAcc = coords['accuracy'];
      if (rawLat != null && rawLng != null) {
        return {
          'latitude': (rawLat as num).toDouble(),
          'longitude': (rawLng as num).toDouble(),
          if (rawAcc != null) 'accuracy': (rawAcc as num).toDouble(),
        };
      }
    }
  } catch (_) {}

  return null;
}

/// Fresh browser GPS only. Cached and IP-based results are not requested.
Future<Map<String, dynamic>?> getPlatformCoordinates({Duration? timeout}) async {
  try {
    final geo = html.window.navigator.geolocation;
    final pos = await geo.getCurrentPosition(
      enableHighAccuracy: true,
      timeout: timeout ?? const Duration(seconds: 25),
      maximumAge: Duration.zero,
    );
    return _extractCoordinates(pos);
  } catch (_) {
    return null;
  }
}

/// Continuous browser GPS. Coarse readings are left for the caller to drop.
Stream<Map<String, dynamic>> watchPlatformCoordinates() {
  final controller = StreamController<Map<String, dynamic>>.broadcast();
  try {
    final geo = html.window.navigator.geolocation;
    StreamSubscription? sub;

    void startWatching() {
      sub?.cancel();
      sub = geo.watchPosition(
        enableHighAccuracy: true,
        maximumAge: Duration.zero,
      ).listen(
        (pos) {
          final res = _extractCoordinates(pos);
          if (res != null && !controller.isClosed) {
            controller.add(res);
          }
        },
        onError: (err) {
          if (!controller.isClosed) {
            controller.addError(err);
          }
        },
      );
    }

    startWatching();

    controller.onCancel = () {
      sub?.cancel();
    };
  } catch (_) {}

  return controller.stream;
}
