import 'package:flutter_test/flutter_test.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/utils/app_validators.dart';

void main() {
  group('اختبارات التحقق من صحة الحقول (Form Validation) - السيناريوهات العشرة', () {
    // السيناريو 1: إرسال النموذج وجميع الحقول فارغة
    test('1. إرسال النموذج وجميع الحقول فارغة يجب أن يُرجع رسائل الخطأ المطلوبة لكل حقل', () {
      expect(AppValidators.validateArabicTripleName(''), 'الرجاء إدخال الاسم الكامل');
      expect(AppValidators.validateEmail(''), 'الرجاء إدخال البريد الإلكتروني');
      expect(
        AppValidators.validateLibyanPhone('', isRequired: true, isAlternative: false),
        'الرجاء إدخال رقم الهاتف الأساسي',
      );
      expect(
        AppValidators.validateLibyanPhone('', isRequired: false, isAlternative: true),
        isNull, // اختياري عند تركه فارغاً
      );
      expect(AppValidators.validatePassword(''), 'الرجاء إدخال كلمة المرور');
      expect(AppValidators.validateConfirmPassword('', ''), 'الرجاء إدخال كلمة المرور');
    });

    // السيناريو 2: إدخال بريد إلكتروني غير صالح
    test('2. إدخال بريد إلكتروني غير صالح يُرجع رسالة دقيقة وقصيرة', () {
      expect(AppValidators.validateEmail('invalid-email'), 'أدخل بريدًا إلكترونيًا صحيحًا');
      expect(AppValidators.validateEmail('test@'), 'أدخل بريدًا إلكترونيًا صحيحًا');
      expect(AppValidators.validateEmail('test@com'), 'أدخل بريدًا إلكترونيًا صحيحًا');
      expect(AppValidators.validateEmail('valid.email@example.com'), isNull);
    });

    // السيناريو 3: إدخال رقم أساسي غير صالح
    test('3. إدخال رقم أساسي غير صالح يُرجع رسالة مخصصة للرقم الأساسي', () {
      expect(
        AppValidators.validateLibyanPhone('12345', isRequired: true, isAlternative: false),
        'رقم الهاتف الأساسي غير صحيح',
      );
      expect(
        AppValidators.validateLibyanPhone('0901234567', isRequired: true, isAlternative: false),
        'رقم الهاتف الأساسي غير صحيح',
      );
      expect(
        AppValidators.validateLibyanPhone('0911234567', isRequired: true, isAlternative: false),
        isNull,
      );
    });

    // السيناريو 4: إدخال رقم احتياطي غير صالح
    test('4. إدخال رقم احتياطي غير صالح يُرجع رسالة مخصصة للرقم الاحتياطي', () {
      expect(
        AppValidators.validateLibyanPhone('0987654321', isRequired: false, isAlternative: true),
        'رقم الهاتف الاحتياطي غير صحيح',
      );
      expect(
        AppValidators.validateLibyanPhone('092123456', isRequired: false, isAlternative: true), // 9 خانات
        'رقم الهاتف الاحتياطي غير صحيح',
      );
      expect(
        AppValidators.validateLibyanPhone('0921234567', isRequired: false, isAlternative: true),
        isNull,
      );
    });

    // السيناريو 5: إدخال 922222222 في حقل الرقم الاحتياطي (مشكلة البداية بدون 0)
    test('5. إدخال 922222222 في حقل الرقم الاحتياطي يجب رفضه بدقة وعدم قبوله تلقائياً', () {
      final result = AppValidators.validateLibyanPhone(
        '922222222',
        isRequired: false,
        isAlternative: true,
      );
      expect(result, 'رقم الهاتف الاحتياطي غير صحيح');

      // والتأكد أيضاً من رفضه إذا دخل في الرقم الأساسي
      final primaryResult = AppValidators.validateLibyanPhone(
        '922222222',
        isRequired: true,
        isAlternative: false,
      );
      expect(primaryResult, 'رقم الهاتف الأساسي غير صحيح');

      // بينما الرقم بالصيغة الصحيحة 0922222222 يُقبل
      final validResult = AppValidators.validateLibyanPhone(
        '0922222222',
        isRequired: false,
        isAlternative: true,
      );
      expect(validResult, isNull);
    });

    // السيناريو 6: إدخال رقم أساسي ورقم احتياطي غير صالحين معاً
    test('6. إدخال رقم أساسي ورقم احتياطي غير صالحين معاً يُنتج رسالتين منفصلتين ومستقلتين', () {
      final primaryErr = AppValidators.validateLibyanPhone(
        '0811111111',
        isRequired: true,
        isAlternative: false,
      );
      final altErr = AppValidators.validateLibyanPhone(
        '922222222',
        isRequired: false,
        isAlternative: true,
      );

      expect(primaryErr, 'رقم الهاتف الأساسي غير صحيح');
      expect(altErr, 'رقم الهاتف الاحتياطي غير صحيح');
      expect(primaryErr != altErr, isTrue); // كل رسالة مخصصة لحقلها

      // حالة تطابق الرقمين
      final sameAltErr = AppValidators.validateLibyanPhone(
        '0911234567',
        isRequired: false,
        primaryPhone: '0911234567',
        isAlternative: true,
      );
      expect(sameAltErr, 'لا يمكن أن يكون رقم الهاتف الاحتياطي نفس رقم الهاتف الأساسي');
    });

    // السيناريو 7: إدخال أخطاء متعددة من Backend والتحقق من توزيعها على الحقول الصحيحة
    test('7. توزيع استجابة أخطاء الـ Backend المفهرسة على الحقول المناسبة دون دمجها', () {
      final backendResponse = {
        'status': false,
        'message': 'بيانات الإدخال غير صالحة',
        'errors': {
          'email': ['البريد الإلكتروني مسجل بالفعل.'],
          'phone': ['رقم الهاتف الأساسي غير صالح.'],
          'alternative_phone': ['رقم الهاتف الاحتياطي مسجل لحساب آخر.'],
          'password': ['كلمة المرور يجب أن تحتوي على حرف ورقم.'],
        },
      };

      final fieldErrors = ApiException.extractFieldErrors(backendResponse);
      expect(fieldErrors, isNotNull);
      expect(fieldErrors!['email'], 'البريد الإلكتروني مسجل بالفعل.');
      expect(fieldErrors['phone'], 'رقم الهاتف الأساسي غير صالح.');
      expect(fieldErrors['alternative_phone'], 'رقم الهاتف الاحتياطي مسجل لحساب آخر.');
      expect(fieldErrors['password'], 'كلمة المرور يجب أن تحتوي على حرف ورقم.');

      // التأكد من عدم خلط أو دمج الرسائل مع بعضها
      expect(fieldErrors['email']!.contains('الهاتف'), isFalse);
      expect(fieldErrors['phone']!.contains('البريد'), isFalse);
      expect(fieldErrors['alternative_phone']!.contains('الأساسي'), isFalse);
    });

    // السيناريو 8: تصحيح حقل واحد مع بقاء حقل آخر غير صالح
    test('8. تصحيح حقل واحد يزيل خطأه بينما يبقى خطأ الحقل الآخر مستقلاً', () {
      // البريد تم تصحيحه
      final emailResult = AppValidators.validateEmail('user@test.ly');
      expect(emailResult, isNull);

      // بينما الهاتف ما زال خاطئاً
      final phoneResult = AppValidators.validateLibyanPhone(
        '091abc',
        isRequired: true,
        isAlternative: false,
      );
      expect(phoneResult, 'رقم الهاتف الأساسي غير صحيح');
    });

    // السيناريو 9: تصحيح جميع الحقول وإعادة الإرسال
    test('9. تصحيح جميع الحقول بنجاح يقبل النموذج بالكامل', () {
      expect(AppValidators.validateArabicTripleName('محمد علي الساعدي'), isNull);
      expect(AppValidators.validateEmail('parent@darby.ly'), isNull);
      expect(
        AppValidators.validateLibyanPhone('0912345678', isRequired: true, isAlternative: false),
        isNull,
      );
      expect(
        AppValidators.validateLibyanPhone(
          '0923456789',
          isRequired: false,
          primaryPhone: '0912345678',
          isAlternative: true,
        ),
        isNull,
      );
      expect(AppValidators.validatePassword('Password123'), isNull);
      expect(AppValidators.validateConfirmPassword('Password123', 'Password123'), isNull);
    });

    // السيناريو 10: خطأ عام في الاتصال أو الخادم دون ربطه بأي حقل عشوائي
    test('10. حدوث خطأ عام بالخادم لا يوزع الخطأ على الحقول ويترك fieldErrors فارغاً', () {
      final generalErrorResponse = {
        'status': false,
        'message': 'حدث خطأ في الاتصال بالخادم، يرجى المحاولة لاحقاً.',
      };

      final fieldErrors = ApiException.extractFieldErrors(generalErrorResponse);
      // يجب أن يكون null لكي يظهر فقط في SnackBar ولا يُربط بأي حقل عشوائي
      expect(fieldErrors, isNull);
    });

    // السيناريو 11: رسالة تعذر إرسال رمز التحقق عبر البريد الإلكتروني لا تُربط بحقل البريد
    test('11. رسالة تعذر إرسال رمز التحقق عبر البريد الإلكتروني لا تُنسب كخطأ حقل للبريد وتترك fieldErrors فارغاً', () {
      final otpErrorResponse = {
        'status': false,
        'message': 'تعذر إرسال رمز التحقق عبر البريد الإلكتروني',
      };

      final fieldErrors = ApiException.extractFieldErrors(otpErrorResponse);
      // يجب أن يكون null لكي يظهر فقط في SnackBar ولا يظهر تحت خانة البريد
      expect(fieldErrors, isNull);

      // بينما خطأ البريد المسجل مسبقاً يرتبط بحقل البريد
      final emailRegisteredResponse = {
        'status': false,
        'message': 'البريد الإلكتروني مسجل بالفعل، يرجى استخدام بريد آخر.',
      };
      final emailFieldErrors = ApiException.extractFieldErrors(emailRegisteredResponse);
      expect(emailFieldErrors, isNotNull);
      expect(emailFieldErrors!['email'], 'البريد الإلكتروني مسجل بالفعل، يرجى استخدام بريد آخر.');
    });
  });
}
