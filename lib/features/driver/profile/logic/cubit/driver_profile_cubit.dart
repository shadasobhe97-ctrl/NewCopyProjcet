import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/driver_profile_repository.dart';
import 'driver_profile_state.dart';

class DriverProfileCubit extends Cubit<DriverProfileState> {
  final DriverProfileRepository repository;

  DriverProfileCubit(this.repository) : super(DriverProfileInitial());

  // 1. دالة جلب بيانات البروفايل عند فتح الشاشة
  Future<void> fetchProfile() async {
    if (!isClosed) emit(DriverProfileLoading());
    try {
      final driver = await repository.getDriverProfile();
      if (!isClosed) emit(DriverProfileLoaded(driver));
    } catch (e) {
      if (!isClosed)
        emit(DriverProfileError(e.toString().replaceAll('Exception:', '')));
    }
  }

  // 2. دالة تحديث البيانات الشخصية والمظهر (POST)
  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
    String? alternativePhone,
    String? email,
    File? avatarFile,
  }) async {
    if (state is DriverProfileLoaded) {
      if (!isClosed)
        emit(DriverProfileUpdateLoading((state as DriverProfileLoaded).driver));
    }

    try {
      final updatedDriver = await repository.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        alternativePhone: alternativePhone,
        email: email,
        avatarFile: avatarFile,
      );

      if (!isClosed)
        emit(DriverProfileSuccess(updatedDriver, 'تم تحديث ملفك الشخصي بنجاح'));

      // 💡 نجيبوا أحدث بيانات من السيرفر باش نضمنوا تحديث الكاش والواجهة بشكل كامل
      await fetchProfile();
    } catch (e) {
      if (!isClosed)
        emit(DriverProfileError(e.toString().replaceAll('Exception:', '')));
    }
  }

  String getCachedFullName() => repository.getCachedFullName();
  String getCachedPhoneNumber() => repository.getCachedPhoneNumber();
}
