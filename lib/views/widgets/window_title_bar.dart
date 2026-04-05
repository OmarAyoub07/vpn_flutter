import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';

const _channel = MethodChannel('com.app.vpn/tray');

class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.primaryBlue : AppColors.pureWhite;
    final fg = isDark ? Colors.white60 : Colors.black54;

    return Container(
      height: 36,
      color: bg,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (_) => _channel.invokeMethod('startDrag'),
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    Image.asset('assets/symbol.png', width: 16, height: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Free Fast VPN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _Btn(icon: Icons.minimize_rounded, color: fg, onTap: () => _channel.invokeMethod('minimize')),
          _Btn(icon: Icons.visibility_off_outlined, color: fg, onTap: () => _channel.invokeMethod('hide')),
          _Btn(icon: Icons.close_rounded, color: Colors.redAccent, onTap: () => _channel.invokeMethod('close')),
        ],
      ),
    );
  }
}

class _Btn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.color, required this.onTap});

  @override
  State<_Btn> createState() => _BtnState();
}

class _BtnState extends State<_Btn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 38,
          height: 36,
          color: _hovered ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
          child: Center(child: Icon(widget.icon, size: 16, color: widget.color)),
        ),
      ),
    );
  }
}
