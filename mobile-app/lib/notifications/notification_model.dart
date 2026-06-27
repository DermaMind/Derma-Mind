import 'package:flutter/material.dart';

enum NotificationCategory { all, unread, reminders }

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String timestamp;
  bool isRead;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool isToday;
  final String? actionLabel;
  final bool isReminder;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.isToday,
    this.actionLabel,
    this.isReminder = false,
  });
}
