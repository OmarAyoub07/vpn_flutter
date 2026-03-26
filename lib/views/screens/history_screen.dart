import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../widgets/zen_glass_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  final historyData = [
    {
      'server': '🇺🇸 US-East',
      'duration': '01:45:20',
      'data': '1.2 GB',
      'date': 'Today, 3:42 PM',
    },
    {
      'server': '🇬🇧 UK-London',
      'duration': '00:30:15',
      'data': '450 MB',
      'date': 'Today, 11:08 AM',
    },
    {
      'server': '🇯🇵 JP-Tokyo',
      'duration': '02:10:05',
      'data': '2.1 GB',
      'date': 'Yesterday, 9:15 PM',
    },
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + historyData.length * 150),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEmpty = historyData.isEmpty;

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
                child: isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    AppColors.ash.withValues(alpha: 0.1),
                              ),
                              child: Icon(
                                Icons.history_toggle_off_rounded,
                                size: 40,
                                color:
                                    AppColors.ash.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.get('no_history'),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppColors.ash,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                        itemCount: historyData.length,
                        itemBuilder: (context, index) {
                          final item = historyData[index];
                          final intervalStart =
                              (index * 0.15).clamp(0.0, 0.7);
                          final intervalEnd =
                              (intervalStart + 0.5).clamp(0.0, 1.0);

                          final fadeAnim = Tween<double>(
                            begin: 0,
                            end: 1,
                          ).animate(CurvedAnimation(
                            parent: _staggerController,
                            curve: Interval(
                              intervalStart,
                              intervalEnd,
                              curve: Curves.easeOutCubic,
                            ),
                          ));

                          final slideAnim = Tween<Offset>(
                            begin: const Offset(0, 0.15),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _staggerController,
                            curve: Interval(
                              intervalStart,
                              intervalEnd,
                              curve: Curves.easeOutCubic,
                            ),
                          ));

                          return FadeTransition(
                            opacity: fadeAnim,
                            child: SlideTransition(
                              position: slideAnim,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12),
                                child: ZenGlassCard(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.mintTeal
                                              .withValues(alpha: 0.1),
                                        ),
                                        child: Center(
                                          child: Text(
                                            item['server']!
                                                .substring(0, 2),
                                            style: const TextStyle(
                                                fontSize: 20),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['server']!,
                                              style: theme.textTheme
                                                  .titleSmall
                                                  ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurface,
                                                fontWeight:
                                                    FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item['date'] ?? '',
                                              style: theme
                                                  .textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisSize:
                                                MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.timer_outlined,
                                                size: 14,
                                                color: AppColors.ash,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                item['duration']!,
                                                style: theme
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisSize:
                                                MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons
                                                    .data_usage_rounded,
                                                size: 14,
                                                color: AppColors.primaryBlue,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                item['data']!,
                                                style: theme
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: AppColors
                                                      .primaryBlue,
                                                  fontWeight:
                                                      FontWeight.w500,
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
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
