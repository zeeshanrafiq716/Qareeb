import '../services/google_maps_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../models/category_model.dart';
import '../models/health_status_model.dart';
import '../services/backend_service.dart';
import '../models/provider_model.dart';
import '../models/provider_dashboard_model.dart';
import '../services/location_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final backendServiceProvider = Provider<BackendService>((ref) {
  final client = ref.watch(apiClientProvider);
  return BackendService(client);
});

final googleMapsServiceProvider = Provider<GoogleMapsService>((ref) {
  return GoogleMapsService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  final googleMaps = ref.watch(googleMapsServiceProvider);
  return LocationService(null, googleMaps);
});

/// Continuous real-time GPS tracking stream provider
final userLocationProvider = StreamProvider<UserLocation>((ref) {
  final locService = ref.watch(locationServiceProvider);
  return locService.watchLocation();
});

/// Health check provider
final healthCheckProvider = FutureProvider<HealthStatusModel>((ref) async {
  final service = ref.watch(backendServiceProvider);
  return await service.checkHealth();
});

/// Categories provider
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final service = ref.watch(backendServiceProvider);
  return await service.getCategories();
});

/// Real nearby providers based on real user GPS coordinates
final nearbyProvidersProvider = FutureProvider<List<ProviderMarkerModel>>((ref) async {
  final userLoc = ref.watch(userLocationProvider).value ?? UserLocation.defaultLocation;
  final backendService = ref.watch(backendServiceProvider);

  return await backendService.getNearbyProviders(
    latitude: userLoc.latitude,
    longitude: userLoc.longitude,
    radiusKm: 5.0,
  );
});

/// Filtered nearby providers by category slug
final categoryNearbyProvidersProvider =
    FutureProvider.family<List<ProviderMarkerModel>, String?>((ref, categorySlug) async {
  final userLoc = ref.watch(userLocationProvider).value ?? UserLocation.defaultLocation;
  final backendService = ref.watch(backendServiceProvider);

  return await backendService.getNearbyProviders(
    latitude: userLoc.latitude,
    longitude: userLoc.longitude,
    radiusKm: 5.0,
    categorySlug: categorySlug,
  );
});

/// Real provider home quick stats (Views today, Contacts today)
final providerQuickStatsProvider = FutureProvider<ProviderQuickStatsModel>((ref) async {
  final backendService = ref.watch(backendServiceProvider);
  return await backendService.getProviderStats();
});

/// Real provider dashboard analytics data
final providerDashboardProvider = FutureProvider<ProviderDashboardModel>((ref) async {
  final backendService = ref.watch(backendServiceProvider);
  return await backendService.getProviderDashboard();
});
