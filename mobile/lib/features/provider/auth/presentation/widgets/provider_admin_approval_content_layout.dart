import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_admin_approval_badge.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_admin_approval_heading.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_admin_approval_status_card.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_got_it_button.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_under_review_card.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_whats_next_card.dart';
import 'package:mobile/features/provider/home/presentation/provider_home_screen.dart';

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

  const ProviderAdminApprovalContentLayout({
    super.key,
    this.badge,
    this.heading,
    this.statusCard,
    this.whatsNextCard,
    this.actionButton,
    this.content,
    this.children,
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
  Timer? _approvalTimer;

  @override
  void dispose() {
    _approvalTimer?.cancel();
    super.dispose();
  }

  void _onGotItPressed() {
    HapticFeedback.lightImpact();

    if (_isApproved) {
      _navigateToHome();
      return;
    }

    if (_showReviewNotice) return;

    setState(() {
      _showReviewNotice = true;
    });

    // Simulate verification cycle:
    // Update pending status, remove notice card, and auto-land on home
    _approvalTimer?.cancel();
    _approvalTimer = Timer(const Duration(milliseconds: 3800), () {
      if (!mounted) return;
      setState(() {
        _isApproved = true;
        _showReviewNotice = false;
      });

      ProviderRegistrationStore.instance.update(
        (data) => data.copyWith(status: 'APPROVED'),
      );

      // Brief pause to display the completed checkmarks before auto-landing on home screen
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        _navigateToHome();
      });
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const ProviderHomeScreen(),
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
              widget.heading ?? const ProviderAdminApprovalHeading(),

              // Gap: 20px
              const SizedBox(height: ProviderAdminApprovalContentLayout.designGap),

              // 3. next card widget branding: width: 350; height: 180; padding: 16px; 3 rows
              widget.statusCard ?? ProviderAdminApprovalStatusCard(isApproved: _isApproved),

              // Gap: 20px
              const SizedBox(height: ProviderAdminApprovalContentLayout.designGap),

              // 4. next card branding: width: 350; height: 77; padding: 16px; bg: #F2F5F4;
              widget.whatsNextCard ?? const ProviderWhatsNextCard(),

              // Gap: 24px (proper gap before button matching previous branding)
              const SizedBox(height: ProviderAdminApprovalContentLayout.buttonGap),

              // 5. Got It Button: width: 100%, height: 52, radius: 12, bg: #8B53FE, text: Got it
              widget.actionButton ??
                  ProviderGotItButton(
                    onTap: _onGotItPressed,
                  ),

              // 6. Under Review Notice Box (Animates in when Got It is tapped, then auto-removes after verification)
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity, height: 0.0),
                secondChild: const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: ProviderUnderReviewCard(),
                ),
                crossFadeState: _showReviewNotice
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
