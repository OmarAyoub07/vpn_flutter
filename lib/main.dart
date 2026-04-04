import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_localizations.dart';
import 'models/app_config.dart';
import 'models/app_user.dart';
import 'services/device_service.dart';
import 'services/user_service.dart';
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

  // Device identification & config
  final deviceId = await DeviceService.getDeviceId();
  final userService = UserService();
  final isFirstLaunch = !prefs.containsKey('device_registered');

  AppUser? appUser;
  AppConfigResponse? appConfig;
  try {
    appConfig = await userService.getConfig();
    if (!isFirstLaunch) {
      // Returning user — register/fetch immediately
      appUser = await userService.registerDevice(deviceId);
    }
    // First launch: defer registration until after referral code prompt
  } catch (_) {
    // Fallback: app works offline with defaults
  }

  runApp(MyApp(
    initialLocalizations: localizations,
    deviceId: deviceId,
    appUser: appUser,
    appConfig: appConfig,
    isFirstLaunch: isFirstLaunch,
  ));
}

class MyApp extends StatefulWidget {
  final AppLocalizations initialLocalizations;
  final String deviceId;
  final AppUser? appUser;
  final AppConfigResponse? appConfig;
  final bool isFirstLaunch;

  const MyApp({
    super.key,
    required this.initialLocalizations,
    required this.deviceId,
    this.appUser,
    this.appConfig,
    this.isFirstLaunch = false,
  });

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
    return AppSession(
      deviceId: widget.deviceId,
      appUser: widget.appUser,
      appConfig: widget.appConfig,
      isFirstLaunch: widget.isFirstLaunch,
      child: LocalizationProvider(
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
      ),
    );
  }
}

/// InheritedWidget to provide session data down the tree.
class AppSession extends InheritedWidget {
  final String deviceId;
  final AppUser? appUser;
  final AppConfigResponse? appConfig;
  final bool isFirstLaunch;

  const AppSession({
    super.key,
    required this.deviceId,
    this.appUser,
    this.appConfig,
    this.isFirstLaunch = false,
    required super.child,
  });

  static AppSession of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppSession>()!;
  }

  static AppSession? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppSession>();
  }

  @override
  bool updateShouldNotify(AppSession oldWidget) {
    return deviceId != oldWidget.deviceId ||
        appUser != oldWidget.appUser ||
        appConfig != oldWidget.appConfig;
  }
}
