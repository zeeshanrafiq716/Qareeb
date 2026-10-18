import 'package:flutter/material.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';

/// Provider Card Bottom Indicator Bar Widget
/// Matches exact specifications from customer side screens:
///
/// bottom indicator bar:
///   width: 134;
///   height: 4;
///   border-radius: 100px;
///   background: #1C2926;
class ProviderCardBottomIndicator extends StatelessWidget {
  const ProviderCardBottomIndicator({super.key});

  static const double designWidth = 134.0;
  static const double designHeight = 4.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24.0,
      child: Center(
        child: Container(
          key: const Key('bottom_bar_indicator'),
          width: designWidth,
          height: designHeight,
          decoration: BoxDecoration(
            color: ProviderColors.cardTitle, // #1C2926
            borderRadius: BorderRadius.circular(100.0), // border-radius: 100px
          ),
        ),
      ),
    );
  }
}
