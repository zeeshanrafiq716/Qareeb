import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../models/category_model.dart';
import '../models/health_status_model.dart';
import '../services/backend_service.dart';

import '../models/provider_model.dart';
import '../services/location_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final backendServiceProvider = Provider<BackendService>((ref) {
  final client = ref.watch(apiClientProvider);
  return BackendService(client);
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});

final userLocationProvider = FutureProvider<UserLocation>((ref) async {
  final locService = ref.watch(locationServiceProvider);
  return await locService.getCurrentLocation();
});

final healthCheckProvider = FutureProvider<HealthStatusModel>((ref) async {
  final service = ref.watch(backendServiceProvider);
  return await service.checkHealth();
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final service = ref.watch(backendServiceProvider);
  return await service.getCategories();
});

final nearbyProvidersProvider = FutureProvider<List<ProviderMarkerModel>>((ref) async {
  final userLocAsync = await ref.watch(userLocationProvider.future);
  final backendService = ref.watch(backendServiceProvider);

  return await backendService.getNearbyProviders(
    latitude: userLocAsync.latitude,
    longitude: userLocAsync.longitude,
    radiusKm: 5.0,
  );
});

