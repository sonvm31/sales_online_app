import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme{
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardColor: AppColors.surfaceLight,
      fontFamily: 'Roboto',
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
      ),
    );
  }

  static ThemeData get dartTheme{
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.surfaceDark,
      fontFamily: 'Roboto',
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
      ),
    );
  }
}