import 'package:flutter/material.dart';

class ServiceModel {
  final String title;
  final String subtitle;
  final String iconPath;
  final int color;
  final int iconColor;
  final IconData watermarkIcon;
  final void Function()? onTap;

  ServiceModel({
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.color,
    required this.watermarkIcon,
    this.iconColor = 0xFF1483DA,
    this.onTap,
  });
}
