import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/home/presentation/provider_home_screen.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Got It Button Widget
/// Implements exact Figma branding specifications following previous buttons:
///
/// button layout:
///   width: 350 (or double.infinity);
///   height: 52;
///   border-radius: 12px;
///   background: #8B53FE;
///
/// content: Got it
///   font-family: Inter;
///   font-weight: 500 (Medium);
///   font-size: 14px;
///   line-height: 22px;
///   color: #FFFFFF;
class ProviderGotItButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String? title;

  const ProviderGotItButton({
    super.key,
    this.onTap,
    // Deprecated: pass null to use localized string from context
    this.title,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 52.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: designHeight,
      child: ElevatedButton(
        onPressed: onTap ?? () => _defaultOnTap(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: ProviderColors.primaryButton,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Text(
          title ?? (context.isArabic ? 'فهمت ذلك' : 'Got it'),
          style: ProviderTextStyles.backToHomeButtonText,
        ),
      ),
    );
  }

  void _defaultOnTap(BuildContext context) {
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
}
