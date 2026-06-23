import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  // --- [المخزن المؤقت لتجميع بيانات الشاشات محلياً] ---
  String? selectedRole; // 'parent' أو 'driver' للتحقق الذكي في شاشة الموقع
  int? selectedRoleId;  // 3 للأب، 2 للسائق
  
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

  // --- [مخزن مؤقت إضافي لبيانات السائق المجزأة] ---
  String? driverNationalId;
  String? driverLicenseNumber;
  String? driverLicenseExpiry;
  String? driverBrand;
  String? driverModel;
  String? driverPlateNumber;
  int? driverYear;
  String? driverColor;
  int? driverCapacityManual;

  // دالة تحديث الرول المختار من الشاشة الأولى
  void updateRole(int roleId) {
    selectedRoleId = roleId;
    selectedRole = (roleId == 2) ? 'driver' : 'parent';
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

  // --- [دوال المحاكاة للسائق لضمان عمل الفلو بدون إيرور] ---

  // 1. دالة إعادة إرسال الرمز (لشاشة التحقق)
  Future<void> resendOtp(String emailAddress) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // ==================== [APIs فلو ولي الأمر] ====================

  // 1. إرسال الأوتوبي للأب (شاشة البريد)
  Future<void> sendParentOtp(String targetEmail) async {
    emit(ParentOtpSentLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      email = targetEmail; 
      emit(ParentOtpSentSuccess("تم إرسال كود التحقق بنجاح."));
    } catch (e) {
      emit(ParentOtpSentError(e.toString()));
    }
  }

  // 2. التسجيل النهائي للأب (شاشة البديل بعد تجميع كل شيء)
  Future<void> registerParent(int otpCode) async {
    emit(ParentRegisterLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
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
      await Future.delayed(const Duration(milliseconds: 500));
      registeredUserId = 15; // محاكاة تخزين الـ id المستلم
      emit(DriverRegisterFirstStageSuccess("تم تسجيل البيانات الأساسية، يرجى تفعيل الحساب.", 15));
    } catch (e) {
      emit(DriverRegisterFirstStageError(e.toString()));
    }
  }

  // 2. المرحلة الثانية للسائق (التحقق وتفعيل الحساب)
  Future<void> verifyDriverOtp(String otpCode) async {
    emit(DriverVerifyOtpLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      emit(DriverVerifyOtpSuccess("تم تفعيل حساب السائق بنجاح."));
    } catch (e) {
      emit(DriverVerifyOtpError(e.toString()));
    }
  }

  // 3. المرحلة الثالثة الحقيقية للسائق (إكمال ملف السيارة والوثائق)
  Future<void> submitDriverCompleteProfile() async {
    emit(DriverCompleteProfileLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(DriverCompleteProfileSuccess("تم رفع البيانات بنجاح، بانتظار مراجعة الإدارة."));
    } catch (e) {
      emit(DriverCompleteProfileError(e.toString()));
    }
  }

  // دالة بديلة في حال تمرير داتا الـ Map مباشرة من الشاشة الـ 7
  Future<void> completeDriverProfile(Map<String, dynamic> vehicleAndDocsData) async {
    await submitDriverCompleteProfile();
  }

  // ==================== [Endpoint الموقع المشترك] ====================
  Future<void> saveLocation({required String label, required double lat, required double lng, required bool isDefault}) async {
    emit(LocationSaveLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      emit(LocationSaveSuccess("تم حفظ الموقع بنجاح."));
    } catch (e) {
      emit(LocationSaveError(e.toString()));
    }
  }
}