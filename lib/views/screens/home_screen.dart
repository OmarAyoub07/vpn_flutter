import 'dart:ui' as ui;
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../controllers/home_controller.dart';
import '../../models/server.dart';
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
  final HomeController _controller = HomeController();
  late AnimationController _bgController;
  String? _currentLang;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
        if (_controller.errorMessage != null) {
          _showError(_controller.errorMessage!);
        }
      }
    });
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = AppLocalizations.of(context).languageCode;
    if (lang != _currentLang) {
      _currentLang = lang;
      _controller.loadServers(langCode: lang);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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

  void _onConnect() {
    _controller.connect(
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
    await _controller.disconnect();
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
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
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
        final serverList = _controller.servers;
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
              if (_controller.isLoadingServers)
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
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _serverTile(BuildContext ctx, Server server) {
    final isSelected = _controller.selectedServer?.id == server.id;
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
      leading: CountryFlag.fromCountryCode(
        server.countryFlag,
        theme: const ImageTheme(
          height: 28,
          width: 40,
          shape: RoundedRectangle(4),
        ),
      ),
      title: Text(server.name, style: theme.textTheme.bodyLarge),
      subtitle: Text(
        '${server.activeConnections} active',
        style: theme.textTheme.bodySmall,
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.mintTeal)
          : null,
      onTap: () {
        _controller.selectServer(server);
        Navigator.pop(ctx);
      },
    );
  }

  void _addTime(int minutes) {
    _controller.addTime(minutes);
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
                                        _controller.selectedServer?.name ?? 'Auto',
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
                          _formatTime(_controller.remainingSeconds),
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
                          isConnected: _controller.isConnected,
                          isConnecting: _controller.isConnecting,
                          onTap: _controller.isConnected
                              ? _onDisconnect
                              : _onConnect,
                          label: _controller.isConnected
                              ? l10n.get('disconnect')
                              : l10n.get('connect'),
                          size: 200,
                        ),

                        const SizedBox(height: 40),

                        if (!_controller.isConnected &&
                            !_controller.isConnecting) ...[
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _addTime(15),
                                  icon: const Icon(
                                    Icons.play_circle_outline_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    l10n.get('watch_ads_15'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _addTime(35),
                                  icon: const Icon(
                                    Icons.play_circle_outline_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    l10n.get('watch_ads_35'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else if (_controller.isConnected) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricTile(
                                  icon: Icons.arrow_downward_rounded,
                                  label: l10n.get('download'),
                                  value: _controller.downloadSpeed,
                                  color: AppColors.mintTeal,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMetricTile(
                                  icon: Icons.arrow_upward_rounded,
                                  label: l10n.get('upload'),
                                  value: _controller.uploadSpeed,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ZenGlassCard(
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
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              // Ad placeholder
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.04),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppColors.glassBorder
                          : AppColors.pearl.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Banner Ad Placeholder',
                    style: TextStyle(
                      color: AppColors.ash.withValues(alpha: 0.5),
                      fontSize: 12,
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
