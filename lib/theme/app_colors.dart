import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand primaries
  static const Color deepNavy = Color(0xFF053E72);
  static const Color primaryBlue = Color(0xFF1B6497);
  static const Color navyLight = Color(0xFF0A4F87);
  static const Color mintTeal = Color(0xFF5DD4BD);

  // Surfaces
  static const Color iceWhite = Color(0xFFF4F9FA);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Neutrals
  static const Color pearl = Color(0xFFE2E8F0);
  static const Color snow = Color(0xFFFFFFFF);
  static const Color ash = Color(0xFF94A3B8);

  // Status
  static const Color ember = Color(0xFFF87171);

  // Glassmorphism helpers
  static Color glassWhite = Colors.white.withValues(alpha: 0.08);
  static Color glassBorder = Colors.white.withValues(alpha: 0.12);
  static Color glassDark = const Color(0xFF053E72).withValues(alpha: 0.6);
}
