import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'google_maps_service.dart';
import 'dart:math' as math;
import 'location/web_location.dart';

export 'package:geolocator/geolocator.dart'
    show LocationPermission, LocationAccuracy, LocationServiceDisabledException, PermissionDeniedException;

class UserLocation {
  final double latitude;
  final double longitude;
  final String cityName;
  final String address;
  final bool isGpsDetected;
  final double? accuracy;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.address,
    this.isGpsDetected = false,
    this.accuracy,
  });

  String get coordinatesDisplay =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  String get exactCoordinatesDisplay =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  String get formattedGps =>
      '${latitude.abs().toStringAsFixed(4)}° ${latitude >= 0 ? 'N' : 'S'}, ${longitude.abs().toStringAsFixed(4)}° ${longitude >= 0 ? 'E' : 'W'}';

  UserLocation copyWith({
    double? latitude,
    double? longitude,
    String? cityName,
    String? address,
    bool? isGpsDetected,
    double? accuracy,
  }) {
    return UserLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
      address: address ?? this.address,
      isGpsDetected: isGpsDetected ?? this.isGpsDetected,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  /// Sentinel when no satellite fix is available. Never plot these coordinates.
  static const UserLocation defaultLocation = UserLocation(
    latitude: 0,
    longitude: 0,
    cityName: 'Location is OFF',
    address: 'Device Location is OFF',
    isGpsDetected: false,
  );

  /// Safe land fallback coordinates for initial map viewport only (never plot 0,0 ocean).
  static const double fallbackMapLat = 24.7136;
  static const double fallbackMapLng = 46.6753;

  /// Accept accurate GPS and indoor fused fixes while rejecting coarse IP-level estimates.
  static bool isPreciseGpsFix(double? accuracyMeters) {
    if (accuracyMeters == null || accuracyMeters.isNaN || accuracyMeters <= 0) {
      return false;
    }
    return accuracyMeters <= 250;
  }

  bool get hasValidDeviceGps =>
      isGpsDetected && !(latitude == 0 && longitude == 0);
}

class LocationService {
  final GoogleMapsService _googleMaps;

  /// In-memory cache of the most recent valid device location from this session,
  /// so map screens never flash ocean (0, 0) while streams resubscribe or invalidate.
  static UserLocation? lastKnownValidLocation;

  LocationService([dynamic dio, GoogleMapsService? googleMaps])
      : _googleMaps = googleMaps ?? GoogleMapsService();

  bool get _isAndroidNative =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  bool get _isIosNative => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  bool get _isWebBrowser => kIsWeb;

  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }

  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  /// Fast device location lookup using Android Fused Location / iOS CoreLocation.
  /// Works immediately both indoors and outdoors when device Location is ON.
  Future<UserLocation> acquireDeviceLocation({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (_isAndroidNative || _isIosNative) {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationServiceDisabledException();
      }
      var permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw const PermissionDeniedException('Location permission denied');
      }
    }

    if (_isAndroidNative) {
      return await _acquireAndroidGps(timeout);
    } else if (_isIosNative) {
      return await _acquireIosGps(timeout);
    } else if (_isWebBrowser) {
      return await _acquireWebGps(timeout);
    } else {
      throw const LocationServiceDisabledException();
    }
  }

  /// Instant non-blocking lookup of recent (< 45s) precise non-mocked device position.
  Future<UserLocation?> getFastLastKnownLocation() async {
    if (lastKnownValidLocation != null && lastKnownValidLocation!.hasValidDeviceGps) {
      return lastKnownValidLocation;
    }
    if (!_isAndroidNative && !_isIosNative) return null;
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null &&
          _isValidDevicePosition(
            pos,
            maxAge: const Duration(seconds: 45),
            maxAccuracyMeters: 50.0,
          )) {
        return await _userLocationFromCoords(
          pos.latitude,
          pos.longitude,
          pos.accuracy,
        );
      }
    } catch (_) {}
    return null;
  }

  Future<UserLocation> _acquireAndroidGps(Duration timeout) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: timeout,
        ),
      );
      if (_isValidDevicePosition(
        position,
        maxAge: const Duration(seconds: 20),
        maxAccuracyMeters: 50.0,
      )) {
        return await _userLocationFromCoords(
          position.latitude,
          position.longitude,
          position.accuracy,
        );
      }
    } on LocationServiceDisabledException {
      rethrow;
    } on PermissionDeniedException {
      rethrow;
    } catch (_) {}

    // Indoor fallback: use recent OS last known position if valid, sharp & non-mocked
    final fallback = await getFastLastKnownLocation();
    if (fallback != null && fallback.hasValidDeviceGps) {
      return fallback;
    }
    throw TimeoutException('Unable to get GPS fix within ${timeout.inSeconds}s');
  }

  Future<UserLocation> _acquireIosGps(Duration timeout) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: AppleSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          activityType: ActivityType.otherNavigation,
          pauseLocationUpdatesAutomatically: false,
          allowBackgroundLocationUpdates: false,
          timeLimit: timeout,
        ),
      );
      if (_isValidDevicePosition(position, maxAge: const Duration(seconds: 30))) {
        return await _userLocationFromCoords(
          position.latitude,
          position.longitude,
          position.accuracy,
        );
      }
    } on LocationServiceDisabledException {
      rethrow;
    } on PermissionDeniedException {
      rethrow;
    } catch (_) {}

    final fallback = await getFastLastKnownLocation();
    if (fallback != null && fallback.hasValidDeviceGps) {
      return fallback;
    }
    throw TimeoutException('Unable to get GPS fix within ${timeout.inSeconds}s');
  }

  Future<UserLocation> _acquireWebGps(Duration timeout) async {
    final coords = await getBrowserCoordinates(timeout: timeout);
    final loc = await _userLocationFromRaw(coords);
    if (loc == null) {
      throw const LocationServiceDisabledException();
    }
    return loc;
  }

  bool _isValidDevicePosition(
    Position position, {
    Duration maxAge = const Duration(seconds: 20),
    double maxAccuracyMeters = 50.0,
  }) {
    if (position.isMocked) return false;
    if (position.latitude.isNaN || position.longitude.isNaN) return false;
    if (position.latitude == 0 && position.longitude == 0) return false;
    // Reject stale OS-cached locations so old coordinates never masquerade as live GPS
    final age = DateTime.now().toUtc().difference(position.timestamp.toUtc()).abs();
    if (age > maxAge) return false;
    // Reject coarse cell-tower / Wi-Fi network jumps that produce fake locations & distances
    if (position.accuracy.isNaN || position.accuracy <= 0 || position.accuracy > maxAccuracyMeters) {
      return false;
    }
    // Anti-drift / anti-teleport guard:
    // Once we have a sharp GPS lock (<= 25m), reject degraded accuracy fixes (> 25m)
    // unless the user genuinely moved significantly with good accuracy (<= 35m).
    final prev = lastKnownValidLocation;
    if (prev != null && prev.hasValidDeviceGps) {
      final prevAcc = prev.accuracy ?? 999.0;
      final jumpMeters = Geolocator.distanceBetween(
        prev.latitude,
        prev.longitude,
        position.latitude,
        position.longitude,
      );
      if (prevAcc <= 25.0 && position.accuracy > 25.0) {
        if (position.accuracy > 35.0 || jumpMeters < position.accuracy) {
          return false;
        }
      }
      if (prevAcc <= 35.0 && position.accuracy > prevAcc * 1.8 && position.accuracy > 20.0 && jumpMeters < 60.0) {
        return false;
      }
    }
    return true;
  }

  /// Emits fast initial fix followed by self-healing live GPS updates.
  /// Automatically reconnects if Android/iOS drops the location stream after some time.
  Stream<UserLocation> watchLocation() async* {
    // Deliver instant last-known fix if available so UI/map never stalls
    var deliveredGps = false;
    final fast = await getFastLastKnownLocation();
    if (fast != null && fast.hasValidDeviceGps) {
      deliveredGps = true;
      yield fast;
    }

    while (true) {
      if (_isAndroidNative || _isIosNative) {
        final enabled = await isLocationServiceEnabled();
        if (!enabled) {
          yield UserLocation.defaultLocation;
          await Future<void>.delayed(const Duration(seconds: 3));
          continue;
        }
        final perm = await checkPermission();
        if (perm == LocationPermission.denied ||
            perm == LocationPermission.deniedForever) {
          yield UserLocation.defaultLocation;
          await Future<void>.delayed(const Duration(seconds: 3));
          continue;
        }
      }

      final iterator = StreamIterator<UserLocation>(_liveGpsFixes());
      try {
        final pending = iterator.moveNext();
        bool firstArrived;
        try {
          firstArrived = await pending.timeout(const Duration(seconds: 10));
        } on TimeoutException {
          if (!deliveredGps) {
            final fallback = await getFastLastKnownLocation();
            if (fallback != null && fallback.hasValidDeviceGps) {
              deliveredGps = true;
              yield fallback;
            } else {
              yield UserLocation.defaultLocation;
            }
          }
          firstArrived = await pending;
        }
        if (firstArrived) {
          deliveredGps = true;
          yield iterator.current;
          while (await iterator.moveNext()) {
            deliveredGps = true;
            yield iterator.current;
          }
        }
      } catch (_) {
        // Stream error or OS hiccup -> keep last valid GPS and reconnect cleanly below
        if (!deliveredGps) {
          final fallback = await getFastLastKnownLocation();
          if (fallback != null && fallback.hasValidDeviceGps) {
            deliveredGps = true;
            yield fallback;
          }
        }
      } finally {
        try {
          await iterator.cancel();
        } catch (_) {}
      }

      // Brief backoff before auto-reconnecting the OS location stream
      await Future<void>.delayed(const Duration(seconds: 3));
    }
  }

  Stream<UserLocation> _liveGpsFixes() async* {
    if (_isAndroidNative) {
      yield* _androidGpsFixes();
      return;
    }
    if (_isIosNative) {
      yield* _iosGpsFixes();
      return;
    }
    if (_isWebBrowser) {
      yield* _webGpsFixes();
    }
  }

  Stream<UserLocation> _androidGpsFixes() async* {
    await for (final position in Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 2),
      ),
    )) {
      if (!_isValidDevicePosition(position)) continue;
      yield await _userLocationFromCoords(
        position.latitude,
        position.longitude,
        position.accuracy,
      );
    }
  }

  Stream<UserLocation> _iosGpsFixes() async* {
    await for (final position in Geolocator.getPositionStream(
      locationSettings: AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.otherNavigation,
        distanceFilter: 5,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: false,
      ),
    )) {
      if (!_isValidDevicePosition(position)) continue;
      yield await _userLocationFromCoords(
        position.latitude,
        position.longitude,
        position.accuracy,
      );
    }
  }

  Stream<UserLocation> _webGpsFixes() async* {
    await for (final coords in watchBrowserCoordinates()) {
      if (coords['isIp'] == true) continue;
      final loc = await _userLocationFromRaw(coords);
      if (loc != null) yield loc;
    }
  }

  Future<UserLocation> traceExactGps() => getCurrentLocation();

  Future<UserLocation> getCurrentLocation() async {
    try {
      return await acquireDeviceLocation();
    } catch (_) {
      return UserLocation.defaultLocation;
    }
  }

  bool _isAcceptableBrowserAccuracy(double? accuracyMeters) {
    if (accuracyMeters == null || accuracyMeters.isNaN || accuracyMeters <= 0) {
      return true;
    }
    // Desktop/laptop browsers often report Wi-Fi fixes above 250 m.
    return accuracyMeters <= 10000;
  }

  Future<UserLocation?> _userLocationFromRaw(dynamic raw) async {
    if (raw is! Map) return null;
    if (raw['isIp'] == true) return null;
    final lat = (raw['latitude'] as num?)?.toDouble();
    final lng = (raw['longitude'] as num?)?.toDouble();
    final accuracy = (raw['accuracy'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    final acceptable = kIsWeb
        ? _isAcceptableBrowserAccuracy(accuracy)
        : UserLocation.isPreciseGpsFix(accuracy);
    if (!acceptable) return null;
    if (lat == 0 && lng == 0) return null;
    final double resolvedAccuracy =
        (accuracy == null || accuracy.isNaN || accuracy <= 0) ? 65.0 : accuracy;
    return _userLocationFromCoords(lat, lng, resolvedAccuracy);
  }

  Future<UserLocation> _userLocationFromCoords(
    double lat,
    double lng,
    double accuracy,
  ) async {
    Map<String, String> geoInfo;
    final prev = lastKnownValidLocation;
    final bool reusePrevGeo = prev != null &&
        prev.hasValidDeviceGps &&
        prev.cityName.isNotEmpty &&
        prev.cityName != 'Location is OFF' &&
        !prev.address.startsWith('GPS:') &&
        calculateDistanceKm(prev.latitude, prev.longitude, lat, lng) < 0.15;

    if (reusePrevGeo) {
      geoInfo = {
        'city': prev.cityName,
        'address': prev.address,
      };
    } else {
      try {
        geoInfo = await _reverseGeocode(lat, lng).timeout(const Duration(seconds: 4));
      } catch (_) {
        final coords = '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
        geoInfo = {
          'city': prev?.cityName ?? coords,
          'address': prev?.address ?? 'GPS: $coords',
        };
      }
    }

    final coords = '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    final resolved = UserLocation(
      latitude: lat,
      longitude: lng,
      cityName: geoInfo['city'] ?? coords,
      address: geoInfo['address'] ?? 'Current GPS Location',
      isGpsDetected: true,
      accuracy: accuracy,
    );
    if (resolved.hasValidDeviceGps) {
      lastKnownValidLocation = resolved;
    }
    return resolved;
  }

  Future<Map<String, String>> _reverseGeocode(double lat, double lng) async {
    try {
      final googleAddr = await _googleMaps.reverseGeocode(lat, lng);
      return {
        'city': googleAddr.cityName,
        'address': googleAddr.formattedAddress,
      };
    } catch (_) {
      final coords = '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      return {
        'city': coords,
        'address': 'Exact GPS: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
      };
    }
  }

  double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295;
    final double a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }
}

typedef UserLocationModel = UserLocation;
