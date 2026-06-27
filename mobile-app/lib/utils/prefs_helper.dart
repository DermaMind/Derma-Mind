import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PrefsHelper {
  static const _keyName = 'user_name';
  static const _keyEmail = 'user_email';
  static const _keyPhone = 'user_phone';
  static const _keyDob = 'user_dob';
  static const _keyGender = 'user_gender';
  static const _keyLoggedIn = 'is_logged_in';

  static const _keySkinType = 'skin_type';
  static const _keySkinHistory = 'skin_history';
  static const _keyLastScan = 'last_scan';
  static const _keySkinTypeScores = 'skin_type_scores';
  static const _keyScanHistory = 'scan_history_json';
  static const _keyScanHistoryCleared = 'scan_history_cleared_v1';

  static const _keyFavorites = 'favorite_ids';
  static const _keyPushNotif = 'push_notifications';
  static const _keyWeeklyReport = 'weekly_skin_report';
  static const _keyToken = 'auth_token';
  static const _keyDarkMode = 'dark_mode';
  static const _keyLocale = 'app_locale';
  static const _keyLocaleSaved = 'app_locale_saved';

  static Future<void> saveLoginData({
    required String name,
    required String email,
    required String phone,
    required String dob,
    required String gender,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPhone, phone);
    await prefs.setString(_keyDob, dob);
    await prefs.setString(_keyGender, gender);
    await prefs.setBool(_keyLoggedIn, true);
  }

  static Future<Map<String, String>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyName) ?? '',
      'email': prefs.getString(_keyEmail) ?? '',
      'phone': prefs.getString(_keyPhone) ?? '',
      'dob': prefs.getString(_keyDob) ?? '',
      'gender': prefs.getString(_keyGender) ?? 'Female',
    };
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  /// Full wipe — use only for Delete Account.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Only clears the logged-in flag — preserves profile & skin data.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
  }

  /// Sets only the logged-in flag.
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, value);
  }

  static Future<void> saveSkinResult({
    required String skinType,
    required String skinHistory,
    required String lastScan,
    List<Map<String, dynamic>> typeScores = const [],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySkinType, skinType);
    await prefs.setString(_keySkinHistory, skinHistory);
    await prefs.setString(_keyLastScan, lastScan);
    await prefs.setString(_keySkinTypeScores, jsonEncode(typeScores));
  }

  static Future<Map<String, dynamic>> loadSkinResult() async {
    final prefs = await SharedPreferences.getInstance();
    final rawScores = prefs.getString(_keySkinTypeScores);
    List<Map<String, dynamic>> typeScores = [];
    if (rawScores != null && rawScores.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawScores);
        if (decoded is List) {
          typeScores = decoded
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      } catch (_) {}
    }

    return {
      'skinType': prefs.getString(_keySkinType) ?? '',
      'skinHistory': prefs.getString(_keySkinHistory) ?? '',
      'lastScan': prefs.getString(_keyLastScan) ?? '',
      'typeScores': typeScores,
    };
  }

  static Future<void> saveFavorites(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFavorites, ids.join(','));
  }

  static Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFavorites) ?? '';
    if (raw.isEmpty) return {};
    return raw.split(',').where((s) => s.isNotEmpty).toSet();
  }

  static Future<void> saveNotifSettings({
    required bool pushNotif,
    required bool weeklyReport,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPushNotif, pushNotif);
    await prefs.setBool(_keyWeeklyReport, weeklyReport);
  }

  static Future<Map<String, bool>> loadNotifSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'pushNotifications': prefs.getBool(_keyPushNotif) ?? true,
      'weeklySkinReport': prefs.getBool(_keyWeeklyReport) ?? true,
    };
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  static Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  static Future<void> saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, languageCode);
    await prefs.setBool(_keyLocaleSaved, true);
  }

  static Future<String?> loadLocaleOrNull() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_keyLocaleSaved) ?? false)) return null;
    return prefs.getString(_keyLocale);
  }

  static Future<String> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLocale) ?? 'en';
  }

  static Future<bool> isScanHistoryCleared() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyScanHistoryCleared) ?? false;
  }

  static Future<void> markScanHistoryCleared() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyScanHistoryCleared, true);
  }

  static Future<void> saveScanHistory(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyScanHistory, jsonEncode(items));
  }

  static Future<List<Map<String, dynamic>>> loadScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyScanHistory);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyScanHistory);
  }
}
