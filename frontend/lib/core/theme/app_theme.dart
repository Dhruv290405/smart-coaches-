import 'package:flutter/material.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    primaryColor: ColorConstants.primary,
    scaffoldBackgroundColor: Colors.white,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.black,
      selectionColor: Color(0x661976D2),
      selectionHandleColor: ColorConstants.primary,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorConstants.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: ColorConstants.blueColorDark,
      secondary: ColorConstants.blueColorDark,
      onPrimary: Colors.white,
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStatePropertyAll(ColorConstants.blueColorDark),
    ),
  );
}