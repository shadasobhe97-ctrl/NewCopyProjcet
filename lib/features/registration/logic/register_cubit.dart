import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_state.dart';
// حنستوردوا الموديلز اللي جهزناهم سابقاً هنا

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  // --- [المخزن المؤقت لتجميع بيانات الشاشات محلياً] ---
  int? selectedRoleId; // 3 للأب، 2 للسائق
  
  // بيانات أساسية مشتركة
  String? fullName;
  String? email;
  String? phoneNumber;
  String? password;
  String? alternativePhone;
  File? avatarFile;
  String? gender;
  
  // بيانات جهاز ومنصة (تتولد تلقائياً وتتخزن هنا)
  String deviceName = "Unknown";
  String platformName = "Unknown";

  // بيانات تم استلامها من السيرفر ونحتاجوها للمراحل الجاية
  int? registeredUserId; // الـ user_id المستلم من دالة السائق 1
  int? parentOtpCode;    // كود أوتوبي الأب المحقق

  // دالة تحديث الرول المختار من الشاشة الأولى
  void updateRole(int roleId) {
    selectedRoleId = roleId;
  }

  // دالة تجميع البيانات الأساسية من الشاشات المشتركة
  void saveBasicInfo({
    required String name,
    required String mail,
    required String phone,
    required String pass,
    String? altPhone,
    File? avatar,
    String? userGender,
  }) {
    fullName = name;
    email = mail;
    phoneNumber = phone;
    password = pass;
    alternativePhone = altPhone;
    avatarFile = avatar;
    gender = userGender;
  }

  // ==================== [APIs فلو ولي الأمر] ====================

  // 1. إرسال الأوتوبي للأب (شاشة البريد)
  Future<void> sendParentOtp(String targetEmail) async {
    emit(ParentOtpSentLoading());
    try {
      // محاكاة طلب السيرفر لتجربة التحميل والـ UI
      await Future.delayed(const Duration(milliseconds: 800));
      email = targetEmail; // حفظ البريد الإلكتروني محلياً لاستخدامه لاحقاً
      emit(ParentOtpSentSuccess("تم إرسال كود التحقق بنجاح."));
    } catch (e) {
      emit(ParentOtpSentError(e.toString()));
    }
  }

  // 2. التسجيل النهائي للأب (شاشة البديل بعد تجميع كل شيء)
  Future<void> registerParent(int otpCode) async {
    emit(ParentRegisterLoading());
    try {
      // محاكاة طلب السيرفر لتجربة التحميل والـ UI
      await Future.delayed(const Duration(milliseconds: 1000));
      // حفظ كود التحقق مؤقتاً
      parentOtpCode = otpCode;
      emit(ParentRegisterSuccess("تم إنشاء حساب ولي الأمر بنجاح."));
    } catch (e) {
      emit(ParentRegisterError(e.toString()));
    }
  }

  // ==================== [APIs فلو السائق] ====================

  // 1. المرحلة الأولى للسائق (إنشاء الحساب الأساسي)
  Future<void> registerDriverFirstStage() async {
    emit(DriverRegisterFirstStageLoading());
    try {
      // إرسال البيانات كـ Multipart بسبب الصورة
      // final response = await _repository.registerDriverFirst(DriverRegisterRequest(...));
      // registeredUserId = response.userId; // تخزين الـ id المستلم للمرحلة الثالثة
      emit(DriverRegisterFirstStageSuccess("تم تسجيل البيانات الأساسية، يرجى تفعيل الحساب.", 15));
    } catch (e) {
      emit(DriverRegisterFirstStageError(e.toString()));
    }
  }

  // 2. المرحلة الثانية للسائق (التحقق وتفعيل الحساب)
  Future<void> verifyDriverOtp(String otpCode) async {
    emit(DriverVerifyOtpLoading());
    try {
      // final response = await _repository.verifyDriverOtp(DriverVerifyOtpRequest(email: email!, otp: otpCode));
      emit(DriverVerifyOtpSuccess("تم تفعيل حساب السائق بنجاح."));
    } catch (e) {
      emit(DriverVerifyOtpError(e.toString()));
    }
  }

  // 3. المرحلة الثالثة للسائق (إكمال ملف السيارة والوثائق)
  Future<void> completeDriverProfile(Map<String, dynamic> vehicleAndDocsData) async {
    emit(DriverCompleteProfileLoading());
    try {
      // تحويل الخريطة المستقبلة من شاشات الـ UX إلى الـ Request Model النهائي
      // ونمرر الـ registeredUserId في الـ Endpoint كطلب ريان
      // final response = await _repository.completeDriverProfile(userId: registeredUserId!, request: ...);
      emit(DriverCompleteProfileSuccess("تم رفع بيانات المركبة والوثائق، بانتظار مراجعة الإدارة."));
    } catch (e) {
      emit(DriverCompleteProfileError(e.toString()));
    }
  }

  // ==================== [Endpoint الموقع المشترك] ====================
  Future<void> saveLocation({required String label, required double lat, required double lng, required bool isDefault}) async {
    emit(LocationSaveLoading());
    try {
      // محاكاة طلب السيرفر لتجربة التحميل والـ UI
      await Future.delayed(const Duration(milliseconds: 800));
      emit(LocationSaveSuccess("تم حفظ الموقع بنجاح."));
    } catch (e) {
      emit(LocationSaveError(e.toString()));
    }
  }
}