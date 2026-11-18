import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens native dialer / WhatsApp. Qareeb does not host calls or chat.
class ContactLauncher {
  ContactLauncher._();

  static String digitsOnly(String phone) => phone.replaceAll(RegExp(r'[^0-9]'), '');

  static String e164OrRaw(String phone) {
    final trimmed = phone.trim();
    if (trimmed.startsWith('+')) return trimmed.replaceAll(RegExp(r'[^\d+]'), '');
    return trimmed.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  static Future<bool> call(String phone) async {
    HapticFeedback.mediumImpact();
    final clean = e164OrRaw(phone);
    if (clean.isEmpty) return false;
    final uri = Uri(scheme: 'tel', path: clean);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> whatsApp(String phone, {String? message}) async {
    HapticFeedback.mediumImpact();
    final digits = digitsOnly(phone);
    if (digits.isEmpty) return false;
    final encoded = message != null && message.isNotEmpty
        ? Uri.encodeComponent(message)
        : null;
    final query = encoded != null ? '&text=$encoded' : '';
    final nativeUri = Uri.parse('whatsapp://send?phone=$digits$query');
    final webPath = encoded != null ? '$digits?text=$encoded' : digits;
    final webUri = Uri.parse('https://wa.me/$webPath');

    try {
      if (await canLaunchUrl(nativeUri)) {
        final ok = await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
        if (ok) return true;
      }
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        return false;
      }
    }
  }

  static Future<bool> shareLocation({
    required String phone,
    required double latitude,
    required double longitude,
    String? providerName,
    bool isArabic = false,
  }) {
    final mapsUrl =
        'https://maps.google.com/?q=${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
    final name = providerName?.trim();
    final message = isArabic
        ? 'مرحباً${name != null && name.isNotEmpty ? ' $name' : ''}، أحتاج خدمتك عبر زيشو. موقعي: $mapsUrl'
        : 'Hi${name != null && name.isNotEmpty ? ' $name' : ''}, I need your service via Zesho. My location: $mapsUrl';
    return whatsApp(phone, message: message);
  }

  static Future<bool> openInstagramDirect() async {
    HapticFeedback.lightImpact();
    const candidates = [
      'instagram://direct-inbox',
      'https://www.instagram.com/direct/inbox/',
    ];
    for (final raw in candidates) {
      final uri = Uri.parse(raw);
      try {
        if (await canLaunchUrl(uri)) {
          final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (ok) return true;
        }
      } catch (_) {}
    }
    return false;
  }

  static Future<bool> sendServiceRequest({
    required String phone,
    required String category,
    String? providerName,
    bool isArabic = false,
  }) {
    final name = providerName?.trim();
    final cat = category.trim();
    final message = isArabic
        ? 'مرحباً${name != null && name.isNotEmpty ? ' $name' : ''}، أريد طلب خدمة${cat.isNotEmpty ? ' ($cat)' : ''} عبر زيشو.'
        : 'Hi${name != null && name.isNotEmpty ? ' $name' : ''}, I would like to request${cat.isNotEmpty ? ' $cat' : ' a service'} via Zesho.';
    return whatsApp(phone, message: message);
  }
}
