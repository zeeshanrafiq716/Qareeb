import 'dart:async';
import 'package:flutter/foundation.dart';
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

/// Real-time Categories notifier automatically synced with the backend.
/// When an admin creates, activates, or deletes a category in the admin panel,
/// it automatically detects the change via listEquals and updates the UI
/// without requiring a manual refresh or rebuilding when unchanged.
class CategoriesNotifier extends AsyncNotifier<List<CategoryModel>> {
  Timer? _syncTimer;

  @override
  Future<List<CategoryModel>> build() async {
    final service = ref.watch(backendServiceProvider);

    ref.onDispose(() {
      _syncTimer?.cancel();
    });

    _syncTimer?.cancel();
    // Background sync every 15s to keep state fresh without overwhelming network
    _syncTimer = Timer.periodic(const Duration(seconds: 15), (_) => _syncCategories());

    return await service.getCategories();
  }

  Future<void> _syncCategories() async {
    try {
      final service = ref.read(backendServiceProvider);
      final fresh = await service.getCategories();

      final current = state.value;
      if (current == null || !listEquals(current, fresh)) {
        state = AsyncData(fresh);
      }
    } catch (_) {
      // Keep existing state if offline or transient error
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(backendServiceProvider);
      return await service.getCategories();
    });
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<CategoryModel>>(
  CategoriesNotifier.new,
);

/// Real-time Vehicle Types notifier automatically synced with the backend.
class VehicleTypesNotifier extends AsyncNotifier<List<String>> {
  Timer? _syncTimer;

  @override
  Future<List<String>> build() async {
    final service = ref.watch(backendServiceProvider);

    ref.onDispose(() {
      _syncTimer?.cancel();
    });

    _syncTimer?.cancel();
    // Background sync every 15s to keep state fresh without overwhelming network
    _syncTimer = Timer.periodic(const Duration(seconds: 15), (_) => _syncTypes());

    return await service.getVehicleTypes();
  }

  Future<void> _syncTypes() async {
    try {
      final service = ref.read(backendServiceProvider);
      final fresh = await service.getVehicleTypes();

      final current = state.value;
      if (current == null || !listEquals(current, fresh)) {
        state = AsyncData(fresh);
      }
    } catch (_) {}
  }
}

final vehicleTypesProvider =
    AsyncNotifierProvider<VehicleTypesNotifier, List<String>>(
  VehicleTypesNotifier.new,
);

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
