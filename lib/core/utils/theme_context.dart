import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';

extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;

  bool get isDarkMode => theme.brightness == Brightness.dark;

  Color get primaryColor => theme.primaryColor;
  Color get scaffoldBackgroundColor => theme.scaffoldBackgroundColor;
  Color get cardColor => theme.cardTheme.color ?? colorScheme.surface;
  Color get surfaceColor => colorScheme.surface;
  Color get errorColor => colorScheme.error;

  Color get textMuted => AppColors.textMuted;
  Color get successColor => AppColors.success;
  Color get pendingColor => AppColors.pending;
  Color get warningColor => AppColors.warning;
  Color get infoColor => AppColors.info;

  Color get genderMaleColor => AppColors.maleBlue;
  Color get genderFemaleColor => AppColors.femalePink;
  Color get accentPurple => AppColors.accentPurple;
  Color get accentBlue => AppColors.accentBlue;
  Color get accentGreen => AppColors.accentGreen;
  Color get accentAmber => AppColors.accentAmber;
  Color get maleBlueBg => AppColors.maleBlueBg;
  Color get femalePinkBg => AppColors.femalePinkBg;
  Color get textDark => AppColors.textDark;
  Color get primaryContainer => colorScheme.primaryContainer;

  Color get cardSurface => cardColor;
  Color get backgroundSurface => scaffoldBackgroundColor;
  Color get darkSurface => surfaceColor;

  List<Color> get primaryGradient => isDarkMode
      ? [AppColors.darkGradientStart, AppColors.darkGradientEnd]
      : [AppColors.primaryLight, AppColors.primaryGradientEnd];
}
