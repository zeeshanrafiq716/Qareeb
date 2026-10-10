import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class LoadingIndicatorWidget extends StatelessWidget {
  final double progress;
  final String statusText;

  const LoadingIndicatorWidget({
    super.key,
    required this.progress,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    const double barWidth = 160.0;
    const double barHeight = 4.5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Rounded Progress Bar
        Container(
          width: barWidth,
          height: barHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF2C3C37),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: barWidth * progress.clamp(0.0, 1.0),
              height: barHeight,
              decoration: BoxDecoration(
                color: AppColors.mintAccent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mintGlow.withValues(alpha: 0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Status Message Text
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            statusText,
            key: ValueKey<String>(statusText),
            textAlign: TextAlign.center,
            style: AppTextStyles.statusText,
          ),
        ),

        const SizedBox(height: 28),

        // Native iOS/Android Home Indicator Bar
        Container(
          width: 134,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ],
    );
  }
}
