import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: AppColors.skyBlue,
      secondary: AppColors.aquaBlue,
      background: AppColors.softWhite,
      surface: AppColors.pureWhite,
      onPrimary: AppColors.coolGray900,
      onSecondary: AppColors.coolGray900,
      onBackground: AppColors.coolGray900,
      onSurface: AppColors.coolGray900,
    ),
    scaffoldBackgroundColor: AppColors.softWhite,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.skyBlue,
      foregroundColor: AppColors.coolGray900,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.coolGray900),
      bodyMedium: TextStyle(color: AppColors.coolGray900),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: AppColors.chromeBlue,
      secondary: AppColors.mistTeal,
      background: AppColors.coolGray900,
      surface: AppColors.coolGray500,
      onPrimary: AppColors.pureWhite,
      onSecondary: AppColors.pureWhite,
      onBackground: AppColors.pureWhite,
      onSurface: AppColors.pureWhite,
    ),
    scaffoldBackgroundColor: AppColors.coolGray900,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.chromeBlue,
      foregroundColor: AppColors.pureWhite,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.pureWhite),
      bodyMedium: TextStyle(color: AppColors.pureWhite),
    ),
  );
}
