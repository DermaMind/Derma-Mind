import 'package:flutter/material.dart';
import '../utils/prefs_helper.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> loadFromPrefs() async {
    final saved = await PrefsHelper.loadLocaleOrNull();
    if (saved != null) {
      _locale = Locale(saved == 'ar' ? 'ar' : 'en');
    } else {
      final systemLang =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      _locale = Locale(systemLang == 'ar' ? 'ar' : 'en');
      await PrefsHelper.saveLocale(_locale.languageCode);
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await PrefsHelper.saveLocale(locale.languageCode);
    notifyListeners();
  }
}
