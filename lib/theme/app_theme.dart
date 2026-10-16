import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      secondary: const Color(0xFF7BC9AE),
      error: AppColors.red,
      surface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.canvas,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: AppColors.ink, fontSize: 24, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: AppColors.ink, fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: AppColors.ink, fontSize: 16, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: AppColors.ink, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.muted, fontSize: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.canvas,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.green, width: 1.5)),
      ),
    );
  }
}

class AppTextStyles {
  static const eyebrow = TextStyle(color: AppColors.muted, fontSize: 11, letterSpacing: 0.5, fontWeight: FontWeight.w600);
}
