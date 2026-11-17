import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_mode_selection_screen.dart';

/// Clears the navigation stack and returns to the role chooser (app entry).
class AppModeNavigation {
  AppModeNavigation._();

  static Future<void> openRoleSelection(BuildContext context) async {
    HapticFeedback.lightImpact();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const AppModeSelectionScreen(),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
      (route) => false,
    );
  }
}