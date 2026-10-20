/// Non-web fallback stub for platform GPS
Future<Map<String, double>?> getPlatformCoordinates() async {
  return null;
}

Stream<Map<String, double>> watchPlatformCoordinates() => const Stream.empty();
