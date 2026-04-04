import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const _fontFamily = 'Inter';
  static final _borderRadius = BorderRadius.circular(16);
  static final _pillRadius = BorderRadius.circular(28);

  static TextTheme _buildTextTheme(Color base, Color muted) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: _fontFamily,

        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: base,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,

        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: base,
        letterSpacing: -0.5,
      ),
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,

        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,

        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,

        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,

        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamily,

        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: muted,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,

        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: base,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,

        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: muted,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamily,

        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: muted,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontFamily: _fontFamily,

        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: base,
        letterSpacing: 0.5,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontFamily,

        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: muted,
      ),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme(AppColors.deepNavy, AppColors.ash);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: AppColors.iceWhite,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.deepNavy),
        titleTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.deepNavy,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.snow,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          shape: RoundedRectangleBorder(borderRadius: _pillRadius),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.deepNavy,
          side: BorderSide(color: AppColors.pearl.withValues(alpha: 0.6)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: _pillRadius),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.snow,
        hintStyle: const TextStyle(
          fontFamily: _fontFamily,
          color: AppColors.ash,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(color: AppColors.pearl.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(color: AppColors.pearl.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.snow,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        margin: EdgeInsets.zero,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.pureWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.pureWhite,
        selectedColor: AppColors.primaryBlue.withValues(alpha: 0.12),
        side: BorderSide(color: AppColors.pearl.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: _pillRadius),
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.deepNavy,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.mintTeal,
        surface: AppColors.snow,
        error: AppColors.ember,
        onPrimary: AppColors.snow,
        onSecondary: AppColors.deepNavy,
        onSurface: AppColors.deepNavy,
        onError: AppColors.snow,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = _buildTextTheme(AppColors.iceWhite, AppColors.ash);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: AppColors.deepNavy,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.iceWhite),
        titleTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.iceWhite,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mintTeal,
          foregroundColor: AppColors.deepNavy,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          shape: RoundedRectangleBorder(borderRadius: _pillRadius),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.iceWhite,
          side: BorderSide(color: AppColors.glassBorder),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: _pillRadius),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.mintTeal,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.navyLight,
        hintStyle: const TextStyle(
          fontFamily: _fontFamily,
          color: AppColors.ash,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: const BorderSide(color: AppColors.mintTeal, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.primaryBlue,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        margin: EdgeInsets.zero,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.navyLight,
        selectedColor: AppColors.mintTeal.withValues(alpha: 0.2),
        side: BorderSide(color: AppColors.glassBorder),
        shape: RoundedRectangleBorder(borderRadius: _pillRadius),
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.iceWhite,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.mintTeal,
        secondary: AppColors.primaryBlue,
        surface: AppColors.primaryBlue,
        error: AppColors.ember,
        onPrimary: AppColors.deepNavy,
        onSecondary: AppColors.iceWhite,
        onSurface: AppColors.iceWhite,
        onError: AppColors.snow,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
