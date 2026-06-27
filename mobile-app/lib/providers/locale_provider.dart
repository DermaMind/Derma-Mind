import 'package:flutter/material.dart';
import '../utils/prefs_helper.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> loadFromPrefs() async {
    final code = await PrefsHelper.loadLocale();
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await PrefsHelper.saveLocale(locale.languageCode);
    notifyListeners();
  }}