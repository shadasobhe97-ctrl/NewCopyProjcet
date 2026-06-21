import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../app_theme.dart';
import '../../services/storage_service.dart'; // تأكدي من صحة المسار حسب مجلدك

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : super(ThemeState(
          themeData: AppTheme.lightTheme,
          isDarkMode: false,
        )) {
    _loadThemeFromStorage();
  }

  // دالة قراءة الثيم المحفوظ فور إنشاء الكوبيت
  void _loadThemeFromStorage() {
    final bool isDark = StorageService.getThemeMode(); 
    emit(ThemeState(
      themeData: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      isDarkMode: isDark,
    ));
  }

  // دالة تبديل الثيم وحفظ الخيار الجديد في الذاكرة
  void toggleTheme() async {
    final bool newIsDarkMode = !state.isDarkMode;
    
    await StorageService.saveThemeMode(newIsDarkMode);
    
    emit(ThemeState(
      themeData: newIsDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      isDarkMode: newIsDarkMode,
    ));
  }
}