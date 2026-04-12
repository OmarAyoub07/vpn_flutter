import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Renders a country flag from an image URL, with emoji fallback.
class FlagEmoji extends StatelessWidget {
  final String countryCode;
  final String? imageUrl;
  final double size;

  const FlagEmoji({
    super.key,
    required this.countryCode,
    this.imageUrl,
    this.size = 24,
  });

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
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => SizedBox(width: size, height: size),
          errorWidget: (_, __, ___) => _emojiFallback(),
        ),
      );
    }
    return _emojiFallback();
  }

  Widget _emojiFallback() {
    return Text(
      toEmoji(countryCode),
      style: TextStyle(fontSize: size),
    );
  }
}
