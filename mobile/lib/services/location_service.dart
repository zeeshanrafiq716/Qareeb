import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'location/web_location.dart';

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

  // Default fallback when GPS is not yet acquired
  static const UserLocation defaultLocation = UserLocation(
    latitude: 31.5204,
    longitude: 74.3587,
    cityName: 'Detecting Location...',
    address: 'Detecting current GPS coordinates',
    isGpsDetected: false,
  );
}

class LocationService {
  final Dio _dio;
  static UserLocation? _cachedLocation;

  LocationService([Dio? dio]) : _dio = dio ?? Dio();

  /// Real-time continuous GPS tracking stream.
  /// Emits new exact coordinates whenever the device/browser location updates.
  Stream<UserLocation> watchLocation() async* {
    if (_cachedLocation != null) {
      yield _cachedLocation!;
    }

    try {
      final initial = await getCurrentLocation();
      _cachedLocation = initial;
      yield initial;
    } catch (_) {}

    await for (final coords in watchBrowserCoordinates()) {
      if (coords.containsKey('latitude') && coords.containsKey('longitude')) {
        final double lat = coords['latitude']!;
        final double lng = coords['longitude']!;
        final double? acc = coords['accuracy'];

        String city = _cachedLocation?.cityName ?? '';
        String addr = _cachedLocation?.address ?? '';

        final bool needsGeocode = city.isEmpty ||
            city == 'Detecting Location...' ||
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
  }

  /// Detects user's real GPS coordinates from browser/platform.
  /// When permission is allowed, obtains device latitude and longitude,
  /// then reverse geocodes to the exact real city name.
  Future<UserLocation> getCurrentLocation() async {
    try {
      final coords = await getBrowserCoordinates();
      if (coords != null &&
          coords['latitude'] != null &&
          coords['longitude'] != null) {
        final double lat = coords['latitude']!;
        final double lng = coords['longitude']!;
        final double? acc = coords['accuracy'];

        // Attempt reverse geocoding to resolve real address & city
        final geoInfo = await _reverseGeocode(lat, lng);

        final result = UserLocation(
          latitude: lat,
          longitude: lng,
          cityName: geoInfo['city'] ?? 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}',
          address: geoInfo['address'] ?? 'Current GPS Location',
          isGpsDetected: true,
          accuracy: acc,
        );
        _cachedLocation = result;
        return result;
      }
    } catch (_) {
      // Fallback below
    }

    // Real IP Geolocation fallback: If browser location is pending or unavailable on desktop PC,
    // detect real location via public client IP address so it NEVER defaults to Saudi Arabia!
    try {
      final ipLoc = await _getIpFallbackLocation();
      if (ipLoc != null) {
        _cachedLocation = ipLoc;
        return ipLoc;
      }
    } catch (_) {}

    return _cachedLocation ?? UserLocation.defaultLocation;
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

  /// Reverse geocodes latitude/longitude into city & locality name
  Future<Map<String, String>> _reverseGeocode(double lat, double lng) async {
    try {
      final response = await _dio.get(
        'https://api.bigdatacloud.net/data/reverse-geocode-client',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'localityLanguage': 'en',
        },
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final city = (data['city'] ?? data['locality'] ?? data['principalSubdivision'] ?? '').toString().trim();
        final locality = (data['locality'] ?? '').toString().trim();
        final country = (data['countryName'] ?? '').toString().trim();

        final displayCity = city.isNotEmpty
            ? (country.isNotEmpty ? '$city, $country' : city)
            : (country.isNotEmpty ? country : 'Current Location');

        final displayAddress = locality.isNotEmpty
            ? (city.isNotEmpty && locality != city ? '$locality, $city' : locality)
            : displayCity;

        return {
          'city': displayCity,
          'address': displayAddress,
        };
      }
    } catch (_) {
      // Return coordinates as label if reverse geocoding API unreachable
    }

    return {
      'city': '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
      'address': 'GPS: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
    };
  }

  /// Calculates distance in km between two GPS coordinates using the Haversine formula
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
