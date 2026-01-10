import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: Colors.white,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.yellowColor,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    textTheme: TextTheme(
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.yellowColor,
      primary: AppColors.yellowColor,
    ),
  );
}