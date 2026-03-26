import 'package:flutter/material.dart';

import '../../core/app_localizations.dart';
import '../../theme/app_colors.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _allLanguages = [
    'English',
    'Arabic',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
    'Russian',
    'Portuguese',
    'Hindi',
    'Bengali',
    'Urdu',
    'Indonesian',
    'Turkish',
    'Vietnamese',
    'Korean',
    'Italian',
    'Thai',
    'Dutch',
    'Polish',
    'Ukrainian',
    'Greek',
    'Czech',
    'Swedish',
    'Romanian',
    'Hungarian',
    'Danish',
    'Finnish',
  ];

  List<String> _filteredLanguages = [];
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _filteredLanguages = _allLanguages;
    _searchController.addListener(_filterSearch);
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
          .where((lang) => lang.toLowerCase().contains(query))
          .toList();
    });
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
                      l10n.get('language'),
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
                    hintText: 'Search language...',
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
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _filteredLanguages.length,
                  itemBuilder: (context, index) {
                    final lang = _filteredLanguages[index];
                    final isSelected = lang == _selectedLanguage;

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
                            ? AppColors.mintTeal.withValues(alpha: 0.08)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.mintTeal.withValues(alpha: 0.3)
                              : Colors.transparent,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        leading: isSelected
                            ? Container(
                                width: 4,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.mintTeal,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              )
                            : const SizedBox(width: 4),
                        title: Text(
                          lang,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.mintTeal
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.mintTeal,
                                size: 22,
                              )
                            : null,
                        onTap: () {
                          setState(() => _selectedLanguage = lang);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$lang selected'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.mintTeal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
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
