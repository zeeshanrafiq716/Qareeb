import 'package:geolocator/geolocator.dart';

/// Shared haversine distance formatting for customer ↔ provider surfaces.
class GeoDistance {
  GeoDistance._();

  static bool coordsValid(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (!lat.isFinite || !lng.isFinite) return false;
    return lat.abs() > 0.001 || lng.abs() > 0.001;
  }

  /// Great-circle distance in metres (same as backend [distanceMeters]).
  static double? metersBetween(
    double? fromLat,
    double? fromLng,
    double? toLat,
    double? toLng,
  ) {
    if (!coordsValid(fromLat, fromLng) || !coordsValid(toLat, toLng)) {
      return null;
    }
    final meters = Geolocator.distanceBetween(
      fromLat!,
      fromLng!,
      toLat!,
      toLng!,
    );
    if (!meters.isFinite || meters < 0) return null;
    return meters;
  }

  static String formatDistance(double meters, {required bool isArabic}) {
    if (meters < 1000.0) {
      final rounded = meters.round();
      return isArabic ? '$rounded م' : '$rounded m';
    }
    final km = meters / 1000.0;
    return isArabic ? '${km.toStringAsFixed(1)} كم' : '${km.toStringAsFixed(1)} km';
  }

  static String zeroDistanceLabel({required bool isArabic}) =>
      isArabic ? '0 كم' : '0 km';

  /// Provider reached the customer — stop showing live "distance away".
  static bool isAtCustomerSite({required int step, String? status}) {
    if (step >= 2) return true;
    final s = status?.trim().toLowerCase() ?? '';
    return s == 'arrived' || s == 'in_progress';
  }

  static String formatEta(double meters, {required bool isArabic}) {
    if (meters < 100.0) {
      return isArabic ? 'أقل من دقيقة' : '< 1 min';
    }
    final mins = ((meters / 1000.0) / 30.0 * 60.0).ceil().clamp(1, 180);
    return isArabic ? '$mins د' : '$mins min';
  }

  static double? parseMetersFromLabel(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty || text == '--' || text == '—') return null;
    final cleaned = text
        .replaceAll(RegExp(r'\s*away\s*', caseSensitive: false), '')
        .replaceAll('على بعد ', '')
        .trim();
    final mMatch = RegExp(
      r'^(\d+(?:\.\d+)?)\s*(m|م)\b',
      caseSensitive: false,
    ).firstMatch(cleaned);
    if (mMatch != null) {
      return double.tryParse(mMatch.group(1) ?? '');
    }
    final kmMatch = RegExp(
      r'^(\d+(?:\.\d+)?)\s*(km|كم)\b',
      caseSensitive: false,
    ).firstMatch(cleaned);
    if (kmMatch != null) {
      final km = double.tryParse(kmMatch.group(1) ?? '');
      if (km != null) return km * 1000.0;
    }
    if (cleaned.contains('< 1') || cleaned.contains('أقل من دقيقة')) {
      return 50.0;
    }
    final minMatch = RegExp(
      r'^(\d+)\s*(min|د|دقيقة)\b',
      caseSensitive: false,
    ).firstMatch(cleaned);
    if (minMatch != null) {
      final mins = int.tryParse(minMatch.group(1) ?? '');
      if (mins != null && mins > 0) {
        return (mins / 60.0) * 30.0 * 1000.0;
      }
    }
    return null;
  }

  /// Provider device GPS → customer request pin (symmetric with customer-side UI).
  static String resolveProviderToCustomerLabel({
    required double? providerLat,
    required double? providerLng,
    required bool providerGpsValid,
    required double? customerLat,
    required double? customerLng,
    required bool isArabic,
    int? metadataDistanceMeters,
    String? fallbackLabel,
  }) {
    return _resolveLabel(
      liveMeters: providerGpsValid
          ? metersBetween(providerLat, providerLng, customerLat, customerLng)
          : null,
      metadataDistanceMeters: metadataDistanceMeters,
      fallbackLabel: fallbackLabel,
      isArabic: isArabic,
    );
  }

  static String resolveCustomerToProviderLabel({
    required double? customerLat,
    required double? customerLng,
    required bool customerGpsValid,
    required double? providerLat,
    required double? providerLng,
    required bool isArabic,
    int? metadataDistanceMeters,
    String? fallbackLabel,
  }) {
    return _resolveLabel(
      liveMeters: customerGpsValid
          ? metersBetween(customerLat, customerLng, providerLat, providerLng)
          : null,
      metadataDistanceMeters: metadataDistanceMeters,
      fallbackLabel: fallbackLabel,
      isArabic: isArabic,
    );
  }

  static String _resolveLabel({
    required double? liveMeters,
    required int? metadataDistanceMeters,
    required String? fallbackLabel,
    required bool isArabic,
  }) {
    if (liveMeters != null) {
      return formatDistance(liveMeters, isArabic: isArabic);
    }
    if (metadataDistanceMeters != null && metadataDistanceMeters >= 0) {
      return formatDistance(metadataDistanceMeters.toDouble(), isArabic: isArabic);
    }
    final parsed = parseMetersFromLabel(fallbackLabel);
    if (parsed != null) {
      return formatDistance(parsed, isArabic: isArabic);
    }
    final fallback = fallbackLabel?.trim() ?? '';
    if (fallback.isNotEmpty && fallback != '--' && fallback != '—') {
      return fallback;
    }
    return isArabic ? '—' : '—';
  }

  static Map<String, dynamic> distanceMetadataBundle(double meters) {
    final rounded = meters.round();
    return {
      'distanceMeters': rounded,
      'distance': formatDistance(meters, isArabic: false),
      'eta': formatEta(meters, isArabic: false),
    };
  }

  /// Distance label when ingesting provider notifications (live GPS preferred).
  /// Parses `https://maps.google.com/?q=lat,lng` (or similar) from shared location text.
  static (double?, double?) parseLatLngFromSharedLocation(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return (null, null);
    final q = RegExp(
      r'[?&]q=([-\d.]+)\s*,\s*([-\d.]+)',
      caseSensitive: false,
    ).firstMatch(text);
    if (q != null) {
      final la = double.tryParse(q.group(1) ?? '');
      final lo = double.tryParse(q.group(2) ?? '');
      if (coordsValid(la, lo)) return (la, lo);
    }
    final at = RegExp(r'@([-\d.]+)\s*,\s*([-\d.]+)').firstMatch(text);
    if (at != null) {
      final la = double.tryParse(at.group(1) ?? '');
      final lo = double.tryParse(at.group(2) ?? '');
      if (coordsValid(la, lo)) return (la, lo);
    }
    final plain = RegExp(
      r'^([-\d.]{4,})\s*,\s*([-\d.]{4,})$',
    ).firstMatch(text);
    if (plain != null) {
      final la = double.tryParse(plain.group(1) ?? '');
      final lo = double.tryParse(plain.group(2) ?? '');
      if (coordsValid(la, lo)) return (la, lo);
    }
    return (null, null);
  }

  static bool isGpsCoordinateLabel(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return false;
    if (RegExp(r'^GPS:\s*', caseSensitive: false).hasMatch(text)) return true;
    if (RegExp(r'^Exact GPS:', caseSensitive: false).hasMatch(text)) return true;
    return RegExp(r'^[-\d.]{4,}\s*,\s*[-\d.]{4,}$').hasMatch(text);
  }

  /// Human-readable location for lists and cards (never raw GPS coordinates).
  static String customerLocationLabel(
    String? primary, {
    required bool isArabic,
    String? alternate,
  }) {
    String pick = primary?.trim() ?? '';
    final alt = alternate?.trim() ?? '';
    if (pick.isEmpty || isGpsCoordinateLabel(pick)) {
      if (alt.isNotEmpty && !isGpsCoordinateLabel(alt)) {
        pick = alt;
      }
    }
    if (pick.isEmpty) {
      return isArabic ? 'موقع العميل' : 'Customer location';
    }
    if (isGpsCoordinateLabel(pick)) {
      return isArabic ? 'موقع مشترك' : 'Shared location';
    }
    if (pick == 'Shared via Zesho') {
      return isArabic ? 'موقع مشترك' : 'Shared location';
    }
    if (pick.startsWith('http') && pick.contains('maps.google')) {
      return isArabic ? 'موقع مشترك' : 'Shared location';
    }
    if (pick.startsWith('http')) {
      return isArabic ? 'موقع العميل' : 'Customer location';
    }
    return pick;
  }

  static String labelForProviderNotification({
    required double? providerLat,
    required double? providerLng,
    required bool providerGpsValid,
    required double? customerLat,
    required double? customerLng,
    required Map<String, dynamic> meta,
  }) {
    final metaMeters = (meta['distanceMeters'] as num?)?.round();
    return resolveProviderToCustomerLabel(
      providerLat: providerLat,
      providerLng: providerLng,
      providerGpsValid: providerGpsValid,
      customerLat: customerLat,
      customerLng: customerLng,
      isArabic: false,
      metadataDistanceMeters: metaMeters,
      fallbackLabel: meta['distance']?.toString(),
    );
  }
}