import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static const double radiusSmall = 12;
  static const double radiusMedium = 16;
  static const double radiusLarge = 24;
  static const double radiusPill = 30;

  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 18,
  );

  static TextTheme _buildTextTheme(TextTheme baseTheme) {
    return GoogleFonts.tajawalTextTheme(baseTheme).copyWith(
      displayLarge: GoogleFonts.tajawal(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.tajawal(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.tajawal(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.tajawal(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.tajawal(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: GoogleFonts.tajawal(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static BorderRadius radius(double value) => BorderRadius.circular(value);

  static BorderRadiusGeometry radiusAll(double value) =>
      BorderRadius.circular(value);

  static Radius cornerRadius(double value) => Radius.circular(value);

  static BorderRadius verticalRadius({
    Radius top = Radius.zero,
    Radius bottom = Radius.zero,
  }) {
    return BorderRadius.vertical(top: top, bottom: bottom);
  }

  static BorderRadius horizontalRadius({
    Radius left = Radius.zero,
    Radius right = Radius.zero,
  }) {
    return BorderRadius.horizontal(left: left, right: right);
  }

  static BorderRadius onlyRadius({
    Radius topLeft = Radius.zero,
    Radius topRight = Radius.zero,
    Radius bottomLeft = Radius.zero,
    Radius bottomRight = Radius.zero,
  }) {
    return BorderRadius.only(
      topLeft: topLeft,
      topRight: topRight,
      bottomLeft: bottomLeft,
      bottomRight: bottomRight,
    );
  }

  static BorderSide borderSide({
    required Color color,
    double width = 1,
    BorderStyle style = BorderStyle.solid,
  }) {
    return BorderSide(color: color, width: width, style: style);
  }

  static BoxBorder border({
    required Color color,
    double width = 1,
    BorderStyle style = BorderStyle.solid,
  }) {
    return Border.all(color: color, width: width, style: style);
  }

  static BoxBorder bottomBorder({
    required Color color,
    double width = 1,
    BorderStyle style = BorderStyle.solid,
  }) {
    return Border(
      bottom: borderSide(color: color, width: width, style: style),
    );
  }

  static RoundedRectangleBorder roundedRectangleBorder({
    double radius = radiusLarge,
    BorderRadiusGeometry? borderRadius,
    BorderSide side = BorderSide.none,
  }) {
    return RoundedRectangleBorder(
      borderRadius: borderRadius ?? BorderRadius.circular(radius),
      side: side,
    );
  }

  static OutlineInputBorder inputBorder({
    Color? color,
    double width = 1.5,
    double radius = radiusPill,
    BorderRadius? borderRadius,
    BorderSide? borderSide,
  }) {
    return OutlineInputBorder(
      borderRadius: borderRadius ?? BorderRadius.circular(radius),
      borderSide:
          borderSide ?? BorderSide(color: color ?? AppColors.grey200, width: width),
    );
  }

  static InputDecoration inputDecoration(
    BuildContext context, {
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Widget? suffix,
    Widget? prefix,
    String? errorText,
    String? helperText,
    bool? filled,
    Color? fillColor,
    EdgeInsetsGeometry? contentPadding,
    InputBorder? border,
    InputBorder? enabledBorder,
    InputBorder? focusedBorder,
    InputBorder? errorBorder,
    InputBorder? focusedErrorBorder,
    TextStyle? hintStyle,
    TextStyle? labelStyle,
    bool? alignLabelWithHint,
    FloatingLabelBehavior? floatingLabelBehavior,
    bool? isDense,
    Icon? icon,
    String? counterText,
  }) {
    final theme = Theme.of(context).inputDecorationTheme;
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      suffix: suffix,
      prefix: prefix,
      errorText: errorText,
      helperText: helperText,
      filled: filled ?? theme.filled,
      fillColor: fillColor ?? theme.fillColor,
      contentPadding: contentPadding ?? theme.contentPadding,
      border: border ?? theme.border,
      enabledBorder: enabledBorder ?? theme.enabledBorder,
      focusedBorder: focusedBorder ?? theme.focusedBorder,
      errorBorder: errorBorder ?? theme.errorBorder,
      focusedErrorBorder: focusedErrorBorder ?? theme.focusedErrorBorder,
      hintStyle: hintStyle ?? theme.hintStyle,
      labelStyle: labelStyle ?? theme.labelStyle,
      alignLabelWithHint: alignLabelWithHint,
      floatingLabelBehavior: floatingLabelBehavior,
      isDense: isDense,
      icon: icon,
      counterText: counterText,
    );
  }

  static BoxShadow boxShadow({
    required Color color,
    Offset offset = Offset.zero,
    double blurRadius = 0,
    double spreadRadius = 0,
    BlurStyle blurStyle = BlurStyle.normal,
  }) {
    return BoxShadow(
      color: color,
      offset: offset,
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
      blurStyle: blurStyle,
    );
  }

  static LinearGradient linearGradient({
    required List<Color> colors,
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
    List<double>? stops,
    TileMode tileMode = TileMode.clamp,
    GradientTransform? transform,
  }) {
    return LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
      stops: stops,
      tileMode: tileMode,
      transform: transform,
    );
  }

  static BoxDecoration boxDecoration({
    Color? color,
    DecorationImage? image,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
    BoxShape shape = BoxShape.rectangle,
    BlendMode? backgroundBlendMode,
  }) {
    return BoxDecoration(
      color: color,
      image: image,
      border: border,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      gradient: gradient,
      shape: shape,
      backgroundBlendMode: backgroundBlendMode,
    );
  }

  static ButtonStyle elevatedButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? disabledBackgroundColor,
    Color? disabledForegroundColor,
    Color? shadowColor,
    Color? surfaceTintColor,
    double? elevation,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    Size? fixedSize,
    Size? maximumSize,
    BorderSide? side,
    OutlinedBorder? shape,
    BorderRadiusGeometry? borderRadius,
    MouseCursor? enabledMouseCursor,
    MouseCursor? disabledMouseCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    Duration? animationDuration,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    InteractiveInkFeatureFactory? splashFactory,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: disabledBackgroundColor,
      disabledForegroundColor: disabledForegroundColor,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      elevation: elevation,
      textStyle: textStyle ?? GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold),
      padding: padding,
      minimumSize: minimumSize,
      fixedSize: fixedSize,
      maximumSize: maximumSize,
      side: side,
      shape: shape ??
          (borderRadius == null
              ? null
              : RoundedRectangleBorder(borderRadius: borderRadius)),
      enabledMouseCursor: enabledMouseCursor,
      disabledMouseCursor: disabledMouseCursor,
      visualDensity: visualDensity,
      tapTargetSize: tapTargetSize,
      animationDuration: animationDuration,
      enableFeedback: enableFeedback,
      alignment: alignment,
      splashFactory: splashFactory,
    );
  }

  static ButtonStyle outlinedButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? disabledBackgroundColor,
    Color? disabledForegroundColor,
    Color? shadowColor,
    Color? surfaceTintColor,
    double? elevation,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    Size? fixedSize,
    Size? maximumSize,
    BorderSide? side,
    OutlinedBorder? shape,
    BorderRadiusGeometry? borderRadius,
    MouseCursor? enabledMouseCursor,
    MouseCursor? disabledMouseCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    Duration? animationDuration,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    InteractiveInkFeatureFactory? splashFactory,
  }) {
    return OutlinedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: disabledBackgroundColor,
      disabledForegroundColor: disabledForegroundColor,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      elevation: elevation,
      textStyle: textStyle ?? GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold),
      padding: padding,
      minimumSize: minimumSize,
      fixedSize: fixedSize,
      maximumSize: maximumSize,
      side: side,
      shape: shape ??
          (borderRadius == null
              ? null
              : RoundedRectangleBorder(borderRadius: borderRadius)),
      enabledMouseCursor: enabledMouseCursor,
      disabledMouseCursor: disabledMouseCursor,
      visualDensity: visualDensity,
      tapTargetSize: tapTargetSize,
      animationDuration: animationDuration,
      enableFeedback: enableFeedback,
      alignment: alignment,
      splashFactory: splashFactory,
    );
  }

  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    return baseTheme.copyWith(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.onPrimaryLight,
        primaryContainer: AppColors.primaryContainerLight,
        secondary: AppColors.secondaryLight,
        surface: AppColors.surfaceLight,
        error: AppColors.errorLight,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: _buildTextTheme(baseTheme.textTheme),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 2,
        shadowColor: AppColors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.onPrimaryLight,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.grey200, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.grey200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.errorLight, width: 1.5),
        ),
        labelStyle: GoogleFonts.tajawal(color: AppColors.grey600),
        hintStyle: GoogleFonts.tajawal(color: AppColors.grey400),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
    return baseTheme.copyWith(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: AppColors.onPrimaryDark,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: _buildTextTheme(baseTheme.textTheme),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.grey800, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.onPrimaryDark,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          side: const BorderSide(color: AppColors.primaryDark, width: 1.5),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.grey800, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.grey800, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.errorLight, width: 1.5),
        ),
        labelStyle: GoogleFonts.tajawal(color: AppColors.grey400),
        hintStyle: GoogleFonts.tajawal(color: AppColors.grey600),
      ),
    );
  }
}

