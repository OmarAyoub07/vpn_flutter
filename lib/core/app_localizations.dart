import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_client.dart';
import '../services/localization_service.dart';

class AppLocalizations {
  final String languageCode;
  final Map<String, String> _labels;

  /// Fallback strings for keys that may not yet exist on the backend.
  static const _defaults = {
    'share_text_copied': 'Copied to clipboard!',
    'referral_description': 'Share your code with friends. When they install '
        'the app and enter your code, you both get {minutes} minutes free!',
    'copy_invite_message': 'Copy invite message',
  };

  AppLocalizations(this.languageCode, this._labels);

  String get(String key) => _labels[key] ?? _defaults[key] ?? key;

  static AppLocalizations of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LocalizationProvider>()!
        .localizations;
  }

  /// Fetch labels from the backend.
  /// If the backend returns 404, falls back to English.
  /// On network failure, loads from cache.
  static Future<AppLocalizations> fetchLabels(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final service = LocalizationService();

    try {
      final labels = await service.getLabels(code);
      await prefs.setString('labels_$code', jsonEncode(labels));
      service.dispose();
      return AppLocalizations(code, labels);
    } on ApiException catch (e) {
      if (e.statusCode == 404 && code != 'en') {
        try {
          final labels = await service.getLabels('en');
          await prefs.setString('labels_en', jsonEncode(labels));
          service.dispose();
          return AppLocalizations('en', labels);
        } catch (_) {
          service.dispose();
          return _loadCached(prefs, 'en');
        }
      }
      service.dispose();
      return _loadCached(prefs, code);
    } catch (_) {
      service.dispose();
      return _loadCached(prefs, code);
    }
  }

  static AppLocalizations _loadCached(SharedPreferences prefs, String code) {
    final cached = prefs.getString('labels_$code');
    if (cached != null) {
      return AppLocalizations(
          code, Map<String, String>.from(jsonDecode(cached)));
    }
    final cachedEn = prefs.getString('labels_en');
    if (cachedEn != null) {
      return AppLocalizations(
          'en', Map<String, String>.from(jsonDecode(cachedEn)));
    }
    return AppLocalizations('en', {});
  }

  /// Fetch the list of available languages from the backend.
  static Future<List<Map<String, dynamic>>> fetchLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    final service = LocalizationService();
    try {
      final languages = await service.getLanguages();
      await prefs.setString('cached_languages', jsonEncode(languages));
      service.dispose();
      return languages;
    } catch (_) {
      service.dispose();
      final cached = prefs.getString('cached_languages');
      if (cached != null) {
        return (jsonDecode(cached) as List).cast<Map<String, dynamic>>();
      }
      return [];
    }
  }
}

class LocalizationProvider extends InheritedWidget {
  final AppLocalizations localizations;

  const LocalizationProvider({
    super.key,
    required this.localizations,
    required super.child,
  });

  @override
  bool updateShouldNotify(LocalizationProvider oldWidget) =>
      !identical(localizations, oldWidget.localizations);
}
