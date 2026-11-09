/// Non-web fallback stub for platform GPS
Future<Map<String, dynamic>?> getPlatformCoordinates() async {
  return null;
}

Stream<Map<String, dynamic>> watchPlatformCoordinates() => const Stream.empty();
