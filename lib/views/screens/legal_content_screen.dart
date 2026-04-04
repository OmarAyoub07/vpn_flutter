import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../../core/app_localizations.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';

/// Displays Privacy Policy or Terms of Use HTML fetched from the backend.
///
/// Usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => LegalContentScreen(type: LegalContentType.privacyPolicy),
/// ));
/// ```
enum LegalContentType { privacyPolicy, termsOfUse }

class LegalContentScreen extends StatefulWidget {
  final LegalContentType type;

  const LegalContentScreen({super.key, required this.type});

  @override
  State<LegalContentScreen> createState() => _LegalContentScreenState();
}

class _LegalContentScreenState extends State<LegalContentScreen> {
  final ApiClient _api = ApiClient();
  String? _html;
  String _lang = 'en';
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) {
      _fetchContent();
    }
  }

  Future<void> _fetchContent() async {
    final langCode = AppLocalizations.of(context).languageCode;
    final path = widget.type == LegalContentType.privacyPolicy
        ? '/localization/privacy-policy/$langCode/'
        : '/localization/terms-of-use/$langCode/';

    try {
      final response = await _api.get(path);
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (mounted) {
        setState(() {
          _html = data['html'] as String? ?? '';
          _lang = data['lang'] as String? ?? langCode;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  String get _title {
    final l10n = AppLocalizations.of(context);
    return widget.type == LegalContentType.privacyPolicy
        ? l10n.get('privacy_policy')
        : l10n.get('terms_of_service');
  }

  bool get _isRtl => _lang == 'ar' || _lang == 'ur' || _lang == 'he';

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNavy : AppColors.iceWhite,
      appBar: AppBar(
        title: Text(
          _title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.iceWhite : AppColors.deepNavy,
          ),
        ),
        backgroundColor: isDark ? AppColors.deepNavy : AppColors.pureWhite,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.iceWhite : AppColors.deepNavy,
        ),
      ),
      body: _buildBody(theme, isDark),
    );
  }

  Widget _buildBody(ThemeData theme, bool isDark) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.mintTeal),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.ember),
              const SizedBox(height: 16),
              Text(
                'Failed to load content',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDark ? AppColors.iceWhite : AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.ash),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  _fetchContent();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: TextButton.styleFrom(foregroundColor: AppColors.mintTeal),
              ),
            ],
          ),
        ),
      );
    }

    if (_html == null || _html!.trim().isEmpty) {
      return Center(
        child: Text(
          'No content available.',
          style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.ash),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Directionality(
        textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: HtmlWidget(
          _html!,
          textStyle: TextStyle(
            fontSize: 15,
            height: 1.7,
            color: isDark ? const Color(0xFFd1d5db) : const Color(0xFF334155),
          ),
          customStylesBuilder: (element) {
            switch (element.localName) {
              case 'h1':
                return {
                  'color': isDark ? '#e2e8f0' : '#053E72',
                  'font-size': '1.6em',
                  'font-weight': 'bold',
                  'margin-bottom': '1rem',
                  'padding-bottom': '0.5rem',
                  'border-bottom': isDark
                      ? '2px solid #2a9d8f'
                      : '2px solid #5DD4BD',
                };
              case 'h2':
                return {
                  'color': isDark ? '#8bb8d9' : '#0A4F87',
                  'font-size': '1.2em',
                  'font-weight': 'bold',
                  'margin-top': '1.5rem',
                  'margin-bottom': '0.5rem',
                };
              case 'strong':
              case 'b':
                return {
                  'color': isDark ? '#e2e8f0' : '#053E72',
                };
              case 'li':
                return {
                  'margin-bottom': '0.4rem',
                };
            }
            return null;
          },
        ),
      ),
    );
  }
}
