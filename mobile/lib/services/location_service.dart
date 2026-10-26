import 'package:geolocator/geolocator.dart';
import 'google_maps_service.dart';
import 'dart:math' as math;
import 'package:dio/dio.dart';
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

  /// 4-decimal coordinates (standard GPS precision, e.g. 31.2049, 73.9431)
  String get coordinatesDisplay =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  /// 6-decimal exact real GPS coordinates (centimeter precision, e.g. 31.204918, 73.943124)
  String get exactCoordinatesDisplay =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  /// Compass formatted coordinates (e.g. 31.2049° N, 73.9431° E)
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

  // Default fallback when GPS is OFF or not yet acquired
  static const UserLocation defaultLocation = UserLocation(
    latitude: 31.5204,
    longitude: 74.3587,
    cityName: 'Location is OFF',
    address: 'Device Location is OFF',
    isGpsDetected: false,
  );
}

class LocationService {
  final Dio _dio;
  final GoogleMapsService _googleMaps;
  static UserLocation? _cachedLocation;

  LocationService([Dio? dio, GoogleMapsService? googleMaps])
      : _dio = dio ?? Dio(),
        _googleMaps = googleMaps ?? GoogleMapsService();

  /// Checks whether GPS / Location services are enabled at the device system level.
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  /// Checks the current location permission status.
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  /// Requests location permission from the device OS / browser.
  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  /// Opens the native device location settings screen so user can toggle GPS ON.
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }

  /// Opens the app's OS settings page so user can grant permissions if blocked.
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  /// Actively enforces device location to be turned ON and permission granted.
  /// Acquires real device GPS coordinates with high accuracy.
  /// Throws [LocationServiceDisabledException] if device GPS is switched off.
  /// Throws [PermissionDeniedException] if user denies permission.
  Future<UserLocation> acquireDeviceLocation({
    Duration timeout = const Duration(seconds: 12),
  }) async {
    // 1. Verify device location service is turned ON
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    // 2. Check and request location permission
    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        throw const PermissionDeniedException('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const PermissionDeniedException('Location permission permanently denied.');
    }

    // 3. Acquire real GPS coordinates from device
    double? lat;
    double? lng;
    double? acc;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      lat = position.latitude;
      lng = position.longitude;
      acc = position.accuracy;
    } catch (_) {
      // Fallback: Try last known location or medium accuracy
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          lat = lastKnown.latitude;
          lng = lastKnown.longitude;
          acc = lastKnown.accuracy;
        } else {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 8),
            ),
          );
          lat = pos.latitude;
          lng = pos.longitude;
          acc = pos.accuracy;
        }
      } catch (_) {
        // Fallback for web if geolocator failed
        final coords = await getBrowserCoordinates();
        if (coords != null && coords['latitude'] != null && coords['longitude'] != null) {
          lat = coords['latitude']!;
          lng = coords['longitude']!;
          acc = coords['accuracy'];
        }
      }
    }

    if (lat == null || lng == null) {
      throw const LocationServiceDisabledException();
    }

    // 4. Reverse geocode to resolve city & address
    final geoInfo = await _reverseGeocode(lat, lng);
    final userLoc = UserLocation(
      latitude: lat,
      longitude: lng,
      cityName: geoInfo['city'] ?? '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
      address: geoInfo['address'] ?? 'Current GPS Location',
      isGpsDetected: true,
      accuracy: acc,
    );

    _cachedLocation = userLoc;
    return userLoc;
  }

  /// Real-time continuous GPS tracking stream.
  /// Emits new exact coordinates whenever the device/browser location updates.
  Stream<UserLocation> watchLocation() async* {
    yield _cachedLocation ?? UserLocation.defaultLocation;

    try {
      final initial = await getCurrentLocation();
      yield initial;
    } catch (_) {
      _cachedLocation = null;
      yield UserLocation.defaultLocation;
    }

    // Listen to real-time device GPS updates
    try {
      await for (final pos in Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      )) {
        final double lat = pos.latitude;
        final double lng = pos.longitude;
        final double acc = pos.accuracy;

        String city = _cachedLocation?.cityName ?? '';
        String addr = _cachedLocation?.address ?? '';

        final bool needsGeocode = city.isEmpty ||
            city == 'Detecting Location...' ||
            city == 'Location is OFF' ||
            _cachedLocation == null ||
            calculateDistanceKm(lat, lng, _cachedLocation!.latitude, _cachedLocation!.longitude) > 0.5;

        if (needsGeocode) {
          final geoInfo = await _reverseGeocode(lat, lng);
          city = geoInfo['city'] ?? '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
          addr = geoInfo['address'] ?? 'Current GPS Location';
        }

        final live = UserLocation(
          latitude: lat,
          longitude: lng,
          cityName: city,
          address: addr,
          isGpsDetected: true,
          accuracy: acc,
        );
        _cachedLocation = live;
        yield live;
      }
    } catch (_) {
      // Fallback: try web location stream if running on web
      try {
        await for (final coords in watchBrowserCoordinates()) {
          if (coords.containsKey('latitude') && coords.containsKey('longitude')) {
            final double lat = coords['latitude']!;
            final double lng = coords['longitude']!;
            final double? acc = coords['accuracy'];

            String city = _cachedLocation?.cityName ?? '';
            String addr = _cachedLocation?.address ?? '';

            final bool needsGeocode = city.isEmpty ||
                city == 'Detecting Location...' ||
                city == 'Location is OFF' ||
                _cachedLocation == null ||
                calculateDistanceKm(lat, lng, _cachedLocation!.latitude, _cachedLocation!.longitude) > 0.5;

            if (needsGeocode) {
              final geoInfo = await _reverseGeocode(lat, lng);
              city = geoInfo['city'] ?? '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
              addr = geoInfo['address'] ?? 'Current GPS Location';
            }

            final live = UserLocation(
              latitude: lat,
              longitude: lng,
              cityName: city,
              address: addr,
              isGpsDetected: true,
              accuracy: acc,
            );
            _cachedLocation = live;
            yield live;
          }
        }
      } catch (_) {
        // Location turned OFF or permission denied
        _cachedLocation = null;
        yield UserLocation.defaultLocation;
      }
    }
  }

  /// Actively trace fresh, exact GPS coordinates from the device / browser.
  /// Bypasses and clears any stale cached coordinates.
  Future<UserLocation> traceExactGps() async {
    _cachedLocation = null;
    return getCurrentLocation();
  }

  Future<UserLocation> getCurrentLocation() async {
    try {
      return await acquireDeviceLocation();
    } catch (_) {
      // When location is OFF on device, do NOT use stale GPS cache.
      _cachedLocation = null;
      return UserLocation.defaultLocation;
    }
  }

  /// Real IP fallback: Resolves user's actual location via client IP address
  /// if browser geolocation permission was denied or unavailable on PC.
  Future<UserLocation?> _getIpFallbackLocation() async {
    try {
      final response = await _dio.get(
        'https://api.bigdatacloud.net/data/reverse-geocode-client',
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();

        if (lat != null && lng != null) {
          final city = (data['city'] ?? data['locality'] ?? data['principalSubdivision'] ?? '').toString().trim();
          final locality = (data['locality'] ?? '').toString().trim();
          final country = (data['countryName'] ?? '').toString().trim();

          final displayCity = city.isNotEmpty
              ? (country.isNotEmpty ? '$city, $country' : city)
              : (country.isNotEmpty ? country : 'Current Location');

          final displayAddress = locality.isNotEmpty
              ? (city.isNotEmpty && locality != city ? '$locality, $city' : locality)
              : displayCity;

          return UserLocation(
            latitude: lat,
            longitude: lng,
            cityName: displayCity,
            address: displayAddress,
            isGpsDetected: true,
            accuracy: 1000.0,
          );
        }
      }
    } catch (_) {}
    return null;
  }

  /// Reverse geocodes latitude/longitude into city & locality name using Google Maps Platform
  Future<Map<String, String>> _reverseGeocode(double lat, double lng) async {
    try {
      final googleAddr = await _googleMaps.reverseGeocode(lat, lng);
      return {
        'city': googleAddr.cityName,
        'address': googleAddr.formattedAddress,
      };
    } catch (_) {
      return {
        'city': 'GPS (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})',
        'address': 'Exact GPS: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
      };
    }
  }
  double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // math.pi / 180
    final double a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }
}

typedef UserLocationModel = UserLocation;
