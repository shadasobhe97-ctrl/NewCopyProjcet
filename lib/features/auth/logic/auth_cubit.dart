import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/auth/data/models/reset_password_request_model.dart';
import 'package:kids_transport/features/auth/data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository = AuthRepository();
  AuthCubit() : super(AuthInitial());

  bool isPasswordObscured = true;

  void togglePasswordVisibility() {
    isPasswordObscured = !isPasswordObscured;
    emit(PasswordVisibilityChanged(isPasswordObscured));
  }

  // 1. تسجيل الدخول
 // 1. تسجيل الدخول (معدلة للوضع التجريبي لتمرير البيانات بنجاح)
  void login({required String phone, required String password}) async {
    emit(AuthLoading());
    try {
      // ==================== [كود الربط الفعلي بالباكيند - محطوط كومنت] ====================
      /*
      final request = LoginRequestModel(
        phoneNumber: phone,
        password: password,
        deviceName: "Postman_Test_Mac", 
        platform: "web",
      );
      
      final response = await _repository.login(request);
      
      if (response.status) {
        emit(AuthSuccess(
          message: response.message, 
          roleName: response.roleName,
          token: response.accessToken, 
          roleId: response.user.roleId, // تمرير الـ ID الفعلي
        ));
      } else {
        emit(AuthError(response.message));
      }
      */
      // =======================================================================================

      // ==================== [الوضع التجريبي الحالي الذكي] ====================
      await Future.delayed(const Duration(seconds: 2)); 

      // هنا نحددوا الدور وهمياً للتجربة (لو يبدأ بـ 091 خليه سائق، لو غيره خليه ولي أمر)
      // هكي تقدري تجربي الحالتين في التليفون بمجرد تغيير الرقم!
      bool isDriver = phone.startsWith('091'); 

      emit(AuthSuccess(
        message: isDriver ? "مرحباً بك يا كابتن، تم تسجيل الدخول بنجاح!" : "مرحباً خالد مصطفى الورفلي، تم تسجيل الدخول بنجاح!",
        roleName: isDriver ? "سائق" : "ولي أمر",
        token: "3|yj1MsGBh28EDGgZoKvb17ZkA88qZg7aEzUcovroO6899e4a5",
        roleId: isDriver ? 2 : 3, // 2 للسائق و 3 لولي الأمر
      ));
      // ============================================================================

    } catch (e) {
      emit(AuthError("فشل الاتصال بالسيرفر، يرجى المحاولة لاحقاً."));
    }
  }
// 2. إرسال رمز الـ OTP (المصححة والمطابقة للـ Clean Architecture الجديد)
  void sendOtp({required String email}) async {
    emit(AuthLoading());
    try {
      final response = await _repository.sendOtp(email); // الـ response هنا توا نوعه AuthCommonResponseModel
      
      // 🌟 نقرأ الـ status بالنقطة مباشرة مش بالـ Map
      if (response.status) { 
        emit(OtpSentSuccess(message: response.message, email: email));
      } else {
        emit(AuthError(response.message));
      }
    } catch (e) {
      emit(AuthError("فشل الاتصال بالسيرفر."));
    }
  }

  // 3. إعادة تعيين كلمة المرور (المصححة والمطابقة للـ Clean Architecture الجديد)
  void resetPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    emit(AuthLoading());
    try {
      final request = ResetPasswordRequestModel(
        email: email,
        code: code,
        password: password,
        passwordConfirmation: confirmPassword,
      );
      final response = await _repository.resetPassword(request); // الـ response هنا توا نوعه AuthCommonResponseModel
      
      // 🌟 نقرأ الـ status والـ message بالنقطة مباشرة مش بالـ Map
      if (response.status) { 
        emit(PasswordResetSuccessState(response.message));
      } else {
        emit(AuthError(response.message));
      }
    } catch (e) {
      emit(AuthError("فشل الاتصال بالسيرفر."));
    }
  }
}