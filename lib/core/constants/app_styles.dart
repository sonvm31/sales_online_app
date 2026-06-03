import 'dart:core';

import 'package:flutter/material.dart';

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

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const SizedBox h4 = SizedBox(height: xs);
  static const SizedBox h8 = SizedBox(height: sm);
  static const SizedBox h16 = SizedBox(height: md);
  static const SizedBox h24 = SizedBox(height: lg);
  static const SizedBox h32 = SizedBox(height: xl);

  static const SizedBox w4 = SizedBox(width: xs);
  static const SizedBox w8 = SizedBox(width: sm);
  static const SizedBox w16 = SizedBox(width: md);
  static const SizedBox w24 = SizedBox(width: lg);
}

class AppRadius {
  AppRadius._();

  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double circle = 99.0;

  static final BorderRadius small = BorderRadius.circular(sm);
  static final BorderRadius medium = BorderRadius.circular(md);
  static final BorderRadius large = BorderRadius.circular(lg);
  static final BorderRadius xLarge = BorderRadius.circular(xl);
  static final BorderRadius circular = BorderRadius.circular(circle);
}

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}
