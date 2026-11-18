import 'package:flutter/material.dart';

/// Consistent floating snackbars (avoids default light scaffold background).
void showAppSnackBar(
  BuildContext context,
  String message, {
  Color backgroundColor = const Color(0xFF1C2926),
  Duration duration = const Duration(seconds: 2),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: duration,
    ),
  );
}