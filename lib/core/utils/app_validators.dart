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
  /// 3. يبدأ بإحدى البادئات المعتمدة حصراً (091, 092, 093, 094, 095)
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
    var trimmed = value.trim();

    // معالجة البادئات الدولية والتسهيل على المستخدم (مثل +218 أو 00218 أو 218)
    if (trimmed.startsWith('+218')) {
      trimmed = '0${trimmed.substring(4)}';
    } else if (trimmed.startsWith('00218')) {
      trimmed = '0${trimmed.substring(5)}';
    } else if (trimmed.startsWith('218') && trimmed.length == 12) {
      trimmed = '0${trimmed.substring(3)}';
    } else if (trimmed.length == 9 &&
        (trimmed.startsWith('91') ||
            trimmed.startsWith('92') ||
            trimmed.startsWith('94') ||
            trimmed.startsWith('93') ||
            trimmed.startsWith('95'))) {
      trimmed = '0$trimmed';
    }

    final isDigitsOnly = RegExp(r'^[0-9]+$').hasMatch(trimmed);
    if (!isDigitsOnly) {
      return 'رقم الهاتف يجب أن يحتوي على أرقام فقط';
    }
    if (trimmed.length != 10) {
      return 'رقم الهاتف يجب أن يتكون من 10 أرقام بالضبط (مثال: 0912345678)';
    }

    // 🌟 فحص البادئات الليبية المسموحة حصراً: (091, 092, 093, 094, 095)
    // مرفوض تماماً أي رقم يبدأ بـ 090, 096, 097, 098, 099 الخ.
    final allowedPrefixes = ['091', '092', '093', '094', '095'];
    final hasValidPrefix =
        allowedPrefixes.any((prefix) => trimmed.startsWith(prefix));
    if (!hasValidPrefix) {
      return 'رقم الهاتف يجب أن يبدأ بـ 091 أو 092 أو 093 أو 094 أو 095';
    }

    if (primaryPhone != null && primaryPhone.trim().isNotEmpty) {
      var cleanPrimary = primaryPhone.trim();
      if (cleanPrimary.startsWith('+218')) {
        cleanPrimary = '0${cleanPrimary.substring(4)}';
      } else if (cleanPrimary.startsWith('00218')) {
        cleanPrimary = '0${cleanPrimary.substring(5)}';
      } else if (cleanPrimary.startsWith('218') && cleanPrimary.length == 12) {
        cleanPrimary = '0${cleanPrimary.substring(3)}';
      } else if (cleanPrimary.length == 9 &&
          (cleanPrimary.startsWith('91') ||
              cleanPrimary.startsWith('92') ||
              cleanPrimary.startsWith('94') ||
              cleanPrimary.startsWith('93') ||
              cleanPrimary.startsWith('95'))) {
        cleanPrimary = '0$cleanPrimary';
      }

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
