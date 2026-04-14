import 'dart:io' show Platform;
import 'dart:ui' as ui;
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_localizations.dart';
import 'models/app_config.dart';
import 'models/app_user.dart';
import 'services/device_service.dart';
import 'services/user_service.dart';
import 'theme/app_theme.dart';
import 'views/screens/splash_screen.dart';
import 'views/widgets/window_title_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ads SDK early (before any ad loads)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    if (Platform.isIOS) {
      // Request App Tracking Transparency authorization on iOS 14+
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
    await MobileAds.instance.initialize();
  }

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

  static void setAppUser(BuildContext context, AppUser user) {
    context.findAncestorStateOfType<_MyAppState>()?._setAppUser(user);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLocalizations _localizations;
  AppUser? _appUser;

  @override
  void initState() {
    super.initState();
    _localizations = widget.initialLocalizations;
    _appUser = widget.appUser;
  }

  void _setLocalizations(AppLocalizations l10n) {
    setState(() => _localizations = l10n);
  }

  void _setAppUser(AppUser user) {
    setState(() => _appUser = user);
  }

  @override
  Widget build(BuildContext context) {
    return AppSession(
      deviceId: widget.deviceId,
      appUser: _appUser,
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
          builder: (context, child) {
            if (!kIsWeb && Platform.isWindows) {
              return Column(
                children: [
                  const WindowTitleBar(),
                  Expanded(child: child ?? const SizedBox.shrink()),
                ],
              );
            }
            return child ?? const SizedBox.shrink();
          },
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
