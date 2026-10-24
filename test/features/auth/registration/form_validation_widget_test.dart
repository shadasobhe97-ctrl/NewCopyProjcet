import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/utils/app_validators.dart';
import 'package:kids_transport/features/auth/registration/logic/register_cubit.dart';
import 'package:kids_transport/features/auth/registration/logic/register_state.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/parent/parent_basic_info_screen.dart';

class MockRegisterCubit extends Cubit<RegisterState> implements RegisterCubit {
  MockRegisterCubit() : super(RegisterInitial());

  @override
  String? fullName;
  @override
  String? email;
  @override
  String? phoneNumber;
  @override
  String? alternativePhone;
  @override
  String? password;
  @override
  dynamic avatarFile;
  @override
  String? gender;

  @override
  Future<void> sendParentOtp(String targetEmail) async {
    // لا نحتاج لطلب شبكة حقيقي أثناء اختبار الواجهة
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  void emitState(RegisterState state) => emit(state);
}

void main() {
  late MockRegisterCubit mockCubit;

  setUp(() {
    mockCubit = MockRegisterCubit();
  });

  tearDown(() {
    mockCubit.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: BlocProvider<RegisterCubit>.value(
        value: mockCubit,
        child: const ParentBasicInfoScreen(),
      ),
    );
  }

  group('اختبارات الواجهة (Widget Tests) للتحقق من الحقول والأخطاء', () {
    testWidgets('1. ظهور رسالة الخطأ والإطار الأحمر عند إرسال النموذج فارغاً', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final submitButton = find.byType(ElevatedButton);
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('الرجاء إدخال الاسم الكامل'), findsOneWidget);
      expect(find.text('الرجاء إدخال البريد الإلكتروني'), findsOneWidget);
      expect(find.text('الرجاء إدخال رقم الهاتف الأساسي'), findsOneWidget);
      // يظهر لكل من كلمة المرور وتأكيد كلمة المرور
      expect(find.text('الرجاء إدخال كلمة المرور'), findsNWidgets(2));

      final emailDecorator = tester.widget<InputDecorator>(
        find.descendant(of: find.widgetWithIcon(TextFormField, Icons.email_outlined), matching: find.byType(InputDecorator)).first,
      );
      expect(emailDecorator.decoration.errorText, isNotNull);
    });

    testWidgets('2. استقلالية خطأ الرقم الأساسي عن الرقم الاحتياطي في الواجهة', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final phoneField = find.widgetWithIcon(TextFormField, Icons.phone_android_outlined);
      final altPhoneField = find.widgetWithIcon(TextFormField, Icons.phone_outlined);

      await tester.enterText(phoneField, '0911234567');
      await tester.enterText(altPhoneField, '922222222');
      await tester.pumpAndSettle();

      final submitButton = find.byType(ElevatedButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('رقم الهاتف الاحتياطي غير صحيح'), findsOneWidget);
      expect(find.text('رقم الهاتف الأساسي غير صحيح'), findsNothing);
    });

    testWidgets('3. اختفاء خطأ الحقل فور تصحيح قيمته أثناء الكتابة', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final emailField = find.widgetWithIcon(TextFormField, Icons.email_outlined);
      await tester.enterText(emailField, 'invalid-email');
      await tester.pumpAndSettle();

      final submitButton = find.byType(ElevatedButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('أدخل بريدًا إلكترونيًا صحيحًا'), findsOneWidget);

      await tester.enterText(emailField, 'valid.email@darby.ly');
      await tester.pumpAndSettle();

      expect(find.text('أدخل بريدًا إلكترونيًا صحيحًا'), findsNothing);
    });

    testWidgets('4. عدم ظهور SnackBar عند وجود أخطاء مرتبطة بحقول الشاشة فقط', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'example@email.com');
      final phoneField = find.widgetWithText(TextFormField, '091XXXXXXX');
      await tester.enterText(emailField, 'registered@darby.ly');
      await tester.enterText(phoneField, '0911234567');
      await tester.pumpAndSettle();

      mockCubit.emitState(
        ParentOtpSentError(
          'البيانات غير صالحة',
          fieldErrors: {
            'email': 'البريد الإلكتروني مسجل بالفعل.',
            'phone': 'رقم الهاتف مستخدم مسبقاً.',
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('البريد الإلكتروني مسجل بالفعل.'), findsOneWidget);
      expect(find.text('رقم الهاتف مستخدم مسبقاً.'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('5. ظهور SnackBar عند حدوث خطأ عام بالخادم', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      mockCubit.emitState(
        ParentOtpSentError('فشل الاتصال بالخادم، يرجى المحاولة لاحقاً.'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('فشل الاتصال بالخادم، يرجى المحاولة لاحقاً.'), findsOneWidget);
    });

    testWidgets('6. ظهور SnackBar لخطأ غير مرتبط بحقل ظاهر، مع بقاء أخطاء الحقول الظاهرة', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'example@email.com');
      await tester.enterText(emailField, 'registered@darby.ly');
      await tester.pumpAndSettle();

      mockCubit.emitState(
        ParentOtpSentError(
          'فشل التحقق من البيانات',
          fieldErrors: {
            'email': 'البريد الإلكتروني مسجل بالفعل.',
            'city_id': 'المدينة المحددة غير مدعومة حالياً.',
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('البريد الإلكتروني مسجل بالفعل.'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('المدينة المحددة غير مدعومة حالياً.'), findsOneWidget);
    });

    testWidgets('7. ظهور رسالة تعذر إرسال رمز التحقق في SnackBar فقط وليس تحت خانة البريد', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'example@email.com');
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      mockCubit.emitState(
        ParentOtpSentError('تعذر إرسال رمز التحقق عبر البريد الإلكتروني'),
      );
      await tester.pumpAndSettle();

      // تظهر في SnackBar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('تعذر إرسال رمز التحقق عبر البريد الإلكتروني'), findsOneWidget);

      // لا تظهر تحت خانة البريد
      final emailDecorator = tester.widget<InputDecorator>(
        find.descendant(of: emailField, matching: find.byType(InputDecorator)).first,
      );
      expect(emailDecorator.decoration.errorText, isNull);
    });
  });

  group('اختبار استنتاج نوع الهاتف الاحتياطي في الدالة المشتركة', () {
    test('استنتاج أن الرقم احتياطي تلقائياً بمجرد وجود primaryPhone في الشاشات الأخرى', () {
      // شاشة مثل parent_profile_screen أو driver_profile_screen تستدعي:
      // AppValidators.validateLibyanPhone(val, isRequired: false, primaryPhone: '0911111111')
      final result = AppValidators.validateLibyanPhone(
        '922222222',
        isRequired: false,
        primaryPhone: '0911111111',
      );
      // يجب أن يُرجع رسالة الرقم الاحتياطي تلقائياً
      expect(result, 'رقم الهاتف الاحتياطي غير صحيح');
    });

    test('إبقاء رسالة الرقم الأساسي عند عدم تمرير primaryPhone', () {
      final result = AppValidators.validateLibyanPhone(
        '922222222',
        isRequired: true,
      );
      expect(result, 'رقم الهاتف الأساسي غير صحيح');
    });
  });
}
