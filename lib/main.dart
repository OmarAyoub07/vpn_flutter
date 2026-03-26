import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_localizations.dart';
import 'theme/app_theme.dart';
import 'views/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('language');
  final code =
      savedLang ?? ui.PlatformDispatcher.instance.locale.languageCode;

  final localizations = await AppLocalizations.fetchLabels(code);
  await prefs.setString('language', localizations.languageCode);

  runApp(MyApp(initialLocalizations: localizations));
}

class MyApp extends StatefulWidget {
  final AppLocalizations initialLocalizations;

  const MyApp({super.key, required this.initialLocalizations});

  static void setLocalizations(
      BuildContext context, AppLocalizations l10n) {
    context.findAncestorStateOfType<_MyAppState>()?._setLocalizations(l10n);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLocalizations _localizations;

  @override
  void initState() {
    super.initState();
    _localizations = widget.initialLocalizations;
  }

  void _setLocalizations(AppLocalizations l10n) {
    setState(() => _localizations = l10n);
  }

  @override
  Widget build(BuildContext context) {
    return LocalizationProvider(
      localizations: _localizations,
      child: MaterialApp(
        title: 'VPN App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        locale: Locale(_localizations.languageCode),
        supportedLocales: [Locale(_localizations.languageCode)],
        localeResolutionCallback: (locale, supportedLocales) =>
            Locale(_localizations.languageCode),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SplashScreen(),
      ),
    );
  }
}
