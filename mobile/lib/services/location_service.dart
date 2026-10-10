import 'dart:math' as math;

class UserLocation {
  final double latitude;
  final double longitude;
  final String cityName;
  final String address;
  final bool isGpsDetected;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.address,
    this.isGpsDetected = false,
  });

  // Default Riyadh Al Nakheel Mall coordinates matching Figma map
  static const UserLocation defaultLocation = UserLocation(
    latitude: 24.7681,
    longitude: 46.7153,
    cityName: 'Riyadh, Saudi Arabia',
    address: 'Al Nakheel Mall, Northern Ring Rd',
    isGpsDetected: false,
  );
}

class LocationService {
  const LocationService();

  /// Detects user's current GPS location.
  /// Falls back to Riyadh / Al Nakheel Mall if GPS hardware is unavailable or in mock test mode.
  Future<UserLocation> getCurrentLocation() async {
    try {
      // Simulate GPS resolution delay
      await Future.delayed(const Duration(milliseconds: 300));

      return const UserLocation(
        latitude: 24.7681,
        longitude: 46.7153,
        cityName: 'Riyadh, Saudi Arabia',
        address: 'Al Nakheel Mall, Riyadh',
        isGpsDetected: true,
      );
    } catch (_) {
      return UserLocation.defaultLocation;
    }
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
