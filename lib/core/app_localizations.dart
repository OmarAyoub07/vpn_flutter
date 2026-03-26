// Provides core localization logic and mock English/Arabic translations.
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'app_name': 'Free Fast VPN',
      'agree_continue': 'Agree and Continue',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'consent_text':
          'We strictly follow data privacy and confidentiality laws. By continuing, you agree to our Terms of Service and Privacy Policy.',
      'skip': 'Skip',
      'next': 'Next',
      'get_started': 'Get Started',
      'safe_secure_title': 'Safe & Secure',
      'safe_secure_desc':
          'Your data is protected with military-grade encryption.',
      'super_fast_title': 'Super Fast Speed',
      'super_fast_desc': 'Enjoy blazing fast connection speeds worldwide.',
      'multiple_servers_title': 'Multiple Servers',
      'multiple_servers_desc': 'Connect to servers in over 60 countries.',
      'connect': 'Connect',
      'disconnect': 'Disconnect',
      'choose_server': 'Choose your VPN server',
      'connected_time': 'Connected time remaining',
      'watch_ads_15': 'Watch 2 Ads (+15 mins)',
      'watch_ads_35': 'Watch 4 Ads (+35 mins)',
      'connected': 'Connected',
      'disconnected': 'Disconnected',
      'success_connected': 'Success. You are now connected.',
      'close': 'Close',
      'rate_us': 'Rate Us',
      'connections_history': 'Connections History',
      'language': 'Language',
      'share_app': 'Share App',
      'feedback': 'Feedback',
    },
    'ar': {
      'app_name': 'فري فاست في بي إن',
      'agree_continue': 'موافقة ومتابعة',
      'privacy_policy': 'سياسة الخصوصية',
      'terms_of_service': 'شروط الخدمة',
      'consent_text':
          'نحن نتبع قوانين خصوصية البيانات وسريتها بدقة. من خلال المتابعة، فإنك توافق على شروط الخدمة وسياسة الخصوصية الخاصة بنا.',
      'skip': 'تخطي',
      'next': 'التالي',
      'get_started': 'ابدأ الآن',
      'safe_secure_title': 'آمن ومحمي',
      'safe_secure_desc': 'بياناتك محمية بتشفير عالي المستوى.',
      'super_fast_title': 'سرعة فائقة',
      'super_fast_desc': 'استمتع بسرعات اتصال فائقة حول العالم.',
      'multiple_servers_title': 'خوادم متعددة',
      'multiple_servers_desc': 'اتصل بخوادم في أكثر من 60 دولة.',
      'connect': 'اتصال',
      'disconnect': 'قطع الاتصال',
      'choose_server': 'اختر خادم VPN الخاص بك',
      'connected_time': 'الوقت المتبقي للاتصال',
      'watch_ads_15': 'شاهد إعلانين (+15 دقيقة)',
      'watch_ads_35': 'شاهد 4 إعلانات (+35 دقيقة)',
      'connected': 'متصل',
      'disconnected': 'غير متصل',
      'success_connected': 'نجاح. أنت الآن متصل.',
      'close': 'إغلاق',
      'rate_us': 'قيمنا',
      'connections_history': 'سجل الاتصالات',
      'language': 'اللغة',
      'share_app': 'شارك التطبيق',
      'feedback': 'التعليقات',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
