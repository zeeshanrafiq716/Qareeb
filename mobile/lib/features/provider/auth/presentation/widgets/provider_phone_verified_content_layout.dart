import 'package:flutter/material.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_back_to_home_button.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_phone_verified_first_part.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_step_cards_list.dart';

/// Provider Phone Verified Inner Content Branding Widget
/// Implements exact Figma branding specifications:
///
/// next widget layout:
///   width: 350;
///   height: 471;
///   angle: 0 deg;
///   opacity: 1;
///   top: 187px;
///   left: 20px;
///   gap: 20px;
///
/// 1. 1st content part layout: width: 350; height: 151; gap: 20px;
/// 2. gap: 20px;
/// 3. next widget layout (step cards list): width: 350; height: 228; gap: 12px;
/// 4. gap: 20px;
/// 5. button layout (back to home): width: 350; height: 52; #1D8070;
///
/// Total Height: 151 + 20 + 228 + 20 + 52 = 471px
class ProviderPhoneVerifiedContentLayout extends StatelessWidget {
  final Widget? firstPart;
  final Widget? stepCardsList;
  final Widget? backToHomeButton;
  final List<Widget>? remainingParts;

  const ProviderPhoneVerifiedContentLayout({
    super.key,
    this.firstPart,
    this.stepCardsList,
    this.backToHomeButton,
    this.remainingParts,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 471.0;
  static const double designTop = 187.0;
  static const double designLeft = 20.0;
  static const double designGap = 20.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: designWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. 1st content part layout: width: 350; height: 151; gap: 20px;
              firstPart ?? const ProviderPhoneVerifiedFirstPart(),

              // Gap: 20px (Equal gap)
              const SizedBox(height: designGap),

              // 2. Next widget layout (Step Cards List: width: 350, height: 228, gap: 12px)
              stepCardsList ?? const ProviderStepCardsList(),

              // Gap: 20px (Equal gap following previous branding)
              const SizedBox(height: designGap),

              // 3. Button Layout (Back to Home Button: width: 350, height: 52, background: #1D8070)
              backToHomeButton ?? const ProviderBackToHomeButton(),

              // Future content parts with 20px gap
              if (remainingParts != null && remainingParts!.isNotEmpty) ...[
                const SizedBox(height: designGap),
                ..._buildRemainingParts(),
              ],

              // Flexible bottom indicator: scrolls naturally at the end of the content
              const SizedBox(height: 24.0),
              const ProviderCardBottomIndicator(),
              const SizedBox(height: 12.0),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRemainingParts() {
    final List<Widget> items = [];
    final list = remainingParts!;
    for (int i = 0; i < list.length; i++) {
      items.add(list[i]);
      if (i < list.length - 1) {
        items.add(const SizedBox(height: designGap));
      }
    }
    return items;
  }
}
