import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
            color: const Color(0xFFEDE8FD), // soft light lavender track
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
                color: const Color(0xFF8B53FE), // #8B53FE indicator loader
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x668B53FE),
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
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF566663),
              letterSpacing: 0.2,
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Native iOS/Android Home Indicator Bar
        Container(
          width: 134,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFF1C2926),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ],
    );
  }
}
