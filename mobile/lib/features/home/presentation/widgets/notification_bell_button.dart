import 'package:flutter/material.dart';

/// Notification Bell Icon Button
/// Implements exact Figma branding specifications:
///
/// dot layout:
///   width: 4;
///   height: 4;
///   angle: 0 deg;
///   opacity: 1;
///   top: 10px;
///   left: 359px;
///   background: #8B53FE;
///
/// icon container:
///   width: 36;
///   height: 36;
///   border-radius: 50% (circular);
///   border: 1px solid #525252;
///   background: #FFFFFF;
class NotificationBellButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool hasNotification;
  final double size;

  const NotificationBellButton({
    super.key,
    this.onTap,
    this.hasNotification = false,
    this.size = 36.0,
  });

  static const double dotSize = 4.0;
  static const double dotTop = 10.0;
  static const double dotRight = 7.0; // Places dot at left: 359px on 390px artboard

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: 1.0, // opacity: 1
        child: Transform.rotate(
          angle: 0.0, // angle: 0 deg
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFFFFF),
              border: Border.all(
                color: const Color(0xFF525252),
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 6.0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 18.0,
                    color: Color(0xFF525252),
                  ),
                ),
                if (hasNotification)
                  Positioned(
                    top: dotTop,
                    right: dotRight,
                    child: Opacity(
                      opacity: 1.0, // opacity: 1
                      child: Transform.rotate(
                        angle: 0.0, // angle: 0 deg
                        child: Container(
                          width: dotSize,
                          height: dotSize,
                          decoration: const BoxDecoration(
                            color: Color(0xFF8B53FE),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
