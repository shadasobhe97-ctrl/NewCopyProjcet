import 'package:flutter/material.dart';

class AppColors {
  // ============================================================
  // Base Colors
  // ============================================================

  static const Color transparent = Color(0x00000000);

  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color white24 = Color(0x3DFFFFFF);

  static const Color black = Color(0xFF000000);
  static const Color black87 = Color(0xDD000000);
  static const Color black54 = Color(0x8A000000);
  static const Color black26 = Color(0x42000000);
  static const Color black12 = Color(0x1F000000);

  // ============================================================
  // Neutral Scale
  // ============================================================

  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  static const Color grey950 = Color(0xFF0A0A0A);

  static const Color grey = grey500;

  // ============================================================
  // DARBI BRAND COLORS
  // ============================================================

  // Main Brand Blue
  static const Color primary = Color(0xFF1D5997);

  // Lighter Blue
  static const Color primaryLight = Color(0xFF2B70B5);

  // Darker Blue
  static const Color primaryDark = Color(0xFF154674);

  // Very Light Blue
  static const Color primarySoft = Color(0xFFE8F2FA);

  // Blue Container
  static const Color primaryContainer = Color(0xFFD6E8F5);

  // Content on Primary
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ============================================================
  // DARBI ACCENT
  // ============================================================

  // Main Lime Green
  static const Color secondary = Color(0xFFA5E300);

  // Dark Lime
  static const Color secondaryDark = Color(0xFF78A600);

  // Light Lime
  static const Color secondarySoft = Color(0xFFF0FBCF);

  // Green Container
  static const Color secondaryContainer = Color(0xFFE4F8A8);

  // Content on Secondary
  static const Color onSecondary = Color(0xFF231F20);

  // ============================================================
  // BRAND DARK
  // ============================================================

  static const Color brandDark = Color(0xFF231F20);

  // ============================================================
  // Brand Gradients
  // ============================================================

  static const Color primaryGradientStart = Color(0xFF2B70B5);
  static const Color primaryGradientEnd = Color(0xFF154674);

  // ============================================================
  // Utility Colors
  // ============================================================

  static const Color red = Color(0xFFEF4444);

  static const Color green = Color(0xFF22C55E);
  static const Color green700 = Color(0xFF16A34A);

  static const Color orange = Color(0xFFF97316);
  static const Color amber = secondaryDark; // Replaced yellow with Dark Lime

  static const Color blue = Color(0xFF1D5997);
  static const Color blueGrey = Color(0xFF607D8B);

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static const Color backgroundLight = Color(0xFFF8FAFC);

  static const Color surfaceLight = Color(0xFFFFFFFF);

  static const Color primaryLightTheme = Color(0xFF1D5997);

  static const Color onPrimaryLight = Color(0xFFFFFFFF);

  static const Color primaryContainerLight = Color(0xFFD6E8F5);

  static const Color secondaryLight = Color(0xFFA5E300);

  static const Color errorLight = Color(0xFFEF4444);

  // Text
  static const Color textDark = Color(0xFF231F20);

  static const Color textPrimary = Color(0xFF231F20);

  static const Color textSecondary = Color(0xFF667085);

  static const Color textMuted = Color(0xFF98A2B3);

  // ============================================================
  // DARK THEME
  // ============================================================

  // Main background
  static const Color backgroundDark = Color(0xFF111418);

  // Main surfaces
  static const Color surfaceDark = Color(0xFF191E24);

  // Cards
  static const Color darkCard = Color(0xFF20262D);

  // Elevated cards
  static const Color darkCardElevated = Color(0xFF272E36);

  // Alternative background
  static const Color darkBackground = Color(0xFF111418);

  // Alternative surface
  static const Color darkSurface = Color(0xFF191E24);

  // Dark gradients
  static const Color darkGradientStart = Color(0xFF173B5E);
  static const Color darkGradientEnd = Color(0xFF123A63);

  // ============================================================
  // DARK THEME BRAND
  // ============================================================

  static const Color primaryDarkTheme = Color(0xFF2B70B5);

  static const Color primaryContainerDark = Color(0xFF173B5E);

  static const Color onPrimaryDark = Color(0xFFFFFFFF);

  // ============================================================
  // DARK THEME ACCENT
  // ============================================================

  static const Color secondaryDarkTheme = Color(0xFFA5E300);

  static const Color secondaryContainerDark = Color(0xFF33420F);

  static const Color onSecondaryDark = Color(0xFF231F20);

  // ============================================================
  // STATUS COLORS
  // ============================================================

  static const Color success = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF16A34A);

  static const Color pending = secondaryDark;

  static const Color warning = secondaryDark;

  static const Color info = Color(0xFF3B82F6);

  static const Color error = Color(0xFFEF4444);

  // ============================================================
  // STATUS BACKGROUNDS
  // ============================================================

  static const Color successBackground = Color(0xFFDCFCE7);

  static const Color warningBackground = secondarySoft;

  static const Color errorBackground = Color(0xFFFEE2E2);

  static const Color infoBackground = Color(0xFFDBEAFE);

  // ============================================================
  // CHILD / GENDER COLORS
  // ============================================================

  static const Color maleBlue = Color(0xFF3B82F6);
  static const Color femalePink = Color(0xFFEC4899);

  static const Color maleBlueBg = Color(0xFFEFF6FF);
  static const Color femalePinkBg = Color(0xFFFDF2F8);

  // ============================================================
  // OPTIONAL ACCENTS
  // ============================================================

  static const Color accentPurple = Color(0xFF8B5CF6);

  static const Color accentBlue = Color(0xFF1D5997);

  static const Color accentGreen = Color(0xFFA5E300);

  static const Color accentAmber = secondary;

  // ============================================================
  // TEXT
  // ============================================================

  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color textOnDark = Color(0xFFF8FAFC);

  // Dark secondary text
  static const Color textSecondaryDark = Color(0xFFB8C1CC);

  static const Color textMutedDark = Color(0xFF687380);

  // ============================================================
  // BORDERS / DIVIDERS
  // ============================================================

  static const Color borderLight = Color(0xFFE5E7EB);

  static const Color borderDark = Color(0xFF303841);

  static const Color dividerLight = Color(0xFFE5E7EB);

  static const Color dividerDark = Color(0xFF303841);

  // ============================================================
  // SHADOWS
  // ============================================================

  static const Color shadowLight = Color(0x14000000);

  static const Color shadowDark = Color(0x33000000);
}
