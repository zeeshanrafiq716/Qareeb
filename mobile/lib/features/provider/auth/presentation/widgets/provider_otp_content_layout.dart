import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/presentation/phone_verified_screen.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_handle_bar.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_change_phone_button.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_otp_heading.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_otp_input_row.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_otp_timer_row.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_verify_code_button.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/services/backend_service.dart';

/// Provider OTP Card Content Layout Branding Widget
/// Implements exact Figma branding specifications:
///
/// content layout branding:
///   width: 390;
///   height: 359;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 40px;
///   top: 12px;
///   padding-right: 20px;
///   padding-left: 20px;
///
/// inner content layout:
///   width: 350;
///   height: 295;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 20px;
class ProviderOtpContentLayout extends StatelessWidget {
  final Widget? innerContent;
  final List<Widget>? children;
  final bool showHandleBar;
  final String? phoneNumber;
  final String? fullPhone;
  final String? dummyOtp;
  final bool isWhatsApp;
  final VoidCallback? onVerified;

  const ProviderOtpContentLayout({
    super.key,
    this.innerContent,
    this.children,
    this.showHandleBar = false,
    this.phoneNumber,
    this.fullPhone,
    this.dummyOtp,
    this.isWhatsApp = false,
    this.onVerified,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 359.0;
  static const double designTop = 12.0;
  static const double designGap = 16.0;
  static const double horizontalPadding = 20.0;

  static const double innerWidth = 350.0;
  static const double innerHeight = 295.0;
  static const double innerGap = 16.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showHandleBar) ...[
                // 1. Top grab handle pill bar: width: 60; height: 4; border-radius: 60px; background: #EFF0ED;
                const ProviderCardHandleBar(),

                // Gap: 16px
                const SizedBox(height: designGap),
              ],

              // 2. inner content layout
              innerContent ??
                  ProviderOtpInnerContentLayout(
                    children: children,
                    phoneNumber: phoneNumber,
                    fullPhone: fullPhone,
                    dummyOtp: dummyOtp,
                    isWhatsApp: isWhatsApp,
                    onVerified: onVerified,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Provider OTP Inner Content Layout Widget
/// Implements exact Figma branding specifications:
///
/// inner content layout:
///   width: 350;
///   height: 295;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 16px;
class ProviderOtpInnerContentLayout extends StatefulWidget {
  final List<Widget>? children;
  final String? phoneNumber;
  final String? fullPhone;
  final String? dummyOtp;
  final bool isWhatsApp;
  final VoidCallback? onVerified;

  const ProviderOtpInnerContentLayout({
    super.key,
    this.children,
    this.phoneNumber,
    this.fullPhone,
    this.dummyOtp,
    this.isWhatsApp = false,
    this.onVerified,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 295.0;
  static const double designGap = 16.0;

  @override
  State<ProviderOtpInnerContentLayout> createState() => _ProviderOtpInnerContentLayoutState();
}

class _ProviderOtpInnerContentLayoutState extends State<ProviderOtpInnerContentLayout> {
  late String _currentOtp;
  bool _isVerifying = false;
  late final BackendService _backendService;

  @override
  void initState() {
    super.initState();
    _currentOtp = widget.dummyOtp ?? '123456';
    _backendService = BackendService(ApiClient());
  }

  Future<void> _handleVerify() async {
    if (_isVerifying) return;
    setState(() => _isVerifying = true);

    final phone = widget.fullPhone ?? '+966501234567';
    final otp = _currentOtp.isNotEmpty ? _currentOtp : (widget.dummyOtp ?? '123456');

    final result = await _backendService.verifyOtp(phone: phone, otp: otp);

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (result.success) {
      if (widget.onVerified != null) {
        widget.onVerified!();
      } else {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const PhoneVerifiedScreen(),
            transitionsBuilder: (_, animation, _, child) => FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              ),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      }
    } else {
      final isArabic = context.isArabic;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          backgroundColor: Colors.redAccent,
          content: Text(
            result.errorMessage ?? (isArabic ? 'رمز التحقق غير صحيح' : 'Invalid OTP code'),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
  }

  Future<void> _handleResend() async {
    final phone = widget.fullPhone ?? '+966501234567';
    final result = await _backendService.requestOtp(phone: phone);

    if (!mounted) return;
    setState(() {
      _currentOtp = result.otp;
    });

    final isArabic = context.isArabic;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1C2926),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        content: Row(
          children: [
            const Icon(Icons.mark_email_read_outlined, color: ProviderColors.primaryButton, size: 20.0),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                isArabic
                    ? (widget.isWhatsApp
                        ? 'رمز التحقق الجديد عبر واتساب (تجريبي): ${result.otp}'
                        : 'رمز التحقق الجديد (تجريبي): ${result.otp}')
                    : (widget.isWhatsApp
                        ? 'New WhatsApp Code (Dummy): ${result.otp}'
                        : 'New Verification Code (Dummy): ${result.otp}'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildSeparatedChildren(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSeparatedChildren() {
    final bool isArabic = context.isArabic;
    final String? subtitle = widget.phoneNumber != null
        ? (isArabic
            ? (widget.isWhatsApp
                ? 'لقد أرسلنا رمز التحقق المكون من 6 أرقام عبر واتساب إلى ${widget.phoneNumber}'
                : 'لقد أرسلنا رمزاً مكوناً من 6 أرقام إلى ${widget.phoneNumber}')
            : (widget.isWhatsApp
                ? 'We’ve sent a 6-digit code via WhatsApp to ${widget.phoneNumber}'
                : 'We’ve sent a 6-digit code to ${widget.phoneNumber}'))
        : null;

    final List<Widget> list = widget.children ??
        [
          ProviderOtpHeading(subtitle: subtitle),
          ProviderOtpInputRow(
            initialValue: widget.dummyOtp ?? '123456',
            onChanged: (code) {
              _currentOtp = code;
            },
            onCompleted: (code) {
              _currentOtp = code;
            },
          ),
          ProviderOtpTimerRow(
            onResend: _handleResend,
          ),
          ProviderVerifyCodeButton(
            isLoading: _isVerifying,
            onVerify: _handleVerify,
          ),
          const ProviderChangePhoneButton(),
        ];

    final List<Widget> items = [];
    for (int i = 0; i < list.length; i++) {
      items.add(list[i]);
      if (i < list.length - 1) {
        items.add(const SizedBox(height: ProviderOtpInnerContentLayout.designGap));
      }
    }
    return items;
  }
}
