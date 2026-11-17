import 'package:shared_preferences/shared_preferences.dart';

/// Tracks when the provider went online so the home timer is real (not fake).
class ProviderOnlineSession {
  ProviderOnlineSession._();

  static const _prefsKey = 'provider_online_since_ms';
  static int? _sinceEpochMs;

  static Future<void> loadPersisted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getInt(_prefsKey);
      if (v != null && v > 0) _sinceEpochMs = v;
    } catch (_) {}
  }

  static Future<void> goOnline() async {
    _sinceEpochMs = DateTime.now().millisecondsSinceEpoch;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKey, _sinceEpochMs!);
    } catch (_) {}
  }

  static Future<void> goOffline() async {
    _sinceEpochMs = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (_) {}
  }

  static bool get hasActiveSession => _sinceEpochMs != null;

  static int elapsedSeconds() {
    final since = _sinceEpochMs;
    if (since == null) return 0;
    final diff = DateTime.now().millisecondsSinceEpoch - since;
    if (diff < 0) return 0;
    return diff ~/ 1000;
  }
}