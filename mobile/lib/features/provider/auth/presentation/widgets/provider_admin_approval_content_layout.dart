import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';
import 'package:mobile/features/provider/auth/presentation/phone_verification_screen.dart';
import 'package:mobile/features/provider/auth/presentation/provider_blocked_screen.dart';
import 'package:mobile/features/provider/auth/presentation/upload_documents_screen.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_admin_approval_badge.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_admin_approval_heading.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_admin_approval_status_card.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_got_it_button.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_under_review_card.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_whats_next_card.dart';
import 'package:mobile/features/provider/home/presentation/provider_home_screen.dart';
import 'package:mobile/services/backend_service.dart';

/// Provider Admin Approval Screen Next Widget Layout Branding
/// Implements exact Figma branding specifications:
///
/// next widget layout branding:
///   width: 350;
///   height: 564;
///   top: 141px;
///   left: 20px;
///   gap: 20px;
///   angle: 0 deg;
///   opacity: 1;
///
/// 1. img layout branding: 124x124 centered badge
/// 2. gap: 20px;
/// 3. content layout: width: 350; height: 51; gap: 12px;
///    - Admin Approval pending (20px, 600, #1C2926)
///    - Your account is submitted our team is reviewing it. (12px, 400, #566663)
/// 4. gap: 20px;
/// 5. next card widget branding: width: 350; height: 180; gap: 20px; 3 rows
///    - Row 1: Account Details (Completed)
///    - Row 2: Document Verification (In Progress -> Completed after review)
///    - Row 3: Admin Approval (Pending -> Approved after review)
/// 6. gap: 20px;
/// 7. next card branding: width: 350; height: 77; gap: 12px;
///    - What’s Next? (14px, 500, #1C2926)
///    - You’ll be notified once approved usually within 1–24 hours. (12px, 400, #566663)
/// 8. button gap: 24px;
/// 9. got it button: width: 100%, height: 52, radius: 12, bg: #8B53FE, text: Got it
/// 10. under review card (shown when Got it is pressed while documents are pending)
class ProviderAdminApprovalContentLayout extends StatefulWidget {
  final Widget? badge;
  final Widget? heading;
  final Widget? statusCard;
  final Widget? whatsNextCard;
  final Widget? actionButton;
  final Widget? content;
  final List<Widget>? children;
  final bool? isSuspended;
  final bool? isRejected;

  const ProviderAdminApprovalContentLayout({
    super.key,
    this.badge,
    this.heading,
    this.statusCard,
    this.whatsNextCard,
    this.actionButton,
    this.content,
    this.children,
    this.isSuspended,
    this.isRejected,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 564.0;
  static const double designTop = 141.0;
  static const double designLeft = 20.0;
  static const double designGap = 20.0;
  static const double buttonGap = 24.0;

  @override
  State<ProviderAdminApprovalContentLayout> createState() =>
      _ProviderAdminApprovalContentLayoutState();
}

class _ProviderAdminApprovalContentLayoutState
    extends State<ProviderAdminApprovalContentLayout> {
  bool _showReviewNotice = false;
  bool _isApproved = false;
  bool _isResubmission = false;
  bool _isRejected = false;
  bool _isSuspended = false;
  String _statusReason = '';
  bool _hasAutoRedirected = false;
  Timer? _pollTimer;
  late final BackendService _backendService;

  bool get _isSuspendedOrRejected {
    if (widget.isSuspended == true || widget.isRejected == true) return true;
    final currentData = ProviderRegistrationStore.instance.data;
    return currentData.isSuspended || _isRejected || _isSuspended;
  }

  @override
  void initState() {
    super.initState();
    _backendService = BackendService(ApiClient());
    final currentData = ProviderRegistrationStore.instance.data;
    _isApproved = currentData.status == 'APPROVED';
    _isRejected = currentData.status == 'REJECTED';
    _isSuspended = currentData.status == 'SUSPENDED';

    if (_isApproved) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToHome();
      });
      return;
    }

    if (!currentData.isOnboardingCompleted && !_isSuspendedOrRejected) {
      ProviderRegistrationStore.instance.update(
        (data) => data.copyWith(isOnboardingCompleted: true),
      );
    }

    // Immediately fetch real status from backend
    _checkRealStatus();

    // High-frequency polling (every 2 seconds) so admin actions show up live on this screen
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _checkRealStatus();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkRealStatus() async {
    try {
      final accountState = await _backendService.checkProviderAccountState();
      if (!mounted) return;

      if (accountState.status == ProviderAccountStatus.deleted) {
        _pollTimer?.cancel();
        await ProviderRegistrationStore.instance.clear();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.isArabic
                  ? 'تم حذف حساب مزود الخدمة الخاص بك من قبل الإدارة'
                  : 'Your provider account has been deleted by administration.',
            ),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PhoneVerificationScreen()),
          (route) => false,
        );
        return;
      }

      if (accountState.status == ProviderAccountStatus.blocked) {
        _pollTimer?.cancel();
        ProviderRegistrationStore.instance.update(
          (d) => d.copyWith(status: 'BLOCKED', isOnline: false),
        );
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => ProviderBlockedScreen(
              reason: accountState.statusReason,
            ),
          ),
          (route) => false,
        );
        return;
      }

      final profile = accountState.profile;
      final rawStatus = accountState.rawStatus;
      final publicId = profile?['providerId']?.toString();
      final statusReason = accountState.statusReason;

      if (rawStatus.isNotEmpty) {
        final approved = accountState.status == ProviderAccountStatus.approved;
        final isResubmission = accountState.status == ProviderAccountStatus.resubmissionRequested;
        final rejected = (rawStatus == 'REJECTED' && !isResubmission) ||
            rawStatus == 'DECLINED';
        final suspended = accountState.status == ProviderAccountStatus.suspended;

        ProviderRegistrationStore.instance.update((data) {
          return data.copyWith(
            status: rawStatus,
            publicId: publicId ?? data.publicId,
            isOnboardingCompleted: true,
          );
        });

        if (mounted) {
          setState(() {
            _isApproved = approved;
            _isResubmission = isResubmission;
            _isRejected = rejected;
            _isSuspended = suspended;
            _statusReason = statusReason;
            if (rejected || suspended || isResubmission) {
              _showReviewNotice = true;
            } else if (approved) {
              _showReviewNotice = false;
            }
          });

          // AUTOMATIC REDIRECT TO HOME WHEN ADMIN APPROVES
          if (approved && !_hasAutoRedirected) {
            _hasAutoRedirected = true;
            _navigateToHome();
          }
        }
      }
    } catch (_) {}
  }

  void _onGotItPressed() async {
    HapticFeedback.lightImpact();

    if (_isApproved) {
      _navigateToHome();
      return;
    }

    if (_isResubmission || _isRejected) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const UploadDocumentsScreen()),
      );
      return;
    }

    // Re-check live status immediately
    await _checkRealStatus();

    if (!mounted) return;

    if (_isApproved) {
      _navigateToHome();
      return;
    }

    setState(() {
      _showReviewNotice = true;
    });
  }

  void _navigateToHome() {
    _pollTimer?.cancel();
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ProviderHomeScreen()),
        (route) => false,
      );
    });
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
            children: [
              // 1. img layout branding (124x124 centered illustration badge)
              widget.badge ?? const Center(child: ProviderAdminApprovalBadge()),

              // Gap: 20px
              const SizedBox(height: ProviderAdminApprovalContentLayout.designGap),

              // 2. content layout: width: 350; height: 51; gap: 12px;
              widget.heading ??
                  ProviderAdminApprovalHeading(
                    title: _isApproved
                        ? (context.isArabic ? 'تمت الموافقة على الحساب' : 'Account Approved')
                        : (_isResubmission
                            ? (context.isArabic ? 'مطلوب إعادة تقديم المستندات' : 'Resubmission Requested')
                            : ((_isRejected || _isSuspended)
                                ? (context.isArabic ? 'تم رفض الطلب' : 'Application Rejected')
                                : null)),
                    subtitle: _isApproved
                        ? (context.isArabic
                            ? 'تمت مراجعة بياناتك وقبولها بنجاح!'
                            : 'Your application has been approved by admin!')
                        : (_isResubmission
                            ? (_statusReason.isNotEmpty
                                ? _statusReason
                                : (context.isArabic
                                    ? 'طلب المشرف إعادة تقديم بعض المستندات. يرجى التحديث.'
                                    : 'Admin requested document resubmission. Please re-upload.'))
                            : ((_isRejected || _isSuspended)
                                ? (_statusReason.isNotEmpty
                                    ? _statusReason
                                    : (context.isArabic
                                        ? 'لم يتم اعتماد مستندات حسابك من قبل الإدارة.'
                                        : 'Your application was rejected by admin.'))
                                : null)),
                  ),

              // Gap: 20px
              const SizedBox(height: ProviderAdminApprovalContentLayout.designGap),

              // 3. next card widget branding: width: 350; height: 180; padding: 16px; 3 rows
              widget.statusCard ??
                  ProviderAdminApprovalStatusCard(
                    isApproved: _isApproved,
                    isSuspended: _isSuspended,
                    isRejected: _isRejected,
                    isResubmission: _isResubmission,
                  ),

              // Gap: 20px
              const SizedBox(height: ProviderAdminApprovalContentLayout.designGap),

              // 4. next card branding: width: 350; height: 77; padding: 16px; bg: #F2F5F4;
              widget.whatsNextCard ??
                  (_isApproved
                      ? ProviderWhatsNextCard(
                          title: context.isArabic ? 'الحساب جاهز!' : 'Account Ready!',
                          subtitle: context.isArabic
                              ? 'تم اعتماد حسابك بنجاح. يمكنك الآن الانتقال للوحة التحكم والبدء.'
                              : 'Your account has been approved. You can now start receiving service requests.',
                        )
                      : const ProviderWhatsNextCard()),

              // Gap: 24px (proper gap before button matching previous branding)
              const SizedBox(height: ProviderAdminApprovalContentLayout.buttonGap),

              // 5. Got It Button: width: 100%, height: 52, radius: 12, bg: #8B53FE, text: Got it
              widget.actionButton ??
                  ProviderGotItButton(
                    title: _isApproved
                        ? (context.isArabic ? 'الدخول إلى حسابي' : 'Go to Dashboard')
                        : (_isResubmission
                            ? (context.isArabic ? 'تحديث المستندات' : 'Re-upload Documents')
                            : ((_isRejected || _isSuspended)
                                ? (context.isArabic ? 'تحديث المستندات' : 'Update Documents')
                                : null)),
                    onTap: _onGotItPressed,
                  ),

              // 6. Under Review Notice Box (Animates in when Got It is tapped, or shown if rejected/resubmission)
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity, height: 0.0),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ProviderUnderReviewCard(
                    isRejected: _isRejected || _isSuspended,
                    isResubmission: _isResubmission,
                    title: _isResubmission
                        ? (context.isArabic ? 'مطلوب إعادة تقديم المستندات' : 'Resubmission Requested')
                        : null,
                    subtitle: _statusReason.isNotEmpty ? _statusReason : null,
                  ),
                ),
                crossFadeState: (!_isApproved && (_showReviewNotice || _isSuspendedOrRejected || _isResubmission))
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),

              if (widget.content != null) ...[
                const SizedBox(height: ProviderAdminApprovalContentLayout.designGap),
                widget.content!,
              ],

              if (widget.children != null && widget.children!.isNotEmpty) ...[
                const SizedBox(height: ProviderAdminApprovalContentLayout.designGap),
                ..._buildSeparatedChildren(),
              ],

              // Flexible bottom indicator: scrolls naturally at the end of content
              const SizedBox(height: 24.0),
              const Center(child: ProviderCardBottomIndicator()),
              const SizedBox(height: 12.0),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSeparatedChildren() {
    final List<Widget> items = [];
    final list = widget.children!;
    for (int i = 0; i < list.length; i++) {
      items.add(list[i]);
      if (i < list.length - 1) {
        items.add(const SizedBox(height: ProviderAdminApprovalContentLayout.designGap));
      }
    }
    return items;
  }
}
