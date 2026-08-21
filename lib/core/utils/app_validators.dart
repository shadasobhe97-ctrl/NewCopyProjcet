class AppValidators {
  /// التحقق من البريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    return null;
  }

  /// التحقق من صحة كلمة المرور بحسب الشروط المطلوبة:
  /// 1. 6 خانات على الأقل
  /// 2. تحتوي على حرف إنجليزي واحد على الأقل (A-Z أو a-z)
  /// 3. تحتوي على رقم واحد على الأقل (0-9)
  /// يظهر خطأ كامل فوري يشمل كافة الشروط معاً عند المخالفة.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    final hasMinLength = value.length >= 6;
    final hasEnglishLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);

    if (!hasMinLength || !hasEnglishLetter || !hasDigit) {
      return 'كلمة المرور يجب أن تتكون من 6 خانات على الأقل، وتحتوي على حرف إنجليزي ورقم على الأقل';
    }
    return null;
  }

  /// التحقق من أن الاسم باللغة العربية وثلاثي على الأقل (3 أسماء)
  static String? validateArabicTripleName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال الاسم الكامل';
    }
    final trimmed = value.trim();
    // التحقق من الحروف العربية فقط (مع السماح بالمسافات)
    final isArabic = RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(trimmed);
    if (!isArabic) {
      return 'يجب كتابة الاسم باللغة العربية فقط (أحرف عربية)';
    }
    // التجزئة بالمسافات للتحقق من أنه اسم ثلاثي على الأقل
    final nameParts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (nameParts.length < 3) {
      return 'يرجى إدخال الاسم ثلاثياً على الأقل (مثال: أحمد محمد علي)';
    }
    for (final part in nameParts) {
      if (part.length < 2) {
        return 'يرجى كتابة أجزاء الاسم الثلاثي بشكل صحيح (كل اسم حرفين على الأقل)';
      }
    }
    return null;
  }

  /// التحقق من رقم الهاتف الليبي (سواء كان أساسي أم اختياري):
  /// 1. 10 أرقام بالضبط
  /// 2. أرقام فقط
  /// 3. يبدأ بـ 09 حصراً (مثل 091, 092, 094, 093, 095)
  /// 4. عدم تطابق الهاتف الاختياري مع الهاتف الأساسي
  static String? validateLibyanPhone(
    String? value, {
    bool isRequired = true,
    String? primaryPhone,
  }) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) {
        return 'الرجاء إدخال رقم الهاتف';
      }
      return null;
    }
    final trimmed = value.trim();
    final isDigitsOnly = RegExp(r'^[0-9]+$').hasMatch(trimmed);
    if (!isDigitsOnly) {
      return 'رقم الهاتف يجب أن يحتوي على أرقام فقط';
    }
    if (trimmed.length != 10) {
      return 'رقم الهاتف يجب أن يتكون من 10 أرقام بالضبط (مثال: 0912345678)';
    }
    if (!trimmed.startsWith('09')) {
      return 'رقم الهاتف الليبي يجب أن يبدأ بـ 09 (مثل: 091, 092, 094)';
    }
    if (primaryPhone != null && primaryPhone.trim().isNotEmpty) {
      if (trimmed == primaryPhone.trim()) {
        return 'لا يمكن أن يكون رقم الهاتف الاحتياطي نفس رقم الهاتف الأساسي';
      }
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
