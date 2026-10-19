import 'dart:ui';
import 'package:flutter/material.dart';

/// Custom ScrollBehavior for Provider Bottom Sheet Cards
/// Enables smooth, effortless drag scrolling across ALL pointer devices:
/// - Mouse click-and-drag (essential for Flutter Web / Desktop testing)
/// - Touch gestures (mobile screens)
/// - Trackpad pan / drag gestures
/// - Stylus pens
///
/// Hides invasive desktop scrollbars to preserve the sleek mobile aesthetic.
class ProviderCardScrollBehavior extends MaterialScrollBehavior {
  const ProviderCardScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Elegant, non-intrusive floating scrollbar that only appears during active scroll/drag
    return RawScrollbar(
      controller: details.controller,
      thumbColor: const Color(0xFF1C2926).withValues(alpha: 0.20),
      radius: const Radius.circular(10.0),
      thickness: 4.0,
      interactive: true,
      fadeDuration: const Duration(milliseconds: 250),
      timeToFade: const Duration(milliseconds: 800),
      thumbVisibility: false, // Hidden when idle, smooth reveal during gesture
      child: child,
    );
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
