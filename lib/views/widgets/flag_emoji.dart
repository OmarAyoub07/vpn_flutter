import 'package:flutter/material.dart';

/// Renders a country flag as an emoji from a 2-letter country code.
/// Zero-size alternative to the country_flags package (saves ~2.5 MB).
class FlagEmoji extends StatelessWidget {
  final String countryCode;
  final double size;

  const FlagEmoji({super.key, required this.countryCode, this.size = 24});

  static String toEmoji(String code) {
    if (code.length != 2) return '';
    final upper = code.toUpperCase();
    return String.fromCharCodes([
      0x1F1E6 + upper.codeUnitAt(0) - 0x41,
      0x1F1E6 + upper.codeUnitAt(1) - 0x41,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      toEmoji(countryCode),
      style: TextStyle(fontSize: size),
    );
  }
}
