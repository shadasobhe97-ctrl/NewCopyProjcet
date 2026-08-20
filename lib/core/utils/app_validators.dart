class AppValidators {
  /// التحقق من البريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    return null;
  }

  /// التحقق من صحة كلمة المرور بحسب الشروط المطلوب:
  /// 1. 8 أحرف على الأقل
  /// 2. تحتوي على حرف إنجليزي واحد على الأقل (كبير أو صغير)
  /// 3. تحتوي على رقم واحد على الأقل
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (value.length < 8) {
      return 'كلمة المرور يجب أن تتكون من 8 أحرف على الأقل';
    }
    final hasEnglishLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    if (!hasEnglishLetter) {
      return 'يجب أن تحتوي كلمة المرور على حرف إنجليزي واحد على الأقل (A-Z أو a-z)';
    }
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    if (!hasDigit) {
      return 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل (0-9)';
    }
    return null;
  }

  /// التحقق من أن الاسم باللغة العربية وثلاثي على الأقل
  static String? validateArabicTripleName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال الاسم الكامل';
    }
    final trimmed = value.trim();
    // التحقق من الحروف العربية فقط (مع السماح بالمسافات)
    final isArabic = RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(trimmed);
    if (!isArabic) {
      return 'يجب كتابة الاسم باللغة العربية فقط';
    }
    // التجزئة بالمسافات للتحقق من أنه اسم ثلاثي على الأقل
    final nameParts = trimmed.split(RegExp(r'\s+'));
    if (nameParts.length < 3) {
      return 'يرجى إدخال الاسم ثلاثياً على الأقل (مثال: أحمد محمد علي)';
    }
    return null;
  }

  /// التحقق من الرقم الوطني الليبي:
  /// 1. 12 رقماً بالضبط
  /// 2. أرقام فقط بدون مسافات أو رموز
  /// 3. الخانة الأولى تبدأ بـ 1 أو 2
  static String? validateLibyanNationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال الرقم الوطني';
    }
    final trimmed = value.trim();
    final isDigitsOnly = RegExp(r'^[0-9]+$').hasMatch(trimmed);
    if (!isDigitsOnly) {
      return 'الرقم الوطني يجب أن يحتوي على أرقام فقط';
    }
    if (trimmed.length != 12) {
      return 'الرقم الوطني يجب أن يتكون من 12 رقماً بالضبط';
    }
    if (!trimmed.startsWith('1') && !trimmed.startsWith('2')) {
      return 'الرقم الوطني يجب أن يبدأ برقم 1 أو 2';
    }
    return null;
  }
}
