/// Non-web stub. Native GPS is read through the platform location APIs.
Future<Map<String, dynamic>?> getPlatformCoordinates({Duration? timeout}) async {
  return null;
}

Stream<Map<String, dynamic>> watchPlatformCoordinates() => const Stream.empty();
