import '../widgets/flag_emoji.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_localizations.dart';
import '../../main.dart';
import '../../theme/app_colors.dart';
import '../widgets/banner_ad_widget.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allLanguages = [];
  List<Map<String, dynamic>> _filteredLanguages = [];
  String _selectedCode = 'en';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterSearch);
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCode = prefs.getString('language') ?? 'en';

    final languages = await AppLocalizations.fetchLanguages();
    if (mounted) {
      setState(() {
        _allLanguages = languages;
        _filteredLanguages = languages;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLanguages = _allLanguages
          .where((lang) =>
              (lang['name'] as String).toLowerCase().contains(query) ||
              (lang['name_en'] as String).toLowerCase().contains(query) ||
              (lang['code'] as String).toLowerCase().contains(query))
          .toList();
    });
  }

  void _onLanguageTap(Map<String, dynamic> lang) {
    final code = lang['code'] as String;
    if (code == _selectedCode) return;

    final l10n = AppLocalizations.of(context);
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
          l10n.get('change_language_title'),
          style: theme.textTheme.titleLarge,
        ),
        content: Text(
          l10n.get('change_language_message'),
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.get('cancel'),
              style: TextStyle(color: AppColors.ash),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _applyLanguage(lang);
            },
            child: Text(l10n.get('confirm')),
          ),
        ],
      ),
    );
  }

  Future<void> _applyLanguage(Map<String, dynamic> lang) async {
    final code = lang['code'] as String;
    setState(() => _selectedCode = code);

    final localizations = await AppLocalizations.fetchLabels(code);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', localizations.languageCode);

    if (mounted) {
      setState(() => _selectedCode = localizations.languageCode);

      MyApp.setLocalizations(context, localizations);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations
              .get('lang_selected')
              .replaceAll('{lang}', lang['name'] as String)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.mintTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
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
                      l10n.get('language_label'),
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.get('search_language'),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.ash,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              color: AppColors.ash,
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _filteredLanguages.length,
                        itemBuilder: (context, index) {
                          final lang = _filteredLanguages[index];
                          final code = lang['code'] as String;
                          final name = lang['name'] as String;
                          final nameEn = lang['name_en'] as String;
                          final flagCode = lang['flag_code'] as String;
                          final isSelected = code == _selectedCode;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: isSelected
                                  ? AppColors.mintTeal
                                      .withValues(alpha: 0.08)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.mintTeal
                                        .withValues(alpha: 0.3)
                                    : Colors.transparent,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 2,
                              ),
                              leading: FlagEmoji(countryCode: flagCode, size: 22),
                              title: Text(
                                name,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.mintTeal
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              subtitle: name != nameEn
                                  ? Text(
                                      nameEn,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppColors.ash,
                                      ),
                                    )
                                  : null,
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.mintTeal,
                                      size: 22,
                                    )
                                  : null,
                              onTap: () => _onLanguageTap(lang),
                            ),
                          );
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
}
