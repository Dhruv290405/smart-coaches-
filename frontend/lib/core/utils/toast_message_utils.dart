import 'package:flutter/material.dart';

class ToastMessageUtils {
  static void showMessage(BuildContext context, String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? '')));
  }
}