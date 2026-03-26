import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../screens/history_screen.dart';
import '../screens/language_screen.dart';
import '../screens/feedback_screen.dart';

import 'package:share_plus/share_plus.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  void _onShareApp(BuildContext context) async {
    Navigator.pop(context);
    try {
      final l10n = AppLocalizations.of(context);
      // ignore: deprecated_member_use
      await Share.share(l10n.get('share_text'));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sharing is not supported on this device: $e'),
          ),
        );
      }
    }
  }

  void _onRateUs(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Navigator.pop(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.primaryBlue : AppColors.pureWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          l10n.get('do_you_like_vpn'),
          style: theme.textTheme.titleLarge,
        ),
        content: Text(
          l10n.get('feedback_helps_improve'),
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedbackScreen()),
              );
            },
            child: Text(
              l10n.get('not_really'),
              style: TextStyle(color: AppColors.ash),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.get('love_it')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Drawer(
          backgroundColor: isDark
              ? AppColors.primaryBlue.withValues(alpha: 0.9)
              : AppColors.pureWhite.withValues(alpha: 0.92),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [AppColors.navyLight, AppColors.primaryBlue]
                          : [AppColors.pureWhite, AppColors.iceWhite],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.mintTeal.withValues(alpha: 0.15),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.asset('assets/symbol.png', width: 56),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.get('app_name'),
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.get('secure_fast_private'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.ash,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                _MenuItem(
                  icon: Icons.history_rounded,
                  label: l10n.get('connections_history'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HistoryScreen()),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.language_rounded,
                  label: l10n.get('language_label'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LanguageScreen()),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.share_rounded,
                  label: l10n.get('share_app'),
                  onTap: () => _onShareApp(context),
                ),
                _MenuItem(
                  icon: Icons.star_rounded,
                  label: l10n.get('rate_us'),
                  onTap: () => _onRateUs(context),
                ),
                _MenuItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: l10n.get('feedback'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FeedbackScreen()),
                    );
                  },
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Divider(
                    color: AppColors.ash.withValues(alpha: 0.15),
                  ),
                ),
                _MenuItem(
                  icon: Icons.shield_outlined,
                  label: l10n.get('privacy_policy'),
                  onTap: () => Navigator.pop(context),
                  muted: true,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool muted;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = muted ? AppColors.ash : theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color.withValues(alpha: 0.7)),
              const SizedBox(width: 16),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
