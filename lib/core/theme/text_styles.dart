
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kids_transport/core/theme/app_colors.dart';

class AppTextStyles {
  static TextStyle style({
    bool inherit = true,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    TextLeadingDistribution? leadingDistribution,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    List<FontVariation>? fontVariations,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? debugLabel,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
  }) {
    return GoogleFonts.cairo(
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }

  static TextStyle heading({required Color color}) {
    return GoogleFonts.cairo(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  static TextStyle body({required Color color}) {
    return GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle button({required Color color}) {
    return GoogleFonts.cairo(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  static TextStyle inputTextStyle({required Color color}) {
    return GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }

  static TextStyle hintTextStyle() {
    return GoogleFonts.cairo(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.textMuted,
    );
  }
}

