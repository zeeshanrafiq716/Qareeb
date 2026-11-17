import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/localization/app_locale.dart';
import '../../../providers/backend_provider.dart';
import '../../../services/backend_service.dart';
import '../../splash/presentation/app_mode_navigation.dart';
import 'data/customer_auth_store.dart';

/// Polls the API while the customer is signed in; signs out if admin deleted the account.
class CustomerAccountWatch {
  CustomerAccountWatch._();

  static Timer? _timer;
  static bool _handlingDeletion = false;

  static void start(BuildContext context, WidgetRef ref) {
    stop();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _poll(context, ref);
    });
    _poll(context, ref);
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> _poll(BuildContext context, WidgetRef ref) async {
    if (_handlingDeletion) return;
    if (!CustomerAuthStore.instance.hasCompletedSignup) return;
    final token = ApiClient.globalAuthToken;
    if (token == null || token.isEmpty) return;

    final CustomerAccountState state;
    try {
      state = await ref.read(backendServiceProvider).checkCustomerAccountState();
    } catch (_) {
      return;
    }

    if (state.status != CustomerAccountStatus.deleted &&
        state.status != CustomerAccountStatus.blocked) {
      return;
    }

    if (!context.mounted) return;
    await _forceExit(context, blocked: state.status == CustomerAccountStatus.blocked);
  }

  static Future<void> _forceExit(BuildContext context, {required bool blocked}) async {
    if (_handlingDeletion) return;
    _handlingDeletion = true;
    CustomerAccountWatch.stop();

    await CustomerAuthStore.instance.logout();
    ApiClient.setGlobalToken(null);

    if (!context.mounted) {
      _handlingDeletion = false;
      return;
    }

    final isArabic = context.isArabic;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          blocked
              ? (isArabic
                  ? 'تم حظر حسابك. يرجى التواصل مع الدعم.'
                  : 'Your account has been blocked. Please contact support.')
              : (isArabic
                  ? 'تم حذف حسابك من قبل الإدارة'
                  : 'Your account was deleted by administration.'),
        ),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 4),
      ),
    );

    await AppModeNavigation.openRoleSelection(context);
    _handlingDeletion = false;
  }
}