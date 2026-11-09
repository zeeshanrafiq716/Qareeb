// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;
import 'dart:async';
import 'dart:convert';

/// Helper to safely extract coordinates from Geoposition
Map<String, dynamic>? _extractCoordinates(dynamic pos) {
  if (pos == null) return null;

  // 1. Native dart:html Geoposition object properties (direct, fast, reliable)
  try {
    if (pos is html.Geoposition) {
      final coords = pos.coords;
      if (coords != null) {
        final lat = coords.latitude?.toDouble();
        final lng = coords.longitude?.toDouble();
        if (lat != null && lng != null) {
          final map = <String, dynamic>{
            'latitude': lat,
            'longitude': lng,
          };
          if (coords.accuracy != null) {
            map['accuracy'] = coords.accuracy!.toDouble();
          }
          return map;
        }
      }
    }
  } catch (_) {}

  // 2. Direct property access on dynamic wrapper
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

  // 3. Fallback via JS interop for raw browser objects
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

/// Fast real IP-based geolocation fallback when browser GPS is blocked/unsupported
Future<Map<String, dynamic>?> getIpLocation() async {
  try {
    final req = await html.HttpRequest.getString('https://freeipapi.com/api/json')
        .timeout(const Duration(seconds: 4));
    final data = json.decode(req);
    if (data is Map && data['latitude'] != null && data['longitude'] != null) {
      final lat = (data['latitude'] as num).toDouble();
      final lng = (data['longitude'] as num).toDouble();
      final city = data['cityName']?.toString() ?? '';
      final country = data['countryName']?.toString() ?? '';
      return {
        'latitude': lat,
        'longitude': lng,
        'city': city,
        'country': country,
        'address': city.isNotEmpty && country.isNotEmpty ? '$city, $country' : city,
        'isIp': true,
      };
    }
  } catch (_) {}

  // Secondary fallback: ipapi.co
  try {
    final req = await html.HttpRequest.getString('https://ipapi.co/json/')
        .timeout(const Duration(seconds: 4));
    final data = json.decode(req);
    if (data is Map && data['latitude'] != null && data['longitude'] != null) {
      final lat = (data['latitude'] as num).toDouble();
      final lng = (data['longitude'] as num).toDouble();
      final city = data['city']?.toString() ?? '';
      final country = data['country_name']?.toString() ?? '';
      return {
        'latitude': lat,
        'longitude': lng,
        'city': city,
        'country': country,
        'address': city.isNotEmpty && country.isNotEmpty ? '$city, $country' : city,
        'isIp': true,
      };
    }
  } catch (_) {}

  return null;
}

/// Requests fresh, exact real GPS coordinates from browser Geolocation API.
/// Triggers browser permission dialog: "Allow location access".
/// If browser GPS fails or is unavailable on desktop, immediately resolves real IP location.
Future<Map<String, dynamic>?> getPlatformCoordinates() async {
  try {
    final geo = html.window.navigator.geolocation;

    // 1. Try browser HTML5 Geolocation with high accuracy (5-second timeout)
    try {
      final pos = await geo.getCurrentPosition(
        enableHighAccuracy: true,
        timeout: const Duration(seconds: 5),
        maximumAge: const Duration(minutes: 2),
      );
      final res = _extractCoordinates(pos);
      if (res != null) return res;
    } catch (_) {}

    // 2. Fallback to standard accuracy (works on Windows / Chrome without dedicated GPS chip)
    try {
      final pos = await geo.getCurrentPosition(
        enableHighAccuracy: false,
        timeout: const Duration(seconds: 6),
        maximumAge: const Duration(minutes: 5),
      );
      final res = _extractCoordinates(pos);
      if (res != null) return res;
    } catch (_) {}
  } catch (_) {}

  // 3. Fast real IP-based geolocation fallback so user location is NEVER fake
  final ipLoc = await getIpLocation();
  if (ipLoc != null) return ipLoc;

  return null;
}

/// Continuous real-time GPS tracking stream from browser.
/// Listens to position updates and automatically handles high/standard accuracy.
Stream<Map<String, dynamic>> watchPlatformCoordinates() {
  final controller = StreamController<Map<String, dynamic>>.broadcast();
  try {
    final geo = html.window.navigator.geolocation;
    StreamSubscription? sub;

    void startWatching({required bool highAccuracy}) {
      sub?.cancel();
      sub = geo.watchPosition(
        enableHighAccuracy: highAccuracy,
        maximumAge: const Duration(minutes: 2),
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
          } else {
            // Location is OFF or permission denied: notify controller
            if (!controller.isClosed) {
              controller.addError(err);
            }
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
