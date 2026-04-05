import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_localizations.dart';
import '../../main.dart';
import '../../theme/app_colors.dart';
import '../screens/history_screen.dart';
import '../screens/language_screen.dart';
import '../screens/feedback_screen.dart';
import '../screens/legal_content_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  static bool get _isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  /// Share text via the native share sheet, with clipboard fallback on desktop.
  Future<void> _shareText(BuildContext context, String text) async {
    if (_isDesktop) {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).get('share_text_copied')),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppColors.mintTeal,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    try {
      // ignore: deprecated_member_use
      await Share.share(text);
    } catch (_) {
      // Fallback to clipboard if native share fails
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).get('share_text_copied')),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppColors.mintTeal,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _onShareApp(BuildContext context) async {
    Navigator.pop(context);
    final l10n = AppLocalizations.of(context);
    final session = AppSession.of(context);
    final storeUrl = session.appConfig?.storeUrl ?? '';
    final text = l10n.get('share_text').replaceAll('{store_url}', storeUrl);
    await _shareText(context, text);
  }

  void _showReferralCode(BuildContext context) {
    final session = AppSession.of(context);
    final l10n = AppLocalizations.of(context);
    final referralCode = session.appUser?.referralCode ?? '';
    if (referralCode.isEmpty) return;

    Navigator.pop(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final rewardMinutes = (session.appConfig?.referralRewardSeconds ?? 3600) ~/ 60;

    String _buildShareText() {
      final storeUrl = session.appConfig?.storeUrl ?? '';
      return l10n.get('referral_share_text')
          .replaceAll('{code}', referralCode)
          .replaceAll('{minutes}', '$rewardMinutes')
          .replaceAll('{store_url}', storeUrl);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.primaryBlue : AppColors.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.get('your_referral_code')),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.get('referral_description')
                    .replaceAll('{minutes}', '$rewardMinutes'),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.mintTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.mintTeal.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: SelectableText(
                        referralCode,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 20),
                      tooltip: l10n.get('code_copied'),
                      color: AppColors.mintTeal,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: referralCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.get('code_copied')),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: AppColors.mintTeal,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (_isDesktop) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _buildShareText()));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.get('share_text_copied')),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: AppColors.mintTeal,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.content_copy_rounded, size: 18),
                    label: Text(l10n.get('copy_invite_message')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.mintTeal,
                      side: BorderSide(color: AppColors.mintTeal.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.get('close')),
          ),
          if (!_isDesktop)
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                await _shareText(context, _buildShareText());
              },
              icon: const Icon(Icons.share_rounded, size: 18),
              label: Text(l10n.get('share_app')),
            ),
        ],
      ),
    );
  }

  void _onRateUs(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ratingUrl = AppSession.of(context).appConfig?.ratingUrl ?? '';

    Navigator.pop(context); // close drawer

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
            onPressed: () {
              Navigator.pop(ctx);
              if (ratingUrl.isNotEmpty) {
                launchUrl(Uri.parse(ratingUrl),
                    mode: LaunchMode.externalApplication);
              }
            },
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
                    final deviceId = AppSession.of(context).deviceId;
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => HistoryScreen(deviceId: deviceId)),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.card_giftcard_rounded,
                  label: l10n.get('refer_and_earn'),
                  onTap: () => _showReferralCode(context),
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
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const LegalContentScreen(
                        type: LegalContentType.privacyPolicy,
                      ),
                    ));
                  },
                  muted: true,
                ),
                _MenuItem(
                  icon: Icons.description_outlined,
                  label: l10n.get('terms_of_service'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const LegalContentScreen(
                        type: LegalContentType.termsOfUse,
                      ),
                    ));
                  },
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
