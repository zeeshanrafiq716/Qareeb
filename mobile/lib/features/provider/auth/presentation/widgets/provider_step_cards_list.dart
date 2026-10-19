import 'package:flutter/material.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_step_card.dart';

/// Provider Step Cards List Layout Widget
/// Implements exact Figma branding specifications:
///
/// next widget layout:
///   width: 350;
///   height: 228;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 12px;
class ProviderStepCardsList extends StatelessWidget {
  final List<Widget>? cards;

  const ProviderStepCardsList({
    super.key,
    this.cards,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 228.0;
  static const double designGap = 12.0;

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
            children: _buildSeparatedCards(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSeparatedCards() {
    final list = cards ??
        const [
          ProviderStepCard.profile(),
          ProviderStepCard.getVerified(),
          ProviderStepCard.startReceivingRequests(),
        ];

    final List<Widget> items = [];
    for (int i = 0; i < list.length; i++) {
      items.add(list[i]);
      if (i < list.length - 1) {
        items.add(const SizedBox(height: designGap));
      }
    }
    return items;
  }
}
