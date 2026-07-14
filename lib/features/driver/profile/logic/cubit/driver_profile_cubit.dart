import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/driver_profile_repository.dart';
import 'driver_profile_state.dart';

class DriverProfileCubit extends Cubit<DriverProfileState> {
  final DriverProfileRepository repository;

  DriverProfileCubit(this.repository) : super(DriverProfileInitial());

  // 1. دالة جلب بيانات البروفايل عند فتح الشاشة
  Future<void> fetchProfile() async {
    emit(DriverProfileLoading());
    try {
      final driver = await repository.getDriverProfile();
      emit(DriverProfileLoaded(driver));
    } catch (e) {
      // إزالة كلمة "Exception:" لتظهر الرسالة نظيفة للمستخدم
      emit(DriverProfileError(e.toString().replaceAll('Exception:', '')));
    }
  }

  // 2. دالة تحديث البيانات الشخصية والمظهر (POST)
  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
    String? alternativePhone,
    String? email,
  }) async {
    // إذا كنا في حالة العرض السابقة، نمرر البيانات الحالية للـ Loading حتى لا تظهر شاشة بيضاء فارغة
    if (state is DriverProfileLoaded) {
      emit(DriverProfileUpdateLoading((state as DriverProfileLoaded).driver));
    }

    try {
      // استدعاء المستودع لإرسال البيانات الجديدة للسيرفر
      final updatedDriver = await repository.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        alternativePhone: alternativePhone,
        email: email,
      );

      // إطلاق حالة النجاح لإظهار الـ SnackBar وقفل وضع التعديل في الواجهة
      emit(DriverProfileSuccess(updatedDriver, 'تم تحديث ملفك الشخصي بنجاح'));

      // إعادة الواجهة لحالة العرض بالبيانات الجديدة المحدثة
      emit(DriverProfileLoaded(updatedDriver));
    } catch (e) {
      emit(DriverProfileError(e.toString().replaceAll('Exception:', '')));
    }
  }
}
