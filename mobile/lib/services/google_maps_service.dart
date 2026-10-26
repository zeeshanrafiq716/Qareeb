import 'dart:math' as math;
import 'package:dio/dio.dart';
import '../core/config/app_config.dart';

/// Structured address result from Google Geocoding / Places
class GoogleAddress {
  final String formattedAddress;
  final String cityName;
  final String locality;
  final String country;
  final double latitude;
  final double longitude;
  final bool isGpsDetected;

  const GoogleAddress({
    required this.formattedAddress,
    required this.cityName,
    this.locality = '',
    this.country = '',
    required this.latitude,
    required this.longitude,
    this.isGpsDetected = true,
  });

  @override
  String toString() => formattedAddress.isNotEmpty ? formattedAddress : cityName;
}

/// Place autocomplete suggestion from Google Places API (New)
class GooglePlaceSuggestion {
  final String placeId;
  final String text;
  final String mainText;
  final String secondaryText;

  const GooglePlaceSuggestion({
    required this.placeId,
    required this.text,
    required this.mainText,
    required this.secondaryText,
  });

  factory GooglePlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final prediction = json['placePrediction'] ?? json;
    final placeId = (prediction['placeId'] ?? prediction['place_id'] ?? '').toString();
    
    final textMap = prediction['text'] as Map<String, dynamic>?;
    final text = textMap?['text']?.toString() ?? prediction['description']?.toString() ?? '';

    final structured = prediction['structuredFormat'] as Map<String, dynamic>?;
    final mainText = structured?['mainText']?['text']?.toString() ?? text;
    final secondaryText = structured?['secondaryText']?['text']?.toString() ?? '';

    return GooglePlaceSuggestion(
      placeId: placeId,
      text: text,
      mainText: mainText,
      secondaryText: secondaryText,
    );
  }
}

/// Computed route with distance, duration, and optional polyline from Google Routes API (New)
class GoogleRouteResult {
  final int distanceMeters;
  final double distanceKm;
  final String distanceText;
  final int durationSeconds;
  final int durationMinutes;
  final String durationText;
  final String? encodedPolyline;
  final bool isFallback;

  const GoogleRouteResult({
    required this.distanceMeters,
    required this.distanceKm,
    required this.distanceText,
    required this.durationSeconds,
    required this.durationMinutes,
    required this.durationText,
    this.encodedPolyline,
    this.isFallback = false,
  });

  factory GoogleRouteResult.fromRoutesApi(Map<String, dynamic> json) {
    final routes = json['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      throw Exception('No routes found');
    }

    final route = routes.first as Map<String, dynamic>;
    final distanceMeters = (route['distanceMeters'] as num?)?.toInt() ?? 0;
    final durationStr = route['duration']?.toString() ?? '0s'; // e.g. "227s"
    final durationSeconds = int.tryParse(durationStr.replaceAll('s', '')) ?? 0;

    final distanceKm = distanceMeters / 1000.0;
    final durationMinutes = (durationSeconds / 60).ceil();

    final polylineMap = route['polyline'] as Map<String, dynamic>?;
    final encodedPolyline = polylineMap?['encodedPolyline']?.toString();

    return GoogleRouteResult(
      distanceMeters: distanceMeters,
      distanceKm: distanceKm,
      distanceText: distanceKm >= 1.0 ? '${distanceKm.toStringAsFixed(1)} km' : '$distanceMeters m',
      durationSeconds: durationSeconds,
      durationMinutes: durationMinutes,
      durationText: durationMinutes > 1 ? '$durationMinutes mins' : '1 min',
      encodedPolyline: encodedPolyline,
      isFallback: false,
    );
  }

  /// Safe offline/fallback calculation using Haversine formula (never gets stuck)
  factory GoogleRouteResult.fallback(double lat1, double lng1, double lat2, double lng2) {
    const double p = 0.017453292519943295; // math.pi / 180
    final double a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((lng2 - lng1) * p)) / 2;
    final double distanceKm = 12742.0 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
    final int distanceMeters = (distanceKm * 1000).round();

    // Estimate city driving at ~30 km/h (0.5 km/min)
    final int durationMinutes = math.max(1, (distanceKm / 0.5).ceil());
    final int durationSeconds = durationMinutes * 60;

    return GoogleRouteResult(
      distanceMeters: distanceMeters,
      distanceKm: distanceKm,
      distanceText: distanceKm >= 1.0 ? '${distanceKm.toStringAsFixed(1)} km' : '$distanceMeters m',
      durationSeconds: durationSeconds,
      durationMinutes: durationMinutes,
      durationText: '$durationMinutes mins',
      encodedPolyline: null,
      isFallback: true,
    );
  }
}

/// High-performance Google Maps Platform Service for Routes, Places, and Geocoding.
/// Engineered with multi-layer timeouts and safe fallbacks to guarantee the app NEVER freezes or gets stuck.
class GoogleMapsService {
  final Dio _dio;
  final String _apiKey;

  GoogleMapsService({Dio? dio, String? apiKey})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 4),
                receiveTimeout: const Duration(seconds: 4),
                sendTimeout: const Duration(seconds: 4),
              ),
            ),
        _apiKey = apiKey ?? AppConfig.googleMapsApiKey;

  String get apiKey => _apiKey;

  // ---------------------------------------------------------------------------
  // 1. REVERSE GEOCODING (Coordinates -> Address & City)
  // ---------------------------------------------------------------------------
  /// Resolves exact human address from coordinates.
  /// Tries Google Places (New) searchNearby & Geocoding first, then falls back seamlessly.
  Future<GoogleAddress> reverseGeocode(double latitude, double longitude, {String lang = 'ar'}) async {
    // 1st Priority: Google Places API (New) searchNearby
    try {
      final response = await _dio.post(
        'https://places.googleapis.com/v1/places:searchNearby',
        data: {
          'maxResultCount': 1,
          'locationRestriction': {
            'circle': {
              'center': {'latitude': latitude, 'longitude': longitude},
              'radius': 150.0,
            }
          }
        },
        options: Options(
          headers: {
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask': 'places.displayName,places.formattedAddress,places.shortFormattedAddress,places.addressComponents',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final places = response.data['places'] as List<dynamic>?;
        if (places != null && places.isNotEmpty) {
          final place = places.first as Map<String, dynamic>;
          final formatted = place['formattedAddress']?.toString() ?? '';
          final shortFormatted = place['shortFormattedAddress']?.toString() ?? '';
          final displayNameMap = place['displayName'] as Map<String, dynamic>?;
          final displayName = displayNameMap?['text']?.toString() ?? '';

          String cityName = shortFormatted.isNotEmpty ? shortFormatted : displayName;
          if (cityName.isEmpty && formatted.isNotEmpty) {
            cityName = formatted.split(',').first.trim();
          }

          return GoogleAddress(
            formattedAddress: formatted.isNotEmpty ? formatted : (displayName.isNotEmpty ? displayName : cityName),
            cityName: cityName.isNotEmpty ? cityName : 'Riyadh',
            latitude: latitude,
            longitude: longitude,
          );
        }
      }
    } catch (_) {
      // Continue to next priority without crashing
    }

    // 2nd Priority: Google Maps Legacy Geocoding API
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '$latitude,$longitude',
          'key': _apiKey,
          'language': lang,
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final status = response.data['status']?.toString();
        if (status == 'OK') {
          final results = response.data['results'] as List<dynamic>?;
          if (results != null && results.isNotEmpty) {
            final first = results.first as Map<String, dynamic>;
            final formatted = first['formatted_address']?.toString() ?? '';
            final components = first['address_components'] as List<dynamic>? ?? [];

            String city = '';
            String locality = '';
            String country = '';

            for (final comp in components) {
              final types = (comp['types'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [];
              if (types.contains('locality')) {
                city = comp['long_name']?.toString() ?? '';
              } else if (types.contains('sublocality') || types.contains('neighborhood')) {
                locality = comp['long_name']?.toString() ?? '';
              } else if (types.contains('country')) {
                country = comp['long_name']?.toString() ?? '';
              }
            }

            final displayCity = city.isNotEmpty ? city : (locality.isNotEmpty ? locality : 'Riyadh');
            return GoogleAddress(
              formattedAddress: formatted.isNotEmpty ? formatted : displayCity,
              cityName: displayCity,
              locality: locality,
              country: country,
              latitude: latitude,
              longitude: longitude,
            );
          }
        }
      }
    } catch (_) {
      // Continue to fast fallback
    }

    // 3rd Priority: Fast Open Fallback (BigDataCloud reverse geocode)
    try {
      final response = await _dio.get(
        'https://api.bigdatacloud.net/data/reverse-geocode-client',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'localityLanguage': lang,
        },
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

        return GoogleAddress(
          formattedAddress: displayAddress,
          cityName: displayCity,
          locality: locality,
          country: country,
          latitude: latitude,
          longitude: longitude,
        );
      }
    } catch (_) {}

    // Safe Guarantee: Coordinates display so UI NEVER hangs or breaks
    final coordStr = '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    return GoogleAddress(
      formattedAddress: 'GPS: $coordStr',
      cityName: coordStr,
      latitude: latitude,
      longitude: longitude,
      isGpsDetected: false,
    );
  }

  // ---------------------------------------------------------------------------
  // 2. PLACES AUTOCOMPLETE (User Search -> Suggestions)
  // ---------------------------------------------------------------------------
  /// Searches places and returns autocomplete suggestions using Places API (New).
  Future<List<GooglePlaceSuggestion>> autocomplete(
    String query, {
    String? languageCode,
    double? latitude,
    double? longitude,
    double radiusMeters = 50000.0,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    try {
      final Map<String, dynamic> body = {
        'input': trimmed,
      };

      if (languageCode != null && languageCode.isNotEmpty) {
        body['languageCode'] = languageCode;
      }

      if (latitude != null && longitude != null) {
        body['locationBias'] = {
          'circle': {
            'center': {'latitude': latitude, 'longitude': longitude},
            'radius': radiusMeters,
          }
        };
      }

      final response = await _dio.post(
        'https://places.googleapis.com/v1/places:autocomplete',
        data: body,
        options: Options(
          headers: {
            'X-Goog-Api-Key': _apiKey,
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final suggestions = response.data['suggestions'] as List<dynamic>?;
        if (suggestions != null) {
          return suggestions
              .whereType<Map<String, dynamic>>()
              .map((s) => GooglePlaceSuggestion.fromJson(s))
              .toList();
        }
      }
    } catch (_) {}

    return const [];
  }

  // ---------------------------------------------------------------------------
  // 3. PLACE DETAILS (Place ID -> Coordinates & Full Address)
  // ---------------------------------------------------------------------------
  /// Resolves full details and coordinates for a selected place.
  Future<GoogleAddress?> getPlaceDetails(String placeId, {String? languageCode}) async {
    if (placeId.isEmpty) return null;

    try {
      final response = await _dio.get(
        'https://places.googleapis.com/v1/places/$placeId',
        queryParameters: languageCode != null ? {'languageCode': languageCode} : null,
        options: Options(
          headers: {
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask': 'id,displayName,formattedAddress,location',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final formatted = data['formattedAddress']?.toString() ?? '';
        final displayNameMap = data['displayName'] as Map<String, dynamic>?;
        final displayName = displayNameMap?['text']?.toString() ?? '';
        final location = data['location'] as Map<String, dynamic>?;

        final double lat = (location?['latitude'] as num?)?.toDouble() ?? 0.0;
        final double lng = (location?['longitude'] as num?)?.toDouble() ?? 0.0;

        return GoogleAddress(
          formattedAddress: formatted.isNotEmpty ? formatted : displayName,
          cityName: displayName.isNotEmpty ? displayName : formatted,
          latitude: lat,
          longitude: lng,
        );
      }
    } catch (_) {}

    return null;
  }

  // ---------------------------------------------------------------------------
  // 4. ROUTES API (Compute Distance, Duration & Direction Polyline)
  // ---------------------------------------------------------------------------
  /// Computes real-world driving route between origin and destination using Routes API (New).
  /// Falls back automatically to offline Haversine formula so the app NEVER hangs!
  Future<GoogleRouteResult> computeRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String travelMode = 'DRIVE',
  }) async {
    try {
      final response = await _dio.post(
        'https://routes.googleapis.com/directions/v2:computeRoutes',
        data: {
          'origin': {
            'location': {
              'latLng': {'latitude': originLat, 'longitude': originLng}
            }
          },
          'destination': {
            'location': {
              'latLng': {'latitude': destLat, 'longitude': destLng}
            }
          },
          'travelMode': travelMode,
          'routingPreference': 'TRAFFIC_UNAWARE',
        },
        options: Options(
          headers: {
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        return GoogleRouteResult.fromRoutesApi(response.data as Map<String, dynamic>);
      }
    } catch (_) {}

    // Fallback guarantee: Never stuck!
    return GoogleRouteResult.fallback(originLat, originLng, destLat, destLng);
  }
}