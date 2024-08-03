import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0D47A1);
  static const Color primaryDark = Color(0xFF002171);
  static const Color backgroundLight = Color(0xFFFFFFFF);
}

final appTheme = ThemeData(
  primaryColor: AppColors.primary,
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.yellow),
  scaffoldBackgroundColor: AppColors.backgroundLight,
  textTheme: TextTheme(
    //bodyText1: TextStyle(color: Colors.blue[900]),
    // bodyText2: TextStyle(color: Colors.blue[300]),
    bodyLarge: TextStyle(color: Colors.blue[900]), // anciennement bodyText1
    bodyMedium: TextStyle(color: Colors.blue[300]), // anciennement bodyText2
  ),
);
