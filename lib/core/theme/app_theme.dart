import 'package:fluent_ui/fluent_ui.dart';
import 'app_colors.dart';

class AppTheme {
  static final AccentColor accent = AccentColor.swatch({
    'darkest': AppColors.chromeBlue,
    'darker': AppColors.primary,
    'dark': AppColors.skyBlue,
    'normal': AppColors.skyBlue,
    'light': AppColors.aquaBlue,
    'lighter': AppColors.lightCyan,
    'lightest': AppColors.softWhite,
    'secondary': AppColors.mistTeal,
    'tertiary': AppColors.accent,
    'transparent': const Color(0x00000000),
  });

  /// Light mode Fluent theme
  static final FluentThemeData light = FluentThemeData(
    brightness: Brightness.light,
    accentColor: accent,
    scaffoldBackgroundColor: AppColors.softWhite,
    cardColor: AppColors.pureWhite,
    menuColor: AppColors.lightCyan,
  );

  /// Dark mode Fluent theme
  static final FluentThemeData dark = FluentThemeData(
    brightness: Brightness.dark,
    accentColor: accent,
    scaffoldBackgroundColor: AppColors.coolGray900,
    cardColor: AppColors.coolGray500,
    menuColor: AppColors.neutralDark,
  );
}
