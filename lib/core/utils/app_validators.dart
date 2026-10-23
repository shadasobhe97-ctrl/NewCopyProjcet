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
      return 'أدخل بريدًا إلكترونيًا صحيحًا';
    }
    return null;
  }

  /// التحقق من صحة كلمة المرور بحسب الشروط المطلوبة:
  /// 1. 6 خانات على الأقل
  /// 2. تحتوي على حرف إنجليزي واحد على الأقل (A-Z أو a-z)
  /// 3. تحتوي على رقم واحد على الأقل (0-9)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    final hasMinLength = value.length >= 6;
    final hasEnglishLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);

    if (!hasMinLength || !hasEnglishLetter || !hasDigit) {
      return 'كلمة المرور يجب أن تتكون من 6 خانات وتحتوي على حرف ورقم';
    }
    return null;
  }

  /// التحقق من تطابق كلمة المرور وتأكيدها
  static String? validateConfirmPassword(String? value, String? password) {
    final error = validatePassword(value);
    if (error != null) return error;
    if (value != password) {
      return 'كلمة المرور غير متطابقة';
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
      return 'يجب كتابة الاسم باللغة العربية فقط';
    }
    final nameParts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (nameParts.length < 3) {
      return 'يرجى إدخال الاسم ثلاثياً على الأقل';
    }
    for (final part in nameParts) {
      if (part.length < 2) {
        return 'يرجى كتابة أجزاء الاسم بشكل صحيح';
      }
    }
    return null;
  }

  /// التحقق من رقم الهاتف الليبي (سواء كان أساسي أم احتياطي):
  /// 1. 10 أرقام بالضبط
  /// 2. أرقام فقط
  /// 3. يبدأ بإحدى البادئات المعتمدة حصراً (091, 092, 093, 094, 095)
  /// 4. عدم تطابق الهاتف الاحتياطي مع الهاتف الأساسي
  /// يرفض أي رقم لا يبدأ بـ 09 (مثل 922222222) ولا يقوم بتحويله تلقائياً
  static String? validateLibyanPhone(
    String? value, {
    bool isRequired = true,
    String? primaryPhone,
    bool isAlternative = false,
  }) {
    final isAlt = isAlternative || primaryPhone != null;
    final emptyMsg = isAlt
        ? 'الرجاء إدخال رقم الهاتف الاحتياطي'
        : 'الرجاء إدخال رقم الهاتف الأساسي';
    final invalidMsg = isAlt
        ? 'رقم الهاتف الاحتياطي غير صحيح'
        : 'رقم الهاتف الأساسي غير صحيح';

    if (value == null || value.trim().isEmpty) {
      if (isRequired) {
        return emptyMsg;
      }
      return null;
    }

    final trimmed = value.trim().replaceAll(' ', '').replaceAll('-', '');

    // 1. أرقام فقط
    final isDigitsOnly = RegExp(r'^[0-9]+$').hasMatch(trimmed);
    if (!isDigitsOnly) {
      return invalidMsg;
    }

    // 2. الطول 10 أرقام بالضبط
    if (trimmed.length != 10) {
      return invalidMsg;
    }

    // 3. فحص البادئات الليبية المسموحة حصراً: (091, 092, 093, 094, 095)
    // أي رقم يبدأ بـ 92 أو 090 أو غيرها يعتبر غير صحيح
    final allowedPrefixes = ['091', '092', '093', '094', '095'];
    final hasValidPrefix = allowedPrefixes.any(
      (prefix) => trimmed.startsWith(prefix),
    );
    if (!hasValidPrefix) {
      return invalidMsg;
    }

    // 4. التحقق من عدم تطابق الرقم الاحتياطي مع الرقم الأساسي
    if (primaryPhone != null && primaryPhone.trim().isNotEmpty) {
      final cleanPrimary = primaryPhone.trim().replaceAll(' ', '').replaceAll('-', '');
      if (trimmed == cleanPrimary) {
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
