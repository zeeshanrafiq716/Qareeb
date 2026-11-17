import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

  /// A locked phone GPS fix is typically well under 50m.
  /// Network, Wi-Fi, and IP estimates are coarser and are rejected.
  static bool isPreciseGpsFix(double? accuracyMeters) {
    if (accuracyMeters == null || accuracyMeters.isNaN || accuracyMeters <= 0) {
      return false;
    }
    return accuracyMeters <= 50;
  }

  bool get hasValidDeviceGps =>
      isGpsDetected && !(latitude == 0 && longitude == 0);
}

class LocationService {
  final GoogleMapsService _googleMaps;

  static const MethodChannel _androidGps = MethodChannel('com.qareeb.mobile/gps');
  static const EventChannel _androidGpsStream = EventChannel('com.qareeb.mobile/gps_stream');

  LocationService([dynamic dio, GoogleMapsService? googleMaps])
      : _googleMaps = googleMaps ?? GoogleMapsService();

  bool get _isAndroidNative =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  bool get _isIosNative => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Mobile browsers can expose the phone GPS. Desktop browsers only have IP/Wi-Fi.
  bool get _isMobileWeb =>
      kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

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

  /// Reads one fresh satellite GPS fix.
  /// Network, Wi-Fi, IP, cached, and mock locations are not used.
  Future<UserLocation> acquireDeviceLocation({
    Duration timeout = const Duration(seconds: 25),
  }) async {
    if (_isAndroidNative || _isIosNative) {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationServiceDisabledException();
      }
    } else if (!_isMobileWeb) {
      throw const LocationServiceDisabledException();
    }

    try {
      final permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        await requestPermission();
      }
    } catch (_) {}

    final UserLocation userLoc;
    if (_isAndroidNative) {
      userLoc = await _acquireAndroidGps(timeout);
    } else if (_isIosNative) {
      userLoc = await _acquireIosGps(timeout);
    } else if (_isMobileWeb) {
      userLoc = await _acquireWebGps(timeout);
    } else {
      throw const LocationServiceDisabledException();
    }

    return userLoc;
  }

  Future<UserLocation> _acquireAndroidGps(Duration timeout) async {
    try {
      final raw = await _androidGps.invokeMethod<dynamic>('getGpsFix', {
        'timeoutMs': timeout.inMilliseconds,
      });
      final loc = await _userLocationFromRaw(raw);
      if (loc == null) {
        throw const LocationServiceDisabledException();
      }
      return loc;
    } on LocationServiceDisabledException {
      rethrow;
    } catch (_) {
      throw const LocationServiceDisabledException();
    }
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
      if (!_isLiveGpsPosition(position)) {
        throw const LocationServiceDisabledException();
      }
      return await _userLocationFromCoords(
        position.latitude,
        position.longitude,
        position.accuracy,
      );
    } on LocationServiceDisabledException {
      rethrow;
    } catch (_) {
      throw const LocationServiceDisabledException();
    }
  }

  Future<UserLocation> _acquireWebGps(Duration timeout) async {
    final coords = await getBrowserCoordinates(timeout: timeout);
    final loc = await _userLocationFromRaw(coords);
    if (loc == null) {
      throw const LocationServiceDisabledException();
    }
    return loc;
  }

  bool _isLiveGpsPosition(Position position) {
    if (position.isMocked) return false;
    if (!UserLocation.isPreciseGpsFix(position.accuracy)) return false;
    if (position.latitude == 0 && position.longitude == 0) return false;
    final age = DateTime.now().toUtc().difference(position.timestamp.toUtc()).abs();
    return age <= const Duration(seconds: 20);
  }

  /// Emits satellite GPS updates only. The off sentinel is used when no fix arrives.
  Stream<UserLocation> watchLocation() async* {
    final iterator = StreamIterator<UserLocation>(_liveGpsFixes());
    var deliveredGps = false;
    try {
      final pending = iterator.moveNext();
      bool firstArrived;
      try {
        firstArrived = await pending.timeout(const Duration(seconds: 25));
      } on TimeoutException {
        yield UserLocation.defaultLocation;
        firstArrived = await pending;
      }
      if (!firstArrived) {
        yield UserLocation.defaultLocation;
        return;
      }
      deliveredGps = true;
      yield iterator.current;
      while (await iterator.moveNext()) {
        yield iterator.current;
      }
    } catch (_) {
      if (!deliveredGps) {
        yield UserLocation.defaultLocation;
      }
    } finally {
      await iterator.cancel();
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
    if (_isMobileWeb) {
      yield* _webGpsFixes();
    }
  }

  Stream<UserLocation> _androidGpsFixes() async* {
    await for (final event in _androidGpsStream.receiveBroadcastStream()) {
      final loc = await _userLocationFromRaw(event);
      if (loc != null) yield loc;
    }
  }

  Stream<UserLocation> _iosGpsFixes() async* {
    await for (final position in Geolocator.getPositionStream(
      locationSettings: AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.otherNavigation,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: false,
      ),
    )) {
      if (!_isLiveGpsPosition(position)) continue;
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

  Future<UserLocation?> _userLocationFromRaw(dynamic raw) async {
    if (raw is! Map) return null;
    if (raw['isIp'] == true) return null;
    final lat = (raw['latitude'] as num?)?.toDouble();
    final lng = (raw['longitude'] as num?)?.toDouble();
    final accuracy = (raw['accuracy'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    if (!UserLocation.isPreciseGpsFix(accuracy)) return null;
    if (lat == 0 && lng == 0) return null;
    return _userLocationFromCoords(lat, lng, accuracy!);
  }

  Future<UserLocation> _userLocationFromCoords(
    double lat,
    double lng,
    double accuracy,
  ) async {
    Map<String, String> geoInfo;
    try {
      geoInfo = await _reverseGeocode(lat, lng).timeout(const Duration(seconds: 4));
    } catch (_) {
      final coords = '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      geoInfo = {
        'city': coords,
        'address': 'GPS: $coords',
      };
    }

    final coords = '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    return UserLocation(
      latitude: lat,
      longitude: lng,
      cityName: geoInfo['city'] ?? coords,
      address: geoInfo['address'] ?? 'Current GPS Location',
      isGpsDetected: true,
      accuracy: accuracy,
    );
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
