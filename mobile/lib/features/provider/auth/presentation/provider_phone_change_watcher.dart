import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';
import 'package:mobile/features/provider/auth/presentation/phone_verification_screen.dart';
import 'package:mobile/services/backend_service.dart';

/// Polls for admin decision on login phone change requests.
class ProviderPhoneChangeWatcher {
  ProviderPhoneChangeWatcher._();

  static Timer? _timer;
  static bool _handling = false;

  static const Color _flashPurple = Color(0xFF8B53FE);

  static void start(BuildContext context) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      _poll(context);
    });
    _poll(context);
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> _poll(BuildContext context) async {
    if (_handling) return;
    if (ProviderRegistrationStore.instance.data.authToken == null ||
        ProviderRegistrationStore.instance.data.authToken!.isEmpty) {
      return;
    }

    final backend = BackendService(ApiClient());
    final ticket = await backend.getProviderPhoneChangeRequest();
    if (ticket == null) return;

    final status = ticket['status']?.toString().toLowerCase() ?? '';
    if (status == 'open') return;

    if (!context.mounted) return;
    _handling = true;

    try {
      if (status == 'resolved' || status == 'accepted') {
        final newPhone = ticket['requested_phone']?.toString() ?? '';
        if (newPhone.isNotEmpty) {
          ProviderRegistrationStore.instance.update(
            (d) => d.copyWith(phone: newPhone, contactPhone: newPhone),
          );
        }
        stop();
        final isArabic = context.isArabic;
        final msg = isArabic
            ? 'تم قبول طلبك وتحديث رقم تسجيل الدخول. سجّل الدخول بالرقم الجديد.'
            : 'Your request was accepted. Sign in with your new login number.';
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => PhoneVerificationScreen(
              initialIsLogin: true,
              flashMessage: msg,
              flashMessageBackground: _flashPurple,
            ),
          ),
          (_) => false,
        );
      } else if (status == 'rejected' || status == 'blocked') {
        stop();
        final isArabic = context.isArabic;
        final msg = status == 'blocked'
            ? (isArabic
                ? 'تم رفض طلبك وحظر الحساب. يرجى التسجيل من جديد.'
                : 'Your request was denied and the account was blocked. Please sign up again.')
            : (isArabic
                ? 'تم رفض طلب تغيير الرقم. يرجى التسجيل من جديد.'
                : 'Your phone change request was rejected. Please sign up again.');
        await ProviderRegistrationStore.instance.logout();
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => PhoneVerificationScreen(
              initialIsLogin: false,
              flashMessage: msg,
              flashMessageBackground: _flashPurple,
            ),
          ),
          (_) => false,
        );
      }
    } finally {
      _handling = false;
    }
  }
}