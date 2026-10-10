import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.mintAccent,
        surface: AppColors.surfaceDark,
        error: Color(0xFFFF5252),
        onPrimary: AppColors.textWhite,
        onSecondary: AppColors.background,
        onSurface: AppColors.textWhite,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        fontFamilyFallback: const ['Inter', 'Roboto', 'Segoe UI', 'Arial', 'sans-serif'],
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
    );
  }
}
