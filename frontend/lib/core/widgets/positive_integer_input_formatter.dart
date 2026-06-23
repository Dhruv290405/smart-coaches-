import 'package:flutter/services.dart';

class PositiveIntegerInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    final isValid = RegExp(r'^\d*$').hasMatch(text);
    if (isValid) {
      return newValue;
    } else {
      return oldValue;
    }
  }
}