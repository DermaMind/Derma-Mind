import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../utils/prefs_helper.dart';

class NotificationProvider extends ChangeNotifier {
  bool _pushNotifications = true;
  bool _weeklyReport = true;
  int _unreadCount = 3;

  bool get pushNotifications => _pushNotifications;
  bool get weeklyReport => _weeklyReport;
  int get unreadCount => _unreadCount;

  Future<void> loadFromPrefs() async {
    final data = await PrefsHelper.loadNotifSettings();
    _pushNotifications = data['pushNotifications'] ?? true;
    _weeklyReport = data['weeklySkinReport'] ?? true;
    notifyListeners();
    _rescheduleAll();
  }

  Future<void> togglePushNotifications(bool value) async {
    _pushNotifications = value;
    await PrefsHelper.saveNotifSettings(
      pushNotif: _pushNotifications,
      weeklyReport: _weeklyReport,
    );
    if (value) {
      _schedulePushNotifications();
    } else {
      try {
        await NotificationService.cancelNotification(1);
        await NotificationService.cancelNotification(2);
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> toggleWeeklyReport(bool value) async {
    _weeklyReport = value;
    await PrefsHelper.saveNotifSettings(
      pushNotif: _pushNotifications,
      weeklyReport: _weeklyReport,
    );
    if (value) {
      _scheduleWeeklyReport();
    } else {
      try {
        await NotificationService.cancelNotification(3);
      } catch (_) {}
    }
    notifyListeners();
  }

  void markAllRead() {
    _unreadCount = 0;
    notifyListeners();
  }

  void _rescheduleAll() {
    if (_pushNotifications) _schedulePushNotifications();
    if (_weeklyReport) _scheduleWeeklyReport();
  }

  void _schedulePushNotifications() {
    try {
      NotificationService.scheduleDailyNotification(
        id: 1,
        title: 'Morning Skincare Reminder',
        body: 'Start your day with your morning skincare routine!',
        hour: 8,
        minute: 0,
      );
      NotificationService.scheduleDailyNotification(
        id: 2,
        title: 'Evening Skincare Reminder',
        body: 'Don\'t forget your evening skincare routine before bed.',
        hour: 21,
        minute: 0,
      );
    } catch (_) {}
  }

  void _scheduleWeeklyReport() {
    try {
      NotificationService.scheduleWeeklyNotification(
        id: 3,
        title: 'Weekly Skin Report',
        body: 'Your weekly skin health summary is ready. Tap to view.',
        weekday: DateTime.sunday,
        hour: 10,
        minute: 0,
      );
    } catch (_) {}
  }
}
