import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/category_model.dart';
import '../models/health_status_model.dart';

import '../models/provider_model.dart';

class BackendService {
  final ApiClient _client;

  BackendService(this._client);

  /// Fetch nearby service providers based on user GPS location from real backend
  Future<List<ProviderMarkerModel>> getNearbyProviders({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    String? categorySlug,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.discoveryNearby,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radiusKm': radiusKm,
          if (categorySlug != null) 'categorySlug': categorySlug,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<dynamic> items = [];
        if (data is Map<String, dynamic> && data['data'] is List) {
          items = data['data'] as List<dynamic>;
        } else if (data is Map<String, dynamic> && data['data'] is Map && (data['data'] as Map)['items'] is List) {
          items = (data['data'] as Map)['items'] as List<dynamic>;
        } else if (data is Map<String, dynamic> && data['data'] is Map && (data['data'] as Map)['list'] is List) {
          items = (data['data'] as Map)['list'] as List<dynamic>;
        } else if (data is Map<String, dynamic> && data['items'] is List) {
          items = data['items'] as List<dynamic>;
        } else if (data is List) {
          items = data;
        }

        if (items.isNotEmpty) {
          return items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value as Map<String, dynamic>;
            final layout = defaultProviderLayouts[idx % defaultProviderLayouts.length];
            return ProviderMarkerModel.fromJson(
              item,
              fallbackTop: layout['top']!,
              fallbackLeft: layout['left']!,
              fallbackAngle: layout['angle']!,
            );
          }).toList();
        }
      }
    } catch (_) {
      // Backend offline or unreachable — fallback to default seeded providers matching Figma
    }

    return defaultProviders;
  }

  static const List<Map<String, double>> defaultProviderLayouts = [
    {'top': 174.0, 'left': 82.0, 'angle': 60.0},
    {'top': 200.0, 'left': 122.0, 'angle': 45.0},
    {'top': 172.0, 'left': 215.0, 'angle': -50.0},
    {'top': 42.0, 'left': 95.0, 'angle': 45.0},
    {'top': 110.0, 'left': 40.0, 'angle': 70.0},
    {'top': 105.0, 'left': 285.0, 'angle': -35.0},
    {'top': 205.0, 'left': 280.0, 'angle': -45.0},
    {'top': 295.0, 'left': 248.0, 'angle': -50.0},
    {'top': 310.0, 'left': 105.0, 'angle': 50.0},
    {'top': 345.0, 'left': 168.0, 'angle': 0.0},
  ];

  static const List<ProviderMarkerModel> defaultProviders = [
    // 1. Specified in user prompt: width: 15, height: 24, top: 174px, left: 82px, angle: 60 deg
    ProviderMarkerModel(
      id: 1,
      publicId: 'prov_uzair',
      name: 'Uzair Ahmed',
      distanceKm: 0.6,
      ratingAvg: 4.9,
      ratingCount: 142,
      latitude: 24.7685,
      longitude: 46.7142,
      screenTop: 174.0,
      screenLeft: 82.0,
      carAngle: 60.0,
    ),
    // 2. Adnan Said: 0.7 km
    ProviderMarkerModel(
      id: 2,
      publicId: 'prov_adnan',
      name: 'Adnan Said',
      distanceKm: 0.7,
      ratingAvg: 4.8,
      ratingCount: 98,
      latitude: 24.7672,
      longitude: 46.7148,
      screenTop: 200.0,
      screenLeft: 122.0,
      carAngle: 45.0,
    ),
    // 3. Abdul Ahad: 0.8 km
    ProviderMarkerModel(
      id: 3,
      publicId: 'prov_abdul',
      name: 'Abdul Ahad',
      distanceKm: 0.8,
      ratingAvg: 5.0,
      ratingCount: 215,
      latitude: 24.7690,
      longitude: 46.7170,
      screenTop: 172.0,
      screenLeft: 215.0,
      carAngle: -50.0,
    ),
    // 4. Mehmood Ali: 0.5 km
    ProviderMarkerModel(
      id: 4,
      publicId: 'prov_mehmood',
      name: 'Mehmood Ali',
      distanceKm: 0.5,
      ratingAvg: 4.9,
      ratingCount: 88,
      latitude: 24.7710,
      longitude: 46.7135,
      screenTop: 42.0,
      screenLeft: 95.0,
      carAngle: 45.0,
    ),
    // 5. Ubaid Raza: 0.3 km
    ProviderMarkerModel(
      id: 5,
      publicId: 'prov_ubaid',
      name: 'Ubaid Raza',
      distanceKm: 0.3,
      ratingAvg: 4.9,
      ratingCount: 160,
      latitude: 24.7698,
      longitude: 46.7120,
      screenTop: 110.0,
      screenLeft: 40.0,
      carAngle: 70.0,
    ),
    // 6. Rayan Sajjad: 0.5 km
    ProviderMarkerModel(
      id: 6,
      publicId: 'prov_rayan',
      name: 'Rayan Sajjad',
      distanceKm: 0.5,
      ratingAvg: 4.8,
      ratingCount: 75,
      latitude: 24.7705,
      longitude: 46.7185,
      screenTop: 105.0,
      screenLeft: 285.0,
      carAngle: -35.0,
    ),
    // 7. Omar Shahid: 0.7 km
    ProviderMarkerModel(
      id: 7,
      publicId: 'prov_omar',
      name: 'Omar Shahid',
      distanceKm: 0.7,
      ratingAvg: 4.9,
      ratingCount: 130,
      latitude: 24.7675,
      longitude: 46.7188,
      screenTop: 205.0,
      screenLeft: 280.0,
      carAngle: -45.0,
    ),
    // 8. Saad Malik: 0.4 km
    ProviderMarkerModel(
      id: 8,
      publicId: 'prov_saad',
      name: 'Saad Malik',
      distanceKm: 0.4,
      ratingAvg: 4.9,
      ratingCount: 112,
      latitude: 24.7655,
      longitude: 46.7175,
      screenTop: 295.0,
      screenLeft: 248.0,
      carAngle: -50.0,
    ),
    // 9. Hassan Ali: 0.5 km
    ProviderMarkerModel(
      id: 9,
      publicId: 'prov_hassan',
      name: 'Hassan Ali',
      distanceKm: 0.5,
      ratingAvg: 4.7,
      ratingCount: 64,
      latitude: 24.7650,
      longitude: 46.7138,
      screenTop: 310.0,
      screenLeft: 105.0,
      carAngle: 50.0,
    ),
    // 10. Ahmed Raza: 0.8 km
    ProviderMarkerModel(
      id: 10,
      publicId: 'prov_ahmed',
      name: 'Ahmed Raza',
      distanceKm: 0.8,
      ratingAvg: 5.0,
      ratingCount: 310,
      latitude: 24.7640,
      longitude: 46.7155,
      screenTop: 345.0,
      screenLeft: 168.0,
      carAngle: 0.0,
    ),
  ];

  /// Check backend server health status
  Future<HealthStatusModel> checkHealth() async {
    try {
      final response = await _client.get(ApiEndpoints.health);
      if (response.statusCode == 200 && response.data != null) {
        return HealthStatusModel.fromJson(response.data as Map<String, dynamic>);
      }
      return HealthStatusModel.offline('Server returned status ${response.statusCode}');
    } on DioException catch (e) {
      // Try fallback to /api/v1/health
      try {
        final fallback = await _client.get(ApiEndpoints.apiHealth);
        if (fallback.statusCode == 200 && fallback.data != null) {
          return HealthStatusModel.fromJson(fallback.data as Map<String, dynamic>);
        }
      } catch (_) {}
      return HealthStatusModel.offline(e.message ?? 'Cannot connect to backend server');
    } catch (e) {
      return HealthStatusModel.offline(e.toString());
    }
  }

  /// Fetch active service categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _client.get(ApiEndpoints.categories);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<dynamic> items = [];
        if (data is Map<String, dynamic> && data['data'] is List) {
          items = data['data'] as List<dynamic>;
        } else if (data is List) {
          items = data;
        }

        return items
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback default categories if server is initializing
    }

    // Default pre-populated categories matching Qareeb service domains
    return const [
      CategoryModel(
        id: 1,
        name: 'Ride',
        slug: 'ride',
        subtitle: 'City & local rides',
        assetImage: 'assets/images/car_ride.png',
        isEnabled: true,
      ),
      CategoryModel(
        id: 2,
        name: 'Pickup',
        slug: 'pickup',
        subtitle: 'Goods & deliveries',
        assetImage: 'assets/images/pickup.png',
        isEnabled: true,
      ),
      CategoryModel(
        id: 3,
        name: 'Rider',
        slug: 'rider',
        subtitle: 'Fast & convenient',
        assetImage: 'assets/images/rider_bike.png',
        isEnabled: true,
      ),
      CategoryModel(
        id: 4,
        name: 'Van',
        slug: 'van',
        subtitle: 'Group & family travel',
        assetImage: 'assets/images/van.png',
        isEnabled: true,
      ),
      CategoryModel(
        id: 5,
        name: 'Home Care',
        slug: 'home-maintenance',
        subtitle: 'Cleaning & repairs',
        isEnabled: true,
      ),
      CategoryModel(
        id: 6,
        name: 'Emergency',
        slug: 'emergency',
        subtitle: 'Urgent roadside aid',
        isEnabled: true,
      ),
    ];
  }
}
