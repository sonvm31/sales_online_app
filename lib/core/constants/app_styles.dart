import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppColors {
  static const Color primary = Color(0xFF2F76F6);

  // Light Mode Colors
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Colors.white;
  static const Color textDark = Color(0xFF1A1D20);
  static const Color textMutedLight = Color(0xFF868E96);
  static const Color borderLight = Color(0xFFE9ECEF);

  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textLight = Color(0xFFE4E6EB);
  static const Color textMutedDark = Color(0xFFA0A5AD);
  static const Color borderDark = Color(0xFF2D2D2D);

  static const Color whitePlaceholder = Color(0xB3FFFFFF);
}

class AppSpacing {
  AppSpacing._();

  static double get xs => 4.0.w;
  static double get sm => 8.0.w;
  static double get md => 16.0.w;
  static double get lg => 24.0.w;
  static double get xl => 32.0.w;
  static double get xxl => 48.0.w;

  static SizedBox get h4 => SizedBox(height: 4.0.h);
  static SizedBox get h8 => SizedBox(height: 8.0.h);
  static SizedBox get h16 => SizedBox(height: 16.0.h);
  static SizedBox get h24 => SizedBox(height: 24.0.h);
  static SizedBox get h32 => SizedBox(height: 32.0.h);

  static SizedBox get w4 => SizedBox(width: 4.0.w);
  static SizedBox get w8 => SizedBox(width: 8.0.w);
  static SizedBox get w16 => SizedBox(width: 16.0.w);
  static SizedBox get w24 => SizedBox(width: 24.0.w);
}

class AppRadius {
  AppRadius._();

  static BorderRadius get small => BorderRadius.circular(4.0.r);
  static BorderRadius get medium => BorderRadius.circular(8.0.r);
  static BorderRadius get large => BorderRadius.circular(12.0.r);
  static BorderRadius get xLarge => BorderRadius.circular(16.0.r);
  static BorderRadius get circular => BorderRadius.circular(99.0.r);
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get display => TextStyle(
    fontSize: 32.0.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get headingLarge => TextStyle(
    fontSize: 24.0.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get headingMedium => TextStyle(
    fontSize: 20.0.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontSize: 16.0.sp,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontSize: 14.0.sp,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get button => TextStyle(
    fontSize: 16.0.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get caption => TextStyle(
    fontSize: 12.0.sp,
    fontWeight: FontWeight.w400,
  );
}
