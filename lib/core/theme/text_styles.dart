

import 'dart:ui';

import 'package:flutter/material.dart' show TextStyle;
import 'package:kids_transport/core/theme/app_colors.dart';

class AppTextStyles {
  static TextStyle heading({required Color color}) {
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  static TextStyle body({required Color color}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle button({required Color color}) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  static TextStyle inputTextStyle({required Color color}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }

  static TextStyle hintTextStyle() {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.textMuted,
    );
  }
}