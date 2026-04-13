import 'dart:io' show Platform;
import 'dart:ui' as ui;
import '../widgets/flag_emoji.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_localizations.dart';
import '../../controllers/home_controller.dart';
import '../../main.dart';
import '../../models/rewarded_ad_tier.dart';
import '../../models/server.dart';
import '../../services/ad_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_colors.dart';
import '../widgets/side_menu.dart';
import '../widgets/zen_glass_card.dart';
import '../widgets/pulse_orb.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  HomeController? _controller;
  AdService? _adService;
  late AnimationController _bgController;
  String? _currentLang;
  bool _initialized = false;
  String? _lastShownError;

  static const _trayChannel = MethodChannel('com.app.vpn/tray');

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
    _pushTrayStatus();
    final error = _controller?.errorMessage;
    if (error != null && error != _lastShownError) {
      _lastShownError = error;
      _showError(error);
    }
  }

  void _pushTrayStatus() {
    if (kIsWeb || !Platform.isWindows) return;
    final c = _controller;
    if (c == null) return;
    _trayChannel.invokeMethod('updateStatus', {
      'connected': c.isConnected,
      'server': c.selectedServer?.name ?? '',
      'download': c.downloadSpeed,
      'upload': c.uploadSpeed,
    });
  }

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final session = AppSession.of(context);
      _controller = HomeController(
        deviceId: session.deviceId,
        appConfig: session.appConfig,
        appUser: session.appUser,
      );
      _controller!.addListener(_onControllerChanged);

      if (session.appConfig != null) {
        _adService = AdService(config: session.appConfig!);
        _adService!.onNativeAdStateChanged = () {
          if (mounted) setState(() {});
        };
        _adService!.initialize();
      }

      _initialized = true;

      // Listen for tray icon connect/disconnect actions (Windows).
      const trayChannel = MethodChannel('com.app.vpn/tray');
      trayChannel.setMethodCallHandler((call) async {
        if (!mounted || _controller == null) return;
        if (call.method == 'connect' && !_controller!.isConnected && !_controller!.isConnecting) {
          _onConnect();
        } else if (call.method == 'disconnect' && _controller!.isConnected) {
          _onDisconnect();
        }
      });

      if (session.isFirstLaunch) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showReferralInputDialog();
        });
      }
    }

    final lang = AppLocalizations.of(context).languageCode;
    if (lang != _currentLang && _controller != null) {
      _currentLang = lang;
      _controller!.loadServers(langCode: lang);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    _controller?.dispose();
    _adService?.onNativeAdStateChanged = null;
    _adService?.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _onConnect() async {
    _controller!.connect(
      () {
        if (mounted) _showConnectionModal(true);
      },
      () {},
      () {
        if (mounted) _showConnectionModal(false);
      },
    );
  }

  void _onDisconnect() async {
    await _controller!.disconnect();
    if (mounted) _showConnectionModal(false);
  }

  void _showConnectionModal(bool connected) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.primaryBlue.withValues(alpha: 0.95)
                : AppColors.pureWhite.withValues(alpha: 0.95),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppColors.glassBorder, width: 1),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(28, 20, 28, MediaQuery.of(ctx).padding.bottom + 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.ash.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (connected ? AppColors.mintTeal : AppColors.ash)
                        .withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    connected
                        ? Icons.check_circle_rounded
                        : Icons.info_rounded,
                    size: 36,
                    color: connected ? AppColors.mintTeal : AppColors.ash,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  connected
                      ? l10n.get('connected')
                      : l10n.get('disconnected'),
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  connected
                      ? l10n.get('success_connected')
                      : l10n.get('vpn_disconnected_message'),
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialIcon(Icons.facebook),
                    const SizedBox(width: 20),
                    _socialIcon(Icons.play_circle_filled_rounded),
                    const SizedBox(width: 20),
                    _socialIcon(Icons.camera_alt_rounded),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.get('close')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.ash.withValues(alpha: 0.1),
      ),
      child: Icon(icon, size: 20, color: AppColors.ash),
    );
  }

  String _formatTime(int seconds) {
    final int h = seconds ~/ 3600;
    final int m = (seconds % 3600) ~/ 60;
    final int s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _selectServer() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final serverList = _controller!.servers;
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.primaryBlue.withValues(alpha: 0.95)
                : AppColors.pureWhite.withValues(alpha: 0.95),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.ash.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(l10n.get('select_server'), style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              if (_controller!.isLoadingServers)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                )
              else if (serverList.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.get('no_servers_available'),
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              else
                ...serverList.map((s) => _serverTile(ctx, s)),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom + 20),
            ],
          ),
        );
      },
    );
  }

  Widget _serverTile(BuildContext ctx, Server server) {
    final isSelected = _controller!.selectedServer?.id == server.id;
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
      leading: FlagEmoji(countryCode: server.countryFlag, imageUrl: server.flagImageUrl, size: 28),
      title: Text(server.name, style: theme.textTheme.bodyLarge),
      subtitle: Text(
        '${server.activeConnections} active',
        style: theme.textTheme.bodySmall,
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.mintTeal)
          : null,
      onTap: () {
        _controller!.selectServer(server);
        Navigator.pop(ctx);
      },
    );
  }

  Future<void> _watchAds(RewardedAdTier? tier, int fallbackMinutes) async {
    final adsToWatch = tier?.adsToWatch ?? 2;
    final rewardMinutes = tier?.rewardMinutes ?? fallbackMinutes;

    if (_adService == null || !(_adService!.config.rewardedAdsEnabled)) {
      // No ad service or ads disabled — claim directly
      if (tier != null) {
        await _controller!.claimReward(tier);
      } else {
        _controller!.addTime(rewardMinutes);
      }
      _showRewardSnackbar(rewardMinutes);
      return;
    }

    // Show progress dialog
    final progressNotifier = ValueNotifier<int>(0);
    _showAdProgressDialog(progressNotifier, adsToWatch, rewardMinutes);

    final completed = await _adService!.showRewardedAds(
      adsToWatch,
      onProgress: (done, total) {
        progressNotifier.value = done;
      },
    );

    // Dismiss the progress dialog
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (completed) {
      if (tier != null) {
        await _controller!.claimReward(tier);
      } else {
        _controller!.addTime(rewardMinutes);
      }
      _showRewardSnackbar(rewardMinutes);
    } else {
      // User cancelled or ad failed
      _showAdCancelledSnackbar(progressNotifier.value, adsToWatch);
    }

    progressNotifier.dispose();
  }

  void _showAdProgressDialog(
    ValueNotifier<int> progressNotifier,
    int totalAds,
    int rewardMinutes,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return ValueListenableBuilder<int>(
          valueListenable: progressNotifier,
          builder: (context, completed, _) {
            return AlertDialog(
              backgroundColor:
                  isDark ? AppColors.primaryBlue : AppColors.pureWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  // Circular progress
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: totalAds > 0 ? completed / totalAds : 0,
                            strokeWidth: 6,
                            backgroundColor: AppColors.ash.withValues(alpha: 0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.mintTeal,
                            ),
                          ),
                        ),
                        Text(
                          '$completed/$totalAds',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    completed < totalAds
                        ? l10n.get('watching_ad')
                            .replaceAll('{current}', '${completed + 1}')
                            .replaceAll('{total}', '$totalAds')
                        : l10n.get('all_ads_watched'),
                    style: theme.textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.get('reward_amount')
                        .replaceAll('{minutes}', '$rewardMinutes'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.mintTeal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (completed < totalAds)
                    Text(
                      l10n.get('watch_all_to_earn')
                          .replaceAll('{total}', '$totalAds'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.ash,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAdCancelledSnackbar(int watched, int total) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).get('ad_cancelled')
              .replaceAll('{watched}', '$watched')
              .replaceAll('{total}', '$total'),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.ash,
      ),
    );
  }

  /// Build the ad button label from the template, filling {count} and {minutes}
  /// from the tier config. Falls back to defaults if no tier exists.
  String _adButtonLabel(AppLocalizations l10n, int tierIndex, int defaultCount, int defaultMinutes) {
    final tiers = _controller?.adTiers ?? [];
    final count = tierIndex < tiers.length ? tiers[tierIndex].adsToWatch : defaultCount;
    final minutes = tierIndex < tiers.length ? tiers[tierIndex].rewardMinutes : defaultMinutes;
    return l10n.get('watch_ads_template')
        .replaceAll('{count}', '$count')
        .replaceAll('{minutes}', '$minutes');
  }

  void _showReferralInputDialog() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final codeController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.primaryBlue : AppColors.pureWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l10n.get('have_referral_code'), style: theme.textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.get('referral_hint'),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  letterSpacing: 4,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: 'A3X9K2',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                codeController.dispose();
                Navigator.pop(ctx);
                _registerDevice(null);
              },
              child: Text(l10n.get('skip'), style: TextStyle(color: AppColors.ash)),
            ),
            ElevatedButton(
              onPressed: () async {
                final code = codeController.text.trim();
                codeController.dispose();
                Navigator.pop(ctx);
                await _registerDevice(code.length == 6 ? code : null);
              },
              child: Text(l10n.get('submit')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registerDevice(String? referralCode) async {
    final l10n = AppLocalizations.of(context);
    final session = AppSession.of(context);
    try {
      final userService = UserService();
      final result = await userService.registerDevice(
        session.deviceId,
        referralCode: referralCode,
      );
      // Update remaining time from backend
      _controller?.updateRemainingSeconds(result.remainingSeconds);

      // Persist user into session so referral code is available immediately
      if (mounted) MyApp.setAppUser(context, result);

      // Save registration state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('device_registered', true);

      if (mounted && referralCode != null) {
        final status = result.referralStatus;
        if (status == 'rewarded') {
          final bonus = (session.appConfig?.referralRewardSeconds ?? 3600) ~/ 60;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.get('referral_applied').replaceAll('{minutes}', '$bonus')),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: AppColors.mintTeal,
            ),
          );
        } else if (status == 'already_referred') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.get('already_referred')),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: AppColors.ash,
            ),
          );
        } else if (status == 'invalid_code') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.get('invalid_referral')),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else if (status == 'self_referral') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.get('self_referral')),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (_) {
      // Registration failed — will retry on next app launch
    }
  }

  void _openStoreForRating() {
    final ratingUrl = AppSession.of(context).appConfig?.ratingUrl ?? '';
    if (ratingUrl.isNotEmpty) {
      launchUrl(Uri.parse(ratingUrl), mode: LaunchMode.externalApplication);
    }
  }

  void _showRewardSnackbar(int minutes) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.get('minutes_added').replaceAll('{minutes}', '$minutes')),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.mintTeal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.get('app_name')),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium_rounded),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const SideMenu(),
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          final t = _bgController.value;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0, -1 + t * 0.3),
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        Color.lerp(AppColors.primaryBlue,
                            AppColors.navyLight, t)!,
                        AppColors.deepNavy,
                      ]
                    : [
                        Color.lerp(AppColors.pureWhite, AppColors.iceWhite, t)!,
                        AppColors.iceWhite,
                      ],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        // Server selector
                        GestureDetector(
                          onTap: _selectServer,
                          child: ZenGlassCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.mintTeal
                                        .withValues(alpha: 0.1),
                                  ),
                                  child: const Icon(
                                    Icons.dns_rounded,
                                    color: AppColors.mintTeal,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.get('choose_server'),
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _controller!.selectedServer?.name ?? 'Auto',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedRotation(
                                  turns: 0,
                                  duration:
                                      const Duration(milliseconds: 300),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.ash,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Timer
                        Text(
                          _formatTime(_controller!.remainingSeconds),
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontFeatures: [
                              const ui.FontFeature.tabularFigures()
                            ],
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.get('connected_time'),
                          style: theme.textTheme.bodySmall,
                        ),

                        const SizedBox(height: 48),

                        // Connect orb
                        PulseOrb(
                          isConnected: _controller!.isConnected,
                          isConnecting: _controller!.isConnecting,
                          onTap: _controller!.isConnected
                              ? _onDisconnect
                              : _onConnect,
                          label: _controller!.isConnected
                              ? l10n.get('disconnect')
                              : l10n.get('connect'),
                          size: 200,
                        ),

                        const SizedBox(height: 40),

                        if (!_controller!.isConnected &&
                            !_controller!.isConnecting) ...[
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _watchAds(
                                    _controller!.adTiers.isNotEmpty
                                        ? _controller!.adTiers.first
                                        : null,
                                    15,
                                  ),
                                  icon: const Icon(
                                    Icons.play_circle_outline_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    _adButtonLabel(l10n, 0, 2, 15),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _watchAds(
                                    _controller!.adTiers.length > 1
                                        ? _controller!.adTiers[1]
                                        : null,
                                    35,
                                  ),
                                  icon: const Icon(
                                    Icons.play_circle_outline_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    _adButtonLabel(l10n, 1, 4, 35),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else if (_controller!.isConnected) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricTile(
                                  icon: Icons.arrow_downward_rounded,
                                  label: l10n.get('download'),
                                  value: _controller!.downloadSpeed,
                                  color: AppColors.mintTeal,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMetricTile(
                                  icon: Icons.arrow_upward_rounded,
                                  label: l10n.get('upload'),
                                  value: _controller!.uploadSpeed,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: _openStoreForRating,
                            child: ZenGlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.amber
                                          .withValues(alpha: 0.12),
                                    ),
                                    child: Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber.shade600,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.get('enjoying_speed'),
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            color:
                                                theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          l10n.get('tap_to_rate'),
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.ash,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        // Native ad
                        _buildNativeAd(isDark),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNativeAd(bool isDark) {
    final nativeAdWidget = _adService?.getNativeAdWidget();
    if (nativeAdWidget == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: nativeAdWidget,
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return ZenGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
