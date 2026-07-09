import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFFF7F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF12172B);
  static const muted = Color(0xFF898781);
  static const income = Color(0xFF1D9E75);
  static const expense = Color(0xFFE34948);
  static const accent = Color(0xFF2A78D6);
  static const gold = Color(0xFFC98500);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      surface: AppColors.surface,
    ),
    fontFamily: 'Roboto',
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.ink,
      elevation: 0,
    ),
  );
}
