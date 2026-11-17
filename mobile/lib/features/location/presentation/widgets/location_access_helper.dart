import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../providers/backend_provider.dart';
import '../../../../services/location_service.dart';

enum LocationAccessIssue {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unavailable,
}

/// Friendly, Google Maps–style location prompts (not error snackbars).
class LocationAccessHelper {
  LocationAccessHelper._();

  static Future<LocationAccessIssue> diagnose(LocationService loc) async {
    if (!kIsWeb) {
      final enabled = await loc.isLocationServiceEnabled();
      if (!enabled) return LocationAccessIssue.serviceDisabled;
    }
    final permission = await loc.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return LocationAccessIssue.permissionDeniedForever;
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      return LocationAccessIssue.permissionDenied;
    }
    return LocationAccessIssue.unavailable;
  }

  /// Shows guidance dialog when location is off or permission missing.
  /// Returns `true` if the user completed an enable flow (settings / allow).
  static Future<bool> showEnableLocationDialog(
    BuildContext context,
    WidgetRef ref, {
    LocationAccessIssue? issue,
    String? serviceName,
  }) async {
    final tr = ref.read(translationsProvider);
    final loc = ref.read(locationServiceProvider);
    final resolvedIssue = issue ?? await diagnose(loc);

    final service = (serviceName ?? '').trim();
    final serviceSuffix = service.isNotEmpty
        ? (tr.isArabic ? ' لـ $service' : ' for $service')
        : '';

    late final String title;
    late final String body;
    late final String primaryLabel;
    late final IconData headerIcon;

    switch (resolvedIssue) {
      case LocationAccessIssue.serviceDisabled:
        title = tr.isArabic ? 'فعّل الموقع على هاتفك' : 'Turn on location';
        body = tr.isArabic
            ? 'نستخدم موقعك لعرض الخريطة والمزودين القريبين منك$serviceSuffix. فعّل خدمة الموقع (GPS) ثم ارجع إلى قريب.'
            : 'We use your location to show the map and nearby providers$serviceSuffix. Turn on Location (GPS) in your phone settings, then return to Qareeb.';
        primaryLabel = tr.isArabic ? 'تفعيل الموقع' : 'Turn on location';
        headerIcon = Icons.location_on_rounded;
        break;
      case LocationAccessIssue.permissionDenied:
        title = tr.isArabic ? 'السماح بالوصول للموقع' : 'Allow location access';
        body = tr.isArabic
            ? 'لنعرض موقعك على الخريطة ونجد أقرب مزود$serviceSuffix، اسمح لقريب باستخدام موقعك أثناء استخدام التطبيق.'
            : 'To show your position on the map and find the nearest providers$serviceSuffix, allow Qareeb to access your location while you use the app.';
        primaryLabel = tr.isArabic ? 'متابعة' : 'Continue';
        headerIcon = Icons.near_me_rounded;
        break;
      case LocationAccessIssue.permissionDeniedForever:
        title = tr.isArabic ? 'تفعيل الموقع من الإعدادات' : 'Enable location in Settings';
        body = tr.isArabic
            ? 'تم رفض إذن الموقع سابقاً. افتح إعدادات التطبيق وفعّل «الموقع» لمتابعة استخدام الخريطة.'
            : 'Location access was turned off for Qareeb. Open app Settings and turn on Location to use the map.';
        primaryLabel = tr.isArabic ? 'فتح الإعدادات' : 'Open Settings';
        headerIcon = Icons.settings_rounded;
        break;
      case LocationAccessIssue.unavailable:
        title = tr.isArabic ? 'لا يمكن تحديد موقعك' : 'Can’t find your location';
        body = tr.isArabic
            ? 'تأكد أن خدمة الموقع مفعّلة وأن التطبيق مسموح له بالوصول للموقع، ثم حاول مرة أخرى.'
            : 'Make sure Location is on and Qareeb is allowed to access it, then try again.';
        primaryLabel = tr.isArabic ? 'حاول مرة أخرى' : 'Try again';
        headerIcon = Icons.location_searching_rounded;
        break;
    }

    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          contentPadding: const EdgeInsets.fromLTRB(20.0, 22.0, 20.0, 16.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8F0FE),
                ),
                child: Icon(headerIcon, size: 28.0, color: const Color(0xFF1A73E8)),
              ),
              const SizedBox(height: 16.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: tr.font(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF202124),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                body,
                textAlign: TextAlign.center,
                style: tr.font(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF5F6368),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22.0),
              SizedBox(
                width: double.infinity,
                height: 48.0,
                child: ElevatedButton(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    Navigator.of(dialogContext).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  child: Text(
                    primaryLabel,
                    style: tr.font(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(
                  tr.isArabic ? 'ليس الآن' : 'Not now',
                  style: tr.font(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5F6368),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != true || !context.mounted) return false;

    switch (resolvedIssue) {
      case LocationAccessIssue.serviceDisabled:
        await loc.openLocationSettings();
        return true;
      case LocationAccessIssue.permissionDenied:
        final granted = await loc.requestPermission();
        return granted == LocationPermission.always ||
            granted == LocationPermission.whileInUse;
      case LocationAccessIssue.permissionDeniedForever:
        await loc.openAppSettings();
        return true;
      case LocationAccessIssue.unavailable:
        try {
          final fresh = await loc.traceExactGps();
          return fresh.isGpsDetected;
        } catch (_) {
          return false;
        }
    }
  }

  /// Resolve location for map actions — uses live GPS when already on, otherwise shows dialog.
  static Future<UserLocation?> resolveForMapAction(
    BuildContext context,
    WidgetRef ref, {
    String? serviceName,
  }) async {
    final loc = ref.read(locationServiceProvider);
    try {
      final fresh = await loc.traceExactGps();
      if (fresh.hasValidDeviceGps) {
        ref.invalidate(userLocationProvider);
        return fresh;
      }
    } catch (_) {}

    var issue = await diagnose(loc);
    if (issue == LocationAccessIssue.permissionDenied) {
      final granted = await loc.requestPermission();
      if (granted == LocationPermission.whileInUse ||
          granted == LocationPermission.always) {
        try {
          final fresh = await loc.traceExactGps();
          if (fresh.hasValidDeviceGps) {
            ref.invalidate(userLocationProvider);
            return fresh;
          }
        } catch (_) {}
      }
      issue = await diagnose(loc);
    }

    if (!context.mounted) return null;

    if (issue != LocationAccessIssue.unavailable) {
      final acted = await showEnableLocationDialog(
        context,
        ref,
        issue: issue,
        serviceName: serviceName,
      );
      if (!acted || !context.mounted) return null;
    } else {
      final acted = await showEnableLocationDialog(
        context,
        ref,
        issue: issue,
        serviceName: serviceName,
      );
      if (!acted || !context.mounted) return null;
    }

    ref.invalidate(userLocationProvider);
    try {
      final after = await loc.traceExactGps();
      return after.hasValidDeviceGps ? after : null;
    } catch (_) {
      return null;
    }
  }
}