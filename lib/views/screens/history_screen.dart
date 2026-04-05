import '../widgets/flag_emoji.dart';
import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../models/connection_history.dart';
import '../../services/user_service.dart';
import '../../theme/app_colors.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/zen_glass_card.dart';

class HistoryScreen extends StatefulWidget {
  final String deviceId;

  const HistoryScreen({super.key, required this.deviceId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  final UserService _userService = UserService();

  List<ConnectionHistory> _history = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _userService.getHistory(widget.deviceId);
      if (mounted) {
        setState(() {
          _history = history;
          _isLoading = false;
        });
        final animDuration = (400 + _history.length * 150).clamp(400, 2000);
        _staggerController.duration = Duration(milliseconds: animDuration);
        _staggerController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _userService.dispose();
    // Cap animation duration to a reasonable max
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.primaryBlue, AppColors.deepNavy]
                : [AppColors.pureWhite, AppColors.iceWhite],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.get('connections_history'),
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline_rounded,
                                    size: 40,
                                    color: AppColors.ash.withValues(alpha: 0.5)),
                                const SizedBox(height: 16),
                                Text(
                                  'Failed to load history',
                                  style: theme.textTheme.bodyLarge
                                      ?.copyWith(color: AppColors.ash),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLoading = true;
                                      _error = null;
                                    });
                                    _loadHistory();
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : _history.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.ash
                                            .withValues(alpha: 0.1),
                                      ),
                                      child: Icon(
                                        Icons.history_toggle_off_rounded,
                                        size: 40,
                                        color: AppColors.ash
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.get('no_history'),
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        color: AppColors.ash,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                    20, 12, 20, 20),
                                itemCount: _history.length,
                                itemBuilder: (context, index) {
                                  return _buildHistoryItem(
                                      index, _history[index]);
                                },
                              ),
              ),
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(int index, ConnectionHistory item) {
    final theme = Theme.of(context);
    final intervalStart = (index * 0.15).clamp(0.0, 0.7);
    final intervalEnd = (intervalStart + 0.5).clamp(0.0, 1.0);

    final fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(intervalStart, intervalEnd,
            curve: Curves.easeOutCubic),
      ),
    );

    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(intervalStart, intervalEnd,
            curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ZenGlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mintTeal.withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: FlagEmoji(countryCode: item.serverCountryFlag, imageUrl: item.serverFlagImageUrl, size: 22),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.serverName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.formattedDate,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_outlined,
                            size: 14, color: AppColors.ash),
                        const SizedBox(width: 4),
                        Text(
                          item.formattedDuration,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.serverCountry,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
