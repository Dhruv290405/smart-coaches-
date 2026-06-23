import 'package:flutter/material.dart';

class AlertModel {
  final String status; // Warning, Critical, Good
  final String title;
  final String subtitle;
  final double percentage;
  final DateTime dateTime;

  AlertModel({
    required this.status,
    required this.title,
    required this.subtitle,
    required this.percentage,
    required this.dateTime,
  });
}

class AlertStatusStyle {
  final Color color;
  final IconData icon;

  AlertStatusStyle({required this.color, required this.icon});
}

AlertStatusStyle getAlertStyle(String status) {
  switch (status) {
    case 'Warning':
      return AlertStatusStyle(
        color: Colors.orange,
        icon: Icons.warning_amber,
      );
    case 'Critical':
      return AlertStatusStyle(
        color: Colors.red,
        icon: Icons.error,
      );
    case 'Good':
      return AlertStatusStyle(
        color: Colors.green,
        icon: Icons.check_circle,
      );
    default:
      return AlertStatusStyle(
        color: Colors.grey,
        icon: Icons.info_outline,
      );
  }
}