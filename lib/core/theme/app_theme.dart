import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.raspberry,
      onPrimary: AppColors.white,
      secondary: AppColors.violet,
      onSecondary: AppColors.white,
      tertiary: AppColors.sakura,
      onTertiary: AppColors.white,
      error: AppColors.raspberry,
      onError: AppColors.white,
      background: AppColors.viola,
      onBackground: AppColors.white,
      surface: AppColors.iris,
      onSurface: AppColors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppTypography.fontFamily,
    );
  }
}
