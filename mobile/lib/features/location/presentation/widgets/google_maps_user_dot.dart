import 'package:flutter/material.dart';

/// Google Maps–style blue location dot with white ring.
class GoogleMapsUserDot extends StatelessWidget {
  final double size;
  final bool showAccuracyRing;

  const GoogleMapsUserDot({
    super.key,
    this.size = 20.0,
    this.showAccuracyRing = true,
  });

  static const Color _googleBlue = Color(0xFF4285F4);

  @override
  Widget build(BuildContext context) {
    final double ring = size * 2.4;
    return SizedBox(
      width: ring,
      height: ring,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showAccuracyRing)
            Container(
              width: ring,
              height: ring,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _googleBlue.withValues(alpha: 0.18),
              ),
            ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _googleBlue,
              border: Border.all(color: Colors.white, width: size * 0.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 4.0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}