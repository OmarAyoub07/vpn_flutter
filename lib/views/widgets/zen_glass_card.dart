import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ZenGlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? fillColor;

  const ZenGlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blurSigma = 24,
    this.padding = const EdgeInsets.all(20),
    this.borderColor,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = fillColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.7));
    final border = borderColor ??
        (isDark ? AppColors.glassBorder : AppColors.pearl.withValues(alpha: 0.5));

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: border, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
