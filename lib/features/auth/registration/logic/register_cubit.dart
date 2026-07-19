import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/auth/registration/data/models/driver_register_request.dart';
import 'package:kids_transport/features/auth/registration/data/models/parent_register_request.dart';
import 'package:kids_transport/features/auth/registration/data/repositories/registration_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegistrationRepository _repository;

  RegisterCubit(this._repository) : super(RegisterInitial());

  // --- [المخزن المؤقت لتجميع بيانات الشاشات محلياً] ---
  String? selectedRole; // 'parent' أو 'driver'
  int? selectedRoleId; // 3 للأب، 4 للسائق

  // بيانات أساسية مشتركة
  String? fullName;
  String? email;
  String? phoneNumber;
  String? password;
  String? alternativePhone;
  File? avatarFile;
  String? gender;

  // بيانات الجهاز والمنصة (تتولد تلقائياً)
  String get _platform {
    if (kIsWeb) return 'web';
    if (defaultTargetPlatform == TargetPlatform.android) return 'android';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    return 'web';
  }

  String get _deviceName {
    if (kIsWeb) return 'Derbi_Flutter_Web';
    if (defaultTargetPlatform == TargetPlatform.android)
      return 'Derbi_Flutter_Android';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'Derbi_Flutter_iOS';
    return 'Derbi_Flutter';
  }

  // بيانات تم استلامها من السيرفر ونحتاجوها للمراحل الجاية
  int? registeredUserId;
  String? driverAccessToken;
  String? parentAccessToken; // التوكن المستلم بعد تسجيل ولي الأمر

  // مخزن مؤقت إضافي لبيانات السائق
  String? driverNationalId;
  String? driverLicenseNumber;
  String? driverLicenseExpiry;
  String? driverBrand;
  String? driverModel;
  String? driverPlateNumber;
  int? driverYear;
  String? driverColor;
  int? driverCapacityManual;

  // دالة تحديث الرول المختار
  void updateRole(int roleId) {
    selectedRoleId = roleId;
    selectedRole = (roleId == 4) ? 'driver' : 'parent';
  }

  // دالة تجميع البيانات الأساسية
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

  // 1. إرسال OTP لولي الأمر → POST /api/parent/send-otp
  // يُستخدم لأول إرسال وأيضاً لإعادة الإرسال (نفس الـ endpoint)
  Future<void> sendParentOtp(String targetEmail) async {
    emit(ParentOtpSentLoading());
    try {
      email = targetEmail;
      final responseData = await _repository.sendParentOtp(targetEmail);

      // تعديل مباشر وآمن لقراءة الـ status والـ message
      final bool success = responseData['status'] == true;
      final String message =
          responseData['message']?.toString() ?? 'تم إرسال رمز التحقق.';

      if (success) {
        emit(ParentOtpSentSuccess(message));
      } else {
        emit(ParentOtpSentError(message));
      }
    } on ApiException catch (e) {
      emit(ParentOtpSentError(e.message));
    } catch (e) {
      emit(ParentOtpSentError('خطأ: ${e.toString()}'));
    }
  }

  // 2. إعادة إرسال OTP لولي الأمر - يستخدم نفس الـ endpoint /api/parent/send-otp
  Future<String> resendParentOtp(String targetEmail) async {
    final responseData = await _repository.resendParentOtp(targetEmail);
    final bool success = _readBool(responseData['status']);
    final String message = _readMessage(
      responseData,
      'تم إعادة إرسال رمز التحقق.',
    );
    if (!success) {
      throw ApiException(message);
    }
    return message;
  }

  // 3. التسجيل النهائي لولي الأمر → POST /api/parent/register
  // الـ OTP يُرسل مباشرة في الـ body مع بيانات التسجيل (لا يوجد verify endpoint منفصل)
  Future<void> registerParent(String otpCode) async {
    emit(ParentRegisterLoading());
    try {
      final parsedOtp = int.tryParse(otpCode);
      if (parsedOtp == null) {
        emit(ParentRegisterError('رمز التحقق غير صالح، يرجى إدخال 6 أرقام.'));
        return;
      }

      final request = ParentRegisterRequest(
        fullName: fullName ?? '',
        email: email ?? '',
        phoneNumber: phoneNumber ?? '',
        alternativePhone: alternativePhone,
        password: password ?? '',
        passwordConfirmation: password ?? '',
        otp: parsedOtp,
        deviceName: _deviceName,
        platform: _platform,
        fcmToken: null,
        avatar: avatarFile,
      );

      // طباعة الـ payload للتأكد من صحته وعدم قلب الرمز
      print('=== Parent Registration Request Payload ===');
      print(request.toJson());
      print('===========================================');

      final response = await _repository.registerParent(request);

      if (!response.status) {
        emit(
          ParentRegisterError(
            response.message.isNotEmpty
                ? response.message
                : 'فشل إنشاء الحساب.',
          ),
        );
        return;
      }

      // حفظ التوكن والجلسة كاملة لاستخدامها فوراً في API calls
      parentAccessToken = response.accessToken;
      registeredUserId = response.id;

      await StorageService.saveUserSession(
        token: response.accessToken,
        tokenType: response.tokenType.isNotEmpty
            ? response.tokenType
            : 'Bearer',
        roleId: response.user.roleId,
        roleName: response.roleName,
        userId: response.user.id,
        fullName: response.user.fullName,
        phoneNumber: response.user.phoneNumber,
        isActive: response.user.isActive,
      );

      // حفظ parent_id فوراً لاستخدامه في إضافة الأطفال والعناوين
      final pid = response.parentId;
      if (pid != null && pid > 0) {
        await StorageService.saveParentId(pid);
      }

      emit(
        ParentRegisterSuccess(
          response.fullName.isNotEmpty
              ? 'مرحباً ${response.fullName}، تم إنشاء حسابك بنجاح.'
              : 'تم إنشاء الحساب بنجاح.',
        ),
      );
    } on ApiException catch (e) {
      emit(ParentRegisterError(e.message));
    } catch (_) {
      emit(ParentRegisterError('فشل إنشاء الحساب، يرجى المحاولة مرة أخرى.'));
    }
  }

  // ==================== [APIs فلو السائق] ====================

  // 1. المرحلة الأولى للسائق
  Future<void> registerDriverFirstStage() async {
    emit(DriverRegisterFirstStageLoading());
    try {
      final request = DriverRegisterRequest(
        fullName: fullName ?? '',
        email: email ?? '',
        phoneNumber: phoneNumber ?? '',
        gender: gender ?? 'male',
        password: password ?? '',
        avatarFile: avatarFile,
        deviceName: _deviceName,
        platform: _platform,
        fcmToken: 'derbi_fcm_token_placeholder',
        alternativePhone: alternativePhone,
      );

      final response = await _repository.registerDriver(request);

      if (!response.status) {
        emit(
          DriverRegisterFirstStageError(
            response.message.isNotEmpty
                ? response.message
                : 'فشل إنشاء الحساب.',
          ),
        );
        return;
      }

      registeredUserId = response.userId;
      emit(DriverRegisterFirstStageSuccess(response.message, response.userId));
    } on ApiException catch (e) {
      emit(DriverRegisterFirstStageError(e.message));
    } catch (_) {
      emit(
        DriverRegisterFirstStageError(
          'فشل الاتصال بالخادم، يرجى المحاولة مرة أخرى.',
        ),
      );
    }
  }

  // 2. إعادة إرسال OTP للسائق
  Future<String> resendOtp(String emailAddress) async {
    final responseData = await _repository.resendDriverOtp(emailAddress);
    final bool success = _readBool(responseData['status']);
    final String message = _readMessage(
      responseData,
      'تم إعادة إرسال رمز التحقق.',
    );
    if (!success) {
      throw ApiException(message);
    }
    return message;
  }

  // 3. المرحلة الثانية للسائق (التحقق من OTP)
  Future<void> verifyDriverOtp(String otpCode) async {
    emit(DriverVerifyOtpLoading());
    try {
      final response = await _repository.verifyDriverOtp(email ?? '', otpCode);

      if (!response.status) {
        emit(
          DriverVerifyOtpError(
            response.message.isNotEmpty
                ? response.message
                : 'رمز التحقق غير صحيح.',
          ),
        );
        return;
      }

      if (response.userId > 0) registeredUserId = response.userId;
      driverAccessToken = response.accessToken;

      emit(DriverVerifyOtpSuccess(response.message));
    } on ApiException catch (e) {
      emit(DriverVerifyOtpError(e.message));
    } catch (_) {
      emit(
        DriverVerifyOtpError('فشل التحقق من الرمز، يرجى المحاولة مرة أخرى.'),
      );
    }
  }

  // 4. إكمال ملف السائق
  Future<void> completeDriverProfile(
    Map<String, dynamic> vehicleAndDocsData,
  ) async {
    emit(DriverCompleteProfileLoading());
    try {
      final combinedData = {
        ...vehicleAndDocsData,
        'national_id': driverNationalId ?? '',
        'license_number': driverLicenseNumber ?? '',
        'license_expiry': driverLicenseExpiry ?? '',
        if (alternativePhone != null) 'alternative_phone': alternativePhone,
      };

      final response = await _repository.completeDriverProfile(
        userId: registeredUserId ?? 0,
        token: driverAccessToken ?? '',
        data: combinedData,
      );

      if (!response.status) {
        emit(
          DriverCompleteProfileError(
            response.message.isNotEmpty ? response.message : 'فشل رفع الملف.',
          ),
        );
        return;
      }

      // حفظ جلسة السائق بعد إكمال الملف
      final driverData = response.data;
      await StorageService.saveUserSession(
        token: driverAccessToken ?? '',
        tokenType: 'Bearer',
        roleId: 4, // driver
        roleName: 'driver',
        userId: driverData?.id ?? registeredUserId,
        fullName: driverData?.fullName,
        phoneNumber: null,
        isActive: true,
      );

      // حفظ driver_id لاستخدامه في المهام الخاصة بالسائق
      final rawDriverId = driverData?.driverId ?? driverData?.id ?? 0;
      if (rawDriverId > 0) {
        await StorageService.saveDriverId(rawDriverId);
      }

      emit(DriverCompleteProfileSuccess(response.message));
    } on ApiException catch (e) {
      emit(DriverCompleteProfileError(e.message));
    } catch (_) {
      emit(
        DriverCompleteProfileError('فشل رفع البيانات، يرجى المحاولة مرة أخرى.'),
      );
    }
  }

  Future<void> submitDriverCompleteProfile() async {
    await completeDriverProfile({});
  }

  // ==================== [Endpoint الموقع - ولي الأمر] ====================
  Future<void> saveLocation({
    required String label,
    required double lat,
    required double lng,
    required bool isDefault,
  }) async {
    emit(LocationSaveLoading());
    try {
      final token = parentAccessToken ?? '';
      if (token.isEmpty) {
        emit(
          LocationSaveError('لا يوجد توكن صالح، يرجى تسجيل الدخول مرة أخرى.'),
        );
        return;
      }

      final response = await _repository.addParentAddress(
        token: token,
        label: label,
        lat: lat,
        lng: lng,
        isDefault: isDefault,
      );

      emit(
        LocationSaveSuccess(
          response.message.isNotEmpty
              ? response.message
              : 'تم حفظ العنوان بنجاح.',
        ),
      );
    } on ApiException catch (e) {
      emit(LocationSaveError(e.message));
    } catch (_) {
      emit(LocationSaveError('فشل حفظ الموقع، يرجى المحاولة مرة أخرى.'));
    }
  }

  bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }

  String _readMessage(Map<String, dynamic> data, String fallback) {
    return ApiException.extractMessage(data) ?? fallback;
  }
}
