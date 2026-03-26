import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PulseOrb extends StatefulWidget {
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback? onTap;
  final String label;
  final double size;

  const PulseOrb({
    super.key,
    required this.isConnected,
    required this.isConnecting,
    required this.label,
    this.onTap,
    this.size = 200,
  });

  @override
  State<PulseOrb> createState() => _PulseOrbState();
}

class _PulseOrbState extends State<PulseOrb>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _connectingController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _connectingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _connectingController.dispose();
    super.dispose();
  }

  Color get _orbColor =>
      widget.isConnected ? AppColors.mintTeal : AppColors.primaryBlue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isConnecting ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _connectingController]),
        builder: (context, child) {
          return CustomPaint(
            painter: _OrbRingsPainter(
              color: _orbColor,
              pulseValue: _pulseAnimation.value,
              isConnecting: widget.isConnecting,
              connectingValue: _connectingController.value,
              ringCount: widget.isConnected ? 3 : 2,
            ),
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Center(child: child),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          width: widget.size * 0.65,
          height: widget.size * 0.65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _orbColor.withValues(alpha: 0.9),
                _orbColor.withValues(alpha: 0.6),
              ],
              stops: const [0.3, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: _orbColor.withValues(alpha: 0.4),
                blurRadius: 40,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: _orbColor.withValues(alpha: 0.15),
                blurRadius: 80,
                spreadRadius: 20,
              ),
            ],
          ),
          child: widget.isConnecting
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                    color: AppColors.snow,
                    strokeWidth: 2.5,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.power_settings_new_rounded,
                      size: widget.size * 0.18,
                      color: AppColors.snow,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: AppColors.snow,
                        fontWeight: FontWeight.w600,
                        fontSize: widget.size * 0.065,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _OrbRingsPainter extends CustomPainter {
  final Color color;
  final double pulseValue;
  final bool isConnecting;
  final double connectingValue;
  final int ringCount;

  _OrbRingsPainter({
    required this.color,
    required this.pulseValue,
    required this.isConnecting,
    required this.connectingValue,
    required this.ringCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    if (isConnecting) {
      final paint = Paint()
        ..color = color.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final sweepAngle = math.pi * 1.5;
      final startAngle = connectingValue * math.pi * 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: maxRadius * 0.85),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      return;
    }

    for (int i = 0; i < ringCount; i++) {
      final delay = i * 0.15;
      final adjustedPulse = ((pulseValue + delay) % 1.0);
      final ringRadius = maxRadius * (0.75 + adjustedPulse * 0.25);
      final opacity = (1.0 - adjustedPulse) * 0.15;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, ringRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbRingsPainter oldDelegate) => true;
}
